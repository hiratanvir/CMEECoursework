#!/bin/bash
# Author: Hira hira.tannvir@imperial.ac.uk
# Script: csvtospace.sh
# Desc: Coverts comma separated values to a space separated values file
# saves the output into a .txt file
# Arguments: 1-> tab delimited file
# Date: Oct 2017
echo "Create space delimited version of $1 ..."
cat $1 | tr -s "," " " >> $1.txt
echo "Done!"
exit