#!/usr/bin/python
# Filename: align_seqs.py

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '0.0.1'

# These are the two sequences to match
import csv #module allows script to read csv files when run in python
import sys

#This section tells us that the script has a default relative path which uses "../Data/align.csv' as the sole argument"
#However, you can also run this script other .csv files because you are providing it with another argument (>1)
def file_function(arguments): 
    if len(arguments) > 1:
        print "more than one argument given, assigning relative path to given path"
        return str(arguments[1])
    else:
        print "script called as sole argument, using default relative path"
        return str('../Data/align.csv')

# function that computes a score
# by returning the number of matches 
# starting from arbitrary startpoint
def calculate_score(s1, s2, l1, l2, startpoint):
    # startpoint is the point at which we want to start
    matched = "" # contains string for alignement
    score = 0
    for i in range(l2):
        if (i + startpoint) < l1:
            # if its matching the character
            if s1[i + startpoint] == s2[i]: #if a sequence at from the start of s1 matches s2, then it is matched 
                matched = matched + "*" #creating a variable that marks the location with "*" where two characters from each sequence match 
                score = score + 1 #
            else:
                matched = matched + "-" #otherwise creating a variable which can be outputted to mark unmatched sequences with "-"

    # build some formatted output
    print "." * startpoint + matched           
    print "." * startpoint + s2
    print s1
    print score 
    print ""

    return score

#In this main argument, 
#we are creating a function to open and read the csv file and looping through rows to print out the rows 
def main(arguments): 
    filename = file_function(arguments)
    f = csv.reader(open(filename, 'r'))
    for row in f:
        seq1 = row[0]
        seq2 = row[1]
    print seq1
    print seq2

    #seq2 = "ATCGCCGGATTACGGG"
    #seq1 = "CAATTCGGAT"

    # assigning the longest sequence s1, and the shortest to s2
    # l1 is the length of the longest, l2 that of the shortest

    l1 = len(seq1)
    l2 = len(seq2)
    if l1 >= l2:
        s1 = seq1
        s2 = seq2
    else:
        s1 = seq2
        s2 = seq1
        l1, l2 = l2, l1 # swap the two lengths

    """
    calculate_score(s1, s2, l1, l2, 0)  
    calculate_score(s1, s2, l1, l2, 1)
    calculate_score(s1, s2, l1, l2, 5)
    """
    # now try to find the best match (highest score)
    my_best_align = None  #When the best aligned sequence is found, it overrides 'None'
    my_best_score = -1    #When the best score of the sequence is found, it overrides -1

    for i in range(l1):
        z = calculate_score(s1, s2, l1, l2, i)
        if z > my_best_score:
            my_best_align = "." * i + s2
            my_best_score = z

    print my_best_align
    print s1
    print "Best score:", my_best_score

    """This function creates and writes the results of the best aligned sequence, best score and s1 into a file called aligned_seq.txt"""
    g = open('../Results/aligned_seq.txt', 'w')
    g.write(s1 + '\n')
    g.write(my_best_align + '\n')
    g.write(str(my_best_score))
    g.close()

    return 0

if (__name__ == "__main__"):
    status = main(sys.argv)
