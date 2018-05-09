#!/usr/bin/env Rscript
rm(list=ls())
graphics.off()
require(ggplot2)
library(dplyr)
library(reshape2)
library(scales)
require(gridExtra)

#load in TPC data set to get the x and y co-ordinates per group
df <- read.csv("../Results/archaea_subset.csv")
DF = df %>% group_by(uniqueID) %>% arrange(uniqueID) #orders the ID in ascending order

#load in the nlls results for the full schoolfield model and plot the results on the same ggplot2 graph
schoolfield_df <- read.csv("../Results/archaea_schoolfield_report.csv")


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
    
    
    temp <- data.frame(x_points, schoolfield_model)
    return(temp)
  }
  
  else{
    print("Model did not converge..")
    return(NULL)
  }
}

unique(DF$uniqueID)
pdf("../Results/archaea_plots.pdf")  
for(i in unique(DF$uniqueID)){
  print(i)
  sfdf = subset(schoolfield_df, ID == i)
  DF2 = subset(DF, uniqueID == i)
  x_vals = DF2$Temp.kel.
  y_vals = DF2$StandardisedTraitValue
  
  
  schoolout <- schoolfield(i, schoolfield_df, DF)
  if(!is.null(schoolout)){
    x2 = schoolout[1]
    y2 = schoolout[2]
  }
  if(sfdf$status =="C"){
    models_plot <- ggplot(DF2, aes(x=x_vals, y=y_vals, colour))+geom_point(color="blue")+
      xlab("Temp(kelvin)")+
      ylab("Standardised Trait Value")+
      ggtitle(paste("Archaea Model plot for ID:",i))+
      theme(plot.title = element_text(hjust = 0.5)) + geom_line(data=schoolfield(i, schoolfield_df, DF), aes(x2, y2, colour="Schoolfield model"))
    models_plot <- models_plot + labs(color='Legend')
    print(models_plot)
  }
}

dev.off()