#!/bin/bash

normalize() {
	while read v
	do
		echo $(($v/1000*1000))
	done
}

decorate() {
	while read v1 v2
	do
		echo $v2-$(($v2+1000)) $v1
	done
}

ack-grep -f --cc | xargs -L 1 wc -l | \
	cut -d' ' -f1 | normalize | sort -n | uniq -c | decorate | sed '1s/^/lines counts\n/' > /tmp/codelines.dat

gnuplot ~/srcutils/bin/codelines.dem
