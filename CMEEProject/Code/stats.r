#!/usr/bin/env Rscript
rm(list=ls())
graphics.off()

#read in growth rate and cell volume data for the three groups
bacteria <- read.csv("../Results/HighTemp_Bacteria.csv")  #16 degrees
archaea <- read.csv("../Results/LowTemp_Archaea.csv")    #42.85 degrees
phytoplankton <- read.csv("../Results/HighTemp_Phytoplankton.csv") #32.8 degrees

#changing headers for dataframes
colnames(bacteria) <- c("GenusSpecies","Phylum","AverageVolume","GrowthRate")
colnames(archaea) <- c("GenusSpecies","AverageVolume","GrowthRate")
colnames(phytoplankton) <- c("GenusSpecies","AverageVolume","GrowthRate")

archaea$Phylum <- 'Other'
phytoplankton$Phylum <- 'Other'

#assign temperature at which the growth rate was taken at
bacteria$Temp <- 32.8
archaea$Temp <- 26.85
phytoplankton$Temp <- 23.05

#adding column for group
bacteria$Group <- 'Bacteria'
archaea$Group <- 'Archaea'
phytoplankton$Group <- 'Phytoplankton'

merged <- rbind(bacteria, archaea, phytoplankton)

# Plotting all three linear regressions on one plot by group
combined_plot <- ggplot(merged, aes(x = AverageVolume, y = GrowthRate, color=Group)) + 
  geom_point(aes(colour = Phylum, shape=Group), size=2.5) + scale_shape_manual(values = c(0, 17, 3)) +
  scale_colour_manual(breaks=c("Archaea", "Bacteria", "Phytoplankton","Cyanobacteria"), values=c("orange1", "darkred", "red","black","darkblue")) + 
  stat_smooth(method="lm", se=TRUE) +  stat_poly_eq(formula = y~x, eq.with.lhs=FALSE, 
                                                                   aes(label = paste("hat(italic(y))","~`=`~",..eq.label..,"~~~", ..rr.label.., sep = "")), 
                                                                   parse = TRUE, label.x.npc = 'right', label.y.npc = 'top', size = 4) + xlab(expression(paste("log(Volume, ", m^{3},")"))) +
  ylab(expression(paste("log(Growth rate, ", s^{-1},")"))) + ggtitle("Scaling of Growth Rate across Unicellular Groups") + theme_bw()

print(combined_plot)
ggsave("../Results/plots/across_groups.pdf")



######################### ALL TEMPERATURES PLOT ##################################################################
#read in growth rate and cell volume data for the three groups
bacteria_all <- read.csv("../Results/Bacteria_all.csv")  #all temps
archaea_all <- read.csv("../Results/Archaea_all.csv")    #all_temps
phytoplankton_all <- read.csv("../Results/Phytoplankton_all.csv") #all_temps

#adding column for group
bacteria_all$Group <- 'Bacteria'
archaea_all$Group <- 'Archaea'
phytoplankton_all$Group <- 'Phytoplankton'

merged_all <- rbind(bacteria_all, archaea_all, phytoplankton_all)

# Plotting all three linear regressions on one plot by group
combined_temp <- ggplot(merged_all, aes(x = AverageVolume, y = GrowthRate, color=interaction(Group,Temp))) + 
  geom_point() + stat_smooth(method="lm", se=TRUE) +  stat_poly_eq(formula = y~x, eq.with.lhs=FALSE, 
                                                                   aes(label = paste("hat(italic(y))","~`=`~",..eq.label..,"~~~", ..rr.label.., sep = "")), 
                                                                   parse = TRUE, label.x.npc = 'right', label.y.npc = 'top', size = 4) + xlab(expression(paste("log(Volume, ", m^{3},")"))) +
  ylab(expression(paste("log(Growth rate, ", s^{-1},")"))) + ggtitle("Scaling of Growth Rate across Unicellular Groups") + theme_bw()

print(combined_temp)

lME <- lmer(GrowthRate ~ AverageVolume*Group + (1|Temp), data=merged_all)
summary(lME)

###################################################################################################################
#Statistical inference
# Linear mixed effects model
library(lme4)

#Checking the distribution of the data
hist(merged$GrowthRate)   #shows a normal distribution

#If temp was considered a random effect and group was a fixed effect then lmer would be used and the model would be this:
mixed_model <- lmer(GrowthRate ~ AverageVolume*Group + (1|Temp), data=merged) ####
summary(mixed_model)

#simplified model without the interaction between volume and group
mixed_simp<- lmer(GrowthRate ~ AverageVolume + Group + (1|Temp), data=merged)
summary(mixed_simp)

mixed_model_vol<- lmer(GrowthRate ~ AverageVolume + (1|Temp), data=merged)
summary(mixed_model_vol)

mixed_model_temp <- lmer(GrowthRate ~ Temp + (1|Temp), data=merged)
summary(mixed_model_temp)

mixed_model_group <- lmer(GrowthRate ~ Group + (1|Temp), data=merged)
summary(mixed_model_group)

anova(mixed_model, mixed_simp)
anova(mixed_model, mixed_simp, mixed_model_vol)
anova(mixed_model, mixed_simp, mixed_model_vol, mixed_model_temp)
anova(mixed_model, mixed_simp, mixed_model_vol, mixed_model_temp, mixed_model_group)
AIC(mixed_model, mixed_simp, mixed_model_vol, mixed_model_temp, mixed_model_group)

############# LINEAR MODEL ##############################

LM <- lm(GrowthRate ~ AverageVolume + Temp + Group, data = merged)
summary(LM)

LM_interact <- lm(GrowthRate ~ AverageVolume + Group + AverageVolume:Group, data = merged)
summary(LM_interact)

LM_full <- lm(GrowthRate ~ AverageVolume + Temp + Group + AverageVolume:Temp + Group:AverageVolume, data = merged)
summary(LM_full)

## ancova ###############################################################  
m.interaction <- lm(GrowthRate ~ AverageVolume*Group, data = merged)
anova(m.interaction)

#ancova using aov
ancova <- aov(GrowthRate ~ AverageVolume*Group, data = merged)

#simplified ancova - taking the interaction out
ancova_simplified <- aov(GrowthRate ~ AverageVolume+Group, data = merged)
summary(ancova_simplified)
summary(ancova)