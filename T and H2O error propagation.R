# T error propagation for the hygrometer + H2O error propagation for the barometer 
# Kyra Cutler: last updated 25/09/23 
# Note: units are MPa for P, degrees Celsius for T & wt.% for H2O 

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
library(ranger)
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

#----------------------------(2) THERMOMETRY-----------------------------------#
# Isolating the model predictors
dropcolumns <- c("Ref","Sample","H2O","T","plag_sat_check","Type")
INPUT = inputdata[,!(names(inputdata) %in% dropcolumns)]
INPUT

# Load model
load("liquid_noH2O_thermometer2.Rdata")

# Run the model (H2O-independent thermometer)
predT_liq <- predict(liquidT_noH2O_final, data = INPUT,predict.all = TRUE)
predT_liq <- predT_liq$predictions

# Calculating median and SD for temperature values (H2O-independent thermometer)
Tliq_median <- round(apply(predT_liq, 1, median), digits = 0)
Tliq_sd <-round(apply(predT_liq,1,sd),0)
# Check values 
Tliq_median
Tliq_sd

#-----------------------------(3) HYGROMETRY-----------------------------------#
# Load model
load("liquid_hygrometer2.Rdata")

# Adding T values to input dataframe for T-dependent hygrometer
INPUTH2O <-cbind(INPUT,Tliq_median)
INPUTH2O <- INPUTH2O %>% dplyr::rename(T = Tliq_median)

# Run models
predH2O_liq <- predict(liquidH2O_final, data = INPUTH2O, predict.all = TRUE) 
predH2O_liq <- predH2O_liq$predictions

# Calculating median and SD for H2O content values (T-dependent hygrometer)
H2Oliq_median <- round(apply(predH2O_liq, 1, median), 1)
H2Oliq_sd <-round(apply(predH2O_liq,1,sd),1)
# Check values 
H2Oliq_median
H2Oliq_sd

# T error propagation, simulating T values 
T_estimates<-cbind(Tliq_median,Tliq_sd)
T_estimates<-as.data.frame(T_estimates)
set.seed(333)
T_montecarlo_function <- function(x) runif(n=50, min=(T_estimates$Tliq_median-T_estimates$Tliq_sd),max=(T_estimates$Tliq_median+T_estimates$Tliq_sd))
T_montecarlo_values <-round(apply(T_estimates, 1, FUN = T_montecarlo_function),0)
T_montecarlo_values<-as.data.frame(T_montecarlo_values)

# Creating new dataframe with monte carlo simulation T values 
allinputdata <- cbind(inputdata, Tliq_median,Tliq_sd,H2Oliq_median,H2Oliq_sd)
allinputdata <- allinputdata %>% dplyr::slice(rep(1:n(), each = 50)) 
T_errorprop_input <- INPUT %>% slice(rep(1:n(), each = 50)) 
stacking <-stack(T_montecarlo_values)
T_errorprop_input <-cbindX(T_errorprop_input,stacking)
INPUTH2O <- T_errorprop_input %>% dplyr::rename(T = values)
INPUTH2O = select(INPUTH2O, -10)
INPUTH2O <- na.omit(INPUTH2O)

# Run model
errorprop_predH2O_liq <- predict(liquidH2O_final, data = INPUTH2O, predict.all = TRUE) 
errorprop_predH2O_liq <- errorprop_predH2O_liq$predictions

# Calculating median and SD for H2O content values (T-dependent hygrometer)
errorprop_H2Oliq_median <- round(apply(errorprop_predH2O_liq, 1, median), 1)
errorprop_H2Oliq_sd <-round(apply(errorprop_predH2O_liq,1,sd),1)
# Check values 
errorprop_H2Oliq_median
errorprop_H2Oliq_sd

#------------------------------(4) BAROMETRY-----------------------------------#
# H2O error propagation, simulating H2O values 
H2O_estimates<-cbind(errorprop_H2Oliq_median,errorprop_H2Oliq_sd)
H2O_estimates<-as.data.frame(H2O_estimates)
set.seed(333)
H2O_montecarlo_function <- function(x) runif(n=50,min=(H2O_estimates$errorprop_H2Oliq_median-H2O_estimates$errorprop_H2Oliq_sd),max=(H2O_estimates$errorprop_H2Oliq_median+H2O_estimates$errorprop_H2Oliq_sd))
H2O_montecarlo_values <-round(apply(H2O_estimates, 1, FUN = H2O_montecarlo_function),1)
H2O_montecarlo_values<-as.data.frame(H2O_montecarlo_values)

# Creating new dataframe with monte carlo simulation H2O values 
H2O_errorprop_input <- INPUT %>% slice(rep(1:n(), each = 50)) 
stacking2 <-stack(H2O_montecarlo_values)
H2O_errorprop_input <-cbindX(H2O_errorprop_input,stacking2)
INPUTP <- H2O_errorprop_input %>% dplyr::rename(H2O = values)
INPUTP = select(INPUTP, -10)
INPUTP <- na.omit(INPUTP)

# Load model
load("liquid_barometer2.Rdata")

# Run model
errorprop_predP_liq <- predict(liquidP_final, data = INPUTP, predict.all = TRUE) 
errorprop_predP_liq <- errorprop_predP_liq$predictions

# Calculating median and SD for P values
errorprop_Pliq_median <- round(apply(errorprop_predP_liq, 1, median), 1)
errorprop_Pliq_sd <-round(apply(errorprop_predP_liq,1,sd),1)
# Check values 
errorprop_Pliq_median
errorprop_Pliq_sd

#----------------------(5) FILTERING & SAVING ESTIMATES------------------------#
# Save results from error propagation
OUTPUT2 <- cbind(allinputdata,errorprop_H2Oliq_median,errorprop_H2Oliq_sd,
                 errorprop_Pliq_median,errorprop_Pliq_sd)
write_xlsx(OUTPUT2,"eruption_errorprop.xlsx")

# Set up filters (currently removes values above 75th quantile for P-T-An and values above 50th quantile for H2O)
T_quantile <- quantile(Tliq_sd, c(0.75)) 
H2O_quantile <- quantile(H2Oliq_sd, c(0.5)) 
errorprop_H2O_quantile <- quantile(errorprop_H2Oliq_sd, c(0.5)) 
errorprop_P_quantile <- quantile(errorprop_Pliq_sd, c(0.75)) 

# Filter all estimates (take out # to include models or add in # to remove unused models)
filtered_OUTPUT2 <- OUTPUT2 %>% mutate (Tliq_median = replace(Tliq_median, Tliq_sd >=T_quantile,NA),
                                        Tliq_sd = replace(Tliq_sd, Tliq_sd >= T_quantile,NA),
                                        H2Oliq_median = replace(H2Oliq_median, H2Oliq_sd >=H2O_quantile,NA),
                                        H2Oliq_sd = replace(H2Oliq_sd, H2Oliq_sd >= H2O_quantile,NA),
                                        errorprop_H2Oliq_median = replace(errorprop_H2Oliq_median, errorprop_H2Oliq_sd >=errorprop_H2O_quantile,NA),
                                        errorprop_H2Oliq_sd = replace(errorprop_H2Oliq_sd, errorprop_H2Oliq_sd >=errorprop_H2O_quantile,NA),
                                        errorprop_Pliq_median = replace(errorprop_Pliq_median, errorprop_Pliq_sd >=errorprop_P_quantile, NA),
                                        errorprop_Pliq_sd = replace(errorprop_Pliq_sd, errorprop_Pliq_sd >=errorprop_P_quantile, NA))
                                  
                                  
# Save filtered file
write_xlsx(filtered_OUTPUT2,"eruption_errorprop_filtered.xlsx")



