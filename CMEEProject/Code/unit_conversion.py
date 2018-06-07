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
bac_size = pd.read_csv('../Data/bac_dF.csv', low_memory=False)


bac_size.set_index('Unnamed: 0', inplace=True)
bac_size.index.name = 'index'

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

#bac_size = bacteria_size.dropna(subset=['MinWidth','MinLength'], how='all')
#bac_size['Shape'] = bac_size['Shape'].astype(str)

# CODE THAT RESHAPES DATAFRAME ###
#reshape = pd.DataFrame({'width': pd.concat([bac_size.MinWidth, bac_size.MaxWidth]), 'length': pd.concat([bac_size.MinLength, bac_size.MaxLength])}).sort_index()
#bac_dF = bac_size.join(reshape, how='outer')
#Cols = ['VolumeUnit','MassUnit']
#bac_dF = bac_dF.drop(Cols, axis=1)
#bac_dF = bac_dF[['GenusSpecies','width','length','SizeUnit','Shape','Phylum','Sources']]
#bac_dF.to_csv('../Data/bac_dF.csv', sep=',', encoding='utf-8')

#grouped = bac_size.groupby(['Shape'])
#for i,g in grouped:
    #print i

#    if (i == 'Spherical'):
#        g['Volume'] = g.apply(lambda x: sphere_vol(x.loc['width']), axis=1)

#    if (i == ' cylinderical'):
#        g['Volume'] = g.apply(lambda x: cylinder_vol(x.loc['width'], x.loc['length']), axis=1)

    #g.to_csv('../Data/vols.csv', sep=',', encoding='utf-8')

#    print(g.head())


#bac_size['Volume'] = bac_size[bac_size['Shape'] == 'Spherical']['width'].apply(lambda row: sphere_vol(row))
#bac_size['Volume'] = bac_size[bac_size['Shape'] == 'cylindrical'](['width']['length']).apply(lambda row: cylinder_vol(row))

bac_size['Volume'] = ""
mask = bac_size.Shape=='Spherical'
bac_size.loc[mask, 'Volume']=bac_size[mask].apply(lambda row: sphere_vol(row.width),axis=1)

mask = bac_size.Shape=='cylindrical'
bac_size.loc[mask, 'Volume']=bac_size[mask].apply(lambda row: cylinder_vol(row.width, row.length),axis=1)

mask = bac_size.Shape=='rod'
bac_size.loc[mask, 'Volume']=bac_size[mask].apply(lambda row: rod_vol(row.width, row.length),axis=1)

mask = bac_size.Shape=='oval'
bac_size.loc[mask, 'Volume']=bac_size[mask].apply(lambda row: oval_vol(row.width, row.length),axis=1)

bac_size['VolumeUnit'] = 'um3'

bac_size.to_csv('../Data/volumes.csv', sep=',', encoding='utf-8')
