#!/usr/bin/env Rscript

rm(list=ls())
graphics.off()

#Neutral Theory Simulations

#1. Function for species_richness measures species richness for 'community'. 
# It returns the number of different types of species that are present in a community.
species_richness <- function(community){
  length(unique(community))
}

#For example, for community <- c(1,4,4,5,1,6,1), species_richness(community) #should return 4.

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

#5. Perform a single step of a simple neutral model simulation, without speciation,
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
# passed and returns the state of the community without speciation - after a species has died and has been
# replaced by another species already present.
neutral_generation <- function(community){
  generation= round(length(community)/2)
  for (i in 1:generation){
    community=neutral_step(community)
  }
  return(community)
}
#neutral_generation(c(1,4,4,1,5,1,6))

#7. Function returns species richness in a community at each generation, 
# over the course of the duration specified

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
#Function introduces new species to replace the one that has died in the current community if the speciation rate is below random probability
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

#neutral_step_speciation(community, 0.2)

#10. 
# Function is similar to neutral_step_speciation, however returns the state of the new community after a generation has passed
neutral_generation_speciation <- function(community, v){
  generation= round(length(community)/2)
  for(i in 1:generation){
    new_community = neutral_step_speciation(community, v)
    community = new_community
  }
  return(new_community)
}
#neutral_generation_speciation(community, 0.2)

#11. This function returns the species richness for each generation up to the duration with speciation occuring - which is why the list shows 
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
#neutral_time_series_speciation(community, 0.2, 20)

#12. Community size = J
#Function returns the species richness at each generation for a community starting
# at a maximum species richness state and another community starting at a mimumin species richness
# and the function plots the species richness for the two communities on a line graph
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
#Function returns a list of the number of individuals of each species that are present
#in the community in decreasing order. 
species_abundance <- function(community){
  abundances = as.numeric(table(community))
  return(sort((abundances), decreasing = TRUE))
}
#species_abundance(community)

#14. 
#Function returns a list of frequencies of abundancies for each bin size
# i.e the first element will tell you the number of species with an abundance of 1 in a community
# the second element in the octavelist will tell you the number of species with an abundance of
# 2 or 3 in a community, and so on.
octaves <- function(a){
  oct_classes = tabulate(floor(log2(a))+1)
  return(oct_classes)
}
#a = species_abundance(community)
#octaves(a)
#o = octaves(a)

#15. 
# sum_vect adds the length of two vectors together without  repeating
# the length of a shorter vector to complete the addition.
sum_vect <- function(x, y){
  n <- max(length(x), length(y))
 if (length(x) < length(y)){
   x = c(x, rep(0, length(y)-length(x)))
   sum = x + y
 }
 else if (length(x) > length(y)){
   y = c(y, rep(0, length(x)-length(y)))
   sum = x + y
 }
 else {
   sum = x + y
 } 
  return (sum)
}

#x <- c(1, 2, 3, 4, 5, 6)
#y <- c(1, 2, 3)

#sum_vect(x, y)

#16. 
question_16 <- function(J=100, v=0.1, generation = 2000, burnin= 200){
  Initial_Min = initialise_min(J)
  octavelist <- list()
  for(i in 1:burnin){
    Initial_Min <- neutral_generation_speciation(Initial_Min, v)
  }

  #appending octaves at current time to our list of octaves
  for(i in 1:generation){
    Initial_Min <- neutral_generation_speciation(Initial_Min, v)
    #for every 20 generations, adds octaves to octave list
    if(i %% 20 == 0){
      octavelist <- c(octavelist, list(octaves(species_abundance(Initial_Min)))) 
    }
  }
  
  total_octaves = vector()
  for(i in 1:length(octavelist)){
    total_octaves <- sum_vect(total_octaves, octavelist[[i]])
  }
    
  mean_octaves <- total_octaves/(length(octavelist)) #the length(octavelist) equals the number of times an octave is noted
  #print(mean_octaves) #make a bar plot of these values
  
  barplot(mean_octaves, main ="Average Species Abundance Distribution(as octaves)",
          xlab = "Average Species Abundance Octaves",
          ylab = "Avergae Count",
          names.arg = c("1", "2-3", "4-7", "8-15", "16-31", "32-63"),
          col = "darkred")
}

#question_16() tells you how many species have an abundance of 1, 2-3, 4-7, etc.


### SIMULATIONS USING HPC ###

#17. Code to be run on cluster written in 'cluster_run.R'
cluster_run <- function(speciation_rate=0.1, size=100, wall_time=10, interval_rich=1, interval_oct=10, burn_in_generations=200, output_file_name="my_test_file_1.rda"){
  
  n=0 #generation counter which is intially set at 0
  richness = vector()
  community = initialise_min(size)
  octavelist <- list()
  start = as.numeric(proc.time()[3]) #pulls out fixed 'time-now'
  
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

#18. R code to run simulation for different community sizes written in file 'cluster_run.R'.

#19. Shell script for running code on cluster written in file 'rtocluster.sh'.

#20. Loading in and plotting data from HPC simulation 

Load_cluster <- function(){

  file_path <- ("../Data/cluster_result")
  
  total_octaves500 = vector()
  total_octaves1000 = vector()
  total_octaves2500 = vector()
  total_octaves5000 = vector()
  
  #initialising counter for each community size
  counter500 = 0
  counter1000 = 0
  counter2500 = 0
  counter5000 = 0 
  
  for(i in 1:100){
    output_data = paste(file_path, i, ".rda", sep="")
    load(output_data)
    interval_oct = size/10
    burn_in_generations = 8*size
    
    if(size==500){
      #only loading in the octavelist results for generations AFTER the burn-in period of 8*size
      for(n in ((burn_in_generations/interval_oct)+1):length(octavelist)){
        total_octaves500 <- sum_vect(total_octaves500, octavelist[[n]]) #calculating the sum of the octaves list for the community size of 500.
        counter500 = counter500+1
      }
    }
  
    if(size==1000){
      for(n in ((burn_in_generations/interval_oct)+1):length(octavelist)){
        total_octaves1000 <- sum_vect(total_octaves1000, octavelist[[n]])
        counter1000 = counter1000+1
      }
    }
    
    if(size==2500){
      for(n in ((burn_in_generations/interval_oct)+1):length(octavelist)){
        total_octaves2500 <- sum_vect(total_octaves2500, octavelist[[n]])
        counter2500 = counter2500+1
      }
    }
    
    if(size==5000){
      for(n in ((burn_in_generations/interval_oct)+1):length(octavelist)){
        total_octaves5000 <- sum_vect(total_octaves5000, octavelist[[n]])
        counter5000 = counter5000+1
      }
    }  
  }  
  
  #Calculating the average octave results for each community size by dividing the sum of the total octaves
  # by the total number of octave lists for each community size
  total_octaves500 = total_octaves500/counter500
  total_octaves1000 = total_octaves1000/counter1000
  total_octaves2500 = total_octaves2500/counter2500
  total_octaves5000 = total_octaves5000/counter5000
  
  #plotting the results for the average octaves for each community size on a bar plot
  par(mfrow=c(2,2))
  
  barplot(total_octaves500, main ="Average Species Abundance Distribution for community size(J) = 500",
          xlab = "Average Species Abundance Octaves",
          ylab = "Avergae Count",
          names.arg = c("1", "2-3", "4-7", "8-15", "16-31", "32-63","64-127","128-255","256-511"),
          col = "darkred")
  
  barplot(total_octaves1000, main ="Average Species Abundance Distribution for community size(J) = 1000",
          xlab = "Average Species Abundance Octaves",
          ylab = "Avergae Count",
          names.arg = c("1", "2-3", "4-7", "8-15", "16-31", "32-63","64-127","128-255","256-511","512-1023"),
          col = "darkred")
  
  barplot(total_octaves2500, main ="Average Species Abundance Distribution for community size(J) = 2500",
          xlab = "Average Species Abundance Octaves",
          ylab = "Avergae Count",
          names.arg = c("1", "2-3", "4-7", "8-15", "16-31", "32-63","64-127","128-255","256-511","512-1023","1024-2047"),
          col = "darkred")
  
  barplot(total_octaves5000, main ="Average Species Abundance Distribution for community size(J) = 5000",
          xlab = "Average Species Abundance Octaves",
          ylab = "Avergae Count",
          names.arg = c("1", "2-3", "4-7", "8-15", "16-31", "32-63","64-127","128-255","256-511","512-1023","1024-2047"),
          col = "darkred")
}




### FRACTALS IN NATURE ###

#22. The chaos game

plot.new()
plot.window(xlim=c(0,5), ylim=c(0,5))

# Initialising triangle
a <- c(0,0)
b <- c(3,4)
c <- c(4,1)

list <- list(a, b, c)


#Initialising starting co-ordinates
vec_x <- c(0,0)
points(vec_x[1], vec_x[2], cex=0.5)

# Chaos game - sampling the list for random co-ordinates and creating (x,y) as new starting co-ordinates
# which result from the mid-point of the starting co-ordinates(vec_x) and randomly chosen points from list
# and iterating the loop 10000 times to produce a fractal image.

chaos_game <- function(){
  for(n in 1:10000){
    n <- list[[sample(1:3, 1)]]
    x <- (vec_x[1]+(n[1]-vec_x[1]) / 2)
    y <- (vec_x[2]+(n[2]-vec_x[2]) / 2)
    vec_x <- c(x,y)
    points(x, y, cex = 0.5, col="thistle4")
  }
}


#23. 

#plot.new()
#plot.window(xlim= c(-50,100), ylim = c(-50,100))

# Draws a line of a given length from a single point & returns a vector of the endpoint
turtle <- function (start_position, theta , length)
{
  opposite = sin(theta) * length
  adjacent = cos(theta) * length
  x2 = start_position[1] + adjacent
  y2 = start_position[2] + opposite
  lines(c(start_position[1], x2), c(start_position[2], y2))
  return(c(x2, y2))
}

#24. 
# Elbow draws a pair of lines that join together, with the second line being shorter than the
# previous line and being drawn at an angle of 45 degrees to the right of the previous line.
elbow <- function(start_position, theta, length)
{
  output1 <- turtle(start_position, theta, length)
  output2 <- turtle(output1, theta-pi/4, length*0.95) #45 degrees to the right of the line
}


#25. 
# Spiral calls turtle to draw a line of a given length and then calls spiral again to connect a second
# line of a shorter length to the first at an angle and calls the function iteratively to form a spiral
spiral <- function(start_position, theta, length)
{
  output1 <- turtle(start_position, theta, length) #piping the output of that function into an object
  output2 <- spiral(output1, theta-pi/4, length*0.95)
}

#plot.new()
#plot.window(xlim= c(-25,50), ylim = c(-25,50))
#spiral(c(-25,-15), pi/2, 30)

#26.
# Spiral_2 only accepts lines above a given length by putting an if statement into the function.
# It will draw lines forming a spiral for each loop
# but the function will stop drawing lines once the length is below a certain value
spiral_2 <- function(start_position, theta, length)
{
  if(length >= 0.5){
    output1 <- turtle(start_position, theta, length) 
    output2 <- spiral_2(output1, theta-pi/4, length*0.95)
  }
  else{
    return(NULL)
  }
}

#27. 
# For each line drawn, the function connects a shorter line going 45 degrees to the right and another shorter line 
# which goes 45 degrees to the left and function calls itself iteratively to produce a tree image
tree <- function(start_position, theta, length)
{
  if(length >= 0.5){
    output1 <- turtle(start_position, theta, length) 
    output2 <- tree(output1, theta-pi/4, length*0.65)
    output3 <- tree(output1, pi/4+theta, length*0.65)
  }
}

#28.
# For each line drawn by turtle, the function fern draws a short line going straight up 
# and another shorter line going 45 degrees to the left, forming a branches to build a fern image
fern <- function(start_position, theta, length)
{
  if(length >= 0.15){
    output1 <- turtle(start_position, theta, length) 
    output2 <- fern(output1, theta, length*0.87)
    output3 <- fern(output1, pi/4+theta, length*0.38)
  }
}

#plot.new()
#plot.window(xlim= c(-50,100), ylim = c(-50,100))
#fern(c(0,-50), pi/2, 20)

#29.
# fern_2 creates a similar image to fern, except the argument dir decides whether
# the branches of the fern are drawn left or right depending on whether dir is 1 or -1
fern_2 <- function(start_position, theta, length, dir)
{
  if(length >= 0.1){
    output1 <- turtle(start_position, theta, length)
    output2 <- fern_2(output1, theta, length*0.87, -dir)
    output3 <- fern_2(output1, (dir*pi/4)+theta, length*0.38, dir)
  }
}


#plot.new()
#plot.window(xlim= c(-50,100), ylim = c(-50,100))
#fern_2(c(20, -35), pi/2, 15, 1)
