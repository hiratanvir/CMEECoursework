#!/usr/bin/python

"""Description of this program
	you can use several lines"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '0.0.1'

# imports
import sys # module to interface our program with the operating system

# for loops in Python
for i in range(5):
	print i

my_list = [0, 2, "geronimo!", 3.0, True, False]
for k in my_list:
	print k

total = 0
summands = [0, 1, 11, 111, 1111]
for s in summands:
	print total + s

# while loops in Python
z = 0
while z < 100:
	z = z + 1
	print (z)

b = True
while b:
	print "GERONIMO! infinite loop! ctrl+c to stop!"
# ctrl + c to stop!

if (__name__ == "__main__"): #makes sure the "main" function is called from commandline
		status = main(sys.argv)
		sys.exit(status)