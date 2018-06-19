#!usr/bin/python
"""CMEE MSc Project"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '2.7.14'

### A python script that combines the size dataframes with the original dataframe for bacteria, archaea and phytoplankton subsets ###

import pandas as pd #reads in data as dataframes
import numpy as np
import scipy as sc
import math

########################## COMBINING BACTERIA DATA #######################################
##############################################################################################################

# Reading in bactertia volume data
bacteria_vol = pd.read_csv('../Data/bac_volumes.csv', low_memory=False)

# Reading in the bacteria subset data
bacteria_subset = pd.read_csv('../Data/bac_subset.csv', low_memory=False)

# Combining the subset and volumes dataframes on column: 'GenusSpecies'
bac_DF = pd.merge(bacteria_subset, bacteria_vol, on='GenusSpecies', how='outer')
del bac_DF['Phylum']
bac_DF = bac_DF[['FinalID','Consumer','OriginalTraitName','OriginalTraitValue','OriginalTraitUnit', \
                'StandardisedTraitValue','StandardisedTraitUnit', 'ConTemp', 'ConTempUnit', \
                'ConKingdom','ConPhylum','ConClass','ConOrder','ConFamily','ConGenus','ConSpecies', \
                'ConSize','ConSizeUnit','uniqueID','GenusSpecies','MinVolume','MaxVolume', \
                'AverageVolume','VolumeUnit','Sources','Notes']]

#combining the size and volume columns
bac_DF.loc[bac_DF['MinVolume'].isnull(),'MinVolume'] = bac_DF['ConSize']
bac_DF.loc[bac_DF['MaxVolume'].isnull(),'MaxVolume'] = bac_DF['ConSize']
bac_DF.loc[bac_DF['AverageVolume'].isnull(),'AverageVolume'] = bac_DF['ConSize']
bac_DF.loc[bac_DF['VolumeUnit'].isnull(),'VolumeUnit'] = bac_DF['ConSizeUnit']

# Drop rows with no cell volume information
bac_DF = bac_DF.dropna(subset=['MinVolume','MaxVolume'], how='all')

bac_DF.to_csv('../Data/BACTERIA.csv', sep=',', encoding='utf-8')


########################## COMBINING ARCHAEA DATA #######################################
##############################################################################################################

# Reading in bactertia volume data
archaea_vol = pd.read_csv('../Data/archaea_volumes.csv', low_memory=False)

# Reading in the bacteria subset data
archaea_subset = pd.read_csv('../Data/arch_subset.csv', low_memory=False)

# Combining the subset and volumes dataframes on column: 'GenusSpecies'
arch_DF = pd.merge(archaea_subset, archaea_vol, on='GenusSpecies', how='outer')
del arch_DF['Phylum']
arch_DF = arch_DF[['FinalID','Consumer','OriginalTraitName','OriginalTraitValue','OriginalTraitUnit', \
                'StandardisedTraitValue','StandardisedTraitUnit', 'ConTemp', 'ConTempUnit', \
                'ConKingdom','ConPhylum','ConClass','ConOrder','ConFamily','ConGenus','ConSpecies', \
                'ConSize','ConSizeUnit','uniqueID','GenusSpecies','MinVolume','MaxVolume', \
                'AverageVolume','VolumeUnit','Sources','Notes']]

#combining the size and volume columns
arch_DF.loc[arch_DF['MinVolume'].isnull(),'MinVolume'] = arch_DF['ConSize']
arch_DF.loc[arch_DF['MaxVolume'].isnull(),'MaxVolume'] = arch_DF['ConSize']
arch_DF.loc[arch_DF['AverageVolume'].isnull(),'AverageVolume'] = arch_DF['ConSize']
arch_DF.loc[arch_DF['VolumeUnit'].isnull(),'VolumeUnit'] = arch_DF['ConSizeUnit']

# Drop rows with no cell volume information
arch_DF = arch_DF.dropna(subset=['MinVolume','MaxVolume'], how='all')

arch_DF.to_csv('../Data/ARCHAEA.csv', sep=',', encoding='utf-8')


########################## COMBINING PHYTOPLANKTON DATA #######################################
##############################################################################################################

# Reading in bactertia volume data
phytoplankton_vol = pd.read_csv('../Data/phytoplankton_AvgVolumes.csv', low_memory=False)

# Reading in the bacteria subset data
phytoplankton_subset = pd.read_csv('../Data/phyto_subset.csv', low_memory=False)

# Combining the subset and volumes dataframes on column: 'GenusSpecies'
phyto_DF = pd.merge(phytoplankton_subset, phytoplankton_vol, on='GenusSpecies', how='outer')
del phyto_DF['Phylum']
phyto_DF = phyto_DF[['FinalID','Consumer','OriginalTraitName','OriginalTraitValue','OriginalTraitUnit', \
                'StandardisedTraitValue','StandardisedTraitUnit', 'ConTemp', 'ConTempUnit', \
                'ConKingdom','ConPhylum','ConClass','ConOrder','ConFamily','ConGenus','ConSpecies', \
                'ConSize','ConSizeUnit','uniqueID','GenusSpecies', \
                'AverageVolume','VolumeUnit','Sources','Notes']]

#combining the size and volume columns
phyto_DF.loc[phyto_DF['AverageVolume'].isnull(),'AverageVolume'] = phyto_DF['ConSize']
phyto_DF.loc[phyto_DF['VolumeUnit'].isnull(),'VolumeUnit'] = phyto_DF['ConSizeUnit']

# Drop rows with no cell volume information
phyto_DF = phyto_DF.dropna(subset=['AverageVolume'], how='all')

phyto_DF.to_csv('../Data/PHYTOPLANKTON.csv', sep=',', encoding='utf-8')
