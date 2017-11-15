rm(list=ls())
library(dplyr)
library(ggplot2)
library(reshape2)

#Hardy-Weinberg equation p2 + 2pq + q2 = 1
#the sum of the allele frequencies for all the alleles at the locus must be 1, 
#so p + q = 1.
g<- read.table(file="../Data/H938_chr15.geno", header=TRUE) #Loads in file

dim(g) #Tells you the amount of data in the file

#How many SNPs are there? Calculates the number of counts at each locus
#Using the mutate function from dplyr library to do the addition &
#adding a new column to the dataframe in one step
g<- mutate(g,nObs = nA1A1 + nA1A2 + nA2A2)
#nObs - the total number of observation for each gene
 
head(g)
summary(g$nObs)

qplot(nObs, data=g)

#Question: Do most of the SNPs have complete data? Yes, as it shows the highest histogram peak in the graph
#Question: What is the lowest count observed? 887.0

#Calculating genotype and allele frequencies

#Compute genotype frequencies
g <- mutate(g, p11 = nA1A1/nObs, p12 = nA1A2/nObs, p22=nA2A2/nObs)

#Compute allele frequencies from genotype frequencies
#p11 is homozygous and p12 heterozygous
g<- mutate(g, p1= p11 + 0.5*p12, p2 = p22 + 0.5*p12)

head(g)

qplot(p1, p2, data=g)

#Plotting genotype on allele frequencies using ggplot2 commands

gTidy <- select(g, c(p1, p11, p12, p22)) %>%
  melt(id='p1', value.name = "Genotype.Proportion")

head(gTidy)
dim(gTidy)

ggplot(gTidy)+geom_point(aes(x=p1, 
                             y=Genotype.Proportion, 
                             color=variable,
                             shape=variable))

#Plotting the Hardy-Weinberg proportions:
ggplot(gTidy) + geom_point(aes(x=p1, y=Genotype.Proportion, color=variable, shape=variable)) +
  stat_function(fun=function(p) p^2, geom="line", colour="red", size=2.5) +
  stat_function(fun=function(p) 2*p*(1-p), geom="line", colour="green", size=2.5) +
  stat_function(fun=function(p) (1-p)^2, geom="line", colour="blue", size=2.5)

#Hardy-weinberg:  p2 + 2pq + q2 = 1
#p2 = p*p
#q2 = (1-p)*(1-p)
#2pq = 2 * p * (1-p)

#Testing Hardy Weinberg
g <- mutate(g, X2 = (nA1A1-nObs*p1^2)/(nObs*p1^2) + 
              (nA1A2-nObs*2*p1*p2)^2/(nObs*2*p1*p2) + 
              (nA2A2-nObs*p2^2)^2 / (nObs*p2^2))

g <- mutate(g,pval = 1-pchisq(X2,1))

#The problem of multiple testing
head(g$pval)

#How many tests have p-values less than 0.05?
sum(g$pval < 0.05, na.rm = TRUE)

#Result from Fisher is that under the null hypothesis the
#p-values of a well-designed test should be distributes uniformaly
#between 0 and 1.
qplot(pval, data=g)

#Plotting expected vs observed heterzygosity
qplot(2*p1*(1-p1), p12, data=g) + geom_abline(intercept = 0, slope=1, color="red", size=1.5)
#Most of the points fall below the y=x line. 
#That is, we see a systematic deficiency of heterozygotes (and this implies a concordant excess of homozygotes). 
#This general pattern is contributing to the departure from HW seen in the χ2 statistics.

#Plotting average deficiency heterozygotes relative to expected proportions
#Create another column & calculate the deficiency of each row,
#Then find out the mean and plot it
g <- mutate(g, F=(2*p1*(1-p1)-p12)/2*p1*(1-p1))
head(g)
mean(g$F)
plot(g$F, xlab="SNP numbers")
#The mean is <10%, so the difference between observed vs expected average deficiency 
#of heterozygotes is not significant and human pop is not very structured - not very varied

movingavg <- function(x, n=5){stats::filter(x, rep(1/n,n), sides=2)}
plot(movingavg(g$F), xlab="SNP number")

outlier=which(movingavg(g$F)==max(movingavg(g$F), na.rm=TRUE))
g[outlier,]
