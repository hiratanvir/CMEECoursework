#!usr/bin/python

"""Chapter 6.10 Practical - Using is problem 1"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '2.7.14'

# Use the subprocess.os module to get a list of files and  directories
# in your ubuntu home directory

# Hint: look in subprocess.os and/or subprocess.os.path and/or
# subprocess.os.walk for helpful functions

import subprocess
import os

#################################
#~Get a list of files and
#~directories in your home/ that start with an uppercase 'C'

# Type your code here:

# Get the user's home directory.
home = subprocess.os.path.expanduser("~")

# Create a list to store the results.
# creates an empty list
FilesDirsStartingWithC = []

# Use a for loop to walk through the home directory.
# os.walk function goes throught the files
for (dir, subdir, files) in subprocess.os.walk(home):
    for f in files:
        if f.startswith("C"):
            FilesDirsStartingWithC.append(os.path.join(f))
            print FilesDirsStartingWithC

#################################
# Get files and directories in your home/ that start with either an
# upper or lower case 'C'
FilesCc = []
# Type your code here:
for dirpath, subdirs, files in os.walk(home):
    for f in files:
        if f.startswith("c"): #finds files with lowercase c and appends to the list
            FilesCc.append(os.path.join(f))
        if f.startswith("C"): #finds files with uppercase C and appends to the list
            FilesCc.append(os.path.join(f))
            print FilesCc

#################################
# Get only directories in your home/ that start with either an upper or
#~lower case 'C'
SubdirCc = []
# Type your code here:
for f in os.listdir(home):
    if f.startswith("c"): #finds files with lowercase c and appends to the list
        SubdirCc.append(os.path.join(f))
    if f.startswith("C"): #finds files with uppercase C and appends to the list
        SubdirCc.append(os.path.join(f))
        print SubdirCc
