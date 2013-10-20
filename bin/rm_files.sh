#!/bin/bash
#
# remove file in $1 but not in $2
#

for f in `cat $2`
do
	if grep -q $f $1
	then
		echo $f
	else
		rm $f
	fi
done
