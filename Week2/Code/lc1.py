
#(1) Write three separate list comprehensions that create three different
# lists containing the latin names, common names and mean body masses for
# each species in birds, respectively. 

# (2) Now do the same using conventional loops (you can shoose to do this 
# before 1 !). 

# ANNOTATE WHAT EVERY BLOCK OR, IF NECESSARY, LINE IS DOING! 

# ALSO, PLEASE INCLUDE A DOCSTRING AT THE BEGINNING OF THIS FILE THAT 
# SAYS WHAT THE SCRIPT DOES AND WHO THE AUTHOR IS

#!/usr/bin/python

"""Description of this program
	you can use several lines"""

## List comprehension that creates three different lists containing the
# latin names, common names and mean body mass for each bird species

birds = ( ('Passerculus sandwichensis','Savannah sparrow',18.7), 
          ('Delichon urbica','House martin',19),
          ('Junco phaeonotus','Yellow-eyed junco',19.5),
          ('Junco hyemalis','Dark-eyed junco',19.6),
          ('Tachycineata bicolor','Tree swallow',20.2),
         )

#1. Latin names
##Using for loops
latin_loops = set() #Creating an empty set, which will get filled later with species name
for species in birds: #defining everthing between each (tuple) as species
	latin_loops.add(species[0])
print latin_loops


##Using list comprehension
latin_lc = set([species[0] for species in birds]) #Creating and empty set and calling the zeroth element in each tuple (which is each species) for species within birds
print latin_lc

#2. Common names
#using loops
common_loops = set()
for species in birds: #essentially calling each tuple in the list
	common_loops.add(species[1]) #add the second(common) element in each tuple(species) in the list(birds)
print common_loops

#using list comprehension
common_lc = set([species[1] for species in birds])
print common_lc

#3. Mean body mass
mean_loops = set()
for species in birds:
	mean_loops.add(species[2])
print mean_loops

mean_lc = set([species[2] for species in birds])
print mean_lc





