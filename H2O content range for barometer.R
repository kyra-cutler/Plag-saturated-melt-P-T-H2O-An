# Using a range of H2O values for the H2O-dependent barometer 
# Kyra Cutler: last updated 18/06/23 
# Note: units are MPa for P

#--------------------(1) R ENVIRONMENT + DATA INPUT PREP-----------------------#
# Install packages if required (Note: ExtraTrees package is now archived) 
url <- "https://cran.r-project.org/src/contrib/Archive/extraTrees/extraTrees_1.0.5.tar.gz"
pkgFile <- "extraTrees_1.0.5.tar.gz"
download.file(url = url, destfile = pkgFile)
install.packages(pkgs=pkgFile, type="source", repos=NULL)
install.packages("writexl")
install.packages("readxl")
install.packages("gdata")
install.packages("dplyr")
install.packages("rstudioapi")
install.packages("ggplot2")
install.packages("ggpubr")

# Run required libraries for this script 
library(extraTrees)
library(writexl) 
library(gdata)
library(dplyr)
library(readxl)
library(ggplot2)
library(ggpubr)

# Set file pathway and load input data
setwd(paste(dirname(rstudioapi::getActiveDocumentContext()$path)))
INPUT<-read_excel("INPUT.xlsx")
inputdata<-read_excel("INPUT.xlsx")
inputdata <- as.data.frame(inputdata)
INPUT <- as.data.frame (inputdata)
# Checks first rows of data 
head(INPUT)

# Isolating the model predictors
dropcolumns <- c("Ref","Sample","H2O","T","plag_sat_check","Data")
INPUT = inputdata[,!(names(inputdata) %in% dropcolumns)]
INPUT

#------------------------------(2) LIQUID BAROMETRY----------------------------#
# Testing a range of water contents
water_values = seq(from = 0, to = 1, by = 0.3) #Set min ('from'), max ('to') and increment ('by') for sequence. 
H2O <-rep(water_values, nrow(INPUT))
H2Orange_input <- INPUT %>% slice(rep(1:n(), each = length(water_values))) 

# If you want to include other Pnw-T-H2O-An estimates into final output dataframe (swap inputdata below for OUTPUT)
H2Orange_input1 <- inputdata %>% slice(rep(1:n(), each = length(water_values))) 
H2Orange_input1 <-cbind(H2Orange_input1,H2O)
INPUTP <-cbind(H2Orange_input,H2O)

# Load model
load("liquid_barometer.Rdata")

# Run model
predP_liq <- predict(liquidP_final, newdata = INPUTP, allValues=TRUE) 

# Calculating median and SD for P values
Pliq_median <- round(apply(predP_liq, 1, median), 1)
Pliq_sd <-round(apply(predP_liq,1,sd),1)
# Check values 
Pliq_median
Pliq_sd

#----------------------(3) FILTERING & SAVING ESTIMATES------------------------#
# Save results from testing a range of water contents 
OUTPUT3 <- cbind(H2Orange_input1, Pliq_median,Pliq_sd)
write_xlsx(OUTPUT3,"eruption_pressures_H2Orange.xlsx")

# Set up filters (currently removes values above 75th percentile)
H2O_quantile <- quantile(H2Oliq_sd, c(0.5)) 
P_quantile <- quantile(Pliq_sd, c(0.75)) 

# Filter all estimates
filtered_OUTPUT3 <- OUTPUT3 %>% mutate (H2Oliq_median = replace(H2Oliq_median, H2Oliq_sd >=H2O_quantile,NA),
                                      Pliq_median = replace(Pliq_median, Pliq_sd >=P_quantile, NA))

# Save filtered file
write_xlsx(filtered_OUTPUT3,"eruption_pressures_H2Orange_filtered.xlsx")


