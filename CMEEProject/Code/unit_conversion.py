#!usr/bin/python
"""CMEE MSc Project"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '2.7.14'

### A python script that converts units of measurements into another unit ###

import pandas as pd #reads in data as dataframes
import numpy as np
import scipy as sc
import math

# Reading in bactertia size data
bacteria_size = pd.read_csv('../Data/bacteria_size2.csv', low_memory=False)

### FUNCTIONS TO CALCULATE VOLUMES OF DIFFERENT SHAPES OF CELLS ###
def sphere_vol(width):
    """Function returns the volume of a sphere when an argument for width is given"""
    return ((math.pi/6)*width**3)

def cylinder_vol(width, length):
    """Function returns the volume of a cylinder when arguments for width and length are given"""
    return ((math.pi/4)*width*length)

def rod_vol(width, length):
    """Function returns the volume of a rod when arguments for width and length are given"""
    """Function adds volumes of cylinder and sphere to calculate rod volume"""
    sphere = sphere_vol(width)
    cylinder = cylinder_vol(width, length)
    return (sphere + cylinder)

def oval_vol(width, length):
    """Function returns the volume of an oval when arguments for width and length are given"""
    return ((math.pi/6)*width**2*length)

def cone_vol(width, length):
    """Function returns the volume of a cone when arguments for width and length are given"""
    return((math.pi/12)*width**2*length)

### KEEPING ONLY THOSE COLUMNS WHICH HAVE WIDTH AND LENGTH INFORMATION ###
### MERGE WITH THE EXISTING VOLUME AND MASS DATA LATER ###

bac_size = bacteria_size.dropna(subset=['MinWidth','MinLength'], how='all')
bac_size['Shape'] = bac_size['Shape'].astype(str)

#if bacteria_size.Shape == 'Spherical':
            #Converting temperature from celcius to kelvin and adding a column for it
    #        bacteria_size['MinVolume'] = bacteria.apply(lambda row: float(row.MinSizeValue)**2*pi/2, axis = 1)

grouped = bac_size.groupby(['Shape'])

for i,g in grouped:
    print i
    if (i == 'Spherical'):
        name = g.GenusSpecies
        width == g.MinWidth
        g['MinVolume'] = g.iloc[:, 1:].apply(sphere_vol, axis=1)

        print(width)

# CODE THAT RESHAPES DATAFRAME ###
#reshape = pd.DataFrame({'width': pd.concat([bac_size.MinWidth, bac_size.MaxWidth]), 'length': pd.concat([bac_size.MinLength, bac_size.MaxLength])}).sort_index()
#bac_dF = bac_size.join(reshape, how='outer')
#Cols = ['VolumeUnit','MassUnit']
#bac_dF = bac_dF.drop(Cols, axis=1)
#bac_dF = bac_dF[['GenusSpecies','width','length','SizeUnit','Shape','Phylum','Sources']]
#bac_dF.to_csv('../Data/bac_dF.csv', sep=',', encoding='utf-8')

print (bac_size.loc[bac_size['Shape'] == 'Spherical'])

list = bac_size.GenusSpecies.unique()

for i in list:
    tmp = bac_size.loc[bac_size.GenusSpecies == i]
    if len(tmp.Shape) == 1:
        print(str(i) + ' Spherical')
    else:
        print(str(i) +' __________ ')


bac_size.to_csv('../Data/bac_size.csv', sep=',', encoding='utf-8')