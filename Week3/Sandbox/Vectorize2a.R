# Runs the stochastic (with gaussian fluctuations) Ricker Eqn .

rm(list=ls()) #this removes everything and starts from nothing - good habit
#run if is a command within a function that is 
#generating 1000 numbers between the range of 5 and 1.5, they represent the 
#initial population
#p0 - vector of initial pop sizes
#r = growth rate and K = carrying capacity = parameters
#sigma = c parameter - for every time step, adds a normal distribution, if you want to have more 
#fluctuations - increase sigma
stochrick<-function(p0=runif(1000,.5,1.5),r=1.2,K=1,sigma=0.2,numyears=100)
{
  #vectorize an entire row 
  #initialize
  N<-matrix(NA,numyears,length(p0)) 
  N[1,]<-p0 #put p0 in the first vector made

#then it starts looping through the p0 (initial vector)
  for (pop in 1:length(p0)) #loop through the populations
  { #instead of going through each(1) pop upto a 1000 - go through entire row
#for each population subset, it works out the population number for the next year - up to a 100 years
    for (yr in 2:numyears) #for each pop, loop through the years
    {
      N[yr,pop]<-N[yr-1,pop]*exp(r*(1-N[yr-1,pop]/K)+rnorm(1,0,sigma)) #add random error in the population rnorm(1,0,stigma)
    }
  }
  return(N)
}

# Now write another code called stochrickvect that vectorizes the above 
# to the extent possible, with improved performance: 

print("Vectorized Stochastic Ricker takes:")
print(system.time(res2<-stochrick()))

#vectorize this script to make it faster using the apply functions
# - it is currently using loops

#get rid of loop between 15 and 17
#generate random numbers in a vectorized way