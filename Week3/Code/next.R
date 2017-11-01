#!/usr/bin/env Rscript
rm(list=ls())

for (i in 1:10) {
	if ((i %% 2) == 0)
		next # pass to next iteration of loop
	print(i)
}

#if i %% 2 == 0 meaning if the remainder of i/2 
#is comparable to 0 then skip that i?

#This script checks if a number is odd using 
#the “modulo” operation and prints if it is.