#!/bin/bash

# bytes/usecond to Mbits/second

bytes=$1
usecond=$2

echo $(( $bytes*8*1000*1000/1024/1024/$usecond))
