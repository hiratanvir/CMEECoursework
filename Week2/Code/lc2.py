#!/usr/bin/python

# Average UK Rainfall (mm) for 1910 by month
# http://www.metoffice.gov.uk/climate/uk/datasets
rainfall = (('JAN',111.4),
            ('FEB',126.1),
            ('MAR', 49.9),
            ('APR', 95.3),
            ('MAY', 71.8),
            ('JUN', 70.2),
            ('JUL', 97.1),
            ('AUG',140.2),
            ('SEP', 27.0),
            ('OCT', 89.4),
            ('NOV',128.4),
            ('DEC',142.2),
           )

# (1) Use a list comprehension to create a list of month,rainfall tuples where
# the amount of rain was greater than 100 mm.
 
# (2) Use a list comprehension to create a list of just month names where the
# amount of rain was less than 50 mm. 

# (3) Now do (1) and (2) using conventional loops (you can choose to do 
# this before 1 and 2 !). 

# ANNOTATE WHAT EVERY BLOCK OR IF NECESSARY, LINE IS DOING! 

# ALSO, PLEASE INCLUDE A DOCSTRING AT THE BEGINNING OF THIS FILE THAT 
# SAYS WHAT THE SCRIPT DOES AND WHO THE AUTHOR IS
# use if statement

#1. Using loops
#List of months for rainfall > 100 mm 
heavy_loops = set() #Creating an empty set, which will get filled later 
for x in rainfall: #defining everthing between each (tuple) as x
      if x[1] > 100: #If the second [1] element in each tuple (x) is over a 100
            heavy_loops.add(x) #add x(month and rainfall - the entire tuple) to the list
print heavy_loops

#List of months for rainfall < 50 mm
light_loops = set()
for x in rainfall:
      if x[1] < 50:
            light_loops.add(x)
print light_loops

#2. Using list comprehension
#List of months for rainfall > 100 mm
heavy_lc = set([x for x in rainfall if x[1] > 100]) #Creating and empty set and calling the each month (x) for heavy rain within rainfall if rainfall > 100 mm
print heavy_lc

#List of months for rainfall < 50 mm
light_lc = set([x for x in rainfall if x[1] < 50]) #Creating and empty set and calling the each month (x) for light rain within rainfall if rainfall > 50 mm
print light_lc

