#!/usr/bin/python

"""Description of this program
	you can use several lines"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '0.0.1'

# imports
import sys # module to interface our program with the operating system

## Let's find just those taxa that are oak trees from a list of species

taxa = [ 'Quercus robur','Fraxinus excelsior','Pinus sylvestris','Quercus cerris','Quercus petraea' ]

def is_an_oak(name):
	return name.lower().startswith('quercus ')

##Using for loops
oaks_loops = set()
for species in taxa:
	if is_an_oak(species):
		oaks_loops.add(species)
print oaks_loops

##Using list comprehensions
oaks_lc = set([species for species in taxa if is_an_oak(species)])
print oaks_lc

##Get names in UPPER CASE using for loops
oaks_loops = set()
for species in taxa:
	if is_an_oak(species):
		oaks_loops.add(species.upper())
print oaks_loops

##Get names in UPPER CASE using list comprehensions
oaks_lc = set([species.upper() for species in taxa if is_an_oak(species)])
print oaks_lc

