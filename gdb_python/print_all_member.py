#!/usr/bin/python3

import gdb
from collections import defaultdict

alltype = defaultdict()


def print_members(t1, indent=0):
    strt1 = str(t1)
    if strt1 in alltype:
        return
    alltype[strt1] = 1
    dir1 = dir(t1)
    for attr_str1 in dir1:
        if attr_str1.startswith('_'):
            continue
        attr1 = getattr(t1, attr_str1)
        print("{} {} {}".format(' '*indent, attr_str1, type(attr1)))
        print_members(attr1, indent+1)


print('what is gdb', str(gdb))
print_members(gdb)
