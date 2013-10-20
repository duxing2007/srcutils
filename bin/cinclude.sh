#!/bin/bash
#
#Generate all headers included by c source file
#
#cinclude.sh cfiles...

if (($# <1 ))
then
	echo "cinclude.sh cfiles..."
fi

tmpinc=/tmp/$RANDOM
grep -e '#.*include.*".*"' -e '#.*include.*<.*>' "$@" >$tmpinc
grep -o -e '".*"' $tmpinc | sort | uniq
grep -o -e '<.*>' $tmpinc | sort | uniq
rm $tmpinc
