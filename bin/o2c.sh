#!/bin/bash
#
# .o to .c for all file name in filelist
#

for f in `cat $1`
do
	echo ${f/%.o/.c}
done
