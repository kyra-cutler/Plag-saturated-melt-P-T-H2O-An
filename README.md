# Plagioclase-saturated liquid hygrothermobarometry and plagioclase-liquid equilibria using machine learning 

These R scripts allow users to obtain estimates of pre-eruptive storage conditions (P-T-H2O-An) using plagioclase-saturated liquids. Users must have R (https://www.r-project.org/) and R studio (https://www.rstudio.com/products/rstudio/) installed to run the code, as well as have a version of Excel that can open .xlsx files.

To get started: 

1) Click on the green code button and download zip file. Do not remove or delete any files within this folder.

2) Enter your normalised glass compositional data into the INPUT.xlsx spreadsheet. All oxide (wt.%) columns must be filled or entered with zero. 

3) Open the P_T_H2O_An.R script and follow the comments.  Within the script, you can also:
- check whether your glass compositions are within the calibration ranges of the models.
- check whether your glass compositions represent plagioclase-saturated liquids.
- use independent T and H2O estimates/measurements as inputs for the H2O-dependent thermometer, T-dependent hygrometer and H2O-dependent barometer. 
- filter P-T-H2O-An estimates based on the standard deviation (i.e., removing values above the 75th quartile for the P-T-An models or above the 50th quartile for the H2O models).

4) If you want to propagate the temperature and water content errors when using the T-dependent hygrometer and H2O-dependent barometer, open the T and H2O error propagation.R script.
 
5) If you want test using a range of water contents with the H2O-dependent barometer, then open up the H2O content range for barometer.R script. 

Any questions, email: kyra.cutler@stx.ox.ac.uk  

