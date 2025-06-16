library(DT)

# read data
data <- read.csv("./data/data.csv")
DT::datatable(data)
