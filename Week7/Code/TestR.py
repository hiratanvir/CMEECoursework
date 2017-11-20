#!usr/bin/python

import subprocess

subprocess.Popen("/usr/lib/R/bin/Rscipt --verbose TestR.R > \
../Results/TestR.Rout 2> ../Results/TestR_errFile.Rout", \
shell=True).wait()
