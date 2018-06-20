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


#Reading in the csv file as a pandas dataframe
subset_dF = pd.read_csv('../Data/GlobalDataset.csv', low_memory=False)

#read in size DataFrame
sizeDF = pd.read_csv('../Data/cellsizedata.csv', low_memory=False)

#Creating a subset of the dataframes with relevant columns
subset_dF = subset_dF.loc[:, ['FinalID','Consumer','OriginalTraitName','OriginalTraitValue','OriginalTraitUnit','StandardisedTraitValue','StandardisedTraitUnit','ConTemp','ConTempUnit','ConKingdom','ConPhylum','ConClass','ConOrder','ConFamily','ConGenus','ConSpecies','ConSize','ConSizeUnit',]]

#Filter group by bacteria only
subset_dF = subset_dF.loc[subset_dF['ConKingdom'] == 'Archaea']

#removing rows with 0 trait values
subset_dF = subset_dF.loc[subset_dF["StandardisedTraitValue"] > 0]

#Drop rows with no information on OriginalTraitUnit
subset_dF = subset_dF.dropna(subset=['OriginalTraitUnit'])

subset_dF = subset_dF[subset_dF.OriginalTraitUnit != '?']

#subset rows that measure growth rate
subset_dF = subset_dF[subset_dF['OriginalTraitName'].str.contains("rowth")]

#removing any values that are non-numeric in columns
subset_dF = subset_dF[pd.to_numeric(subset_dF['ConTemp'], errors='coerce').notnull()]

#filter rows by group and keep groups where it has more than 1 unique ConTemp value
#subset_dF = subset_dF.groupby('FinalID').filter(lambda x: x.ConTemp.value_counts().max() < 2)
subset_dF = subset_dF.groupby('FinalID').filter(lambda x: x.ConTemp.nunique() > 1)

#Using groupby to group the IDs and then using filter to only show IDs with datasets with more than 4 datapoints
subset_dF = subset_dF.groupby(['FinalID']).filter(lambda x: len(x)>5)

#Drop rows which have no information about ConGenus
#subset_dF = subset_dF.dropna(subset=['ConGenus'])
#Drop rows which have no information about ConGenus and ConSpecies
#If time permits then only drop rows with no ConFamily information and then find average size for families
subset_dF = subset_dF.dropna(subset=['ConGenus','ConSpecies'])

#add column which combines Genus and species name
subset_dF['GenusSpecies'] = subset_dF["ConGenus"].map(str) + ' ' + subset_dF["ConSpecies"]

### COMBININIG SIZE DATAFRAME AND BACTERIAL DataFrame ###
#subset_dF = subset_dF.merge(sizeDF, how='left', left_on='GenusSpecies', right_on='Species').drop('Species', axis=1)

#concatenate columns for size and size size unit
#subset_dF.ConSize = subset_dF.ConSize.fillna(subset_dF.Mass)
#subset_dF.ConSizeUnit = subset_dF.ConSizeUnit.fillna(subset_dF.SizeUnit)

subset_dF.to_csv('../Data/arch_subset.csv', sep=',', encoding='utf-8')

####################### PREPARING BACTERIA DATA FOR NLLS FITTING #########################
###########################################################################################

# Reading in bacteria data after being combined with size dataset
archaea_data = pd.read_csv('../Data/ARCHAEA.csv', index_col=0)

del archaea_data['Notes']
del archaea_data['Sources']

#Creating unique IDs to make the dataset IDs consistent i.e. there are no gaps in the numbering of IDs
archaea_data['uniqueID'] = archaea_data['FinalID'].rank(method='dense').astype(int)

#Adding columns containing starting values of the model parameters for the NLLS fitting
k = constants.value("Boltzmann constant in eV/K")
e = np.exp(1)

#Converting temperature from celcius to kelvin and adding a column for it
archaea_data['Temp(kel)'] = archaea_data.apply(lambda row: float(row.ConTemp) + 273.15, axis = 1)

#Adding a column for 1/kT (k constant x Temperature in Kelvin)
archaea_data['1/kT'] = 1/(archaea_data['Temp(kel)']*float(k))

#Adding columns for the log of Original Trait Values
archaea_data['log_TraitValues'] = np.log(archaea_data.StandardisedTraitValue)

#sort data by temperature and id
archaea_data = archaea_data.sort_values(['uniqueID','Temp(kel)'])

#Creating an empty dataframe with parameter columns
newDF = pd.DataFrame(columns=['B0','E','Eh','El','Th','Tl','ID'])

#subset_dF.to_csv('subset_dF.csv', sep=',', encoding='utf-8')

grouped = archaea_data.groupby('uniqueID')
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

final_dF = pd.merge(archaea_data, newDF, left_on='uniqueID', right_on='ID', how='right').drop('ID', axis=1)

#Deal with E column where there is no E-value and give it a generic valur of 0.66
final_dF.E = final_dF.E.fillna(value=0.66)
final_dF.Eh = final_dF.Eh.fillna(value=2*0.66)
final_dF.El = final_dF.El.fillna(value=0.66/2)

final_dF.to_csv('../Data/archaea_subset.csv', sep=',', encoding='utf-8')
