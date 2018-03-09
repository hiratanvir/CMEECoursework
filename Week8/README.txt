Week 8 - Chapter 11 
The Computing Miniproject
Author: Hira Tanvir
Data: 9th March, 2018

Languages and packages used:

1) Bash 

2) Python version 2.7.12

Packages used:
- Pandas
- Numpy
- Scipy (from Scipy, constants and stats imported)
- matplotlib
- lmfit (from lmfit, minimize, Parameters, Parameter, report_fit imported)

3) R version 3.2.3

Packages used:
- ggplot2
- dplyr
- reshape2
- scales
- gridExtra 

Directory Contents:

Code:
1.  code.py #This script wrangles the raw data and produces a cleaned up version of the data that only contains data used for the NLLS analysis. Starting parameters for the schoolfield model are also estimated using this code.

2.  nlls_fit_all.py #The NLLS fitting for the models and the minimised parameters as well as statistics is produced by this code.

3.  nlls_plots.r #The minimised parameters for each model are plotted against the actual data using this script. The AIC, delta and weights were also calculated for each data set for each model and plots were produced to compare the overall 'goodness of fit' for each model across the trait data using ggplot2. 

4.  Miniproject.tex #This LaTeX code is used to write up the pdf which presents and discusses the findings from the analyses performed in python and R.

5.  run_Miniproject.sh #This bash script compiles the execution of all the codes in one script.



Data: 
1. GrowthRespPhotoData_new.csv


Results:
1. FINAL_dF.csv #This is the wrangled data produced from code.py

2. cubic_report.csv #This is the minimised parameters for Cubic model produced from nlls_fit_all.py

3. schoolfield_report.csv #This is the minimised parameters for the Schoolfield model produced from nlls_fit_all.py

4. AIC_results.csv #AIC, delta and weights results produced from nlls_plots.r

5. nlls_plot.pdf #produced from nlls_plots.r

6. 1554.pdf #produced from nlls_plots.r

7. general_plot.pdf #produced from nlls_plots.r

8. trait_plot.pdf #produced from nlls_plots.r

9. weights_plot.pdf #produced from nlls_plots.r

10. Miniproject.pdf #produced from LaTeX script run using the run_Miniproject.sh script

Sanbox: 

