#!/usr/bin/env Rscript
rm(list=ls())

graphics.off()
require(ggplot2)
require(plyr) #Needed for part 2

MyDF<- read.csv("../Data/EcolArchives-E089-51-D1.csv")

#Loop converts mg to g in prey mass
for (i in 1:nrow(MyDF)) {
  if(MyDF$Prey.mass.unit[i]=="mg"){
    MyDF$Prey.mass[i] = MyDF$Prey.mass[i]*0.001
    MyDF$Prey.mass.unit[i] = "g"
  }
}

# Part 1 - Script results in one pdf file containing a multi-faceted graph 
# displaying linear regression of Predator lifestage for different feeding types
pdf("../Results/PP_Regress.pdf", 11.7, 8.3)

p <- ggplot(MyDF, aes(x=Prey.mass,
                      y=Predator.mass,
                      colour=Predator.lifestage),
            log="xy") 
p <- p + theme_bw() + geom_point(shape=I(3)) + 
  scale_x_log10("Prey mass in grams") + 
  scale_y_log10("Predator mass in grams") + 
  facet_grid(Type.of.feeding.interaction~.) + 
  geom_smooth(method = "lm", fullrange=TRUE)

p <- p + theme(legend.position = "bottom") +
  guides(color = guide_legend(nrow=1)) +
  coord_fixed(0.5)

print(p)
dev.off()

# Part 2 - Calculation of regression results corresponding to the lines fitted 
# in the figure.
# Results of an analysis of Linear regresion on subsets of the data corresponding 
# available Feeding Type x Predator life stage combination.

#Run a function through the dataset to create separate models for each treatment combination.
models <- dlply(MyDF, .(Type.of.feeding.interaction,Predator.lifestage), 
                function(x) lm(log(Predator.mass)~log(Prey.mass), data=x)) # plyr

#Getting the regression statistics
t <- ldply(models, function(x) {r.sqr <- summary(x)$r.squared
intercept <- summary(x)$coefficients[1]
slope <- summary(x)$coefficients[2]
p.value <- summary(x)$coefficients[8] 
data.frame(r.sqr, intercept, slope, p.value)})

#Calculating the f-statistics
f.stat <- ldply(models, function(x) {f.stat <-summary(x)$fstatistic[1]
data.frame(f.stat)})

t <- merge(t, f.stat, by=c("Type.of.feeding.interaction", "Predator.lifestage"), all=T)

write.csv(t, file='../Results/PP_Regress_Results.csv')

