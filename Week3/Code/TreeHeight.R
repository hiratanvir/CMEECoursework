#!/usr/bin/env Rscript
rm(list=ls())

# This function calculates heights of trees from the angle of
# elevation and the distance from the base using the trigonometric
# formula height = distance * tan(radians)
#
# ARGUMENTS:
# degrees The angle of elevation
# distance The distance from base
#
# OUTPUT:
# The height of the tree, same units as "distance"
MyData<-read.csv("../Data/Trees.csv", header=TRUE)

TreeHeight <- function(degrees, distance){
	radians <- degrees * pi / 180
	height <- distance * tan(radians)
	return (height)
}

TreeHeight(MyData$Angle.degrees, MyData$Distance.m)
MyData$Tree.Height.m <- paste(TreeHeight(MyData$Angle.degrees, MyData$Distance.m))

write.csv(MyData, "../Results/TreeHts.csv")

                              