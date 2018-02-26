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

#read in data as pandas
dF = pd.read_csv('../Results/final_dF.csv', low_memory=False)

#Do NLLS fit for one group only
DF_1 = dF.loc[dF['uniqueID']==808]

# create data to be fitted
x_vals = DF_1['Temp(kel)']    #x is you temp data
y_vals = DF_1['log_TraitValues'] #is the y value, log transformed trait data

#Defining constants
k = constants.value("Boltzmann constant in eV/K")
e = np.exp(1)

#### FITTING THE SCHOOLFIELD MODEL ###

# define objective function: returns the array to be minimized
def residual(params, x, y):
    """ modelling the cubic equation """
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

# try to plot results

plt.plot(x_vals, y_vals, 'k+')
plt.plot(x_points, model2, 'r')
plt.xlabel('Temp (Celcius)')
plt.ylabel('Log Trait Value')
plt.show()
