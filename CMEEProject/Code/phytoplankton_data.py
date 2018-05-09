#!usr/bin/python
"""CMEE MSc Project"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '2.7.14'

### A python script that opens the new modified dataset and does the NLLS fitting ###
### Uses the following features:
### Uses lmfit - look up submodules minimize, Parameters, Parameter, and report_fit

import pandas as pd #reads in data as dataframes
import numpy as np
import scipy as sc
from scipy import constants
import matplotlib.pyplot as plt
from scipy import stats
from lmfit import minimize, Parameters, Parameter, report_fit

#Reading in the csv file as a pandas dataframe
subset_dF = pd.read_csv('../Data/standardised_data.csv', low_memory=False)

#Filter Plantae and Protozoa from ConKingdom only using bitwise operator (|)
#subset_dF = subset_dF.loc[(subset_dF['ConKingdom'] == 'Plantae') | (subset_dF['ConKingdom'] == 'Protozoa')]

#checking for list of unique names in ConPhylum
subset_dF.ConPhylum.unique()

#Drop NaNs from trait column
subset_dF = subset_dF[pd.notnull(subset_dF['StandardisedTraitValue'])]

#removing rows with 0 trait values
subset_dF = subset_dF.loc[subset_dF["StandardisedTraitValue"] > 0]

#removing any values that are non-numeric in columns
subset_dF = subset_dF[pd.to_numeric(subset_dF['ConTemp'], errors='coerce').notnull()]

#filter rows by group and keep groups where it has more than 1 unique ConTemp value
#subset_dF = subset_dF.groupby('FinalID').filter(lambda x: x.ConTemp.value_counts().max() < 2)
subset_dF = subset_dF.groupby('FinalID').filter(lambda x: x.ConTemp.nunique() > 1)

#Using groupby to group the IDs and then using filter to only show IDs with datasets with more than 4 datapoints
subset_dF = subset_dF.groupby(['FinalID']).filter(lambda x: len(x)>5)

#Creating unique IDs to make the dataset IDs consistent i.e. there are no gaps in the numbering of IDs
subset_dF['uniqueID'] = subset_dF['FinalID'].rank(method='dense').astype(int)

#Adding columns containing starting values of the model parameters for the NLLS fitting
k = constants.value("Boltzmann constant in eV/K")
e = np.exp(1)

#Converting temperature from celcius to kelvin and adding a column for it
subset_dF['Temp(kel)'] = subset_dF.apply(lambda row: float(row.ConTemp) + 273.15, axis = 1)

#Adding a column for 1/kT (k constant x Temperature in Kelvin)
subset_dF['1/kT'] = 1/(subset_dF['Temp(kel)']*float(k))

#Adding columns for the log of Original Trait Values
subset_dF['log_TraitValues'] = np.log(subset_dF.StandardisedTraitValue)

#sort data by temperature and id
subset_dF = subset_dF.sort_values(['uniqueID','Temp(kel)'])

#Creating an empty dataframe with parameter columns
newDF = pd.DataFrame(columns=['B0','E','Eh','El','Th','Tl','ID'])

#subset_dF.to_csv('subset_dF.csv', sep=',', encoding='utf-8')

grouped = subset_dF.groupby('uniqueID')
for i,g in grouped:
    print i

    #define x and y axis for e parameter estimate plot
    x = g['1/kT']
    y = g['log_TraitValues']

    #plot data
    plt.plot(x,y) #[<matplotlib.lines.Line2D at 0x7fc56a1a2590>]

    #Getting corresponding x values given y
    line2d = plt.plot(x,y)
    xvalues = line2d[0].get_xdata()
    yvalues = line2d[0].get_ydata()

    #Get the index of the max y value
    # idy = np.where(yvalues==yvalues.max(axis=0)) #this is -13.138699...
    idy = np.argmax(yvalues)
    max_y = g['log_TraitValues'].max(axis=0) #Maximum y value but does not index it

    #Getting both x and y vals in an array object together
    xy = line2d[0].get_xydata()
    maxy_x = xy[idy] #gives the max y-values with corresponding x-values array([-13.1386998 ,  38.92175788])
    e_estimators = xy[:(idy+1)] #returns a list of x and y values from the maximum y-value to the maximum x value

    #Split the list of lists (e_estimators) into two lists to give another set of x and y co-ordinates
    x1, y1 = map(list, zip(*e_estimators))

    #Use scipy stats to fit a regression line, and return the slope, intercept and r values
    E_estimate = stats.linregress(x1, y1)

    #Function to find the temperature closest to 283.15 K ~ giving the trait value for B0
    def find_nearest(Temp, value):
        idx = (np.abs(Temp-value)).idxmin()
        return Temp[idx].astype(float)

    Temp = g['Temp(kel)']
    value = 283.15
    #print(find_nearest(Temp,value))

    #Finding the slope for the opposite side for the curve - corresponding to Eh value
    # Eh > E as Eh is a positive slope on a log curve, and E is a negative slope
    Eh_estimators = xy[idy:]
    x2, y2 = map(list, zip(*Eh_estimators))
    Eh_estimate = stats.linregress(x2,y2)


    #Finding T-peak or Th ==>
    #Get the corresponding x value where y is maximised - Also T-peak, as it gives the temperature at which the curve peaks
    #Tl is the temperature at which the enzyme is 50% low-temperature deactivated - Setting it as the lowest temperature

    #EXTRACTING STARTING PARAMETER VALUES and appending them to temporary dataframe

    temp = pd.DataFrame({'B0':(g.loc[g['Temp(kel)']==(find_nearest(Temp,value)), 'StandardisedTraitValue'].iloc[0]),
                        'E': E_estimate[0],
                        'Eh': Eh_estimate[0],
                        'El': E_estimate[0]/2,
                        'Th': (xvalues[idy]).astype(float),
                        'Tl': g['1/kT'].min(axis=0),
                        'ID': i},
                        index=[0])
                        #g.set_index(['uniqueID'], inplace=True))

    newDF = pd.concat([newDF, temp.reset_index()])
    #newDF.to_csv('parameters.csv', sep=',', encoding='utf-8')

final_dF = pd.merge(subset_dF, newDF, left_on='uniqueID', right_on='ID', how='right').drop('ID', axis=1)

#Deal with E column where there is no E-value and give it a generic valur of 0.66
final_dF.E = final_dF.E.fillna(value=0.66)
final_dF.Eh = final_dF.Eh.fillna(value=2*0.66)
final_dF.El = final_dF.El.fillna(value=0.66/2)

final_dF.to_csv('../Data/phytoplankton_subset.csv', sep=',', encoding='utf-8')

### NLLS FITTING ###

#Write an objective function that takes the values of the fitting variables and calculates either
#a scalar value to be minimized or an array of values that are to be minimized
#The objective function should return an array of (data-model) perhaps scaled by some weighting factor
#such as the inverse of the uncertainty in the data.

#read in data as pandas
dF = pd.read_csv('../Data/phytoplankton_subset.csv', low_memory=False)

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



schoolfield_dF.to_csv('../Data/phytoplankton_schoolfield_report.csv', columns=['ID','B0','E','Eh','El','Th','Tl','AIC','chi-squared','r-squared','status'], sep=',', encoding='utf-8')
