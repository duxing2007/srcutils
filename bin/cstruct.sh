#!/bin/bash

tmptags=/tmp/$RANDOM
ctags -n --c-kinds=m -f $tmptags "$@"
awk.cstruct.awk $tmptags
rm $tmptags
