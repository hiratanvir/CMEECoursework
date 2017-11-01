#!/usr/bin/env Rscript
rm(list=ls())

graphics.off()
library(lattice)

MyDF<-read.csv("../Data/EcolArchives-E089-51-D1.csv")

#Loop converts mg to g in prey mass
for (i in 1:nrow(MyDF)) {
  if(MyDF$Prey.mass.unit[i]=="mg"){
    MyDF$Prey.mass[i] = MyDF$Prey.mass[i]*0.001
    MyDF$Prey.mass.unit[i] = "g"
  }
}

pdf("../Results/Pred_Lattice.pdf", # Open blank pdf page
    11.7, 8.3) # These numbers are page dimensions in inches
print(densityplot(~log(Predator.mass) | Type.of.feeding.interaction,
            data=MyDF))
dev.off()

pdf("../Results/Prey_Lattice.pdf", 11.7, 8.3)
print(densityplot(~log(Prey.mass) | Type.of.feeding.interaction, data=MyDF))
dev.off()

SizeRatio<-((MyDF$Prey.mass)/(MyDF$Predator.mass))

pdf("../Results/SizeRatio_Lattice.pdf", 11.7, 8.3)
print(densityplot(~log(SizeRatio) | Type.of.feeding.interaction, data=MyDF))
dev.off()

#Using dplyr to split the dataframe and group data by different feeding interaction types
require(dplyr)

MyDF2 = MyDF %>% 
  group_by(Type.of.feeding.interaction) %>% 
  summarise(mean_Predator_mass = mean(log(Predator.mass)),
            median_Predator_mass = median(log(Predator.mass)), 
             mean_Prey_mass = mean(log(Prey.mass)), 
              median_Prey_mass = median(log(Prey.mass)),
               mean_Size_Ratio = mean(log((Prey.mass)/(Predator.mass))),
                median_Size_Ratio = median(log((Prey.mass)/(Predator.mass))))

write.csv(MyDF2, file='../Results/PP_Results.csv')
                                         


