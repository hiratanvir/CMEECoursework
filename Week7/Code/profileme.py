#!usr/bin/python

"""Chapter 6.2.1 Profiling"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '2.7.14'

def a_useless_function(x):
	y = 0
	# eight zeros!
	for i in range(100000000):
		y = y + i
	return 0

def a_less_useless_function(x):
	y = 0
	# five zeros!
	for i in range(100000):
		y = y + i
	return 0

def some_function(x):
	print x
	a_useless_function(x)
	a_less_useless_function(x)
	return 0

some_function(1000)
