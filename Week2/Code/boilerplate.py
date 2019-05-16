#!/usr/bin/python

"""Description of this program
	you can use several lines"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '2.7.10'
#This version runs on python 2.7.10 so in order to run it
#on a compatible ipython version on mac, enter python -m IPython

# imports
import sys # module to interface our program with the operating system

# constants can go here
def foo1(x):
	return x ** 0.5
# functions can go here
def main(argv):
		print('This is a boilerplate') # NOTE: indented using two tabs or 4 spaces
		return 0


if (__name__ == "__main__"): #makes sure the "main" function is called from commandline
		status = main(sys.argv)
		sys.exit(status)

#if (name__=="__main__") makes the script into a function which you can import from the command line,
#any functions included in the script can also be called from the command line when
#the module (Script) is imported.
