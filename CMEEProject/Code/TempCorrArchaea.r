#!/usr/bin/env Rscript
rm(list=ls())
graphics.off()
require(ggplot2)
library(dplyr)
library(ggpmisc)
library(grid)
library(gridExtra)


#load in TPC data set to get the x and y co-ordinates per group
df <- read.csv("../Data/archaea_subset.csv")
DF = df %>% group_by(uniqueID) %>% arrange(uniqueID) #orders the ID in ascending order

#load in the nlls results for the full schoolfield model and plot the results on the same ggplot2 graph
schoolfield_DF <- read.csv("../Results/archaea_schoolfield_params.csv")

#read in temperature ranges for IDs
temp_range <- read.csv("../Data/temperature_data_archaea.csv")

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


#initialising empty dataframe to append growth rates at temperature = 285.9841 Kelvin 
GR_LowTemp <- data.frame(matrix(ncol = 2, nrow = 0))
GR_LowTemp <- rbind(GR_LowTemp, temp_correct(schoolfield_df, 300))
x <- c("uniqueID", "LowTemp_GR")
colnames(GR_LowTemp) <- x

#initialising empty dataframe to append growth rates at temperature = 289.15 Kelvin
GR_MidTemp <- data.frame(matrix(ncol = 2, nrow = 0))
GR_MidTemp <- rbind(GR_MidTemp, temp_correct(schoolfield_df, 316))
x <- c("uniqueID", "MidTemp_GR")
colnames(GR_MidTemp) <- x

#initialising empty dataframe to append growth rates at temperature = 310 Kelvin
GR_HighTemp <- data.frame(matrix(ncol = 2, nrow = 0))
GR_HighTemp <- rbind(GR_HighTemp, temp_correct(schoolfield_df, 325))
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

#Merge dataframe on ID to combine data for volume and growth rate
merged_DF <- inner_join(Average_volumes, merged_GR, by='uniqueID')

#Drop repeated IDs
unique_ids <- merged_DF[ !duplicated(merged_DF[ , 1] ) , ]

#Subsetting columns which are going to be log-transformed
cols <- c("MinVolume","MaxVolume","AverageVolume","LowTemp_GR","MidTemp_GR","HighTemp_GR")
unique_ids[cols] <- log10(unique_ids[cols])

#Dropping outliers that are 2 or more orders of magnitude away from regression line
unique_ids <- unique_ids[ ! unique_ids$uniqueID %in% c(9,10,15), ]

#Dropping NAs from the data i.e. IDs which did not converge
#subset <- na.omit(merged_DF)

# Subset columns for different temperatures and removing the NAs
# Low Temp subset
LowTemp <- unique_ids[,c("GenusSpecies", "AverageVolume","LowTemp_GR")]
LowTemp <- na.omit(LowTemp)

# Mid Temp subset
MidTemp <- unique_ids[,c("GenusSpecies", "AverageVolume","MidTemp_GR")]
MidTemp <- na.omit(MidTemp)

# High Temp subset
HighTemp <- unique_ids[,c("GenusSpecies", "AverageVolume","HighTemp_GR")]
HighTemp <- na.omit(HighTemp)

#### PLOTTING LOG-TRANSFORMED GROWTH RATES AGAINST CELL VOLUME FOR DIFFERENT TEMPERATURES ####

LT <- ggplot(data = LowTemp, aes(x = AverageVolume, y = LowTemp_GR)) +
  geom_smooth(method = "lm", se=TRUE, color="black", formula = y~x) +
  stat_poly_eq(formula = y~x, eq.with.lhs=FALSE, 
               aes(label = paste("hat(italic(y))","~`=`~",..eq.label..,"~~~", ..rr.label.., sep = "")), 
               parse = TRUE, label.y.npc = 0.2) + 
  stat_fit_glance(method = 'lm',
                  method.args = list(formula = y~x),
                  geom = 'text',
                  aes(label = paste("P-value = ", signif(..p.value.., digits = 4), sep = "")),
                  label.x.npc = 'left', label.y.npc = 0.18, size = 4) +        
  geom_point(col="darkblue") + theme_bw() + theme(axis.title.x=element_blank(),
                                     axis.title.y=element_blank()) + ggtitle("26.85°C")

print(LT)


MT <- ggplot(data = MidTemp, aes(x = AverageVolume, y = MidTemp_GR)) +
  geom_smooth(method = "lm", se=TRUE, color="black", formula = y~x) +
  stat_poly_eq(formula = y~x, eq.with.lhs=FALSE, 
               aes(label = paste("hat(italic(y))","~`=`~",..eq.label..,"~~~", ..rr.label.., sep = "")), 
               parse = TRUE, label.y.npc = 0.2) + stat_fit_glance(method = 'lm',
                                                                  method.args = list(formula = y~x),
                                                                  geom = 'text',
                                                                  aes(label = paste("P-value = ", signif(..p.value.., digits = 4), sep = "")),
                                                                  label.x.npc = 'left', label.y.npc = 0.18, size = 4) + 
  geom_point(col="orange") + theme_bw() + theme(axis.title.x=element_blank(),
                                   axis.title.y=element_blank()) + ggtitle("42.85°C")

print(MT)

HT <- ggplot(data = HighTemp, aes(x = AverageVolume, y = HighTemp_GR)) +
  geom_smooth(method = "lm", se=TRUE, color="black", formula = y~x) +
  stat_poly_eq(formula = y~x, eq.with.lhs=FALSE, 
               aes(label = paste("hat(italic(y))","~`=`~",..eq.label..,"~~~", ..rr.label.., sep = "")), 
               parse = TRUE, label.y.npc = 0.2) + stat_fit_glance(method = 'lm',
                                                                  method.args = list(formula = y~x),
                                                                  geom = 'text',
                                                                  aes(label = paste("P-value = ", signif(..p.value.., digits = 4), sep = "")),
                                                                  label.x.npc = 'left', label.y.npc = 0.18, size = 4) +         
  geom_point(col="red") + theme_bw() + theme(axis.title.x=element_blank(),
                                axis.title.y=element_blank()) + ggtitle("51.85°C")

print(HT)

pdf("../Results/plots/archaea_scaling.pdf") 
plots <- grid.arrange(LT, MT, HT, top = textGrob("Archaea Temperatures Corrected Plots",gp=gpar(fontsize=13,font=3)),
                      bottom = textGrob(expression(paste("log(Volume, ", m^{3},")"))),
                      left = textGrob(expression(paste("log(Growth rate, ", s^{-1},")")), rot=90))
print(plots)
dev.off()


#expression(paste("log(Growth rate, ", s^{-1},")"))
#expression(paste("log(Volume, ", m^{3},")")))

######################################################################################################################
#Pull out p-values and r-squared from a linear regression

ggplotRegression <- function (fit) {
  
  
  ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
    geom_point() +
    stat_smooth(method = "lm", col = "black") +
    labs(title = paste("R2 = ",signif(summary(fit)$r.squared, 5),
                       "Intercept =",signif(fit$coef[[1]],5 ),
                       " Slope =",signif(fit$coef[[2]], 5),
                       " P =",signif(summary(fit)$coef[2,4], 5)))
}

# create multiple linear model

################## LOW TEMPERATURE #####################
lm_LT <- lm(LowTemp_GR ~ AverageVolume , data=LowTemp)
summary(lm_LT)

LL <- ggplotRegression(lm_LT) +         
  geom_point(col="darkblue") +  xlab(expression(paste("log(Volume, ", m^{3},")")))+ 
  ylab(expression(paste("log(Growth rate, ", s^{-1},") at 26.85°C"))) + theme_bw()
print(LL)
ggsave("../Results/plots/supplementary/LowTemp_archaea.pdf")

################## MID TEMPERATURE #####################
lm_MT <- lm(MidTemp_GR ~ AverageVolume, data = MidTemp)
summary(lm_MT)

MM <- ggplotRegression(lm_MT) +         
  geom_point(col="orange") +  xlab(expression(paste("log(Volume, ", m^{3},")")))+ 
  ylab(expression(paste("log(Growth rate, ", s^{-1},") at 42.85°C"))) + theme_bw()
print(MM)
ggsave("../Results/plots/supplementary/MidTemp_archaea.pdf")

################## HIGH TEMPERATURE #####################
lm_HT <- lm(HighTemp_GR ~ AverageVolume, data = HighTemp)
summary(lm_HT)

HH <- ggplotRegression(lm_HT) +         
  geom_point(col="red") +  xlab(expression(paste("log(Volume, ", m^{3},")")))+ 
    ylab(expression(paste("log(Growth rate, ", s^{-1},") at 51.85°C"))) + theme_bw()
print(HH)
ggsave("../Results/plots/supplementary/HighTemp_archaea.pdf") 

dev.off()

#converting data from wide to long format
library(tidyr)
data_wide <- unique_ids[,c("uniqueID","AverageVolume","LowTemp_GR","MidTemp_GR","HighTemp_GR")]
data_long <- gather(data_wide, Temperature, GrowthRate, LowTemp_GR:HighTemp_GR, factor_key=TRUE)
data_long <- data_long[,c("uniqueID","AverageVolume","GrowthRate","Temperature")]
data_long <- na.omit(data_long)


# Plotting all three linear regressions on one plot
combined_plot <- ggplot(data_long, aes(x = AverageVolume, y = GrowthRate, color=Temperature)) + 
  scale_color_manual(labels = c("26.85°C", "42.85°C","51.85°C"), values = c("darkblue", "orange","red")) + 
  geom_point() + stat_smooth(method="lm", se=TRUE) +  stat_poly_eq(formula = y~x, eq.with.lhs=FALSE, 
                                                                   aes(label = paste("hat(italic(y))","~`=`~",..eq.label..,"~~~", ..rr.label.., sep = "")), 
                                                                   parse = TRUE, label.x.npc = 'right', label.y.npc = 'bottom', size = 4) + xlab(expression(paste("log(Volume, ", m^{3},")"))) +
  ylab(expression(paste("log(Growth rate, ", s^{-1},")"))) + ggtitle("Archaea Temperature-Corrected Regressions") + theme_bw()

print(combined_plot)
ggsave("../Results/plots/archaea_slopes.pdf")

#Statistical inference
library(jtools)
summ(lm_LT, confint = TRUE, digits = 3)

library(lsmeans)
m.interaction <- lm(GrowthRate ~ AverageVolume*Temperature, data = data_long)
anova(m.interaction)

# Obtain slopes
m.interaction$coefficients
m.lst <- lstrends(m.interaction, "Temperature", var="AverageVolume")
m.lst

# Compare slopes
pairs(m.lst)

# Linear mixed effects model
library(lme4)
list <- lmList(GrowthRate~AverageVolume|Temperature,data_long)
mixed_model <- lmer(GrowthRate ~ AverageVolume*Temperature + (1|Temperature), data=data_long)
summary(mixed_model)