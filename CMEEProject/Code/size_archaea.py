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

#Reading in the csv file as a pandas dataframe
subset_dF = pd.read_csv('../Data/GlobalDataset.csv', low_memory=False)

#read in size DataFrame
sizeDF = pd.read_csv('../Data/cellsizedata.csv', low_memory=False)

#read in size data from growth, microbial partitioning and the size of microorganisms
microbe_dF = pd.read_csv('../Data/microbial_partitioning_paper_data.csv', low_memory=False)

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

#Drop rows which have no information about ConGenus and ConSpecies
#If time permits then only drop rows with no ConFamily information and then find average size for families
subset_dF = subset_dF.dropna(subset=['ConGenus','ConSpecies'])

#Creating unique IDs to make the dataset IDs consistent i.e. there are no gaps in the numbering of IDs
subset_dF['uniqueID'] = subset_dF['FinalID'].rank(method='dense').astype(int)

#add column which combines Genus and species name
subset_dF['GenusSpecies'] = subset_dF["ConGenus"].map(str) + ' ' + subset_dF["ConSpecies"]

#list of all species with no size information
#subset unique Genus Species information from original dataframe to make a separate size information DataFrame
Species = subset_dF.GenusSpecies[(subset_dF.ConSize.isnull())].unique()
cellsizeDF=pd.DataFrame(Species, columns=['GenusSpecies'])

### COMBININIG SIZE DATAFRAME AND BACTERIAL DataFrame ###
cellsizeDF = cellsizeDF.merge(sizeDF, how='left', left_on='GenusSpecies', right_on='Species').drop('Species', axis=1)
cellsizeDF['SizeType'] = ''
cellsizeDF['Citation'] = ''

#renaming columns
cellsizeDF.rename(columns={'Mass':'SizeValue'}, inplace=True)

#Definig size type based on size SizeUnit
mask = cellsizeDF.SizeUnit == 'g'
cellsizeDF.loc[mask, 'SizeType'] = 'mass'

nan_rows = cellsizeDF[cellsizeDF['SizeValue'].isnull()]

#To find out how many species still need size information
nan_rows.count()

#list of unique species names that need size information##
list = cellsizeDF.GenusSpecies.unique()

#cellsizeDF.to_csv('../Data/Archaea_size1.csv', sep=',', encoding='utf-8')
