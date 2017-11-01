rm(list=ls())

stochrick<-function(p0=runif(1000,.5,1.5),r=1.2,K=1,sigma=0.2,numyears=100)
{
  #vectorize an entire row 
  #initialize
  N<-matrix(NA,numyears,length(p0)) 
  N[1,]<-p0 

#then it starts looping through the p0 (initial vector)
#  for (pop in 1:length(p0)) #cycles through the pop
#  {
#for each population subset, it works out the population number for the next year - up to a 100 years
    for (yr in 2:numyears) #for each pop, loop through the years
    {
      N[yr,]<-(N[yr-1,]*exp(r*(1-N[yr-1,]/K)+rnorm(1,0,sigma))) #add random error in the population rnorm(1,0,stigma)
    }
 # }
  return(N)
}

print("Vectorized Stochastic Ricker takes:")
print(system.time(res2<-stochrick()))

#vectorize this script to make it faster using the apply functions
# - it is currently using loops

#get rid of loop between 15 and 17
#generate random numbers in a vectorized way
#N is the matrix