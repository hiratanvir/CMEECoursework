#!/usr/bin/python

## Try this first
_a_global = 10

def a_function():
	_a_global = 5
	_a_local = 4
	print ("Inside the function, the value is ", _a_global)
	print ("Inside the function, the value is ", _a_local)
	return None

print ("Outside the function, the value is ", _a_global)
a_function()




## Now try this

_a_global = 10

def a_function():
	global _a_global 
	_a_global = 5 
	_a_local = 4
	print ("Inside the function, the value is ", _a_global)
	print ("Inside the function, the value is ", _a_local)
	return None

a_function()
print ("Outside the function, the value is", _a_global)

# a variable does not fully become a global variable until you 
# assign it with this command: global _a_global, therefore in 
# this second example the global variable becomes 5.