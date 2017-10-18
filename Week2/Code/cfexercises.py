#!/usr/bin/python

"""Description of this program
	you can use several lines"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '0.0.1'

# imports
import sys # module to interface our program with the operating system

# 1)
for i in range(3, 17):
	print 'hello' #for the numbers between the ranges of 3 and 17, print 'hello'

# 2)
for j in range(12):
	if j % 3 == 0:
		print 'hello' #for a list of 12 numbers starting from 0 and divided by 3, 
		              #if their remainder is comparable to 0, then print 'hello'

# 3)
	for j in range(15):
		if j % 5 == 3:
			print 'hello'  #print 'hello' if the remainder of the j % 5 == 3, if not
		elif j % 4 == 3:   #...then print 'hello' if the remainder is 3 for j % 4
			print 'hello'

# 4)
z = 0
while z != 15:
	print 'hello'
	z = z + 3 #while z is not equal to 15, print 'hello'

# 5)
z = 12
while z < 100:
	if z == 31: 
		for k in range(7):
			print 'hello'
	elif z == 18:
		print 'hello'
	z = z + 1        

# What does fooXX do?
def foo1(x):
	return x ** 0.5

def foo2(x, y):
	if x > y:
		return x
	return y

def foo3(x, y, z):
	if x > y:
		tmp = y
		y = x
		x = tmp
	if y > z:
		tmp = z
		z = y
		y = tmp
	return [x, y, z]

def foo4(x):
	result = 1
	for i in range(1, x + 1):
		result = result * i
	return result

# This is a recursive function, meaning that the function calls itself
# read about it at
# en.wikipedia.org/wiki/Recursion_(computer_science)
def foo5(x):
	if x == 1:
		return 1
	return x * foo5(x - 1)

foo5(10)

def main(argv):
	# sys.exit("don't want to do this right now!")
	print foo1(22)
	print foo2(33,11)
	print foo3(6,2,7)
	print foo4(5)
	print foo5(3)
	return 0

if (__name__ == "__main__"): #makes sure the "main" function is called from commandline
		status = main(sys.argv)
		sys.exit(status)