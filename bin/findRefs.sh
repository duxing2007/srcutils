#!/bin/bash

for tags in "$@"
do
    echo $tags
    #global -r tags
done | sort | uniq | wc
