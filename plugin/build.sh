#!/bin/bash
# Expects to be run through projectexec.sh

function getMakeVar() {
    sed -n "/^$1\\s*=\\s*/{s/^$1\\s*=\\s*\\(.*\\)$/\\1/;p}" $2
}

command=""
if [[ $1 == r ]]; then
    if [[ -e $projdir/CMakeLists.txt ]]; then
        cd "$projdir/build"
        binName="$(grep 'set(EXECUTABLE_NAME' ../CMakeLists.txt |
                   sed 's/set(EXECUTABLE_NAME \"\(.*\)\")/\1/')"
        command="./$binName"
    elif [[ -e $projdir/$name.pro ]]; then
        outDir=$(getMakeVar DESTDIR $projdir/$name.pro)
        target=$(getMakeVar TARGET $projdir/$name.pro)
        if [[ -n $outDir ]] && [[ -n $target ]]; then
            cd "$projdir/$outDir"
            command="$target"
        fi
    elif [[ -e $projdir/Makefile ]]; then
        target=$(getMakeVar TARGET $projdir/Makefile)
        command="$target"
    elif [[ -e $projdir/build.xml ]]; then
        command="ant run"
    elif [[ -e $projdir/.build/ ]]; then
        command="ino upload"
    elif (ls -a $projdir | grep "$name\.cabal\$" >/dev/null); then
        cabalFile=$projdir/$(ls -a $projdir | grep '\.cabal$' | head -1)
        echo "Cabal file: " $cabalFile
        execName=$(awk 'BEGIN { count = 0 }; \
                        /^executable/ { if(count++ == 0) { print $2 } }' \
                       $cabalFile)
        echo "Exec name: " $execName
        cd $projdir
        pwd
        command=./dist/build/$execName/$execName
    else
        case $extension in
        c | h | hpp | cpp | c1)
            [[ -e ./$name ]] && command="./$name"
            ;;
        tex )
            [[ -e $name.pdf ]] && command="evince $name.pdf"
            ;;
        py )
            command="python $file"
            ;;
        sh )
            command="./$file"
            ;;
        hs )
            command="./$name"
            ;;
        md )
            command="chromium `pwd`/${name}.html"
            ;;
        esac
    fi
    if [[ -z $command ]]; then
        echo ERROR: executable for $file not found
    else
        toRun=${runCommand/@/$command}
        echo "running: " $toRun
        bash -c "$toRun"
    fi
else
    if which clang &>/dev/null; then
        export CC=clang
    else
        export CC=gcc
    fi
    if which clang++ &>/dev/null; then
        export CXX=clang++
    else
        export CXX=g++
    fi
    if [[ -e $projdir/CMakeLists.txt ]]; then
        cd "$projdir"
        if [[ ! -e build ]]; then
            mkdir build
        fi
        cd build
        if [[ ! -e Makefile ]]; then
            cmake ..
        fi
        make
    elif [[ -e $projdir/$name.pro ]]; then
        cd "$projdir"
        qmake $name.pro
        make
    elif [[ -e $projdir/Makefile ]]; then
        cd "$projdir"
        make
    elif [[ -e $projdir/build.xml ]]; then
        cd "$projdir"
        if [[ -n $TMUX ]]; then
            tmux new-window 'bash -c "ant deploy || read"'
        else
            ant deploy
        fi
    elif [[ -e $projdir/.build/ ]]; then
        ino build
    elif (ls -a $projdir | grep "$name\.cabal\$" >/dev/null); then
        cabal build
    else
        cd $dir
        case $extension in
        c )
            $CC -Wall -o "$name" "$file"
            ;;
        cpp )
            $CXX -Wall -o "$name" "$file"
            ;;
        c0 )
            cc0 -d -o "$name" "$file"
            ;;
        hpp )
            [[ -e $name.cpp ]] && $CXX -o "$name" "$name.cpp"
            ;;
        h )
            if [[ -e $name.c ]]; then
                $CC -Wall -o "$name" "$name.c"
            elif [[ -e $name.cpp ]]; then
                $CXX -Wall -o "$name" "$name.cpp"
            fi
            ;;
        tex )
            if which rubber >/dev/null; then
                rubber -d "$name"
            else
                $(dirname $0)/build-latex.sh "$name"
            fi
            ;;
        hs )
            ghc "$file" -o "$name"
            ;;
        md )
            markdown "$file" >"$name.html"
            ;;
        esac
    fi
fi

