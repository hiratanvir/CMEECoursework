#!/usr/bin/env Rscript
rm(list=ls())
graphics.off()
require(ggplot2)
library(dplyr)
library(ggpmisc)

#load in TPC data set to get the x and y co-ordinates per group
df <- read.csv("../Data/archaea_subset.csv")
DF = df %>% group_by(uniqueID) %>% arrange(uniqueID) #orders the ID in ascending order

#load in the nlls results for the full schoolfield model and plot the results on the same ggplot2 graph
schoolfield_df <- read.csv("../Results/archaea_schoolfield_params.csv")


#function returns a dataframe with with x values and expected y values when using the schoolfield model
temp_correct <- function(sfdf, temp){
  
  temp_df <- data.frame(ID=NA, GR=NA)    
  #y_vals <- DF$log_TraitValues
  for(i in 1:nrow(sfdf)){
    
    if(sfdf[i,"status"] =="C"){
      #parameter values for the Schoolfield model
      B0 <- sfdf[i,"B0"]
      E <- sfdf[i,"E"]
      Eh <- sfdf[i,"Eh"]
      El <- sfdf[i,"El"]
      Th <- sfdf[i,"Th"]
      Tl <- sfdf[i,"Tl"] 
      
      # Define k, Boltzmann constant
      k = 8.6173303e-05
      
      #get a large number of equidistant points between the actual x points
      x_points = temp
      
      #get the corresponding y_values from the sampled x_points using the model equation
      schoolfield_model <- ((B0*exp((-E/k)*((1/x_points)-(1/283.15)))) / (1 + (exp((El/k)*((1/Tl)-(1/x_points)))) + (exp((Eh/k)*((1/Th)-(1/x_points))))))
      
      d_f <- data.frame(ID=sfdf[i, "ID"], GR=schoolfield_model)
    }
    else{
      d_f <- data.frame(ID=sfdf[i, "ID"], GR=NA)
    }
    temp_df <- rbind(temp_df, d_f)
  }
  return(temp_df)
}


#initialising empty dataframe to append growth rates at temperature = 285.9841 Kelvin 
GR_LowTemp <- data.frame(matrix(ncol = 2, nrow = 0))
GR_LowTemp <- rbind(GR_LowTemp, temp_correct(schoolfield_df, 285.9841))
x <- c("uniqueID", "LowTemp_GR")
colnames(GR_LowTemp) <- x

#initialising empty dataframe to append growth rates at temperature = 289.15 Kelvin
GR_MidTemp <- data.frame(matrix(ncol = 2, nrow = 0))
GR_MidTemp <- rbind(GR_MidTemp, temp_correct(schoolfield_df, 312))
x <- c("uniqueID", "MidTemp_GR")
colnames(GR_MidTemp) <- x

#initialising empty dataframe to append growth rates at temperature = 310 Kelvin
GR_HighTemp <- data.frame(matrix(ncol = 2, nrow = 0))
GR_HighTemp <- rbind(GR_HighTemp, temp_correct(schoolfield_df, 337.5))
x <- c("uniqueID", "HighTemp_GR")
colnames(GR_HighTemp) <- x

#Joining only two dataframes together using dplyr
#merged <- inner_join(GR_LowTemp, GR_MidTemp, by='ID')

#Joining more than two dataframes together using dplyr
merged_GR <- inner_join(GR_LowTemp, GR_MidTemp, by='uniqueID') %>%
  inner_join(., GR_HighTemp, by='uniqueID')

Average_volumes <- DF[,c("uniqueID","GenusSpecies","MinVolume","MaxVolume","AverageVolume","VolumeUnit")]

####### LOG TRANSFORMING THE GROWTH RATES and VOLUMES ########
# Y= Y0.M^a
# ln(Y) = Y0 + a.ln(M) + E

merged_DF <- inner_join(Average_volumes, merged_GR, by='uniqueID')
#Dropping NAs from the data i.e. IDs which did not converge
subset <- na.omit(merged_DF)

#Subsetting columns which are going to be log-transformed
cols <- c("MinVolume","MaxVolume","AverageVolume","LowTemp_GR","MidTemp_GR","HighTemp_GR")
subset[cols] <- log10(subset[cols])

#### PLOTTING LOG-TRANSFORMED GROWTH RATES AGAINST CELL VOLUME FOR DIFFERENT TEMPERATURES ####

LT <- ggplot(data = subset, aes(x = AverageVolume, y = LowTemp_GR)) +
  geom_smooth(method = "lm", se=FALSE, color="black", formula = y~x) +
  stat_poly_eq(formula = y~x, eq.with.lhs=FALSE, 
               aes(label = paste("hat(italic(y))","~`=`~",..eq.label..,"~~~", ..rr.label.., sep = "")), 
               parse = TRUE, label.x.npc = "right") +         
  geom_point(col="darkblue")

print(LT)


MT <- ggplot(data = subset, aes(x = AverageVolume, y = MidTemp_GR)) +
  geom_smooth(method = "lm", se=FALSE, color="black", formula = y~x) +
  stat_poly_eq(formula = y~x, eq.with.lhs=FALSE, 
               aes(label = paste("hat(italic(y))","~`=`~",..eq.label..,"~~~", ..rr.label.., sep = "")), 
               parse = TRUE, label.x.npc = "right") +         
  geom_point(col="orange")

print(MT)

HT <- ggplot(data = subset, aes(x = AverageVolume, y = HighTemp_GR)) +
  geom_smooth(method = "lm", se=FALSE, color="black", formula = y~x) +
  stat_poly_eq(formula = y~x, eq.with.lhs=FALSE, 
               aes(label = paste("hat(italic(y))","~`=`~",..eq.label..,"~~~", ..rr.label.., sep = "")), 
               parse = TRUE, label.x.npc = "right") +         
  geom_point(col="red")

print(HT)

