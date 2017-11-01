#!/usr/bin/env Rscript
rm(list=ls())

args<-commandArgs(trailingOnly = TRUE)
MyData <- read.csv(args[1])

TreeHeight <- function(degrees, distance){
  radians <- degrees * pi / 180
  height <- distance * tan(radians)
  return (height)
}

TreeHeight(MyData$Angle.degrees, MyData$Distance.m)
MyData$Tree.Height.m <- paste(TreeHeight(MyData$Angle.degrees, MyData$Distance.m))

Output <- paste("../Results/", basename(tools::file_path_sans_ext(args[1])),"_treeheights.csv")
write.csv(MyData, Output)

#This script works with *.csv file when it is called from the command line