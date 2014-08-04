#!/bin/bash

rm -r build
mkdir build
(
if (which latexmk >/dev/null); then
    latexmk -pdf -outdir=build/ $1.tex
else
    pdflatex -halt-on-error -output-directory build/ $1.tex
    if [[ "$?" == "0" ]] && [[ "$2" == "bib" ]]; then
        biber build/$1
        pdflatex -halt-on-error -output-directory build/ $1.tex &&
        pdflatex -halt-on-error -output-directory build/ $1.tex
    fi
fi
) 2>&1 | egrep -i '(^ERROR|^WARNING|^!|^l\.)'
cp build/*.pdf .

