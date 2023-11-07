# Pressure-temperature-melt H2O content estimates + plagioclase equilibrium chemistry (anorthite content; An) 
# Kyra Cutler: last updated 25/09/23 
# Note: units are MPa for P, degrees Celsius for T, wt.% for H2O & mol % for An 

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
library(ranger)
library(writexl) 
library(gdata)
library(dplyr)
library(ggplot2)
library(rstudioapi)
library(ggpubr)
library(readxl)

# Set file pathway and load input data
setwd(paste(dirname(rstudioapi::getActiveDocumentContext()$path)))
inputdata <- read_excel("INPUT.xlsx")
INPUT <- as.data.frame (inputdata)
# Checks first rows of data 
head(INPUT)

# Check if liquid data are within calibration range 
# Change sheet name to "Input for P" for pressure calibration comparison
calibration_data <- read_excel("Supplementary Table 1_calibration dataset_P-T-H2O-An.xlsx", sheet = "Input for T, H2O & An")
Alkalis <- INPUT$Na2O_liq + INPUT$K2O_liq 
INPUT_calibrationcheck <- cbind(INPUT,Alkalis,Data="new_data")
calibration_data <- calibration_data[ -c(11:24)]
INPUT_calibrationcheck <- INPUT_calibrationcheck[ -c(3,12,13)]
calibration_data <- rbind(calibration_data, INPUT_calibrationcheck)

# TAS diagram comparison 
ggplot(calibration_data, aes(x=SiO2_liq, y=Alkalis,colour=Data,shape=Data)) +
  geom_point(size=5, stroke=0.5)+
  scale_colour_manual(values=c("#DEDEDE","#581E4F"))+
  theme_pubr(border=TRUE)+
  xlab("SiO2 (wt.%)")+
  xlim(35, 80)+
  ylim(0,15)+
  ylab("Na2O + K2O (wt.%)")+
  theme(legend.position="bottom")

# Change x and y axis to compare different oxides (SiO2_liq, TiO2,liq, Al2O3_liq, FeOt_liq, MgO_liq, CaO_liq,Na2O_liq, K2O_liq, Alkalis)
ggplot(calibration_data, aes(x=SiO2_liq, y=Al2O3_liq,colour=Data,shape=Data)) +
  geom_point(size=5, stroke=0.5)+
  scale_colour_manual(values=c("#DEDEDE","#581E4F"))+
  theme_pubr(border=TRUE)+
  xlab("SiO2 (wt.%)")+
  ylab("Al2O3 (wt.%)")+
  theme(legend.position="bottom")

#-------(2) PLAGIOCLASE SATURATION CHECK (if needed, otherwise skip step)------#
# Load model
load("plag_saturated??.Rdata")

# Isolating the model predictors
dropcolumns <- c("Ref","Sample","H2O","T","Type")
INPUT = INPUT[,!(names(INPUT) %in% dropcolumns)]
INPUT

# Run the model
plag_sat_check <- predict(plagsat_final, data = INPUT)
plag_sat_check <- plag_sat_check$predictions

# Creating output file 
plag_saturated <-cbind(inputdata,plag_sat_check)
# Filtering out melts that are not plagioclase-saturated
filtered_plag_saturated <- plag_saturated%>% dplyr::filter(grepl('Yes', plag_sat_check)) 
# Replace input file name in step 1 to use new file for P-T-H2O-An predictions
write_xlsx(filtered_plag_saturated, 'OUTPUT_plagsat.xlsx') 

#----------------------------(3) AN CONTENT------------------------------------#
# Load model
load("An2.Rdata") # plagioclase-melt equilibrium 

# Isolating the model predictors (if you used the plagioclase-saturated classifier, then you skip this step and run model)
dropcolumns <- c("Ref","Sample","T","Type","plag_sat_check")
INPUT = INPUT[,!(names(INPUT) %in% dropcolumns)]
INPUT

# Run the model
predAn <- predict(An_final, data = INPUT,predict.all = TRUE)
predAn <- predAn$predictions

# Calculating median and IQR for An contents for plagioclase values 
An_median <- round(apply(predAn, 1, median), digits = 0)
An_sd <-round(apply(predAn,1,sd),0)
# Check values 
An_median
An_sd

#------------------------------(4) THERMOMETRY---------------------------------#
# Load models
load("liquid_noH2O_thermometer2.Rdata") # H2O-independent thermometer
load("liquid_thermometer2.Rdata") # H2O-dependent thermometer 

# If using H2O-dependent thermometer with an independent H2O estimate, add in H2O column to input dataframe
dropcolumns <- c("Ref","Sample","T","Type","plag_sat_check")
INPUTwH2O = inputdata[,!(names(inputdata) %in% dropcolumns)]
INPUTwH2O

# Run models (H2O-independent thermometer) 
predT_liq <- predict(liquidT_noH2O_final, data = INPUT, predict.all = TRUE)
predT_liq <- predT_liq$predictions

# Run models (H2O-dependent thermometer) 
predTwH2O_liq <- predict(liquidT_final, data = INPUTwH2O,predict.all =TRUE)
predTwH2O_liq <- predTwH2O_liq$predictions

# Calculating median and SD for temperature values (H2O-independent thermometer)
Tliq_median <- round(apply(predT_liq, 1, median), digits = 0)
Tliq_sd <-round(apply(predT_liq,1,sd),0)
# Check values 
Tliq_median
Tliq_sd

# Calculating median and SD for temperature values (H2O-dependent thermometer)
TwH2Oliq_median <- round(apply(predTwH2O_liq, 1, median), digits = 0)
TwH2Oliq_sd <-round(apply(predTwH2O_liq,1,sd),1)
# Check values 
TwH2Oliq_median
TwH2Oliq_sd

#-----------------------------(5) HYGROMETRY-----------------------------------#
# Load models
load("liquid_hygrometer2.Rdata") # T-dependent hygrometer
load("liquid_hygrometernoT2.Rdata") # T-independent hygrometer 

# Adding T values to input dataframe for T-dependent hygrometer
INPUTH2O <-cbind(INPUT,Tliq_median)
INPUTH2O <- INPUTH2O %>% dplyr::rename(T = Tliq_median)

# If using T-dependent hygrometer with an independent T estimate, add in T column to input dataframe
dropcolumns <- c("Ref","Sample","H2O","Type","plag_sat_check")
INPUTwT = inputdata[,!(names(inputdata) %in% dropcolumns)]
INPUTwT

# Run models (T-dependent hygrometer; use either INPUTH2O or INPUTwT for 'newdata =')
predH2O_liq <- predict(liquidH2O_final, data = INPUTH2O, predict.all = TRUE) 
predH2O_liq <- predH2O_liq$predictions

# Run models (T-independent hygrometer)
predH2OnoT_liq <- predict(liquidH2OnT_final, data = INPUT, predict.all = TRUE)
predH2OnoT_liq <- predH2OnoT_liq$predictions

# Calculating median and SD for H2O content values (T-dependent hygrometer)
H2Oliq_median <- round(apply(predH2O_liq, 1, median), 1)
H2Oliq_sd <-round(apply(predH2O_liq,1,sd),1)
# Check values 
H2Oliq_median
H2Oliq_sd

# Calculating median and SD for H2O content values (T-independent hygrometer)
H2OnoTliq_median <- round(apply(predH2OnoT_liq, 1, median), 1)
H2OnoTliq_sd <-round(apply(predH2OnoT_liq,1,sd),1)
# Check values 
H2OnoTliq_median
H2OnoTliq_sd

#------------------------------(6) BAROMETRY-----------------------------------#
# Load models
load("liquid_barometer2.Rdata") # H2O-dependent barometer 
load("liquid_barometernoH2O2.Rdata") # H2O-independent barometer 

# Adding H2O values to input dataframe for H2O-dependent barometer
INPUTP <-cbind(INPUT,H2Oliq_median)
INPUTP <- INPUTP %>% dplyr::rename(H2O=H2Oliq_median)

# Run models (H2O-dependent barometer; if using with independent H2O estimate, swap INPUTP for INPUTwH2O for 'newdata =')
predP_liq <- predict(liquidP_final, data = INPUTP, predict.all = TRUE) 
predP_liq <- predP_liq$predictions

# Run models (H2O-independent barometer)
predPnw_liq <- predict(liquidPnoH2O_final, data = INPUT, predict.all = TRUE) 
predPnw_liq <- predPnw_liq$predictions

# Calculating median and SD for P values (H2O-dependent barometer)
Pliq_median <- round(apply(predP_liq, 1, median), 1)
Pliq_sd <-round(apply(predP_liq,1,sd),1)
# Check values
Pliq_median
Pliq_sd

# Calculating median and SD for P values (H2O-independent barometer)
Pnwliq_median <- round(apply(predPnw_liq, 1, median), 1)
Pnwliq_sd <-round(apply(predPnw_liq,1,sd),1)
# Check values
Pnwliq_median
Pnwliq_sd

#----------------------(7) FILTERING & SAVING ESTIMATES------------------------#
# Save results (take out # to include models or add in # to remove unused models)
OUTPUT <- cbind(inputdata, An_median,An_sd,
                Tliq_median,Tliq_sd,
                #TwH2Oliq_median,TwH2Oliq_sd, 
                H2Oliq_median,H2Oliq_sd,
                #H2OnoTliq_median, H2OnoTliq_sd,
                Pliq_median,Pliq_sd,
                Pnwliq_median,Pnwliq_sd)
write_xlsx(OUTPUT,"eruption_estimates.xlsx")

# Set up filters (currently removes values above 75th quantile for P-T-An and values above 50th quantile for H2O)
An_quantile <- quantile(An_sd, c(0.75)) 
T_quantile <- quantile(Tliq_sd, c(0.75)) 
TwH2O_quantile <- quantile(TwH2Oliq_sd, c(0.75)) 
H2O_quantile <- quantile(H2Oliq_sd, c(0.75)) 
H2OnT_quantile <- quantile(H2OnoTliq_sd, c(0.75)) 
P_quantile <- quantile(Pliq_sd, c(0.75)) 
Pnw_quantile <- quantile(Pnwliq_sd, c(0.75)) 

# Filter all estimates (take out # to include models or add in # to remove unused models)
filtered_OUTPUT <- OUTPUT %>% mutate(An_median = replace(An_median, An_sd >= An_quantile, NA),
                                     An_sd = replace(An_sd, An_sd >= An_quantile, NA),
                                     Tliq_median = replace(Tliq_median, Tliq_sd >= T_quantile,NA),
                                     Tliq_sd = replace(Tliq_sd, Tliq_sd >= T_quantile,NA),
                                     #TwH2Oliq_median = replace(TwH2Oliq_median, TwH2Oliq_sd >= TwH2O_quantile,NA),
                                     #TwH2Oliq_sd = replace(TwH2Oliq_sd, TwH2Oliq_sd >= TwH2O_quantile,NA),
                                     H2Oliq_median = replace(H2Oliq_median, H2Oliq_sd >= H2O_quantile,NA),
                                     H2Oliq_sd = replace(H2Oliq_sd, H2Oliq_sd >= H2O_quantile,NA),
                                     H2OnoTliq_median = replace(H2OnoTliq_median, H2OnoTliq_sd >= H2OnT_quantile,NA),
                                     H2OnoTliq_sd = replace(H2OnoTliq_sd, H2OnoTliq_sd >= H2OnT_quantile,NA),
                                     Pliq_median = replace(Pliq_median, Pliq_sd >= P_quantile, NA),
                                     Pliq_sd = replace(Pliq_sd, Pliq_sd >= P_quantile, NA),
                                     Pnwliq_median = replace(Pnwliq_median, Pnwliq_sd >= Pnw_quantile, NA),
                                     Pnwliq_sd = replace(Pnwliq_sd, Pnwliq_sd >= Pnw_quantile, NA))

# Save filtered file 
write_xlsx(filtered_OUTPUT,"eruption_estimates_filtered.xlsx")
#write_xlsx(plag_saturated,"glass_plagsaturated.xlsx")


