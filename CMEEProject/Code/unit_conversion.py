#!usr/bin/python
"""CMEE MSc Project"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '2.7.14'

### A python script that converts units of measurements into another unit ###

import pandas as pd #reads in data as dataframes
import numpy as np
import scipy as sc
import math
import re

################################### FUNCTIONS ##################################################################
################################################################################################################

### FUNCTIONS TO CALCULATE VOLUMES OF DIFFERENT SHAPES OF CELLS ###
def sphere_vol(width):
    """Function returns the volume of a sphere when an argument for width is given"""
    return ((math.pi/6)*width**3)

def cylinder_vol(width, length):
    """Function returns the volume of a cylinder when arguments for width and length are given"""
    return ((math.pi/4)*(width**2)*length)

def rod_vol(width, length):
    """Function returns the volume of a rod when arguments for width and length are given"""
    """Function adds volumes of cylinder and sphere to calculate rod volume"""
    sphere = sphere_vol(width)
    cylinder = cylinder_vol(width, length - width)
    return (sphere + cylinder)

def oval_vol(width, length):
    """Function returns the volume of an oval when arguments for width and length are given"""
    return ((math.pi/6)*(width**2)*length)

def cone_vol(width, length):
    """Function returns the volume of a cone when arguments for width and length are given"""
    return((math.pi/12)*(width**2)*length)


##Function returns values to a significant figure ###
def to_precision(x,p):
    """
    returns a string representation of x formatted with a precision of p

    Based on the webkit javascript implementation taken from here:
    https://code.google.com/p/webkit-mirror/source/browse/JavaScriptCore/kjs/number_object.cpp
    """

    x = float(x)

    if x == 0.:
        return "0." + "0"*(p-1)

    out = []

    if x < 0:
        out.append("-")
        x = -x

    e = int(math.log10(x))
    tens = math.pow(10, e - p + 1)
    n = math.floor(x/tens)

    if n < math.pow(10, p - 1):
        e = e -1
        tens = math.pow(10, e - p+1)
        n = math.floor(x / tens)

    if abs((n + 1.) * tens - x) <= abs(n * tens -x):
        n = n + 1

    if n >= math.pow(10,p):
        n = n / 10.
        e = e + 1

    m = "%.*g" % (p, n)

    if e < -2 or e >= p:
        out.append(m[0])
        if p > 1:
            out.append(".")
            out.extend(m[1:p])
        out.append('e')
        if e > 0:
            out.append("+")
        out.append(str(e))
    elif e == (p -1):
        out.append(m)
    elif e >= 0:
        out.append(m[:e+1])
        if e+1 < len(m):
            out.append(".")
            out.extend(m[e+1:])
    else:
        out.append("0.")
        out.extend(["0"]*-(e+1))
        out.append(m)

    return "".join(out)

##############################################################################################################
##############################################################################################################



########################## CALCULATING VOLUMES FROM BACTERIA SIZE DATA #######################################
##############################################################################################################

# Reading in bactertia size data
bacteria_size = pd.read_csv('../Data/bacteria_size2.csv', low_memory=False)

#bac_size.set_index('Unnamed: 0', inplace=True)
bacteria_size.index.name = 'index'

### KEEPING ONLY THOSE COLUMNS WHICH HAVE WIDTH AND LENGTH INFORMATION ###
### MERGE WITH THE EXISTING VOLUME AND MASS DATA LATER ###

bacteria_size = bacteria_size.dropna(subset=['MinWidth','MinLength'], how='all')
bacteria_size = bacteria_size.loc[:, ['GenusSpecies','MinWidth','MaxWidth','MinLength','MaxLength','SizeUnit','MinVolume','MaxVolume','VolumeUnit','Shape','Sources','Phylum','Notes']]
bacteria_size = bacteria_size[['GenusSpecies','MinWidth','MaxWidth','MinLength','MaxLength','SizeUnit','MinVolume','MaxVolume','VolumeUnit','Shape','Phylum','Sources','Notes']]

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


mask = bacteria_size.Shape=='Spherical'
bacteria_size.loc[mask, 'MinVolume']=bacteria_size[mask].apply(lambda row: sphere_vol(row.MinWidth),axis=1)
bacteria_size.loc[mask, 'MaxVolume']=bacteria_size[mask].apply(lambda row: sphere_vol(row.MaxWidth),axis=1)

mask = bacteria_size.Shape=='cylindrical'
bacteria_size.loc[mask, 'MinVolume']=bacteria_size[mask].apply(lambda row: cylinder_vol(row.MinWidth, row.MinLength),axis=1)
bacteria_size.loc[mask, 'MaxVolume']=bacteria_size[mask].apply(lambda row: cylinder_vol(row.MaxWidth, row.MaxLength),axis=1)

mask = bacteria_size.Shape=='rod'
bacteria_size.loc[mask, 'MinVolume']=bacteria_size[mask].apply(lambda row: rod_vol(row.MinWidth, row.MinLength),axis=1)
bacteria_size.loc[mask, 'MaxVolume']=bacteria_size[mask].apply(lambda row: rod_vol(row.MaxWidth, row.MaxLength),axis=1)

mask = bacteria_size.Shape=='oval'
bacteria_size.loc[mask, 'MinVolume']=bacteria_size[mask].apply(lambda row: oval_vol(row.MinWidth, row.MinLength),axis=1)
bacteria_size.loc[mask, 'MaxVolume']=bacteria_size[mask].apply(lambda row: oval_vol(row.MaxWidth, row.MaxLength),axis=1)

#converting volume units from cubic micro meters to cubic meters
bacteria_size['MinVolume'] = bacteria_size.apply(lambda row: float(row.MinVolume)*1e-18, axis = 1)
bacteria_size['MaxVolume'] = bacteria_size.apply(lambda row: float(row.MaxVolume)*1e-18, axis = 1)

#Merging existing volumes from original dataframe to volumes dataframe
#drop rows with no volumes and drop columns not needed
bac_original = pd.read_csv('../Data/bacteria_size2.csv', low_memory=False)
bac_original = bac_original[np.isfinite(bac_original['MinVolume'])]
del bac_original['Unnamed: 16']
bac_original = bac_original.loc[:, ['GenusSpecies','MinWidth','MaxWidth','MinLength','MaxLength','SizeUnit','MinVolume','MaxVolume','VolumeUnit','Shape','Sources','Phylum','Notes']]
bac_original = bac_original[['GenusSpecies','MinWidth','MaxWidth','MinLength','MaxLength','SizeUnit','MinVolume','MaxVolume','VolumeUnit','Shape','Phylum','Sources','Notes']]

#joining the two dataframes to complete volume information
frames = [bacteria_size, bac_original]
bac_volumes = pd.concat(frames)

bac_volumes['VolumeUnit'] = 'm^3'
bac_volumes['SizeUnit'] = 'um'

#Adding a column in for average cell volumes using the minimum and maximum range
bac_volumes['AverageVolume'] = bac_volumes[['MinVolume', 'MaxVolume']].mean(axis=1)

## APPLYING THE to_precision FUNCTION TO CONVERT THE VOLUMES TO 3 SIGNIFICANT FIGURES ##
bac_volumes['MinVolume'] = bac_volumes.apply(lambda row: to_precision(row.MinVolume, 3),axis=1)
bac_volumes['MaxVolume'] = bac_volumes.apply(lambda row: to_precision(row.MaxVolume, 3),axis=1)
bac_volumes['AverageVolume'] = bac_volumes.apply(lambda row: to_precision(row.AverageVolume, 3),axis=1)

#rearranging columns
bac_volumes = bac_volumes[['GenusSpecies','MinWidth','MaxWidth','MinLength','MaxLength','SizeUnit','MinVolume','MaxVolume','AverageVolume','VolumeUnit','Shape','Phylum','Sources','Notes']]

# Saving volumes to csv
bac_volumes.to_csv('../Data/bac_volumes.csv', sep=',', encoding='utf-8')

##############################################################################################################
##############################################################################################################



########################## CALCULATING VOLUMES FROM ARCHAEA SIZE DATA ########################################
##############################################################################################################

# Reading in Archaea size data
archaea_size = pd.read_csv('../Data/Archaea_size.csv', low_memory=False)
del archaea_size['Unnamed: 0']
archaea_size.index.name = 'index'

### KEEPING ONLY THOSE COLUMNS WHICH HAVE WIDTH AND LENGTH INFORMATION ###
### MERGE WITH THE EXISTING VOLUME AND MASS DATA LATER ###
archaea_size = archaea_size.dropna(subset=['MinWidth','MinLength'], how='all')
archaea_size = archaea_size[['GenusSpecies','MinWidth','MaxWidth','MinLength','MaxLength','SizeUnit','MinVolume','MaxVolume','VolumeUnit','Shape','Phylum','Sources','Notes']]

### VOLUME CONVERSIONS ###
mask = archaea_size.Shape=='Spherical'
archaea_size.loc[mask, 'MinVolume']=archaea_size[mask].apply(lambda row: sphere_vol(row.MinWidth),axis=1)
archaea_size.loc[mask, 'MaxVolume']=archaea_size[mask].apply(lambda row: sphere_vol(row.MaxWidth),axis=1)

mask = archaea_size.Shape=='cylindrical'
archaea_size.loc[mask, 'MinVolume']=archaea_size[mask].apply(lambda row: cylinder_vol(row.MinWidth, row.MinLength),axis=1)
archaea_size.loc[mask, 'MaxVolume']=archaea_size[mask].apply(lambda row: cylinder_vol(row.MaxWidth, row.MaxLength),axis=1)

mask = archaea_size.Shape=='rod'
archaea_size.loc[mask, 'MinVolume']=archaea_size[mask].apply(lambda row: rod_vol(row.MinWidth, row.MinLength),axis=1)
archaea_size.loc[mask, 'MaxVolume']=archaea_size[mask].apply(lambda row: rod_vol(row.MaxWidth, row.MaxLength),axis=1)

mask = archaea_size.Shape=='oval'
archaea_size.loc[mask, 'MinVolume']=archaea_size[mask].apply(lambda row: oval_vol(row.MinWidth, row.MinLength),axis=1)
archaea_size.loc[mask, 'MaxVolume']=archaea_size[mask].apply(lambda row: oval_vol(row.MaxWidth, row.MaxLength),axis=1)

#converting volume units from cubic micro meters to cubic meters
archaea_size['MinVolume'] = archaea_size.apply(lambda row: float(row.MinVolume)*1e-18, axis = 1)
archaea_size['MaxVolume'] = archaea_size.apply(lambda row: float(row.MaxVolume)*1e-18, axis = 1)

archaea_size['VolumeUnit'] = 'm^3'
archaea_size['SizeUnit'] = 'um'
archaea_size = archaea_size.dropna(subset=['MinVolume','MaxVolume'], how='all')

#Adding a column in for average cell volumes using the minimum and maximum range
archaea_size['AverageVolume'] = archaea_size[['MinVolume', 'MaxVolume']].mean(axis=1)

## APPLYING THE to_precision FUNCTION TO CONVERT THE VOLUMES TO 3 SIGNIFICANT FIGURES ##
archaea_size['MinVolume'] = archaea_size.apply(lambda row: to_precision(row.MinVolume, 3),axis=1)
archaea_size['MaxVolume'] = archaea_size.apply(lambda row: to_precision(row.MaxVolume, 3),axis=1)
archaea_size['AverageVolume'] = archaea_size.apply(lambda row: to_precision(row.AverageVolume, 3),axis=1)

#rearranging columns
archaea_size = archaea_size[['GenusSpecies','MinWidth','MaxWidth','MinLength','MaxLength','SizeUnit','MinVolume','MaxVolume','AverageVolume','VolumeUnit','Shape','Phylum','Sources','Notes']]

# Saving volumes to csv
archaea_size.to_csv('../Data/archaea_volumes.csv', sep=',', encoding='utf-8')

##############################################################################################################
##############################################################################################################

#reading in biovolumes for phytoplankton dataset
plankton = pd.read_csv('../Data/Table2.csv', low_memory=False)

#Converting temperature from cubic mirometers to cubic_meters and adding a column for it
plankton['CellVolCubicMeters'] = plankton.apply(lambda row: float(row.Biovolume)*1e-18, axis = 1)

#Drop rows which have no information about ConGenus
plankton = plankton.dropna(subset=['Genus','Species','Biovolume'])

#add column which combines Genus and species name
plankton['GenusSpecies'] = plankton["Genus"].map(str) + ' ' + plankton["Species"]

#to 3.s.f
plankton['CellVolCubicMeters'] = plankton.apply(lambda row: to_precision(row.CellVolCubicMeters, 3),axis=1)

#save dataset
plankton.to_csv('../Data/plankton_volume_data.csv', sep=',', encoding='utf-8')

plankton_vols = pd.read_csv('../Data/phytoplankton_size.csv', low_memory=False)

#Drop rows which have no volumes
plankton_vols = plankton_vols.dropna(subset=['Volumes'])

#creating a new column and finding the average of repeated volume measurements per species
plankton_vols['AverageVolume'] = plankton_vols['Volumes'].groupby(plankton_vols['GenusSpecies']).transform(np.mean)

#to 3.s.f
plankton_vols['AverageVolume'] = plankton_vols.apply(lambda row: to_precision(row.AverageVolume, 3),axis=1)

plankton_vols = plankton_vols[['GenusSpecies','Volumes','AverageVolume','VolumeUnit','Shape','Phylum','Sources','Notes']]

#save dataset
plankton_vols.to_csv('../Data/phytoplankton_volumes.csv', sep=',', encoding='utf-8')

#saving only the averages
plankton_vols.drop_duplicates(subset='GenusSpecies',inplace=True)
del plankton_vols['Volumes']
plankton_vols.to_csv('../Data/phytoplankton_AvgVolumes.csv', sep=',', encoding='utf-8')
