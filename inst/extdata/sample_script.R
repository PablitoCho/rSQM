rm(list=ls()) # Be careful! This removes all object in your working environment.

Start <- Sys.time() # Start time of your work


##########################################
#### Step 1. Working Environments Setting.
##########################################
EnvList <- SetWorkingEnvironment(envfile = "D:/2017_APCC_SDTP/Sample_CC/rSQM.yaml")
# SetWorkingEnvironment() sets up all the attributes required to proceed process.
# You need to give it 4 parameters.
# First, the path to the basedir created beforhand. In this sample case, "/Sample_basedir" will be used.
#   When you carry out your own work, create the base directory named as what you want, and give it the path.
# Second, the NtlCode that denotes the region you want to downscale. In this sample case, just use "NtlCode" itself.
#   When your own project, visit http://adss.apcc21.org/DataSet/CMIP5/cmip5.jsp and find the National Code you need.
# Third, the project name. This will be the name of the project directory which stores the procedure result.
#   Distinguishable names are better so that you would not be confused with multiple projects in a base directory.
# Last but not least, envfile is the external yaml file which contains the essential parameters for the project.
#   In this sample case, an example yaml file is prepared in advance. However, when you do your own work,
#   should write it by yourself and place it in your base directory. Run your eyes through the sample yaml file!
#   Sure that You can get how to fill in it easily.


#######################################
#### Step 2. Load climate scenario data
#######################################
#LoadCmip5DataFromAdss(dbdir = EnvList$dbdir, NtlCode = EnvList$NtlCode)
# LoadCmip5DataFromAdss() downloads CMIP5 climate change scenario data from ADSS.
# ADSS refers to APEC Climate Center Data Service System.
# This scenario data is essential input for this downscaling process.
# Go and see some details. http://adss.apcc21.org


#####################################################
#### Optional Step. Load climatological observations.
#####################################################
# GhcnDailyUpdate(
#   NtlCode = EnvList$NtlCode,
#   ghcndir = EnvList$ghcndir,
#   syear_obs = EnvList$syear_obs,
#   eyear_obs = EnvList$eyear_obs)
# If you already had your own obsercation data, this step is of no avail.
# Otherwise, you can download observation data from GHCN over the area you want to downscale.
# GHCN refers to Global Historical Climatology Network.
# Unfortunately, when you use data from GHCN, some regions have a lot of missing values.
# Go and see some details. https://www.ncdc.noaa.gov/ghcn-daily-description


#######################################
#### Step 3. Downscale Daily CMIP5 data
#######################################
DailyExtractAll(
  cmip5dir = EnvList$cmip5dir,
  stndir = EnvList$stndir,
  stnfile = EnvList$stnfile,
  qmapdir = EnvList$qmapdir,
  SimAll = EnvList$SimAll,
  ModelNames = EnvList$ModelNames,
  RcpNames = EnvList$RcpNames,
  VarNames = EnvList$VarNames,
  OWrite = EnvList$OWrite)
# Now that you have all necessary input data, let`s begin the downscaling.
# This extracts daily time series for every combination of varialbes, GCM models, and RCP scenarios as text format.


############################
#### Step 4. Bias-Correction
############################
DailyQMapAll(
  stndir = EnvList$stndir,
  stnfile = EnvList$stnfile,
  qmapdir = EnvList$qmapdir,
  prjdir = EnvList$prjdir,
  SimAll = EnvList$SimAll,
  RcpNames = EnvList$RcpNames,
  VarNames = EnvList$VarNames,
  syear_obs = EnvList$syear_obs,
  eyear_obs = EnvList$eyear_obs,
  syear_his = EnvList$syear_his,
  eyear_his = EnvList$eyear_his,
  syear_scn = EnvList$syear_scn,
  eyear_scn = EnvList$eyear_scn,
  OWrite = EnvList$OWrite,
  SRadiation = EnvList$SRadiation)
# Bias-Correction Using Quantile Mapping and Save the Bias-Corrected Output for Each Weather Station
# The results are to be stored in project_directory/SQM

End <- Sys.time() # End time of your work.
End - Start # In many cases, it is recommended to check the elapsed time for computing.


#### Some tips.
# 1. A process over this package needs to connect to web server to download required data.
#     This means that unstable internet connectivity fails works.
# 2. If you think it is bothersome to type such a lot of parameters, use the advantage of do.call() built-in function.
#     You can just go with like do.call(DailyQMapAll, EnvList), which makes life easier.

