#!/usr/bin/python

import csv

# Read a file containing:
# 'Species','Infraorder','Family','Distribution','Body mass male (Kg)'
f = open('../Sandbox/testcsv.csv','rb')

csvread = csv.reader(f)
temp = [] #create a mutuble tuple called temp
for row in csvread: #for every row in csvread, append the row to temp tuple
	temp.append(tuple(row))
	print row #Print the row
	print "The species is", row[0] #Print the first element in that row

f.close()

# write a file containing only species name and Body mass
f = open('../Sandbox/testcsv.csv','rb')
g = open('../Sandbox/bodymass.csv','wb')

csvread = csv.reader(f)
csvwrite = csv.writer(g)
for row in csvread:
	print row
	csvwrite.writerow([row[0], row[4]]) #Should print just the species name and bodymass
	#into a new file - extracts data from the original file
f.close()
g.close()
