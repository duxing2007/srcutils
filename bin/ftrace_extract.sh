#!/bin/bash
#
#
#extract function name from ftrace function_graph
#usage:
#ftrace_extract.sh ftrace_output.txt

grep  -o -e '[a-zA-Z_].*()' $1    | sort  | uniq | cut -d'(' -f 1
