#!/usr/bin/env python
#

import sys, os
import time
import re

def errlog(s1):
  print 'err %s' % (s1)

def dbglog(s1):
  pass
  #print 'dbg %s' % (s1)

def trim_ignore_line(ignore_lines, srcfile):
  idx=len(ignore_lines) -1
  while idx>0:
    reverse1=ignore_lines[idx]
    reverse2=ignore_lines[idx-1]
    if reverse1["sline"] <= reverse2["sline"] and reverse1["eline"] >= reverse2["eline"]:
      dbglog( 'ignore_lines before: %s %s' % (srcfile, ignore_lines))
      del ignore_lines[-2]
      dbglog( 'ignore_lines after: %s %s' % (srcfile, ignore_lines))
      idx=len(ignore_lines)-1
    else:
      break

    



def parse_cfgfile(cfgfile):
  all_not_set = set()
  try:
    lines = open(cfgfile,"r").readlines()
  except:
    errlog( "Problem opening file: %s" % cfgfile)
    sys.exit(1)

  not_set_pat = re.compile("^# (CONFIG_[a-zA-Z0-9_]+) is not set$")
  for line in lines:
    m1 = re.match(not_set_pat, line)
    if m1:
      all_not_set.add(m1.group(1))
  return all_not_set


def regen_srcfile(srcfile, all_not_set):
  try:
    lines = open(srcfile,"r").readlines()
  except:
    errlog( "Problem opening file: %s" % srcfile)
    sys.exit(2)

  if_pat = re.compile("^[ \t]*#[ \t]*if[ \t]+|^[ \t]*#[ \t]*ifdef[ \t]+|^[ \t]*#[ \t]*ifndef[ \t]+")
  else_pat = re.compile("^[ \t]*#[ \t]*else|^[ \t]*#[ \t]*elif[ \t]+")
  end_pat = re.compile("^[ \t]*#[ \t]*endif")
  ifdef_pat = re.compile("^[ \t]*#[ \t]*ifdef[ \t]+(CONFIG_[a-zA-Z0-9_]+)")

  ignore_lines=[]

  lineno = 0
  if_stack=[]
  for line in lines:
    lineno += 1
    if if_pat.search(line):
      
      dbglog( 'if_pat match. lineno %d line %s %s' %(lineno, line, if_stack) )

      ifdef_m1=ifdef_pat.search(line)
      need_ignore = False
      if ifdef_m1 and ifdef_m1.group(1) in all_not_set:
        need_ignore = True
      if_stack.append(dict(lno=lineno, lcontent=line, lignore=need_ignore))
    elif else_pat.search(line):

      dbglog( 'else_pat match. lineno %d line %s %s' %(lineno, line, if_stack) )

      if len(if_stack) == 0:
        errlog( "else but empty if,lineno %d, srcfile %s" % (lineno, srcfile))
        sys.exit(3)
      last_if = if_stack[-1]
      if last_if["lignore"]:
        ignore_lines.append(dict(sline=last_if["lno"], eline=lineno))
        trim_ignore_line(ignore_lines, srcfile)
        last_if["lignore"] = False
    elif end_pat.search(line):

      dbglog( 'end_pat match. lineno %d line %s %s' %(lineno, line, if_stack) )

      if len(if_stack) == 0:
        errlog( "end but empty if,lineno %d, srcfile %s" % (lineno, srcfile))
        sys.exit(5)
      last_if = if_stack.pop()
      if last_if["lignore"]:
        ignore_lines.append(dict(sline=last_if["lno"], eline=lineno))
        trim_ignore_line(ignore_lines, srcfile)

  if len(if_stack) > 0:
    errlog( "if but no end srcfile,lineno %d, srcfile %s" % (lineno, srcfile))
    sys.exit(7)




  curignore=0
  lineno = 0
  modify_lines=[]
  for line in lines:
    lineno+=1
    if curignore < len(ignore_lines) and lineno > ignore_lines[curignore]['eline']:
      curignore += 1
    if curignore < len(ignore_lines) and lineno==ignore_lines[curignore]['sline'] and line[-1] == '\n':
      line = line[:-1] + ' // is not set' + line[-1]
    if curignore < len(ignore_lines) and lineno>ignore_lines[curignore]['sline'] and lineno <ignore_lines[curignore]['eline']:
      continue
    modify_lines.append(line)

  dstfile=open(srcfile,"w")
  # dstfile=open(srcfile[0:-2]+".regen"+srcfile[-2:],"w")
  dstfile.writelines(modify_lines)
  dstfile.close()




def main():
  cfgfile = ""
  srcfile = ""

  args = sys.argv[1:]
  if len(args) == 2:
    cfgfile = args[0]
    srcfile = args[1]
  else:
    errlog( 'usage: %s cfgfile srcfile %d %s' %  (sys.argv[0], len(args), sys.argv))
    sys.exit(222)

  all_not_set=parse_cfgfile(cfgfile)
  regen_srcfile(srcfile, all_not_set)

  return

if __name__ == "__main__":
  try:
    main()
  except IOError:
    # skip broken pipe errors (from e.g. "kd foo | head")
    (exc_type, exc_value, exc_trace) = sys.exc_info()
    if str(exc_value)!="[Errno 32] Broken pipe":
      raise
