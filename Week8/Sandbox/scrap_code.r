s_df <- subset(subset_df, select=c("uniqueID","Temp.kel.","log_TraitValues"))
df2 <- df[df$uniqueID=="1",]

#create a subset of the cubic model result data
cubic_subset <- cubic_df[cubic_df$ID=="1",]

pdf("../Results/nlls_plot.pdf")
for(i in unique(DF$uniqueID)[1:2]){
  
  cubic_plot <- ggplot(DF2,aes(x=x_vals, y=y_vals, colour))+geom_point(color="blue")+
    xlab("Temp(kelvin)")+
    ylab("Log Trait Value")+
    ggtitle(paste("Model plots for ID:",df$uniqueID))+
    theme(plot.title = element_text(hjust = 0.5)) + geom_line(data=cdf, aes(x_points, cubic_model, colour="Cubic model"))
  print(cubic_plot)
  dev.off()
  
}


else{
  x2 = 
}


