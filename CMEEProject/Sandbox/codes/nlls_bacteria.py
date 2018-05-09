#!usr/bin/python
"""CMEE MSc project"""

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
dF = pd.read_csv('../Results/bacteria_subset.csv', low_memory=False)

### NLLS FITTING OF THE SCHOOLFIELD MODEL ###

#Defining constants
k = constants.value("Boltzmann constant in eV/K")
e = np.exp(1)

# define objective function: returns the array to be minimized
def get_residual(params, x, y):
    """ modelling the Schoolfield equation """
    B0 = params['B0'].value
    E = params['E'].value
    Eh = params['Eh'].value
    El = params['El'].value
    Th = params['Th'].value
    Tl = params['Tl'].value
    model = np.log((B0*e**((-E/k)*((1/x)-(1/283.15)))) / (1 + (e**((El/k)*((1/Tl)-(1/x)))) + (e**((Eh/k)*((1/Th)-(1/x))))))
    return y - model

def get_ssr(params, x, y):
    """ modelling the Schoolfield equation """
    B0 = params['B0'].value
    E = params['E'].value
    Eh = params['Eh'].value
    El = params['El'].value
    Th = params['Th'].value
    Tl = params['Tl'].value
    model = np.log((B0*e**((-E/k)*((1/x)-(1/283.15)))) / (1 + (e**((El/k)*((1/Tl)-(1/x)))) + (e**((Eh/k)*((1/Th)-(1/x))))))
    return np.exp(y) - np.exp(model)

#create empty DataFrame outside loop to append nlls fit values to it
schoolfield_dF = pd.DataFrame()

grouped = dF.groupby('uniqueID')
for i,g in grouped:

    # create data to be fitted
    x_vals = g['Temp(kel)']    #x is you temp data
    y_vals = g['log_TraitValues'] #is the y value, log transformed trait data
    non_log_y = g['StandardisedTraitValue']

    # create a set of Parameters
    #E and Eh's have to be absolute values (use the abs function) --- make sure all the values for params are positive
    params = Parameters()
    params.add('B0', value= abs(g['B0'].iloc[0]) , min=0)
    params.add('E', value= abs(g['E'].iloc[0]), min=0)
    params.add('Eh', value= abs(g['Eh'].iloc[0]), min=0)
    params.add('El', value= abs(g['El'].iloc[0]), min=0)
    params.add('Th', value= abs(g['Th'].iloc[0]) + 273.15)
    params.add('Tl', value= abs(g['Tl'].iloc[0]) + 273.15)

    # try to do fit, here with leastsq model (use the try function here)
    if len(x_vals) > 5:
        try:
            out = minimize(get_residual, params, args=(x_vals, y_vals))

            #assign all variables to make a dataframe
            A = out.params['B0'].value
            B = out.params['E'].value
            C = out.params['Eh'].value
            D = out.params['El'].value
            E = out.params['Th'].value
            F = out.params['Tl'].value

            log_AIC = out.aic
            log_BIC = out.bic
            chi_squared = out.chisqr
            status = "C"

            ### calculating r-squared Value ###
            # r-squared = 1 - sum(yi - yihat)^2/sum(yi-yibar)^2   r2 = 1 - SSR/SST

            minimised_params = Parameters()
            minimised_params.add('B0', value= A)
            minimised_params.add('E', value= B)
            minimised_params.add('Eh', value= C)
            minimised_params.add('El', value= D)
            minimised_params.add('Th', value= E)
            minimised_params.add('Tl', value= F)


            #use the function that returns the SSR on the un-logged data and use that to calculate AIC r2
            #and un-log the AIC and BIC
            SSR = np.sum((get_ssr(minimised_params, x_vals, y_vals)**2))

            #get the un-logged trait values and get the mean from those to calculate the SST
            ybar = np.mean(non_log_y)
            SST = np.sum((non_log_y - ybar)**2)

            #AIC calculation using the non-logged SST using the formula AIC = 2k + n Log(RSS/n) where k is the number of parameters
            #and n is the number of observations - which is the length of x_vals
            AIC = (2*6 + len(x_vals)*np.log(SSR/len(x_vals)))
            r2 = 1 - (SSR/SST)

            print i,"Model converges!"

        except ValueError:

            A = np.NaN
            B = np.NaN
            C = np.NaN
            D = np.NaN
            E = np.NaN
            F = np.NaN

            AIC = np.NaN
            BIC = np.NaN
            chi_squared = np.NaN
            r2 = np.NaN
            status = "NC"

            print i,"Model doesn't converge..."


    elif len(x_vals) < 6:

        A = np.NaN
        B = np.NaN
        C = np.NaN
        D = np.NaN
        E = np.NaN
        F = np.NaN

        AIC = np.NaN
        BIC = np.NaN
        chi_squared = np.NaN
        r2 = np.NaN
        status = "lessX"

        print i,"Length of x is less than length of parameters!"

    ## SAVING OUTPUT STATS AND MINIMIZED PARAMETER VALUES FOR THE CUBIC MODEL INTO A DATAFRAME ##
    schoolfield_data = pd.DataFrame({"ID": i, "B0":A, "E":B, "Eh":C, "El":D, "Th":E, "Tl":F, "AIC":AIC, "chi-squared":chi_squared, "r-squared":r2, "status": status}, index=[0])
    schoolfield_dF = schoolfield_dF.append(schoolfield_data)



schoolfield_dF.to_csv('../Results/bacteria_schoolfield_report.csv', columns=['ID','B0','E','Eh','El','Th','Tl','AIC','chi-squared','r-squared','status'], sep=',', encoding='utf-8')
