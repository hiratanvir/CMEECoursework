#!/usr/bin/env Rscript
rm(list=ls())
graphics.off()
require(ggplot2)
library(dplyr)
library(reshape2)
library(scales)
require(gridExtra)

#load in TPC data set to get the x and y co-ordinates per group
df <- read.csv("../Data/archaea_subset.csv")
DF = df %>% group_by(uniqueID) %>% arrange(uniqueID) #orders the ID in ascending order

#load in the nlls results for the full schoolfield model and plot the results on the same ggplot2 graph
schoolfield_df <- read.csv("../Results/archaea_schoolfield_params.csv")


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
archaea_df <- data.frame(matrix(ncol = 3, nrow = 0))
x <- c("ID", "x_points", "schoolfield_model")
colnames(archaea_df) <- x



for(i in unique(DF$uniqueID)){
  archaea_df <- rbind(archaea_df, schoolfield(i, schoolfield_df, DF))
}

pdf("../Results/plots/archaea_temperature_plot.pdf") 
models_plot <- ggplot(archaea_df, aes(x=x_points, y=schoolfield_model))+geom_line(aes(color=ID), show.legend = FALSE)+
  xlab("Temp(kelvin)")+
  ylab("Growth Rate")+
  ggtitle(paste("Archaea Model plots"))+
  theme(plot.title = element_text(hjust = 0.5)) 
print(models_plot)
dev.off()

# extracting the highest growth rate (Tpk) for the lowest temperature
require(data.table) ## 1.9.2
group <- as.data.table(archaea_df)
highest_gr = group[group[, .I[schoolfield_model == max(schoolfield_model)], by=ID]$V1]
mean(highest_gr$x_points)