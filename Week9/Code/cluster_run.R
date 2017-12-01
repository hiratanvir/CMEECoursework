#!/usr/bin/env Rscript

rm(list=ls())
graphics.off()

#Simulations using HPC

#17. Question 17

#1. Create a function for species_richness that measures species richness for 'community'
species_richness <- function(community){
  length(unique(community))
}

#2.
initialise_min <- function(size){
  seq(1, 1, length=size)
}

#3. Function chooses random number from a uniform distribution between 1 and x, & then
# chooses a second random number which is not equal to the first & returns it to a vector of length 2.
choose_two <- function(x){
  sample(x, size=2, replace=FALSE, prob=NULL)
}
#choose_two(4) should return once any combination of the numbers between 1 and 4

#4. 
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

#5.
neutral_generation_speciation <- function(community, v){
  generation= round(length(community)/2)
  for(i in 1:generation){
    new_community = neutral_step_speciation(community, v)
    community = new_community
  }
  return(new_community)
}

#6.
species_abundance <- function(community){
  abundances = as.numeric(table(community))
  return(abundances)
}

#7.
octaves <- function(a){
  oct_classes = tabulate(floor(log2(a))+1)
  return(oct_classes)
}

#CLUSTER RUN
cluster_run <- function(speciation_rate=0.1, size=100, wall_time=10, interval_rich=1, interval_oct=10, burn_in_generations=200, output_file_name="my_test_file_1.rda"){
  
  n=0 #generation counter which is intially set at 0
  richness = vector()
  community = initialise_min(size)
  octavelist <- list()
  start = proc.time()[3] #pulls out fixed 'time-now'
  
  while(proc.time()[3] - start < wall_time*60){
    community <- neutral_generation_speciation(community, speciation_rate)
    n = n + 1 
    
    #collect species richness for every interval of 1 
    if ((n < burn_in_generations) && (n %% interval_rich == 0)){
        richness <- c(richness, species_richness(community))
      }
    
    #for every 10 generations, adds octaves to octave list
    if(n %% interval_oct == 0){
      octavelist <- c(octavelist, list(octaves(species_abundance(community)))) 
    }
  }
  
  real_time = as.numeric(proc.time()[3])
  save(richness, octavelist, community, real_time, speciation_rate, size, wall_time, interval_rich, burn_in_generations, file=output_file_name)
  
}
  
#cluster_run(0.1, 100, 10, 2, 10, 200)

#18. Writing a raw function

#iter <- as.numeric(Sys.getenv("PBS_ARRAY_INDEX"))

iter = 1
set.seed(iter)

j = 5000

if(iter <= 25){
  j = 500
}

if((iter>25)&&(iter<=50)){
  j = 1000
}

if((iter>50)&&(iter<=75)){
  j = 2500
}

output_file_name = paste0("annoying_script",iter,".rda")                
cluster_run(speciation_rate=0.1 , size = j, wall_time=1, interval_rich=1, interval_oct=j/10, burn_in_generations=8*j, output_file_name)
#load("annoying_script1.rda")
