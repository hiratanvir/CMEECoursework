#!/usr/bin/env Rscript
rm(list=ls())
graphics.off()
require(ggplot2)
library(dplyr)
library(reshape2)
require(gridExtra)
library(devtools)

#load in TPC data set to get the x and y co-ordinates per group
df <- read.csv("../Data/bacteria_subset.csv")
DF = df %>% group_by(uniqueID) %>% arrange(uniqueID) #orders the ID in ascending order

#load in the nlls results for the full schoolfield model and plot the results on the same ggplot2 graph
schoolfield_df <- read.csv("../Results/bacteria_schoolfield_params.csv")


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
GR_HighTemp <- rbind(GR_HighTemp, temp_correct(schoolfield_df, 310))
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
cols <- c("MinVolume","MaxVolume","AverageVolume","LowTemp_GR","MidTemp_GR","HighTemp_GR")
merged_DF[cols] <- log10(merged_DF[cols])

plot(merged_DF$AverageVolume, merged_DF$LowTemp_GR)
plot(merged_DF$AverageVolume, merged_DF$MidTemp_GR)
plot(merged_DF$AverageVolume, merged_DF$HighTemp_GR)

LowT <- ggplot(merged_DF,aes(x=AverageVolume, y=LowTemp_GR))
LowT <- LowT + geom_point(col="blue")
LowT + stat_smooth(method="lm")

lm_eqn <- function(df){
  m <- lm(y ~ x, df);
  eq <- substitute(italic(y) == a + b %.% italic(x)*","~~italic(r)^2~"="~r2, 
                   list(a = format(coef(m)[1], digits = 2), 
                        b = format(coef(m)[2], digits = 2), 
                        r2 = format(summary(m)$r.squared, digits = 3)))
  as.character(as.expression(eq));                 
}

p <- ggplot(data = merged_DF, aes(x = AverageVolume, y = LowTemp_GR)) +
  geom_smooth(method = "lm", se=FALSE, color="black", formula = y ~ x) +
  geom_point()
print(p)

p1 <- p + geom_text(x =AverageVolume, y =LowTemp_GR, label = lm_eqn(merged_DF), parse = TRUE)

ggplot(data = merged_DF, aes(x = AverageVolume, y = LowTemp_GR, label=y)) +
  stat_smooth_func(geom="text",method="lm",hjust=0,parse=TRUE) +
  geom_smooth(method="lm",se=FALSE) +
  geom_point() + facet_wrap(~class)

#pdf("../Results/plots/bacteria_schoolfield_plots1.pdf") 
#models_plot <- ggplot(bacteria_df, aes(x=x_points, y=schoolfield_model))+geom_line(aes(color=ID), show.legend = FALSE)+
#  xlab("Temp(kelvin)")+
#  ylab("Growth Rate")+
#  ggtitle(paste("Bacteria Model plots"))+
#  theme(plot.title = element_text(hjust = 0.5)) + geom_vline(xintercept=c(279.3598), linetype="dotted")
#print(models_plot)
#dev.off()
