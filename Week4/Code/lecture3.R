getwd()
setwd("Documents/Stats_Julia/Week1/SparrowStats")
d<-read.table("SparrowSize.txt", header=TRUE)
str(d)
#BirdID - Categorical, Nominal use class(d$BirdID) to find out
#Year - Numerical, Discrete or Categorical, ranked?
#Tarsus - Numerical, Continuous
#Bill - Numeric, Continuous
#Wing - Numeric, Continuous
#Mass - Numeric, Continuous
#Sex - Binomial
#Sex.1 - Binomial

#if there's more than 2 categories then it's categorical, otherwise it's binomial

hist(d$Tarsus)
par(mfrow=c(1,1))
par(mar=c(4,7,6,7))

hist(d$Tarsus)
hist(d$Bill)
hist(d$Wing)
hist(d$Mass)

plot(density(d$Year))
hist(d$Year)

sqrt(var(d2$Tarsus)/length(d2$Tarsus))

d2<-subset(d, header=TRUE, na.rm=TRUE)
d2
length(d$Tarsus)
length(d2$Tarsus)
str(d)
