#!/usr/bin/env Rscript
rm(list=ls())
graphics.off()
require(ggplot2)
library(dplyr)
library(ggpmisc)
library(grid)
library(gridExtra)


#load in TPC data set to get the x and y co-ordinates per group
df <- read.csv("../Data/bacteria_subset.csv")
DF = df %>% group_by(uniqueID) %>% arrange(uniqueID) #orders the ID in ascending order

#load in the nlls results for the full schoolfield model and plot the results on the same ggplot2 graph
schoolfield_DF <- read.csv("../Results/bacteria_schoolfield_params.csv")

#read in temperature ranges for IDs
temp_range <- read.csv("../Data/temperature_data.csv")

schoolfield_df <- merge(schoolfield_DF, temp_range, by="ID")


#function returns a dataframe with with x values and expected y values when using the schoolfield model
temp_correct <- function(sfdf, temp){

temp_df <- data.frame(ID=NA, GR=NA)

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
    
    #if (temp < min_temp || temp > max_temp) {d_f = NA}
    x_points = temp
    
    #Defining minimum and maximum temperature
    Min <- temp_range[i,"MinTemp"]
    Max <- temp_range[i,"MaxTemp"]
    
    
    if(x_points >= Min & x_points <= Max){
      #get the corresponding y_values from the sampled x_points using the model equation
      schoolfield_model <- ((B0*exp((-E/k)*((1/x_points)-(1/283.15)))) / (1 + (exp((El/k)*((1/Tl)-(1/x_points)))) + (exp((Eh/k)*((1/Th)-(1/x_points))))))
    } else{
      schoolfield_model <- NA
    }

    d_f <- data.frame(ID=sfdf[i, "ID"], GR=schoolfield_model)
  }
  
    else{
      d_f <- data.frame(ID=sfdf[i, "ID"], GR=NA)
    }
  
    temp_df <- rbind(temp_df, d_f)
  }
    return(temp_df)
}

#initialising empty dataframe to append growth rates at temperature = 279.3598 Kelvin 
GR_LowTemp <- data.frame(matrix(ncol = 2, nrow = 0))
GR_LowTemp <- rbind(GR_LowTemp, temp_correct(schoolfield_df, 279.3598))
x <- c("uniqueID", "LowTemp_GR")
colnames(GR_LowTemp) <- x

#initialising empty dataframe to append growth rates at temperature = 289.15 Kelvin
GR_MidTemp <- data.frame(matrix(ncol = 2, nrow = 0))
GR_MidTemp <- rbind(GR_MidTemp, temp_correct(schoolfield_df, 289.15))
x <- c("uniqueID", "MidTemp_GR")
colnames(GR_MidTemp) <- x

#initialising empty dataframe to append growth rates at temperature = 310 Kelvin
GR_HighTemp <- data.frame(matrix(ncol = 2, nrow = 0))
GR_HighTemp <- rbind(GR_HighTemp, temp_correct(schoolfield_df, 305.9856))
x <- c("uniqueID", "HighTemp_GR")
colnames(GR_HighTemp) <- x

#Joining only two dataframes together using dplyr
#merged <- inner_join(GR_LowTemp, GR_MidTemp, by='ID')

#Joining more than two dataframes together using dplyr
merged_GR <- inner_join(GR_LowTemp, GR_MidTemp, by='uniqueID') %>%
  inner_join(., GR_HighTemp, by='uniqueID')

Average_volumes <- DF[,c("uniqueID","GenusSpecies","MinVolume","MaxVolume","AverageVolume","VolumeUnit")]

####### LOG TRANSFORMING THE GROWTH RATES and VOLUMES ######################################################################
# Y= Y0.M^a
# ln(Y) = Y0 + a.ln(M) + E

#Merge dataframe on ID to combine data for volume and growth rate
merged_DF <- inner_join(Average_volumes, merged_GR, by='uniqueID')

#Drop repeated IDs
unique_ids <- merged_DF[ !duplicated(merged_DF[ , 1] ) , ]

#Subsetting columns which are going to be log-transformed
cols <- c("MinVolume","MaxVolume","AverageVolume","LowTemp_GR","MidTemp_GR","HighTemp_GR")
unique_ids[cols] <- log10(unique_ids[cols])

#Dropping NAs from the data i.e. IDs which did not converge
#subset <- na.omit(merged_DF)

# Subset columns for different temperatures and removing the NAs
# Low Temp subset
LowTemp <- unique_ids[,c("AverageVolume","LowTemp_GR")]
LowTemp <- na.omit(LowTemp)

# Mid Temp subset
MidTemp <- unique_ids[,c("AverageVolume","MidTemp_GR")]
MidTemp <- na.omit(MidTemp)

# High Temp subset
HighTemp <- unique_ids[,c("AverageVolume","HighTemp_GR")]
HighTemp <- na.omit(HighTemp)

#### PLOTTING LOG-TRANSFORMED GROWTH RATES AGAINST CELL VOLUME FOR DIFFERENT TEMPERATURES ####

LT <- ggplot(data = LowTemp, aes(x = AverageVolume, y = LowTemp_GR)) +
  geom_smooth(method = "lm", se=FALSE, color="black", formula = y~x) +
  stat_poly_eq(formula = y~x, eq.with.lhs=FALSE, 
               aes(label = paste("hat(italic(y))","~`=`~",..eq.label..,"~~~", ..rr.label.., sep = "")), 
               parse = TRUE, label.y.npc = 0.2) +         
  geom_point(col="darkblue") +  xlab("Log10 Average Volume (m^3)")+ ylab("Log10 Growth rate (6.2°C)")

print(LT)


MT <- ggplot(data = MidTemp, aes(x = AverageVolume, y = MidTemp_GR)) +
  geom_smooth(method = "lm", se=FALSE, color="black", formula = y~x) +
  stat_poly_eq(formula = y~x, eq.with.lhs=FALSE, 
               aes(label = paste("hat(italic(y))","~`=`~",..eq.label..,"~~~", ..rr.label.., sep = "")), 
               parse = TRUE, label.y.npc = 0.2) +         
  geom_point(col="orange") +  xlab("Log10 Average Volume (m^3)")+ ylab("Log10 Growth rate (16°C)")
print(MT)

HT <- ggplot(data = HighTemp, aes(x = AverageVolume, y = HighTemp_GR)) +
  geom_smooth(method = "lm", se=FALSE, color="black", formula = y~x) +
  stat_poly_eq(formula = y~x, eq.with.lhs=FALSE, 
               aes(label = paste("hat(italic(y))","~`=`~",..eq.label..,"~~~", ..rr.label.., sep = "")), 
               parse = TRUE, label.y.npc = 0.2) +         
  geom_point(col="red") +  xlab("Log10 Average Volume (m^3)")+ ylab("Log10 Growth rate (32.8°C)")
print(HT)

pdf("../Results/plots/bacteria_scaling.pdf") 
plots <- grid.arrange(LT, MT, HT, top = textGrob("Bacteria Temperatures Corrected Plots",gp=gpar(fontsize=10,font=3)))
print(plots)
dev.off()

#GR_HIGHHHTemp <- data.frame(matrix(ncol = 2, nrow = 0))
#GR_HIGHHHTemp <- rbind(GR_HIGHHHTemp, temp_correct(schoolfield_df, 355))
#x <- c("uniqueID", "HIGHHHTemp_GR")
#colnames(GR_HIGHHHTemp) <- x