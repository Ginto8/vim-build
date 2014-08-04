#!/bin/bash

oldwd=$(pwd)
export dir=$(dirname "$(readlink -m $1)")
export projdir=$dir/
export folder=$(basename "$dir")
export file=$(basename "$1")
export name=${file%.*}
export extension=${file##*.}
term=${TERM%-*}
if [[ $projdir =~ /src/ ]]; then
    projdir=${projdir%/src/*}/
elif [[ $projdir =~ /include/ ]]; then
    projdir=${projdir%/include/*}/
elif [[ $extension == cabal ]] || [[ $extension == hs ]]; then
    possDir=$dir
    while [[ -z $(ls -a $possDir | grep '\.cabal$') ]] &&
          (echo $possDir | grep '/[A-Z][^\/]*$' >/dev/null); do
        possDir=$(dirname $possDir)
    done
    (ls -a $possDir | grep '\.cabal$' >/dev/null) && projdir=$possDir
fi
export runCommand="@"
if [[ $term == screen ]]; then
    if [[ -n $TMUX ]]; then
        runCommand="tmux new-window 'bash -c \"@;read\"'"
    fi
fi
#echo "Run command: $runCommand (eg. ${runCommand/@/./test.sh})"
echo "project: $projdir"

#echo "$2"

cd $projdir

bash -c "$2"

cd $oldwd
