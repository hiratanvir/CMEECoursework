rm(list(ls))
library(dplyr)
library(ggplot2)
library(reshape2)

#Hardy-Weinberg equation p2 + 2pq + q2 = 1
#the sum of the allele frequencies for all the alleles at the locus must be 1, 
#so p + q = 1.
g<- read.table(file="H938_chr15.geno", header=TRUE) #Loads in file

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