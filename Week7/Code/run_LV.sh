#!/bin/bash

"""Chapter 6.3 Practical"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '2.7.14'

# Shell script to run the Lotka-Volterra model scripts and profile's them,
#printing the time it takes to run each loop in each script

#The equivalent in bash for %run -p in ipython (which profiles a script) is python -m cProfile

python -m cProfile LV1.py &
python -m cProfile LV2.py 2 0.1 1.5 0.75 30.0
