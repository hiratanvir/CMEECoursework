#!/usr/bin/env Rscript
rm(list=ls())
require(ggplot2)

#load in TPC data set to get the x and y co-ordinates per group
df <- read.csv("../Results/final_dF.csv")

#load in the nlls results for each model and plot the results using ggplot2
cubic_df <- read.csv("../Results/cubic_report.csv")


#subset the dataset to work on just one group initially
subset_df <- df[df$uniqueID=='1',]
x_vals <- subset_df$Temp.kel.
y_vals <- subset_df$log_TraitValues

#create a subset of the cubic model result data
cubic_subset <- cubic_df[cubic_df$ID=="1",]

#parameter values for the cubic model
A1 <- cubic_subset$A
B1 <- cubic_subset$B
C1 <- cubic_subset$C
D1 <- cubic_subset$D

aic <- cubic_subset$AIC
bic <- cubic_subset$BIC
chi_sqr <- cubic_subset$chi.squared

#get a large number of equidistant points between the actual x points
x_points = seq(min(x_vals),max(x_vals),0.1)

#get the corresponding y_values from the sampled x_points using the model equation
cubic_model <- A1 + B1*x_points + C1*x_points^2 + D1*x_points^3


cubic_plot <- ggplot(subset_df,aes(x=x_vals, y=y_vals))+geom_point(color="blue")+
  xlab("1/kT")+
  ylab("Log Trait Value")+
  ggtitle("Best fit for cubic model")+
  theme(plot.title = element_text(hjust = 0.5)) + geom_line(data=cubic_subset, aes(x_points, cubic_model))