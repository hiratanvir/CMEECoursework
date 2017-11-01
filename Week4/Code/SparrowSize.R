rm(list=ls()) #Clear your workspace at the beginning of each session,
# and between different parts of a project.

library(lme4)
require(lme4)
# require is used inside functions, as it outputs a warning &
# continues if the package is not found, 
# lwhereas library will throw an error.

d<-read.table("SparrowSize.txt", header=TRUE) #importing data
str(d)

#In r when you click run, it runs that line
#To run the whole script, you can highlight it and click run
#In this case, you had to run d on the command line first
#for it to identify the object d.
#It is better to run command line by line to see what each function does