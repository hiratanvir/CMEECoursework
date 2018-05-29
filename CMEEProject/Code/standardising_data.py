#!usr/bin/python
"""CMEE MSc Project"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '2.7.14'

import pandas as pd #reads in data as dataframes
import numpy as np
import math

#Reading in the csv file as a pandas dataframe
dF = pd.read_csv('../Data/GlobalDataset.csv', low_memory=False)

#Creating a subset of the dataframes with relevant columns
subset_dF = dF.loc[:, ['FinalID','Consumer','OriginalTraitName','OriginalTraitValue','OriginalTraitUnit','StandardisedTraitValue','StandardisedTraitUnit','ConTemp','ConTempUnit','ConKingdom','ConPhylum','ConClass','ConOrder','ConFamily','ConGenus','ConSpecies','ConSize','ConSizeUnit',]]

#removing rows with 0 trait values
subset_dF = subset_dF.loc[subset_dF["OriginalTraitValue"] > 0]

#subset rows that measure growth rate
subset_dF = subset_dF[subset_dF['OriginalTraitName'].str.contains("rowth", na=False)]

#Drop rows with no information on OriginalTraitUnit
subset_dF = subset_dF.dropna(subset=['OriginalTraitUnit'])

subset_dF = subset_dF[subset_dF.OriginalTraitUnit != '?']

#Dropping Bacteria, Archaea and Metazoa
subset_dF = subset_dF[~subset_dF['ConKingdom'].isin(['Bacteria','Archaea','Metazoa'])]

#Drop phylum that are not algae or phytoplankton
subset_dF = subset_dF[~subset_dF['ConPhylum'].isin(['Ciliophora','Ascomycota','Rhodophyta'])]

#Drop class that are not algae or phytoplankton or unicelllar
subset_dF = subset_dF[~subset_dF['ConClass'].isin(['Liliopsida','Klebsormidiophyceae'])]

#Creating an empty column to add Standardised Trait Values
#subset_dF['StandardisedTraits'] = np.nan
#grouped = subset_dF.groupby('OriginalTraitUnit')

#for i,g in grouped:
#
#    if i == 'day^-1':
#        print("Elif triggered")
#        subset_dF['StandardisedTraits'] = g['OriginalTraitValue']/86400
#
#    elif i == 'milligram (body mass - wet) / (1 individual * 24 hour)':
#        subset_dF['StandardisedTraits'] = g['OriginalTraitValue']*(10**-6)/86400
#
#    else:
#        print 'R sux'

mask = subset_dF.OriginalTraitUnit == 'day^-1'
subset_dF.loc[mask, 'StandardisedTraits'] = subset_dF.OriginalTraitValue[mask]/86400

mask = subset_dF.OriginalTraitUnit == 'milligram (body mass - wet) / (1 individual * 24 hour)'
subset_dF.loc[mask, 'StandardisedTraits'] = subset_dF.OriginalTraitValue[mask]*(10**-6)/86400

mask = subset_dF.OriginalTraitUnit == 'micro (day^-1)'
subset_dF.loc[mask, 'StandardisedTraits'] = subset_dF.OriginalTraitValue[mask]/86400

mask = subset_dF.OriginalTraitUnit == 'event / (1 individual * 24 hour)'
subset_dF.loc[mask, 'StandardisedTraits'] = subset_dF.OriginalTraitValue[mask]/86400


subset_dF.to_csv('../Data/standardised_data.csv', sep=',', encoding='utf-8')
