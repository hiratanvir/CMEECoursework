#!/usr/bin/env Rscript

rm(list=ls())
graphics.off()

#Neutral Theory Simulations

#1. Create a function for species_richness that measures species richness for 'community'
species_richness <- function(community){
  length(unique(community))
}

community <- c(1,4,4,5,1,6,1)
species_richness(community) #should return 4.

#2. Function to generate an initial state for your simulation community with the max possible
# number of species for the community of the size given by the input number variable 'size'
initialise_max <- function(size){
  seq(1, size)
}
#size <- 7
#initialise_max(size) should return '1 2 3 4 5 6 7'

#3. Initial state function that generates alternative initial state for your simulation of a
# certain size with the minimum possible number of species
initialise_min <- function(size){
  seq(1, 1, length=size)
}
#size = 7
#initialise_min(size)

#4. Function chooses random number from a uniform distribution between 1 and x, & then
# chooses a second random number which is not equal to the first & returns it to a vector of length 2.
choose_two <- function(x){
  sample(x, size=2, replace=FALSE, prob=NULL)
}
#choose_two(4) should return once any combination of the numbers between 1 and 4

#5. Perform a single step of a simple neutral model simulation, withoit speciation,
#on a community vector
neutral_step <- function(community){
  indexes <- length(community) #you need to find the length of community
  value <- choose_two(indexes) #randomly sample two indexes from the community
  community[value[1]] = community[value[2]] #replace the randomly chosen value with another value
  return (community)
}
#community <- c(10,5,13)
#neutral_step(community)

#6. Function to simulate several neutral_steps on a community so that a generation has 
# passed.
neutral_generation <- function(community){
  generation= round(length(community)/2)
  for (i in 1:generation){
    community=neutral_step(community)
  }
  return(community)
}
neutral_generation(c(1,4,4,1,5,1,6))

#7. Function returns species richness at each generation, over the course of the duration specified

neutral_time_series <- function(initial, duration){
  list = vector() 
  list[1] = species_richness(initial)
  for(i in 1:duration){
  initial <- neutral_generation(initial) #for each generation
  list[i+1] <- species_richness(initial) #add to list, the species richness for that generation
  
  }
  return (list)
}
#neutral_time_series(initial = initialise_max(7), duration = 20)  

#8. 
question_8 <- function(size=100, generation=200){
  SpeciesRich = neutral_time_series(initialise_max(size), duration = generation)
  gen = seq(0, generation, 1)
  
  plot(SpeciesRich~gen, xlab="generation", ylab="Species Richness", main="Neutral model simulation")
}
#question_8()

#9. 
neutral_step_speciation <- function(community, v){
  prob = runif(1, 0, 1) #gives a single random probability from the range 0 to 1
  if(v<prob){
  index = choose_two(length(community)) #this returns 2 positions from community to use as points to swap at random in a community
  community[index[1]] = community[index[2]] #you're picking an index(the nth item of a species) out of the community and replacing that in index 2
  }
  else{
  new_species = max(community) + 1
  index = sample((length(community)), size=1, replace = TRUE)
  community[index] = new_species
  }
return(community)
  }

neutral_step_speciation(community, 0.2)

#10. 
neutral_generation_speciation <- function(community, v){
  generation= round(length(community)/2)
  for(i in 1:generation){
    new_community = neutral_step_speciation(community, v)
    community = new_community
  }
  return(new_community)
}
neutral_generation_speciation(community, 0.2)

#11. This function returns the species richness for each generation up to the duration with speciation - which is why the list shows 
#fluctuations of species richness (going up and down) because sometimes a new species is added if/when v<prob
neutral_time_series_speciation <- function(community, v, duration){
  list = vector() 
  list[1] = species_richness(community)
  for(i in 1:duration){
    community <- neutral_generation_speciation(community, v) #for each generation
    list[i+1] <- species_richness(community) #add to list, the species richness for that generation
    
  }
  return (list)
}
neutral_time_series_speciation(community, 0.2, 20)

#12. Community size = J
question_12 <- function(J=100, v=0.1, generation=200){
  Initial_Max = neutral_time_series_speciation(community=initialise_max(J), v=0.1, duration=generation)
  Initial_Min = neutral_time_series_speciation(community=initialise_min(J), v=0.1, duration=generation)
  gen = seq(0, generation, 1) #from 0 to generation, with intervals of 1
  
  plot(Initial_Max~gen, type="l", col="red", ylim=range(c(Initial_Max, Initial_Min)), xlab="Generation", ylab="Species Richness", main="Neutral Simulation with Speciation")
  par(new=T)
  plot(Initial_Min~gen, type="l", col="blue", ylim=range(c(Initial_Max, Initial_Min)), xlab="Generation", ylab="Species Richness") 
  
  legend("topright", c("Initial Maximum state", "Initial Minimun state"), lty=c(1,1), lwd=c(1.5,1.5), col=c("red", "blue"))
}
#question_12()

#13. 
species_abundance <- function(community){
  abundances = as.numeric(table(community))
  return(abundances)
}
species_abundance(community)

