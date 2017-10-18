import csv
import sys
import pdb
import doctest

#Define function
def is_an_oak(name):
    """ Returns True if name is starts with 'quercus '
        >>> is_an_oak('quercus')
        True

        Returns False if name starts with 'pinus '
        >>> is_an_oak('pinus')
        False

        >>> is_an_oak('quercuss')
        False
    """
    return name.lower() == 'quercus' #return in the lower case any species that starts with quercus
    #First bug: Identified as a space after 'quercus ', this meant it was looking for words starting with quercus including a space
    #Second bug: Identified as 'startswith('quercus ')' after return name.lower(), this statement identifies any...
    #...word that includes 'quercus' as part of it, rather than a single word on its own
    
print(is_an_oak.__doc__)

def main(argv): 
    f = open('../Data/TestOaksData.csv','rb') #rb - read binary. Third Bug: Removed extra '../' as we're already in codes
    g = open('../Data/JustOaksData.csv','wb') #wb - write binary & g is the file we're writing
    taxa = csv.reader(f) 
    csvwrite = csv.writer(g)
    oaks = set()
    for row in taxa:
        print row
        print "The genus is", row[0]
        if is_an_oak(row[0]):
            print row[0]
            print 'FOUND AN OAK!'
            print " "
            csvwrite.writerow([row[0], row[1]])    
    
    return 0
    
if (__name__ == "__main__"):
    status = main(sys.argv)

doctest.testmod()
