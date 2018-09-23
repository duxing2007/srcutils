#!/usr/bin/python

import sys
import subprocess
import functools
import re
import bisect
import pickle


class FuncInfo:
    def __init__(self, fbegin=0, fsize=0, fname='', fpath=''):
        self.fbegin = fbegin
        self.fend = fbegin + fsize
        self.fname = fname
        self.fpath = fpath

    def __lt__(self, other):
        return self.fbegin < other.fbegin

    def __eq__(self, other):
        return self.fbegin == other.fbegin

    def __str__(self):
        return 'fbegin={:x},fend={:x},fname={},fpath={}'.format(
            self.fbegin, self.fend, self.fname, self.fpath)

    def __repr__(self):
        return str(self)


# nm output:
# 0                17              33 36    /
# 0000000000402310 000000000000004a T main  /root/projecttest/cpp/test_a.cpp:50
def nm2func(image, path):
    result = subprocess.Popen(
        'nm -C -l -S -n {}'.format(image),
        stdout=subprocess.PIPE,
        shell=True).stdout
    ln = 0
    p = re.compile('[0-9a-f]{16} [0-9a-f]{16} T.*' + path)
    allfunc = []
    for line in result:
        ln += 1
        if p.match(line):
            fbegin = int(line[0:16], 16)
            fsize = int(line[17:33], 16)
            fpath_index = line.find(path, 36)
            if fpath_index == -1:
                print 'stupid line:', line
                continue
            fname = line[36:fpath_index].strip()
            fpath = line[fpath_index:].strip()
            allfunc.append(FuncInfo(fbegin, fsize, fname, fpath))
    return allfunc


def find_func(allfunc, addr):
    idx = bisect.bisect_left(allfunc, FuncInfo(addr))
    found = False
    if idx < len(allfunc) \
        and addr >= allfunc[idx].fbegin \
            and addr < allfunc[idx].fend:
        found = True
    return found, idx


def cache(func):
    caches = {}

    @functools.wraps(func)
    def wrap(*args):
        if args not in caches:
            caches[args] = func(*args)

        return caches[args]
    return wrap


@cache
def addr2line(image, addr):
    result = subprocess.Popen(
        'addr2line -C -e {} -f {}'.format(image, addr),
        stdout=subprocess.PIPE,
        shell=True).communicate()[0]
    result = result.split('\n')
    return result[0], result[1]


def step_enter(allfunc, addr, path, level):
    found, idx = find_func(allfunc, addr)
    if found and allfunc[idx].fpath.find(path) != -1:
        print level * '\t' + allfunc[idx].fname
        print allfunc[idx].fpath
        print level * '\t' + '{'
        level += 1
    return level


def step_exit(allfunc, addr, path, level):
    found, idx = find_func(allfunc, addr)
    if found and allfunc[idx].fpath.find(path) != -1:
        level -= 1
        if level < 0:
            level = 0
        print level * '\t' + '}'
    return level


def usage():
    cmds = ['nm2func', 'callgraph']
    if len(sys.argv) < 2 or sys.argv[1] not in cmds:
        print 'Usage:'
        print 'addr2func.py nm2func [a.out] [path] [p.pickle]'
        print 'addr2func.py callgraph [p.pickle] [path] [trace.txt]'
        exit(-1)


def handle_nm2func(image, path, pfilename):
    allfunc = nm2func(image, path)
    with open(pfilename, 'wb') as pfile:
        pickle.dump(allfunc, pfile)


def handle_callgraph(pfilename, path, trace):
    with open(pfilename, 'rb') as pfile:
        allfunc = pickle.load(pfile)
    level = 0
    for line in open(trace):
        line = line.strip()
        if line[0] == 'E':
            level = step_enter(allfunc, int(line[1:], 16), path, level)
        elif line[0] == 'X':
            level = step_exit(allfunc, int(line[1:], 16), path, level)
#       elif line[0] == 'F':
# funcname, filename = addr2line(image, line[1:])
# print filename
        else:
            print 'wrong format:', line
            continue


def main():
    usage()

    if sys.argv[1] == 'nm2func':
        handle_nm2func(*sys.argv[2:])
    elif sys.argv[1] == 'callgraph':
        handle_callgraph(*sys.argv[2:])


if __name__ == '__main__':
    main()
