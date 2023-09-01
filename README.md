# Plagioclase-saturated melt hygrothermobarometry and plagioclase-melt equilibria using machine learning 

These R scripts allow users to assess plagioclaso-melt equilibrium and obtain estimates of last-equilbrated conditions (P-T-H2O-An) using plagioclase-saturated liquids. Users must have R (https://www.r-project.org/) and R studio (https://www.rstudio.com/products/rstudio/) installed to run the code, as well as have a version of Excel that can open .xlsx files.

To get started: 

1) Click on the green code button and download zip file. Do not remove or delete any files within this folder.

2) Enter your normalised glass compositional data into the INPUT.xlsx spreadsheet. All oxide (wt.%) columns must be filled or entered with zero. 

3) Open the P_T_H2O_An.R script and follow the comments to attain P-T-H2O-An esimates.  Within the script, you can also:
- check whether your glass compositions are within the calibration ranges of the models.
- check whether your glass compositions represent plagioclase-saturated liquids.

 --> Section 3 in the script should be run first to obtain predictions of equilibrium plagioclase compositions that can be compared to your plagioclase EPMA analyses. Sections 4, 5 and 6 in the ‘P-T-H2O-An.R’ script allow you to obtain temperature, water content and pressure predictions. If you want to use the T or H2O-dependent models, check the comments to ensure you have added all the input parameters for the model you want to run.

Filtering and saving estimates:

All estimates will be saved as an Excel file (.xlsx). The file will contain the original input data + the calculated parameters (P-T-H2O-An). You can filter the P-T-H2O-An estimates by removing the highest standard deviation values (i.e., currently set up to remove values above the 75th quartile for the P-T-An models or above the 50th quartile for the H2O models; feel free to change).

Error propagation of T or H2O:

If you want to propagate the temperature and water content errors when using the T-dependent hygrometer and H2O-dependent barometer, open up the ‘T and H2O error propagation.R’ script. Do not clear your global environment, as you can combine the output from the ‘P_T_H2O_An.R’ script with the output from the ‘T and H2O error propagation.R’ script.

Testing a range of water contents:

If you want to test using a range of water contents with the H2O-dependent thermometer or barometer, then open up the ‘H2O content range.R’ script. Again, do not clear your global environment, as you can combine the output from the ‘P_T_H2O_An.R’ script with the output from the ‘H2O content range.R’ script.

Any questions, please email: kyra.cutler@stx.ox.ac.uk  

