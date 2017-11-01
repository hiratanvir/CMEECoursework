x<-c(1, 2, 3, 4, 8) #make vectors for x values
y<-c(4, 3, 5, 7, 9) #make vectors for y values
model1<-(lm(y~x)) #create a linear model(lm) for y over x
summary(model1)
plot(model1)
anova(model1) #Computes analysis of variance (or deviance) tables 
resid(model1)
cov(x,y)
var(x)
plot(y~x)
setwd("../Data")
