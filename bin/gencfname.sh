#!/bin/bash

# Generate C function names in provided files
# Usage:
# gencfname.sh files...
ctags -x --c-kinds=f "$@"  | awk '{print $1}' | sort | uniq
