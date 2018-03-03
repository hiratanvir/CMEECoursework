#!/usr/bin/env Rscript
rm(list=ls())
graphics.off()
require(ggplot2)
library(dplyr)


#load in TPC data set to get the x and y co-ordinates per group
df <- read.csv("../Results/FINAL_dF.csv")
DF = df %>% group_by(uniqueID) %>% arrange(uniqueID) #orders the ID in ascending order

#load in the nlls results for the cubic model and plot the results using ggplot2
cubic_df <- read.csv("../Results/cubic_report.csv") #dataframe is already ordered by ID

#load in the nlls results for the full schoolfield model and plot the results on the same ggplot2 graph
schoolfield_df <- read.csv("../Results/schoolfield_report.csv")

#function returns a dataframe with with x values and expected y values when using the cubic model
cubic <- function(i, cubic_df, DF){
  
  cdf = subset(cubic_df, ID == i)
  DF2 = subset(DF, uniqueID == i)
  
  x_vals <- DF2$ConTemp
  #y_vals <- DF$OriginalTraitValue
  
  if(cdf$status =="C"){
    #parameter values for the cubic model
    A1 <- cdf$A
    B1 <- cdf$B
    C1 <- cdf$C
    D1 <- cdf$D
    
    #get a large number of equidistant points between the actual x points
    x_points = seq(min(x_vals),max(x_vals),0.2)
    
    #get the corresponding y_values from the sampled x_points using the model equation
    cubic_model <- (A1 + B1*x_points + C1*x_points^2 + D1*x_points^3)
    
    
    temp <- data.frame(x_points+273.15, cubic_model)
    return(temp)
  }
 
  else{
    print("Model did not converge..")
    return(NULL)
  }
}

#function returns a dataframe with with x values and expected y values when using the schoolfield model
schoolfield <- function(i, schoolfield_df, DF){
  
  sfdf = subset(schoolfield_df, ID == i)
  DF2 = subset(DF, uniqueID == i)
  
  x_vals <- DF2$Temp.kel.
  #y_vals <- DF$log_TraitValues
  
  if(sfdf$status =="C"){
    #parameter values for the cubic model
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


pdf("../Results/nlls_plot.pdf")  
for(i in unique(DF$uniqueID)){
  print(i)
  sfdf = subset(schoolfield_df, ID == i)
  DF2 = subset(DF, uniqueID == i)
  x_vals = DF2$Temp.kel.
  y_vals = DF2$OriginalTraitValue
  
  #cubeout gets the output of the function 
  cubeout <- cubic(i, cubic_df, DF)
  #if the output of cubeout is not null, then it gets the x and y values from cubeout
  if(!is.null(cubeout)){
    x = cubeout[1]
    y = cubeout[2]
  }
  
  schoolout <- schoolfield(i, schoolfield_df, DF)
  if(!is.null(schoolout)){
    x2 = schoolout[1]
    y2 = schoolout[2]
  }

  models_plot <- ggplot(DF2, aes(x=x_vals, y=y_vals, colour))+geom_point(color="blue")+
    xlab("Temp(kelvin)")+
    ylab("Original Trait Value")+
    ggtitle(paste("Model plots for ID:",i))+
    theme(plot.title = element_text(hjust = 0.5)) + geom_line(data=cubic(i, cubic_df, DF), aes(x, y, colour="Cubic model"))
  models_plot <- models_plot + labs(color='Legend')
  #only plots the schoolfield model for those IDs which converged, otherwise it skips to the next ID
  if(sfdf$status =="C"){
    models_plot <- models_plot + geom_line(data=schoolfield(i, schoolfield_df, DF), aes(x2, y2, colour="Schoolfield model"))
  }
  print(models_plot)
}
dev.off()

#Calculate the AIC differences for each model:
#Δi = AICi - AIC(min)
#where AICi is the AIC for the ith model and AIC(min) is the minimum of AIC among all the models
#The model with Δi>10 have no support and can be omited from further consideration as explained
#The larger the Δi the weaker the model

#The AIC differences in the cubic model

#make new dataframe containing ID column and AIC for cubic and schoolfield
subset_cubic <- cubic_df[,c("ID","AIC")]
subset_sf <- schoolfield_df[,c("ID","AIC")]
#merge the two subsetted dataframes by id
aic_df <- merge(x = subset_cubic, y = subset_sf, by = "ID", all = TRUE)
colnames(aic_df) <- c("ID","AIC_cubic","AIC_schoolfield")

aic_min = apply((aic_df[2:3]), 1, FUN=min)
aic_df$AIC_diff_cubic <- aic_df$AIC_cubic - aic_min
aic_df$AIC_diff_sf <- aic_df$AIC_schoolfield - aic_min


#compare how many cubic and schoolfield had minimum aic value
#work out the weighted aic for each model using the formula
# wi = exp(-1/2*Δi)/sum(exp(-1/2*Δ))


aic_df$wi_cubic <- as.numeric(unlist(exp(-1/2*aic_df[4])/((exp(-1/2*(aic_df[4])))+(exp(-1/2*(aic_df[5]))))))
aic_df$wi_sf <- as.numeric(unlist(exp(-1/2*aic_df[5])/((exp(-1/2*(aic_df[4])))+(exp(-1/2*(aic_df[5]))))))
aic_df$weighted_sum <- as.numeric(unlist(aic_df[6]+aic_df[7]))


write.csv(aic_df, "../Results/AIC_results.csv")
