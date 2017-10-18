#!/usr/bin/python
# Filename: using_name.py

if __name__ == '__main__':
	print 'This program is being run by itself'
else:
	print 'I am being imported from another module'

# if __name__ == '__main__' allows a module to be imported and used in another module
# By doing the main check, you can have that code only execute when you want to run 
# the module as a program and not have it execute when someone just wants to import 
# your module and call your functions themselves.