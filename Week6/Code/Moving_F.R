#!/usr/bin/env Rscript

# read in packages
require(dplyr)
require(ggplot2)
require(reshape2)

# Take in the arguments

args <- commandArgs(trailingOnly = TRUE)

FileName <- args[1]

OutputName <- args[2]

# read in the data

g <- read.table(FileName, header = T)

g <- mutate(g, nObs = nA1A1 + nA1A2 + nA2A2)

g <- mutate(g, p11 = nA1A1/nObs, p12 = nA1A2/nObs, p22 = nA2A2/nObs)

g <- mutate(g, p1 = p11 + 0.5*p12, p2 = p22 + 0.5*p12)

g <- mutate(g, X2 = (nA1A1 - nObs*p1^2)^2 /(nObs*p1^2) +
            (nA1A2 - nObs*2*p1*p2)^2 / (nObs*2*p1*p2) +
            (nA2A2 - nObs*p2^2)^2 / (nObs*p2^2))

g <- mutate(g, pval = 1-pchisq(X2,1))

g <- mutate(g, F = (2*p1*(1-p1)-p12) / (2*p1*(1-p1)))



# pdf("../Results/Ob_v_Ex_het.pdf")
# 
# qplot(2*p1*(1-p1), p12, data = g) +
#     geom_abline(intercept = 0, slope = 1, color = "red", size = 1.5)
# 
# dev.off()
# 

movingavg <- function(x, n=5){
    stats::filter(x, rep(1/n, n), sides = 2)
}


pdf(paste(OutputName))
    plot(movingavg(g$F), xlab = "SNP Number")
dev.off()
