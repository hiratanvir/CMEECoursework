#!/usr/bin/python

#############################
# FILE INPUT
#############################
# Open a file for reading
f = open('../Sandbox/test.txt', 'r')
# use "implicit" for loop:
# if the object is a file, python will cycle over lines
for line in f: #for every line in f (file), print the line
	print line, # the "," prevents adding a new line

# close the file
f.close()

# Same example, skip blank lines
f = open('../Sandbox/test.txt', 'r')
for line in f: #only print line if the length of string is greater than 0 - therefore skips lines
	if len(line.strip()) > 0:
		print line,

f.close()

#############################
# FILE OUTPUT
#############################
# Save the elements of a list to a file
list_to_save = range(100 #printing numbers from range 1-100 on new lines to a file

f = open('../Sandbox/testout.txt','w')
for i in list_to_save:
	f.write(str(i) + '\n') ## Add a new line at the end

f.close()

#############################
# STORING OBJECTS
#############################
# To save an object (even complex) for later use
my_dictionary = {"a key": 10, "another key": 11}

import pickle
#Pickle is a python module that serializes or de-serializes data/files
#Data serialization is the concept of converting structured data into a
#format that allows it to be shared or stored in such a way that its original
#structure to be recovered. In some cases, the secondary intention of data serialization
#is to minimize the size of the serialized data which then minimizes disk space or bandwidth requirements.

f = open('../Sandbox/testp.p','wb') ## note the b: accept binary files
pickle.dump(my_dictionary, f)
f.close()

## Load the data again
f = open('../Sandbox/testp.p','rb')
another_dictionary = pickle.load(f)
f.close()

print another_dictionary
