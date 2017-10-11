#!/usr/bin/python

"""Paranoid programming 5.13.3"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '0.0.1'

import sys

def createabug(x):
	y = x**4 # ** means to the power of
	z = 0.
	import pdb; pdb.set_trace()
	y = y/z
	return y

createabug(25)

if (__name__ == "__main__"):
	status = main(sys.argv)
	sys.exit(status)