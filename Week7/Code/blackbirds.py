#!usr/bin/python

"""Chapter 6 Regular Expressions"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '2.7.14'

import re
import ast
# Read the file
f = open('../Data/blackbirds.txt', 'r')
text = f.read()
f.close()

# remove \t\n and put a space in:
text = text.replace('\t',' ')
text = text.replace('\n',' ')

# note that there are "strange characters" (these are accents and
# non-ascii symbols) because we don't care for them, first transform
# to ASCII:
text = text.decode('ascii', 'ignore')


# Now extend this script so that it captures the Kingdom,
# Phylum and Species name for each species and prints it out to screen neatly.

regular_expression = zip(re.findall(r'(?<=\bKingdom\s)\w*', text), re.findall(r'(?<=\bPhylum\s)\w*', text), re.findall(r'(?<=\bSpecies\s)\w*\s\w*', text))
print regular_expression

counter = 1
for i in regular_expression:
    print "Blackbird species ", counter, " is:"
    print "Kingdom: ", i[0], '\n', "Phylum: ", i[1], '\n', "Species: ", i[2], '\n'
    counter = counter + 1


# Hint: you may want to use re.findall(my_reg, text)...
# Keep in mind that there are multiple ways to skin this cat!
# Your solution may involve multiple regular expression calls (easier!), or a single one (harder!)
