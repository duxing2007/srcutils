#!/bin/bash

# Find files which reference most tags and have least lines
# Usage:
# fFilesRefsMost.sh tag1 tag2 tagX...

for tags in "$@"
do
    global -r $tags
done | xargs wc -l | sort | uniq -c | sort -k 1,1n -k 2,2rn
