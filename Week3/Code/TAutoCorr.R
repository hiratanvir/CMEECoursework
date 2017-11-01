#!/usr/bin/env Rscript
rm(list=ls())

load("../Data/KeyWestAnnualMeanTemperature.RData")
plot(ats)

#Creating two set of vectors
first_set<-ats[1:99,2] #t-1 (x)
second_set<-ats[2:100,2] #t (y)

require(ggplot2)
pdf("../Code/TAutoCorrGraph.pdf")
Corr <- data.frame(first_set, second_set)
A<-qplot(second_set, first_set, data=Corr,
         main="Correlation of one years temperature with successive years, across the years",
         xlab="Temperature, t-1 (ºC)",
         ylab="Temperature, t (ºC)")
A <- A + theme_bw() + geom_smooth(method="lm", fullrange=TRUE) + theme(plot.title = element_text(hjust = 0.5))
print(A)
dev.off()

#step 1
true_cor<-cor(first_set,second_set)

#randomly sample the second set and re-calculate cor against the first set
#for loop

#step 2 - Computes the correlation between a sequential time series (1-99 yrs) and random permutations
#of 99 years - by doing this we can see if there is a correlation between sequential 1-99
Temp_vector<-vector(length=10000, mode="numeric") #creating a numeric empty vector of length of 10000
for(i in 1:10000) { #for in in 1 to 10000, take a random sampke of second_set and compare it with first_set
  x<-sample(second_set,replace=FALSE)
  Temp_vector[i]<-cor(first_set,x)
}

#Calculating what fraction of correlation coefficients
#from step 2 were greater than that from step 1 (approximate p-value)
# you can reject the p-value which hypothesises that both sequential time series and 
#random permutations are correlated
approx_p_value<-sum(Temp_vector > true_cor)/10000
print(approx_p_value)

