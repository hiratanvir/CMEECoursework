rm(list=ls())
setwd("~/Documents/Stats_Julia/SparrowStats")
d<-read.table("SparrowSize.txt", header=TRUE)

plot(d$Mass~d$Tarsus, ylab="Mass (g)", xlab="Tarsus (mm)", pch=19, cex=0.4)

x<-c(1:100)
b<-0.5
m<-1.5
y<-m*x+b
plot(x,y, xlim=c(0,100), ylim=c(0,100), pch=19, cex=0.5)
d$Mass[1]
length(d$Mass)
d$Mass[1770]
plot(d$Mass~d$Tarsus, ylab="Mass (g)", xlab="Tarsus (mm)", pch=19, cex=0.4, ylim=c(-5,38), xlim=c(0,22))

d1<-subset(d, d$Mass!="NA")
d2<-subset(d1, d1$Tarsus!="NA")
length(d2$Tarsus)

model1<-lm(Mass~Tarsus, data=d2)
summary(model1)
plot(model1)

hist(model1$residuals)
head(model1$residuals)

model2<-lm(y~x)
summary(model2)
plot(model2)

d2$z.Tarsus<-scale(d2$Tarsus)
model3<-lm(Mass~z.Tarsus, data=d2)
plot(model3)
summary(model3)
