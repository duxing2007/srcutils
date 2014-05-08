#!/bin/bash

# Draw bar chart of linux kernel changes
# Usage:
# kgitstat.sh dir...
# Output:
# kgitstat.png

for ((i=0; i<12; i++))
do
	echo "v3.$i...v3.$(($i+1)) "
	git diff --shortstat v3.$i v3.$(($i+1)) "$@"
done |\
sed 'N;s/\n/ /' |\
awk 'BEGIN {print "versions files insertions deletions" } {print $1," ",$2," ",$5," ",$7 }' > /tmp/kgitstat.dat

gnuplot ~/srcutils/bin/kgitstat.dem
