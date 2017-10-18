#!/usr/bin/python

import sys
print "This is the name of the script: ", sys.argv[0]
print "Number of arguments: ", len(sys.argv)
print "The arguments are: " , str(sys.argv)

# The Python sys module provides access to any command-line arguments via the sys.argv. 
# This serves two purposes −
# sys.argv is the list of command-line arguments.
# len(sys.argv) is the number of command-line arguments.
# Here sys.argv[0] is the program ie. script name.