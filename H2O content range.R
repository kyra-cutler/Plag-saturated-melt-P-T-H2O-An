# Using a range of H2O values for the H2O-dependent thermometer or barometer 
# Kyra Cutler: last updated 25/09/23 
# Note: units are MPa for P

#--------------------(1) R ENVIRONMENT + DATA INPUT PREP-----------------------#
# Install packages if required 
install.packages("writexl")
install.packages("readxl")
install.packages("gdata")
install.packages("dplyr")
install.packages("rstudioapi")
install.packages("ggplot2")
install.packages("ggpubr")
install.packages("ranger")

# Run required libraries for this script 
library(writexl) 
library(gdata)
library(dplyr)
library(readxl)
library(ggplot2)
library(ggpubr)
library(ranger)

# Set file pathway and load input data
setwd(paste(dirname(rstudioapi::getActiveDocumentContext()$path)))
INPUT<-read_excel("INPUT.xlsx")
inputdata<-read_excel("INPUT.xlsx")
inputdata <- as.data.frame(inputdata)
INPUT <- as.data.frame (inputdata)
# Checks first rows of data 
head(INPUT)

# Isolating the model predictors
dropcolumns <- c("Ref","Sample","H2O","T","prediction","Type")
INPUT = inputdata[,!(names(inputdata) %in% dropcolumns)]
INPUT

#------------------------------(1) LIQUID THERMOMETRY----------------------------#
# Testing a range of water contents
water_values = seq(from = 0, to = 1, by = 0.3) #Set min ('from'), max ('to') and increment ('by') for sequence. 
H2O <-rep(water_values, nrow(INPUT))
H2Orange_input <- INPUT %>% slice(rep(1:n(), each = length(water_values))) 

# If you want to include other Pnw-T-H2O-An estimates into final output dataframe (swap inputdata below for OUTPUT)
H2Orange_input1 <- inputdata %>% slice(rep(1:n(), each = length(water_values))) 
H2Orange_input1 <-cbind(H2Orange_input1,H2O)
INPUT2 <-cbind(H2Orange_input,H2O)

# Load model (if you want to just use the barometer, go to section 2)
load("liquid_thermometer2.Rdata") 

# Run model
predTwH2O_liq <- predict(liquidT_final, data = INPUT2, predict.all = TRUE)
predTwH2O_liq <- as.data.frame(predTwH2O_liq)

# Calculating median and SD for temperature values (H2O-dependent thermometer)
TwH2Oliq_median <- round(apply(predTwH2O_liq, 1, median), digits = 0)
TwH2Oliq_sd <-round(apply(predTwH2O_liq,1,sd),1)
# Check values 
TwH2Oliq_median
TwH2Oliq_sd

#------------------------------(2) LIQUID BAROMETRY----------------------------#
# Load model
load("liquid_barometer2.Rdata")

# Run model
predP_liq <- predict(liquidP_final, data = INPUT2, predict.all = TRUE) 
predP_liq <- as.data.frame(predP_liq)

# Calculating median and SD for P values
Pliq_median <- round(apply(predP_liq, 1, median), 1)
Pliq_sd <-round(apply(predP_liq,1,sd),1)
# Check values 
Pliq_median
Pliq_sd

#----------------------(3) FILTERING & SAVING ESTIMATES------------------------#
# Save results from testing a range of water contents 
OUTPUT3 <- cbind(H2Orange_input1, 
                 TwH2Oliq_median,TwH2Oliq_sd, 
                 Pliq_median,Pliq_sd)
write_xlsx(OUTPUT3,"eruption_PT_H2Orange.xlsx")

# Set up filters (currently removes values above 75th percentile)
TwH2O_quantile <- quantile(TwH2Oliq_sd, c(0.75)) 
P_quantile <- quantile(Pliq_sd, c(0.75)) 

# Filter estimates (take out # to include models or add in # to remove unused models)
filtered_OUTPUT3 <- OUTPUT3 %>% mutate(#An_median = replace(An_median, An_sd >= An_quantile, NA),
                                     #An_sd = replace(An_sd, An_sd >= An_quantile, NA),
                                     #Tliq_median = replace(Tliq_median, Tliq_sd >= T_quantile,NA),
                                     #Tliq_sd = replace(Tliq_sd, Tliq_sd >= T_quantile,NA),
                                     TwH2Oliq_median = replace(TwH2Oliq_median, TwH2Oliq_sd >= TwH2O_quantile,NA),
                                     TwH2Oliq_sd = replace(TwH2Oliq_sd, TwH2Oliq_sd >= TwH2O_quantile,NA),
                                     #H2Oliq_median = replace(H2Oliq_median, H2Oliq_sd >= H2O_quantile,NA),
                                     #H2Oliq_sd = replace(H2Oliq_sd, H2Oliq_sd >= H2O_quantile,NA),
                                     #H2OnoTliq_median = replace(H2OnoTliq_median, H2OnoTliq_sd >= H2OnT_quantile,NA),
                                     #H2OnoTliq_sd = replace(H2OnoTliq_sd, H2OnoTliq_sd >= H2OnT_quantile,NA),
                                     #Pnwliq_median = replace(Pnwliq_median, Pnwliq_sd >= Pnw_quantile, NA),
                                     #Pnwliq_sd = replace(Pnwliq_sd, Pnwliq_sd >= Pnw_quantile, NA),
                                     Pliq_median = replace(Pliq_median, Pliq_sd >= P_quantile, NA),
                                     Pliq_sd = replace(Pliq_sd, Pliq_sd >= P_quantile, NA))
                                 
# Save filtered file
write_xlsx(filtered_OUTPUT3,"eruption_PT_H2Orange_filtered.xlsx")


