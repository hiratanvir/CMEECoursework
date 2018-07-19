#!/usr/bin/env Rscript
rm(list=ls())
graphics.off()
require(ggplot2)
library(dplyr)
library(reshape2)
library(scales)
require(gridExtra)

#load in TPC data set to get the x and y co-ordinates per group
df <- read.csv("../Data/bacteria_subset.csv")
DF = df %>% group_by(uniqueID) %>% arrange(uniqueID) #orders the ID in ascending order

#load in the nlls results for the full schoolfield model and plot the results on the same ggplot2 graph
schoolfield_df <- read.csv("../Results/bacteria_schoolfield_params.csv")


#function returns a dataframe with with x values and expected y values when using the schoolfield model
schoolfield <- function(i, schoolfield_df, DF){
  
  sfdf = subset(schoolfield_df, ID == i)
  DF2 = subset(DF, uniqueID == i)
  
  x_vals <- DF2$Temp.kel.
  #y_vals <- DF$log_TraitValues
  
  if(sfdf$status =="C"){
    #parameter values for the Schoolfield model
    B0 <- sfdf$B0
    E <- sfdf$E
    Eh <- sfdf$Eh
    El <- sfdf$El
    Th <- sfdf$Th
    Tl <- sfdf$Tl 
    
    # Define k, Boltzmann constant
    k = 8.6173303e-05
    
    #get a large number of equidistant points between the actual x points
    x_points = seq(min(x_vals),max(x_vals),0.2)
    
    #get the corresponding y_values from the sampled x_points using the model equation
    schoolfield_model <- ((B0*exp((-E/k)*((1/x_points)-(1/283.15)))) / (1 + (exp((El/k)*((1/Tl)-(1/x_points)))) + (exp((Eh/k)*((1/Th)-(1/x_points))))))
    
    
    temp <- data.frame(ID=as.character(i), x_points, schoolfield_model)
    return(temp)
  }
  
  else{
    print("Model did not converge..")
    return(NULL)
  }
}

#initialising empty dataframe to append curve points for each id 
bacteria_df <- data.frame(matrix(ncol = 3, nrow = 0))
x <- c("ID", "x_points", "schoolfield_model")
colnames(bacteria_df) <- x



for(i in unique(DF$uniqueID)){
  bacteria_df <- rbind(bacteria_df, schoolfield(i, schoolfield_df, DF))
}

pdf("../Results/plots/bacteria_schoolfield_plots.pdf") 
models_plot <- ggplot(bacteria_df, aes(x=x_points, y=schoolfield_model))+geom_line(aes(color=ID), show.legend = FALSE)+
  xlab("Temp(kelvin)")+
  ylab("Growth Rate")+
  ggtitle(paste("Bacteria Model plots"))+
  theme(plot.title = element_text(hjust = 0.5)) + geom_vline(xintercept=c(279.3598, 289.15, 310), linetype="dotted")
print(models_plot)
dev.off()

# extracting the highest growth rate for each ID and the corresponding temperature
require(data.table) ## 1.9.2
group <- as.data.table(bacteria_df)
highest_gr = group[group[, .I[schoolfield_model == max(schoolfield_model)], by=ID]$V1]
mean(highest_gr$x_points)

#make a dataframe with unique Id, min temp and max temp.
temperature_data <- data.frame(matrix(ncol = 3, nrow=0))
y <- c("ID","min_temp","max_temp")
colnames(temperature_data) <- y

#function returns the min and max temperature values for each ID
temp_range <- function(i, schoolfield_df, DF){
  #temp_df <- data.frame(ID=NA, MinTemp=NA, MaxTemp=NA)
  sfdf = subset(schoolfield_df, ID == i)
  DF2 = subset(DF, uniqueID == i)
  
  
  if(sfdf$status =="C"){
    #parameter values for the Schoolfield model
    min_temp <- min(DF2$Temp.kel.)
    max_temp <- max(DF2$Temp.kel.)
    
    d_f <- data.frame(ID=as.character(i), MinTemp=min_temp, MaxTemp=max_temp)
  }
  else{
    d_f <- data.frame(ID=as.character(i), MinTemp=NA, MaxTemp=NA)
  }
  #temp_df <- rbind(temp_df, d_f)
  return(d_f)
}

for(i in unique(DF$uniqueID)){
  temperature_data <- rbind(temperature_data, temp_range(i, schoolfield_df, DF))
}

write.csv(temperature_data, file = "../Data/temperature_data.csv", row.names = FALSE)
