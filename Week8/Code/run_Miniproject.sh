#!usr/bin/bash
#"""Chapter 11 The computing Miniproject"""

#__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
#__version__ = '4.3.48(1)'

#Using a bash script to execute the python, R and LaTeX code

########################################################
####### RUNNING PYTHON CODE ############################
echo "Running data wrangling python code..."
python code.py

echo "Running NLLS fitting python code..."
python nlls_fit_all.py

#########################################################
###### RUNNING R CODE ###################################
echo "Running R code..."
Rscript nlls_plots.r
rm Rplots.pdf

#########################################################
###### RUNNING LaTeX CODE ###############################
echo "Compiling LaTeX code to pdf..."
pdflatex Miniproject.tex
bibtex Miniproject
pdflatex Miniproject.tex
pdflatex Miniproject.tex

#moving pdf file to results directory
mv Miniproject.pdf ../Results/

#cleaning up output LaTeX files
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

########################################################
########################################################
echo "~~~Finito!~~~~"
