#!usr/bin/python

"""Chapter 6.9.2 Running R"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '2.7.14'

import subprocess

subprocess.Popen("/usr/lib/R/bin/Rscipt --verbose TestR.R > \
../Results/TestR.Rout 2> ../Results/TestR_errFile.Rout", \
shell=True).wait()
