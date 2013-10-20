#!/bin/bash
# usage:
# this.sh 0x12345678 1:0 9:8

myarr=("$@")
arg0=${myarr[0]}
for((i=1; i<${#myarr[*]}; i++))
do
	arg=${myarr[i]}
	hidx=$((${arg%:*}+1))
	lidx=${arg#*:}
	val=$(( (1<<$hidx) - (1<<$lidx) ))
	val=$(($arg0 & $val))
	val=$(($val >> $lidx))
	printf "%s %x \n" $arg $val
done
