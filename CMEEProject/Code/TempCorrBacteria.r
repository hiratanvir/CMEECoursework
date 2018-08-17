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

Average_volumes <- DF[,c("uniqueID","GenusSpecies","ConPhylum","MinVolume","MaxVolume","AverageVolume","VolumeUnit")]

####### LOG TRANSFORMING THE GROWTH RATES and VOLUMES ######################################################################
# Y= Y0.M^a
# ln(Y) = Y0 + a.ln(M) + E

#Merge dataframe on ID to combine data for volume and growth rate
merged_DF <- inner_join(Average_volumes, merged_GR, by='uniqueID')

#Drop repeated IDs
unique_ids <- merged_DF[ !duplicated(merged_DF[ , 1] ) , ]

#averaging growth rates for repeated species to get single data points per species
unique_gr <- unique_ids %>%
  group_by(GenusSpecies) %>%
  summarise_at(vars("LowTemp_GR", "MidTemp_GR", "HighTemp_GR"), mean, na.rm=T)

unique_species <- Average_volumes[ !duplicated(Average_volumes[ , 2] ) , ]
unique_data <- inner_join(unique_species, unique_gr, by='GenusSpecies')

#Subsetting columns which are going to be log-transformed
cols <- c("MinVolume","MaxVolume","AverageVolume","LowTemp_GR","MidTemp_GR","HighTemp_GR")
unique_data[cols] <- log10(unique_data[cols])

#Dropping outliers that are 2 or more orders of magnitude away from regression line
unique_data <- unique_data[ ! unique_data$uniqueID %in% c(90,117), ]


#Dropping NAs from the data i.e. IDs which did not converge
#subset <- na.omit(merged_DF)

# Subset columns for different temperatures and removing the NAs
# Low Temp subset
LowTemp <- unique_data[,c("GenusSpecies","ConPhylum","AverageVolume","LowTemp_GR")]
LowTemp <- na.omit(LowTemp)

# Mid Temp subset
MidTemp <- unique_data[,c("GenusSpecies","ConPhylum","AverageVolume","MidTemp_GR")]
MidTemp <- na.omit(MidTemp)
write.table(MidTemp, "../Results/MidTemp_Bacteria.csv", sep = ",", row.names = FALSE)

# High Temp subset
HighTemp <- unique_data[,c("GenusSpecies","ConPhylum","AverageVolume","HighTemp_GR")]
HighTemp <- na.omit(HighTemp)
write.table(HighTemp, "../Results/HighTemp_Bacteria1.csv", sep = ",", row.names = FALSE)

#### PLOTTING LOG-TRANSFORMED GROWTH RATES AGAINST CELL VOLUME FOR DIFFERENT TEMPERATURES ####

LT <- ggplot(data = LowTemp, aes(x = AverageVolume, y = LowTemp_GR)) +
  geom_smooth(method = "lm", se=TRUE, color="black", formula = y~x) +
  stat_poly_eq(formula = y~x, eq.with.lhs=FALSE, 
               aes(label = paste("hat(italic(y))","~`=`~",..eq.label..,"~~~", ..rr.label.., sep = "")), 
               parse = TRUE, label.y.npc = 0.15) + stat_fit_glance(method = 'lm',
                                                 method.args = list(formula = y~x),
                                                 geom = 'text',
                                                 aes(label = paste("P-value = ", signif(..p.value.., digits = 4), sep = "")),
                                                 label.x.npc = 'left', label.y.npc = 0.13, size = 4) +        
  geom_point(col="darkblue") + theme_bw() + theme(axis.title.x=element_blank(),
                                     axis.title.y=element_blank()) + ggtitle("6.2°C")
print(LT)


MT <- ggplot(data = MidTemp, aes(x = AverageVolume, y = MidTemp_GR)) +
  geom_smooth(method = "lm", se=TRUE, color="black", formula = y~x) +
  stat_poly_eq(formula = y~x, eq.with.lhs=FALSE, 
               aes(label = paste("hat(italic(y))","~`=`~",..eq.label..,"~~~", ..rr.label.., sep = "")), 
               parse = TRUE, label.y.npc = 0.15) +  stat_fit_glance(method = 'lm',
                                               method.args = list(formula = y~x),
                                               geom = 'text',
                                               aes(label = paste("P-value = ", signif(..p.value.., digits = 4), sep = "")),
                                               label.x.npc = 'left', label.y.npc = 0.13, size = 4) +        
  geom_point(col="orange") + theme_bw() + theme(axis.title.x=element_blank(),
                                     axis.title.y=element_blank()) + ggtitle("16°C") 
print(MT)


HT <- ggplot(data = HighTemp, aes(x = AverageVolume, y = HighTemp_GR)) +
  geom_smooth(method = "lm", se=TRUE, color="black", formula = y~x) +
  stat_poly_eq(formula = y~x, eq.with.lhs=FALSE, 
               aes(label = paste("hat(italic(y))","~`=`~",..eq.label..,"~~~", ..rr.label.., sep = "")), 
               parse = TRUE, label.y.npc = 0.15) + stat_fit_glance(method = 'lm',
                                             method.args = list(formula = y~x),
                                             geom = 'text',
                                             aes(label = paste("P-value = ", signif(..p.value.., digits = 4), sep = "")),
                                             label.x.npc = 'left', label.y.npc = 0.13, size = 4) +        
  geom_point(col="red")  + theme_bw() + theme(axis.title.x=element_blank(),
                                     axis.title.y=element_blank()) + ggtitle("32.8°C") 

print(HT)


pdf("../Results/plots/bacteria_scaling.pdf") 
plots <- grid.arrange(LT, MT, HT, top = textGrob("Bacteria Temperatures Corrected Plots",gp=gpar(fontsize=13,font=3)),
                      bottom = textGrob(expression(paste("log(Volume, ", m^{3},")"))),
                      left = textGrob(expression(paste("log(Growth rate, ", s^{-1},")")), rot=90))
print(plots)
dev.off()

#GR_HIGHHHTemp <- data.frame(matrix(ncol = 2, nrow = 0))
#GR_HIGHHHTemp <- rbind(GR_HIGHHHTemp, temp_correct(schoolfield_df, 355))
#x <- c("uniqueID", "HIGHHHTemp_GR")
#colnames(GR_HIGHHHTemp) <- x

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
  ylab(expression(paste("log(Growth rate, ", s^{-1},") at 6.2°C"))) + theme_bw()
print(LL)
ggsave("../Results/plots/supplementary/LowTemp_bacteria.pdf")


################## MID TEMPERATURE #####################
lm_MT <- lm(MidTemp_GR ~ AverageVolume, data = MidTemp)
summary(lm_MT)


MM <- ggplotRegression(lm_MT) +         
  geom_point(col="orange") +  xlab(expression(paste("log(Volume, ", m^{3},")")))+ 
  ylab(expression(paste("log(Growth rate, ", s^{-1},") at 16°C"))) + theme_bw()
print(MM)
ggsave("../Results/plots/supplementary/MidTemp_bacteria.pdf")


################## HIGH TEMPERATURE #####################
lm_HT <- lm(HighTemp_GR ~ AverageVolume, data = HighTemp)
summary(lm_HT)

HH <- ggplotRegression(lm_HT) +         
  geom_point(col="red") +  xlab(expression(paste("log(Volume, ", m^{3},")")))+ 
  ylab(expression(paste("log(Growth rate, ", s^{-1},") at 32.8°C"))) + theme_bw()
print(HH)
ggsave("../Results/plots/supplementary/HighTemp_bacteria.pdf") 

dev.off()


#converting data from wide to long format
library(tidyr)
data_wide <- unique_data[,c("uniqueID","AverageVolume","LowTemp_GR","MidTemp_GR","HighTemp_GR")]
data_long <- gather(data_wide, Temperature, GrowthRate, LowTemp_GR:HighTemp_GR, factor_key=TRUE)
data_long <- data_long[,c("uniqueID","AverageVolume","GrowthRate","Temperature")]
data_long <- na.omit(data_long)

data_long <- data_long %>% mutate (Temp = ifelse(Temperature == 'LowTemp_GR', '6.2', 
                         ifelse(Temperature == 'MidTemp_GR', '16',
                                 ifelse(Temperature == 'HighTemp_GR', '32.8', NA))))

data_long$Temp <- as.numeric(as.character(data_long$Temp))
write.table(data_long, "../Results/Bacteria_all.csv", sep = ",", row.names = FALSE)

# Plotting all three linear regressions on one plot
combined_plot <- ggplot(data_long, aes(x = AverageVolume, y = GrowthRate, color=Temperature)) + 
  scale_color_manual(labels = c("6.2°C", "16°C","32.8°C"), values = c("darkblue", "orange","red")) + 
  geom_point() + stat_smooth(method="lm", se=TRUE) +  stat_poly_eq(formula = y~x, eq.with.lhs=FALSE, 
               aes(label = paste("hat(italic(y))","~`=`~",..eq.label..,"~~~", ..rr.label.., sep = "")), 
               parse = TRUE, label.x.npc = 'right', label.y.npc = 'top', size = 4) + xlab(expression(paste("log(Volume, ", m^{3},")"))) +
  ylab(expression(paste("log(Growth rate, ", s^{-1},")"))) + ggtitle("Bacteria Temperature-Corrected Regressions") + theme_bw()

print(combined_plot)
ggsave("../Results/plots/bacteria_slopes.pdf")


###################################################################################################################
#Statistical inference
library(jtools)
summ(lm_LT, confint = TRUE, digits = 3)

library(lsmeans)
#ANCOVA analysis with temperature as an interaction
m.interaction <- lm(GrowthRate ~ AverageVolume*Temperature, data = data_long)
anova(m.interaction)

# Obtain slopes
m.interaction$coefficients
m.lst <- lstrends(m.interaction, "Temperature", var="AverageVolume")
m.lst

# Compare slopes
pairs(m.lst)

### Ruling out using an ANCOVA as you need balanced data for that & linear models account for more types of variation

# Linear mixed effects model

#Checking the distribution of the data
hist(data_long$GrowthRate)

library(lme4)
#lm if  you dont include random effect (lmer if you do)
list <- lmList(GrowthRate~AverageVolume|Temperature,data_long)

################# MIXED MODEL ##############################
#If temperature was considered a random effect then lmer would be used and the model would be this:
mixed_model <- lmer(GrowthRate ~ AverageVolume+ (1|Temperature), data=data_long)
summary(mixed_model)

# TO CHECK THE DISTRIBUTION OF RESIDUALS
par(mfrow=c(2,2))
plot(mixed_model)

##################### LINEAR MODELS #########################
#Linear model with temperature as a fixed interaction with average volume
#Temperature is also a continuous variable here and not a factor
l_m <- lm(GrowthRate ~ AverageVolume*Temp, data=data_long)
summary(l_m)

#Temperature as a factor
lm_factor <- lm(GrowthRate ~ AverageVolume*Temperature, data=data_long)
summary(lm_factor)

#Another way of writing the model, and it is easier to simply this as you can take the interaction out
#Volume+Tempertaure+Volume*Temperature 
lm_same<- lm(GrowthRate ~ AverageVolume + Temp + AverageVolume:Temp, data=data_long)
summary(lm_same)

#simplified model minus interaction between average volume and temperature
lm_simplified<- lm(GrowthRate ~ AverageVolume + Temp, data=data_long)
summary(lm_simplified)

#third model just looking at temperature
lm_temp <- lm(GrowthRate ~ Temp, data = data_long)
summary(lm_temp)

# only volume
lm_vol <- lm(GrowthRate ~ AverageVolume, data = data_long)
summary(lm_vol)

anova(l_m, lm_simplified)
anova(l_m, lm_simplified, lm_temp)
anova(l_m, lm_simplified, lm_temp, lm_vol)
AIC(l_m, lm_simplified, lm_temp, lm_vol)


