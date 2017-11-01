data <- read.table(header=TRUE, text='
 id weight
  1     20
  2     27
  3     24
')
data
data$Size <- c("small", "large", "medium")
data

#example on how to add columns to dataframe