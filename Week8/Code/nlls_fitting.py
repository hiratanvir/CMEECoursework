#!usr/bin/python
"""Chapter 11 The computing Miniproject"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '2.7.14'

### A python script that opens the new modified dataset and does the NLLS fitting ###
### Uses the following features:
### Uses lmfit - look up submodules minimize, Parameters, Parameter, and report_fit

import pandas as pd #reads in data as dataframes
from lmfit import minimize, Parameters, Parameter, report_fit
import numpy as np
import matplotlib.pyplot as plt
from scipy import constants

#Write an objective function that takes the values of the fitting variables and calculates either
#a scalar value to be minimized or an array of values that are to be minimized
#The objective function should return an array of (data-model) perhaps scaled by some weighting factor
#such as the inverse of the uncertainty in the data.

#read in data as pandas
dF = pd.read_csv('../Results/final_dF.csv', low_memory=False)

#Do NLLS fit for one group only
DF_1 = dF.loc[dF['uniqueID']==1]

#### FITTING THE CUBIC MODEL ###

# define objective function: returns the array to be minimized
def residual(params, x, y):
    """ modelling the cubic equation """
    a = params['a'].value
    b = params['b'].value
    c = params['c'].value
    d = params['d'].value
    model = a + b*x + c*x**2 + d*x**3
    return y - model

# create data to be fitted
x_vals = DF_1['Temp(kel)']    #x is you temp data
y_vals = DF_1['log_TraitValues'] #is the y value, log transformed trait data

# create a set of Parameters
params = Parameters()
params.add('a', value= 1.)
params.add('b', value= 1.)
params.add('c', value= 1.)
params.add('d', value= 1.)

# do fit, here with leastsq model
out1 = minimize(residual, params, args=(x_vals, y_vals))

# write error report
report_fit(out1)

#assign all variables to make a dataframe
A1 = out1.params['a'].value
B1 = out1.params['b'].value
C1 = out1.params['c'].value
D1 = out1.params['d'].value

#get a large number of equidistant points between the actual x points
x_points_a = np.linspace(min(x_vals), max(x_vals), num=100)

#plotting x_points according to the cubic model using the out paramter values
model2_a = A1 + B1*x_points_a + C1*x_points_a**2 + D1*x_points_a**3


## SAVING OUTPUT STATS AND MINIMIZED PARAMETER VALUES FOR THE CUBIC MODEL INTO A DATAFRAME ##
cubic_dF = pd.DataFrame()
data = pd.DataFrame({"ID": DF_1['uniqueID'].iloc[0], "A": A1, "B": B1, "C": C1, "D": D1, "AIC": out1.aic , "BIC": out1.bic, "chi-squared": out1.chisqr}, index=[0])
cubic_dF = cubic_dF.append(data)

cubic_dF.to_csv('../Results/cubic_report.csv', columns=['ID', 'A', 'C', 'D','AIC','BIC','chi-squared'], sep=',', encoding='utf-8')



### NLLS FITTING OF THE SCHOOLFIELD MODEL ###

#Defining constants
k = constants.value("Boltzmann constant in eV/K")
e = np.exp(1)

# define objective function: returns the array to be minimized
def residual(params, x, y):
    """ modelling the Schoolfield equation """
    B0 = params['B0'].value
    E = params['E'].value
    Eh = params['Eh'].value
    El = params['El'].value
    Th = params['Th'].value
    Tl = params['Tl'].value
    model = np.log((B0*e**((-E/k)*((1/x)-(1/283.15)))) / (1 + (e**((El/k)*((1/Tl)-(1/x)))) + (e**((Eh/k)*((1/Th)-(1/x))))))
    return y - model

# create a set of Parameters
#E and Eh's have to be absolute values (use the abs function)
params = Parameters()
params.add('B0', value= 1.5866052E-06, min=0)
params.add('E', value= 0.824643023, min=0)
params.add('Eh', value= 2.8427281037, min=0)
params.add('El', value= 0.4123215115, min=0)
params.add('Th', value= 37.7812863764+273.15)
params.add('Tl', value= 36.4750027048+273.15)

# do fit, here with leastsq model (use the try function here)
out = minimize(residual, params, args=(x_vals, y_vals))

# write error report
report_fit(out)

#assign all variables to make a dataframe
A = out.params['B0'].value
B = out.params['E'].value
C = out.params['Eh'].value
D = out.params['El'].value
E = out.params['Th'].value
F = out.params['Tl'].value

#get a large number of equidistant points between the actual x points
x_points = np.linspace(min(x_vals), max(x_vals), num=100)

#plotting x_points according to the cubic model using the out paramter values
model2 = np.log((A*e**((-B/k)*((1/x_points)-(1/283.15)))) / (1 + (e**((D/k)*((1/F)-(1/x_points)))) + (e**((C/k)*((1/E)-(1/x_points))))))


#try to plot the results for both models

#plt.plot(x_vals, y_vals, 'k+')
#plt.plot(x_points_a, model2_a, 'b') #cubic fit
#plt.plot(x_points, model2, 'r') #schoolfield fit
#plt.xlabel('Temp (Celcius)')
#plt.ylabel('Log Trait Value')
#plt.show()

## SAVING OUTPUT STATS AND MINIMIZED PARAMETER VALUES FOR THE CUBIC MODEL INTO A DATAFRAME ##
schoolfield_dF = pd.DataFrame()
schoolfield_data = pd.DataFrame({"ID": DF_1['uniqueID'].iloc[0], "B0":A, "E":B, "Eh":C, "El":D, "Th":E, "Tl":F, "AIC":out.aic, "BIC":out.bic, "chi-squared":out.chisqr}, index=[0])
schoolfield_dF = schoolfield_dF.append(schoolfield_data)

schoolfield_dF.to_csv('../Results/schoolfield_report.csv', columns=['ID','B0','E','Eh','El','Th','Tl','AIC','BIC','chi-squared'], sep=',', encoding='utf-8')
