#!usr/bin/python
"""CMEE MSc Project"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '2.7.14'

### A python script that opens the standardised phytoplankton dataset and creates
### a new dataframe with phytoplankton species and size information ###


import pandas as pd #reads in data as dataframes
import numpy as np
import scipy as sc

#Reading in the csv file as a pandas dataframe
subset_dF = pd.read_csv('../Data/phytoplankton_standardised.csv', low_memory=False)

#read in size DataFrame
sizeDF = pd.read_csv('../Data/cellsizedata.csv', low_memory=False)

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

#subset_dF.to_csv('../Data/phyto_subset.csv', sep=',', encoding='utf-8')

#subsetting GenusSpecies with existing size information already recorded in BioTraits
#Dropping duplicated nan columns (if GenusSpecies did not have existing size info)
#gets list of species and sizes that already exist in dataset
dF = subset_dF.loc[:, ['ConPhylum','GenusSpecies','ConSize','ConSizeUnit']]
out = dF[dF["ConSize"].notnull()]
out.rename(columns={'ConPhylum':'Phylum'}, inplace=True)
out.rename(columns={'ConSize':'SizeValue'}, inplace=True)
out.rename(columns={'ConSizeUnit':'SizeUnit'}, inplace=True)

#dropping masses as we only need volumes
out = out[out.SizeUnit.str.contains("mg") == False]

renaming columns
out.rename(columns={'SizeValue':'Volume'}, inplace=True)
out.rename(columns={'SizeUnit':'VolumeUnit'}, inplace=True)

#out.to_csv('../Data/existing_phytoplankton_sizedata.csv', sep=',', encoding='utf-8', index=False)

    ####################### SPECIES WITH NO SIZE INFORMATION #############################

#list of all species with no size information and then creating a size dataframe with those species name
#subset unique Genus Species information from original dataframe to make a separate size information DataFrame
Species = subset_dF.GenusSpecies[(subset_dF.ConSize.isnull())].unique()

#### 1. CHECKING IF ANY SIZE VALUES FROM SIZE DATAFRAME MATCH WITH SPECIES NAMES WITH NO SIZE EXISTING IN BIOTRAITS ###
cellsizeDF=pd.DataFrame(Species, columns=['GenusSpecies'])

### 2. COMBININIG SIZE DATAFRAME AND PHYTOPLANKTON DataFrame ###
cellsizeDF = cellsizeDF.merge(sizeDF, how='left', left_on='GenusSpecies', right_on='Species').drop('Species', axis=1)

# 3. renaming columns
#cellsizeDF.rename(columns={'GenusSpecies':'GenusSpecies.1'}, inplace=True)
cellsizeDF.rename(columns={'Mass':'Volume'}, inplace=True)
cellsizeDF.rename(columns={'SizeUnit':'VolumeUnit'}, inplace=True)

#merging existing size data for species with species that did not have any size data by row level operation (axis=0)
df_concat = pd.concat([cellsizeDF, out], axis=0)
df_concat = df_concat[['GenusSpecies','Volume','VolumeUnit','Phylum']]

#Dropping duplicated size values per group
df_concat = df_concat.drop_duplicates(["GenusSpecies", "Volume"])

#df_concat.to_csv('../Data/phytoplankton_size.csv', sep=',', encoding='utf-8', index=False)
