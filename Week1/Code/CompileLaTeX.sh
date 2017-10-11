#!/bin/bash
pdflatex $1* #Using the wildcard * we can define the type of file when we run it in bash
pdflatex $1*
bibtex $1
pdflatex $1*
pdflatex $1*
evince $1*.pdf &

## Cleanup
rm *
rm *.aux
rm *.dvi
rm *.log
rm *.nav
rm *.out
rm *.snm
rm *.toc
rm *.bbl
rm *.blg