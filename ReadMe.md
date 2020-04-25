<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Bet-Hedging Paper Analysis Scripts](#bet-hedging-paper-analysis-scripts)
  - [Main Loading Scripts](#main-loading-scripts)
  - [No Temperature Tracking](#no-temperature-tracking)
  - [Null Distribution of Preference](#null-distribution-of-preference)
  - [Thermal Preference Persistence](#thermal-preference-persistence)
  - [Life History Curves](#life-history-curves)
  - [Thermal Preference Plasticity](#thermal-preference-plasticity)
  - [Modeling Bet-Hedging Advantage](#modeling-bet-hedging-advantage)
    - [Map of Bet-Hedging Advantage](#map-of-bet-hedging-advantage)
    - [Seasonal Dynamics of Mean Preference](#seasonal-dynamics-of-mean-preference)
  - [Thermal Preference Variability](#thermal-preference-variability)
  - [Thermal Preference Heritability](#thermal-preference-heritability)
  - [Genetic Diversity Analysis](#genetic-diversity-analysis)
  - [Two-Choice Assay Design](#two-choice-assay-design)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Bet-Hedging Paper Analysis Scripts

*created by Jamilla Akhund-Zade on 4-24-2020*

This repository contains all of the scripts used to run the modeling and experimental data analysis for the bet-hedging project in the de Bivort lab. All analysis was run using R and MATLAB platforms. The scripts are partitioned by the experiment/model. 

The datasets corresponding to the scripts will be available on the de Bivort lab website

**Plotting note:** some MATLAB scripts require the gramm package for data visualization. Installation [here](https://github.com/piermorel/gramm).   

## Main Loading Scripts

These are scripts used for processing and filtering positional data exported by [MARGO](https://github.com/de-Bivort-Lab/margo) (beta). MARGO is a MATLAB-based object tracking software, and the output of the beta version of MARGO (used exclusively for all the acquired experimental data) is a .mat file. The following scripts MATLAB-exclusive.

`createTempPref.m` - the main loading function that takes all of the raw experimental .mat files in a single folder and outputs an `expmts` struct and a `tempPref` cell array. The `expmts` struct has the experimental meta-data, raw centroid values, time stamps, and calculated temperature preference metrics for each experimental file. The `tempPref` cell array is temperature preference metrics + labels of all flies across the experiment files.

The `tempPref` column labels are as follows (rows correspond to individual flies): 

1. occupancy of hot side (0-1)

2. distance traveled in px

3. vector of positions over time (used in plotting raw positional data)

4. x-position of top left corner of tunnel in captured camera image (px)

5. y-position of top left corner of tunnel in captured camera image (px)

6. length of tunnel in captured camera image (px)

7. width of tunnel in captured camera image (px)

8. x-position of tunnel center (px)

9. y-position of tunnel center (px)

   

`twoChoicePref.m` - function to calculate occupancy score for `tempPref` cell array. Called by `createTempPref.m`.

`splitROI.m` - function that splits tunnel, so that positional data can be matched with the cold and hot sides. Called by `twoChoicePref.m`.

`activityThresholding.m` - thresholds fly activity based on % of time spent moving. `thresh` parameter should range from 0 -1, with 0 - no movement acceptable and 1 - only constantly moving flies acceptable. 

`removeInactiveBouts.m` - removes bouts where a fly does not move more than `dist` px for longer than `time` and recalculates temperature preference. In addition, subsamples centroid data to `subsampleRate` to decrease file size. Timing parameters are in units of frames. Called by `activityThresholding.m`. 

`plotting4hrTracks.m` - function to plot raw positional traces, along with color coding the positions on the hot side (orange) and cold side (blue). 

`tempPrefToDegrees.m` - function to transform occupancy score (0-1) into a ºC temperature preference based on tunnel temperatures (limited to 20ºC vs 28ºC setpoints). Calls on .mat files in **calibrated-tunnel-temps**. 

**calibrated-tunnel-temps** - folder with .mat files with measured tunnel temperatures across all assay set ups when temperature control set to 20ºC vs 28ºC setpoints (exclusively used in my study). Three .mat files - `bostonTunnelTemps.mat` for the 3 Harvard assay set ups, `virginiaTunnelTemps.mat`  for the UVA assay set up, and `miamiTunnelTemps.mat`  for the UMiami assay set up. 

## No Temperature Tracking

`tempofftracking.m` - analysis scripts for processing experimental data from flies navigating the tunnels without no temperature stimulus. Used to determine the coefficients of the power curve of the relationship between sampling error and distance traveled (for use in the variability experiment). 

`occupancyByDistTrav.m` - function to calculate the sampling error vs. distance traveled. Called by `tempofftracking.m`. 

**tempOFF_RAL535** - folder containing raw experimental data, `tempOffData.mat` - output of `occupancyByDistTrav.m`, `powerFits.mat` - power curve fits to sampling error vs. distance traveled, `GOF_powerFits.mat` - goodness-of-fit metrics for power curve fits. 

## Null Distribution of Preference

`nullDistributionAnalysis.m` - analysis scripts to create null distribution of thermal preference based on bout resampling of experimental data. 

`nullDistribution.m` - function to create simulated fly tracks based on experimental data. Called by `nullDistributionAnalysis.m`. 

`createBoutArray.m` - function to split experimental positional data into "bouts" on the cold and hot sides. Called by `nullDistributionAnalysis.m`. 

**data** directory

- `MA_11_38_nullDist_BoutResampling.mat` - struct with output of `nullDistribution.m` for an <u>isofemale line</u> and observed data/metrics on that line. 
- `SomA_nullDist_sampling.mat` - struct with output of `nullDistribution.m` for an <u>isogenic line</u> and observed data/metrics on that line. 

## Thermal Preference Persistence

`persistenceAnalysis_SomA_trpA1quant.m` - analysis scripts for looking at persistence of thermal preference of flies from SomA isogenic line and correlation of thermal preference to *trpA1* expression.

`modelExplainedBehaviorVariation.m` - (created by Matt Churgin, de Bivort Lab) function to model behavioral variance explained as a function of behavioral persistence and true correlation between latent variable of interest (e.g. transcript expression) with behavior. Used to calculate how much behavioral variation is explained by *trpA1* transcript expression variation. 

**SomA_Persistence** - folder with .mat files; `SomA_trpA1_quant_boxlabel.mat` - behavioral data for SomA (and some RAL535) flies, `SomAquantTranscripts.mat` - transcript quantification data for select SomA flies. 

## Life History Curves

`ThermPref vs Fitness Analysis.R` - R scripts for exploratory data analysis of life history traits of FL, MA, VA, isofemale lines and relationship of life history traits to individual temperature preference. 

`ThermPref vs Fitness Modeling.R` - R scripts for modeling the relationship between rearing temperature, place of origin, and thermal preference with life history traits for FL, MA, VA isofemale lines. 

`Life History Curves.R` - R scripts for fitting a curve to the relationship between temperature and development time/lifespan for FL, MA, VA isofemale lines. Used in the updated life history model to calculate bet-hedging advantage. 

**data** - CSV files with life history traits/behavioral data; processed data from CSVs in `Fitness.RData` and life history data used in Kain *et al.* model in `Kain 2015 Life History Curves.RData`. 

## Thermal Preference Plasticity

`PlasticityDataAnalysis.m` - MATLAB script for processing behavioral data from thermal preference plasticity experiment; creates CSV file for input into Stan model.

`PlasticityAnalysis.R` - R script to run Stan model (`stanThermoWSampEst_degC.stan`), plot posterior distributions, and do sampler diagnostics.

`stanThermoWSampEst_degC.stan` - Stan model used by the Rstan package in `PlasticityAnalysis.R` to  generate posterior distributions of thermal preference mean and variability estimates. For use with thermal preference metric in ºC. 

**data** - .mat files with behavioral data and .csv file with processed behavioral data for input into the Stan model. 

**stan-output** - output of the sampler run; `Plasticity_FixedPhiPsi.RData` - posterior distribution values; `SimulatedPlasticityVals_FixedPhiPsi.RData` - simulated data from posterior values for diagnostic checks. 

## Modeling Bet-Hedging Advantage

Main directory for all bet-hedging modeling in the project. Split into two sub-directories 1) map of predicted bet-hedging advantage, 2) modeling seasonal dynamics of mean preference

**data** - .mat files of weather data and calibrated stations from Kain *et al.* (2015) 

- `hedgeWeatherPack.mat` - Kain *et al.* (2015) 2007-2011 climate normals data
- `stationDataBatch.mat` - Kain *et al.* (2015) bet-hedging advantage for ~1500 random weather stations
- `seasonalAverages.mat` - climate normals 1981-2010 for the seven sampling locations

**scripts** - workhorse functions for modeling bet-hedging advantage

- `hedgeAnalytic.m`  - workhorse function for simulating bet-hedging and adaptive tracking populations; implements the analytical model of a effectively infinite population reproducing over a breeding season, under alternate modes of behavioral heritability (0 - bet-hedging, 1 - adaptive tracking), and alternate simulated weather conditions.
- `hedgeBDCalibrate.m` - function that performs a hill-climbing algorithm to determine the values of birth (b) and death (d) rates in the model that satisfy the two assumptions (constant population size at the beginning and end of the season, and constant mean phototactic preference at the start and end of the season). This can be used to automatically calibrate the model for arbitrary weather and seasonal conditions. All calibration is done under an adaptive-tracking strategy, and only accommodates daily mean temperature data (i.e. not daily deviations or cloud cover, thus the calibration is deterministic). Calls `hedgeAnalytic.m`. 

### Map of Bet-Hedging Advantage

**data** - .mat files with bet-hedging advantage data, and plotting data

- `stationDataAll.mat` - bet-hedging advantage calculated for 7501 stations using `betHedgeAdvantageCalc.m` and updated model
- `hedgeColorMaps.mat` - colormaps for map visualization from Kain *et al.* (2015) 
- `hedgeStateBoundaries.mat` - state boundaries for map visualization from Kain *et al.* (2015) 
- `allSamplingLocations_LatLong.mat ` - latitude/longitude for the seven sampling locations
- `North_america98_48&PR.png` - updated state boundaries 

**scripts** - analysis scripts for modeling geographic bet-hedging advantage

- `geographicBetHedging.m` - scripts to make color map of bet-hedging advantage with Gaussian convolution to imitate dispersal of fly populations; localized predictions for sampling locations. 
- `hedgeMakeStationMap_new.m` - workhorse function for making the color map; adapted from Kain *et al.* (2015) 
- `betHedgeAdvantageCalc.m` - wrapper function for batch submission to cluster of `hedgeGeographyAll.m` 
- `hedgeGeographyAll.m` - function that reads in weather data one location at a time and attempts to fit birth and death parameters for the seasonal weather at that location. If the parameters are fit, runs a bet-hedging scenario at this location and collects summary data of this location and the model performance here. Calls `hedgeAnalytic.m` and `hedgeBDCalibrate.m` (adapted from Kain *et al.* (2015)). 

### Seasonal Dynamics of Mean Preference

**data** - .mat files with behavioral and weather data for 2018 seasonal collections

- `stationData2018.mat` - 2018 daily temperature data for FL, MA, and VA sampling locations
- `seasonalTempPref_2018.mat` - behavioral data for flies sampled in 2018 from FL, MA, and VA
- `CollectionWeeks.mat` - mapping between day of the year and the collection week

**scripts** - analysis scripts for modeling seasonal dynamics of preference and calculating log-likelihood ratios

- `BreedingSeasonSim2018.m` - scripts to plot predicted preference dynamics vs. observed mean preference
- `calibratingBDrates.m` - scripts to calibrate birth/death rates given climate normals for a particular location
- `LikelihoodAnalysis_SeasonalData.m` - scripts to calculate log-likelihood ratio of bet-hedging vs. adaptive tracking given observed data. Calls `calculateLogLikelihood.m` and `logLikBootstrap.m`. 
- `calculateLogLikelihood.m` - function to calculate the log-likelihood ratio given predicted dynamics and observed data
- `logLikBootstrap.m` - function to do bootstrap resampling of observed data in order to calculate the uncertainty in the log-likelihood ratio estimate. 

## Thermal Preference Variability

**data** directory

- **input-data** - .mat files with raw behavioral data for isofemale lines and processed behavioral data in .csv files ready for analysis with Stan
- **stan-output** 
  - `VariabilityXXXXHierModel_FixedPhiPsi.RData` - values of posterior distributions for thermal preference mean and variability; `2018` - Nov/Dec 2018 batch, `2019 ` - Jan 2019 batch, `Apr2019` - Apr 2019 batch, `Total2019` - Jan + Apr 2019 batches combined. 
  - `SimulatedXXXXVals_FixedPhiPsi.RData` - simulated data from posterior values for diagnostic checks. `2018` - Nov/Dec 2018 batch, `2019 ` - Jan 2019 batch, `Apr2019` - Apr 2019 batch, `Total2019` - Jan + Apr 2019 batches combined. 
  - `Site (Line) Averages Variability.RData` - sampling site (isofemale line) average posterior estimates of variability + s.d. of posterior distribution.

**scripts** directory

- `VariabilityEstimation.R` - R script for processing thermal preference data, running Stan model, processing/plotting posterior distributions, and diagnostic checks of sampler output. Calls `stanThermoHierarchicalWSampEst_degC.stan`. 
- `VariabilityAnalysis.m` - MATLAB script for loading and pre-processing of raw thermal preference behavioral data; generates input data as .csv for Stan model. 
- `stanThermoHierarchicalWSampEst_degC.stan` - Stan hierarchical model for estimating line variability nested under sampling site variability. 

## Thermal Preference Heritability

**data** directory

- `parents_fltd.mat` - processed behavioral data from all parental flies
- `midParentValues.mat` - struct with the thermal preference of female and male parents, and the average preference of the parents; includes both the occupancy data (col1 of `parents_fltd.mat`) and ºC (col21 of `parents_fltd.mat`). Output of `heritCrossesTempPref.m`. 
- `heritabilityCrosses.mat` - label array of parental IDs and corresponding cross ID label. 
- `F1_TempPref.mat` - raw behavioral data of F1s from crosses. `F1_TempPref_fltd.mat` is the processed behavioral data of F1s. 

**scripts** directory

- `HeritabilityAnalysis.m` - scripts to process F1 data, pair behavioral data from parents and F1s, and plot/analyze mid parent-offpsring regression. Calls `heritCrossesTempPref.m` and `summarizeF1TempPref.m`. 
- `heritCrossesTempPref.m` - function to make `midParentValues.mat`. 
- `summarizeF1TempPref.m` - function to take in F1 data, get average preference of F1s grouped by cross, and filter out crosses that are not present in both datasets. Outputs a struct to use for regression analysis. 

## Genetic Diversity Analysis

Please see the [variant calling pipeline Github repository](https://github.com/jamilla-az/variant-calling-pipeline) for scripts relating to processing of sequencing data and generation of VCF files/PoPOOLation metrics. This directory contains only the script used in assessing the relationship between thermal preference heritability/variability and final estimates of population genetic diversity. 

**data** directory

- **frac_missing** - output of vcftools (.imiss) to calculate the fraction of missing genotypes for each sequenced individual. 
- **mean_depth** - output of vcftoolds (.idepth) to calcualte average depth per individual when making a genotype call. 
- **new bootstrapping** - directory with output of custom CyVCF/Python bootstrapping analysis to estimate Watterson's theta
  - *herit_boot_all_sites* - tables with counts of segregating sites for flies used in heritability analysis, sorted by sampling site (population). Output of bootstrapping analysis. 
  - *var_boot_all_sites* - tables with counts of segregating sites for flies used in the heritability analysis, sorted by sampling site (population). Output of bootstrapping analysis. 
  - *var_line_count_all_sites* - tables with counts of segregating sites for flies used in the heritability analysis, sorted by isofemale line. Raw counts, no bootstrapping. 
- **popoolation** - directory with output of PoPOOLation estimates of Watterson's theta
  - *herit* - heritability flies, *var* - variability flies
    - *.theta* files - contain the theta estimates across the whole genome in 50kb non-overlapping windows using the pileup file generated for each sampling site (population).
    - *.theta.param* files - shows the parameters used in the theta estimation
    - *xx_bam_herit_merge.txt* files - list of BAM files merged to make pileup file for theta estimation  
- `Heritability (Variability) Theta Estimates.RData` - processed segregating sites/theta estimates from custom boostrapping and PoPOOLation for heritability (variability) flies. 

`VariabilityAnalysis.R ` - scripts to process theta estimates from both the bootstrapping and PoPOOLation analyses, plot relationship of theta estimates to thermal preference heritability/variability, and calculate correlations. Calls on `Site (Line) Averages Variablity.RData` found in the directory for thermal preference variability. 

## Two-Choice Assay Design

**pid-controller** directory

- `PIDController.sch` - EAGLE schematic of connections for the custom Arduino-based temperature PID controller 
- `PIDController_FourIBT2Hbridges.ino` - Arduino script to do PID temperature control

**laser-cut-design** directory

- **outer-box** - PDF files with schematics for roof, 3 walls, door, and PID controller base of the behavioral box. 
- **tray-design** - PDF files with schematics for transparent coverslips, peltier base dividers, and main tray with tunnels (single PDF contains both layers). 

**parts-list** directory

- *Thermo Rig Parts List.xlsx* - the vendors, catalog nos. (or links), quantities for components used to make a single behavioral box + trays. Requires: water chiller, water blocks as heatsinks for Peltiers (custom milled)



