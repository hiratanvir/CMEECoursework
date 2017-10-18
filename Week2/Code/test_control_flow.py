#!/usr/bin/python

"""Some functions exemplifying the use of control statements"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '0.0.1'

import sys
import doctest # Import the doctest module

def even_or_odd(x=0): # if not specified, x should take value 0.

	"""Find whether a number x is even or odd.

	>>> even_or_odd(10)
	'10 is Even!'

	>>> even_or_odd(5)
	'5 is Odd!'

	whenever a float is provided, then the closest integer is used:
	>>> even_or_odd(3.2)
	'3 is Odd!'

	in case of negative numbers, the positive is taken:
	>>> even_or_odd(-2)
	'-2 is Even!'

	"""
	#Define function to be tested
	if x % 2 == 0: #% will divide the first number by the second number & output the remainder
		return "%d is Even!" % x #If there is 0 remainder then return this
	return "%d is Odd!" % x #if there is a remainder i.e if x is not = 0 then it's odd

## I SUPPRESSED THIS BLOCK: WHY?

# def main(argv):
# print even_or_odd(22)
# print even_or_odd(33)
# return 0

# if (__name__ == "__main__"):
# status = main(sys.argv)

doctest.testmod() # To run with embedded tests