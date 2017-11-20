#!usr/bin/python

"""Chapter 6.10 Practical - Using is problem 2"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '2.7.14'

import subprocess
import os

# SUBPROCESS CALL
a = subprocess.Popen("Rscript --verbose fmr.R", shell=True).wait()
#Popen should print 0 as a if process is successful, if it prints 127 then it
#means that there is an error in locating the file.
#Since fmr.R is also in code, you do not need to give it a relative path

# R CONSOLE OUTPUT PRINTED TO PYTHON CONSOLE
if a == 0:               # SUBPROCESS SUCCESSFUL
    print 'SUCCESSFUL'
else:                               # SUBPROCESS FAILED
    print 'FAILED'
