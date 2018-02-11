#!usr/bin/python
"""Chapter 11 The computing Miniproject"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '2.7.14'

import pandas as pd #reads in data as dataframes
import numpy as np
import scipy as sc
from scipy import constants
#import scipy.integrate as integrate
#import sys
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
from scipy.stats import linregress # to get the slope for E
import seaborn as sns

#Reading in the csv file as a pandas dataframe
dF = pd.read_csv('../Data/GrowthRespPhotoData_new.csv', low_memory=False)

#Creating a subset of the dataframes with relevant columns and removing rows with 0 trait values
subset_dF = dF.loc[:, ['FinalID','StandardisedTraitName','StandardisedTraitValue','StandardisedTraitUnit','ConTemp','ConTempUnit']]
subset_dF = subset_dF.iloc[subset_dF.index[dF["StandardisedTraitValue"] > 0]]

subset_dF.StandardisedTraitUnit.unique() #gives you a list of the unit names
#Remove the % units and NaNs?


#Using groupby to group the IDs and then using filter to only show IDs with datasets with more than 5 datapoints
subset_dF = subset_dF.groupby(['FinalID']).filter(lambda x: len(x)>4)
#subset_dF["uniqueID"].value_counts()
#subset_dF.uniqueID.nunique()

#removing any values that are non-numeric in columns
subset_dF = subset_dF[pd.to_numeric(subset_dF['ConTemp'], errors='coerce').notnull()]

#Creating unique IDs to make the dataset IDs consistent i.e. there are no gaps in the numbering of IDs
subset_dF['uniqueID'] = subset_dF['FinalID'].rank(method='dense').astype(int)

#Adding columns containing starting values of the model parameters for the NLLS fitting
k = constants.value("Boltzmann constant in eV/K")
e = np.exp(1)
#E = ? #Need to estimate E values by plotting the groups

#Converting temperature from celcius to kelvin and adding a column for it
subset_dF['Temp(kel)'] = subset_dF.apply(lambda row: float(row.ConTemp) + 273.15, axis = 1)

#Adding a column for 1/kT (k constant x Temperature in Kelvin)
subset_dF['1/kT'] = 1/(subset_dF['Temp(kel)']*float(k))

#Adding columns for the log of StandardisedTraitValues
subset_dF['log_TraitValues'] = np.log(subset_dF.StandardisedTraitValue)

#Filtering outliers that are outside the quantile range in StandardisedTraitValue by group
#subset_dF = subset_dF[subset_dF.groupby("uniqueID").StandardisedTraitValue.transform(lambda x : (x<x.quantile(0.975))&(x>(x.quantile(0.025)))).eq(1)]
#subset_dF.to_csv('outy.csv', sep=',', encoding='utf-8')


# 6 Parameters to be estimated
#1. B0 - B0 is the trait value at 283.15K (10 degrees celcius) which stands for the value of the growth rate at low temperature and controls the offset of the curve.
#2. E - Activation energy (eV) which controls the rise of the curve up to the peak in the "normal operating range" for the enzyme (below the peak of the curve and above Th)
#3. El - is the enzyme's low temperature de-activation energy (eV) which controls the behaviour of the enzyme (and the curve) at very low temperatures
#4. Eh - is the enzyme's high temperature de-activation energy (eV) which controls the behaviour of the enzyme (and the curve) at very high temperatures
#5. Tl - is the temperature at which the enzyme is 50% low-temperature deactivated
#6. Th - is the temperature at which the enzyme is 50% high-temperature deactivated

#Checking plots
#subset_dF.groupby("uniqueID").plot(x="1/kT", y="log_TraitValues")

#To save a plot in each page use:

#with PdfPages('output.pdf') as pdf:
#   for i, group in subset_dF.groupby('uniqueID'):
#       fig=group.plot(x='1/kT', y='log_TraitValues',title=str(i), marker='o').get_figure()
#       pdf.savefig(fig, bbox_inches='tight')
#       plt.close(fig)

#for i, group in subset_dF.groupby('uniqueID'):
#    sns.lmplot(x="1/kT", y="log_TraitValues", data=group, fit_reg=False)
#    plt.savefig(../Results/output3+str(i)+".png")
#plt.show()


#to plot regression line from highest peak:
#maybe you could add subplots for each group where you give highest


with PdfPages('outputx.pdf') as pdf:
    j = 0
    for i, group in subset_dF.groupby("uniqueID"):
        # Break after 10 loops!
        j += 1
        if j > 10:
            print("Breaking...")
            break
        print("Group: {} ".format(i))
        plot = sns.regplot(data = group, x = "1/kT", y = "log_TraitValues", fit_reg=False)
        plot.set_title(str(i))
        fig = plot.get_figure()
        pdf.savefig(fig, bbox_inches='tight')
        plt.close(fig)
