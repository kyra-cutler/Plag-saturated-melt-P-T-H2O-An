# Plagioclase-saturated melt hygrothermobarometry and plagioclase-melt equilibria using machine learning 

These R scripts allow users to assess plagioclase-melt equilibrium and obtain estimates of last-equilibrated conditions (P-T-H2O-An) using plagioclase-saturated liquids. Users must have R (https://www.r-project.org/) and R studio (https://www.rstudio.com/products/rstudio/; at least version 4.3.1) installed to run the code, as well as have a version of Excel that can open .xlsx files. 

To get started:
1.	Click on the green code button and download the zip file. Do not remove or delete any files within this folder. 
2.	Enter your normalised glass compositional data into the INPUT.xlsx spreadsheet. All oxide (wt.%) columns must be filled or entered with zero.
3.	Open the ‘P_T_H2O_An.R’ script. Install the packages and load the libraries.
4.	Load your input data. You do not need to set a specific file pathway, as the script will find the location of the downloaded folder.
   
Obtaining estimates:
1.	Section 1 enables you to set up your R environment and check whether your glass compositions are within the calibration ranges of the models. 
2.	Section 2 allows you to check whether your matrix glass compositions represent plagioclase-saturated melts and filter out non-plagioclase-saturated melts. 
3.	Section 3 in the script gives predictions of equilibrium plagioclase compositions that can be compared to your plagioclase EPMA analyses. 
4.	Sections 4, 5 and 6 allow you to obtain temperature, water content and pressure predictions. If you want to use the T or H2O-dependent models, check the comments to ensure you have added all the input parameters for the model you want to run.

Error propagation of T or H2O:

   If you want to propagate the temperature and water content errors when using the T-dependent hygrometer and H2O-dependent barometer, open up the ‘T and H2O error propagation.R’ script. Do not clear your global environment, as you can use the calculated temperature + water estimates and standard deviation values from the P_T_H2O_An.R script to simulate new T and H2O values.

Testing a range of T/H2O contents:

   If you want to test using a range of water contents and temperatures with the H2O-dependent thermometer/barometer and T-dependent hygrometer, respectively, then open up the ‘T-H2O content range.R’ script. Again, do not clear your global environment, as you can combine the output from the ‘P_T_H2O_An.R’ script with the output from the ‘T-H2O content range.R’ script. 

Filtering and saving estimates:

   All estimates will be saved as an Excel file (.xlsx). The file will contain the original input data + the calculated parameters (P-T-H2O-An). You can filter the P-T-H2O-An estimates by removing the estimates with the highest standard deviation values (i.e., currently set up to remove values above the 75th quartile for the P-T-An models or above the 50th quartile for the H2O models; feel free to change).

Any questions, please email: kyra.cutler@stx.ox.ac.uk


![supplementary 6](https://github.com/kyra-cutler/Plag-saturated-melt-P-T-H2O-An/assets/75129991/0ce28829-2797-4e5a-9c59-91c4aef94322)


