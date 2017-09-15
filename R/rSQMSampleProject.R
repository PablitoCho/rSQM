#' rSQMSampleProject
#'
#' Build environment settings, create necessary directories and load sample data.
#'
#' @export
#'
rSQMSampleProject <- function() # Function Name Should be modified.
{

  if(dir.exists("Sample_basedir")){stop("Sample Project Directory has been already created.\n")}
  # Creates necessary directories
  baseDir <- "Sample_basedir";  SetWorkingDir(baseDir)
  prjDir <- file.path(baseDir,"Sample_prj"); SetWorkingDir(prjDir)
  qmapDir <- file.path(prjDir,"SQM"); SetWorkingDir(qmapDir)
  dbDir <- file.path(baseDir,"Database"); SetWorkingDir(dbDir)
  cmip5Dir <- file.path(dbDir,"cmip5_daily_NtlCode"); SetWorkingDir(cmip5Dir)
  stndir <- file.path(dbDir, "Sample_prj"); SetWorkingDir(stndir)
  bndDir <- file.path(stndir,"gis-boundary"); SetWorkingDir(bndDir)
  ghcnDir <- file.path(stndir,"ghcn-daily_download"); SetWorkingDir(ghcnDir)

  deco <- function()
  {
    total <- 20
    # create progress bar
    pb <- txtProgressBar(min = 0, max = total, style = 3)
    for(i in 1:total){
      Sys.sleep(0.1)
      # update progress bar
      setTxtProgressBar(pb, i)
    }
    close(pb)
  }

  mise::mise(vars = FALSE, figs=FALSE)
  aa <- function(){
    cat("\n")
    cat("\t APEC Climate Center. www.apcc21.org \n\n")
    cat("\t Statistical Downscaling Package 'rSQM'\n")
    cat("\t Environmental Setting for Sample Project.\n")
    deco()
    cat("\n\t Environment Settings Done.\n\n")
  }
  aa()


  bb <- function(){
    cat("*************************Directory Structure********************************\n\n")
    cat("\t\t\t\t*-------cmip5_daily_NtlCode\n")
    cat("\t\t\t\t|\t(cmip5dir)\n")
    cat("\t*-------Database--------*\n")
    cat("\t|\t(dbdir)\t\t|\n")
    cat("\t|\t\t\t*-------Sample_prj\n")
    cat("\t|\t\t\t\t(stndir)\n")
    cat("\t|\t\t\t\n")
    cat("\t|\t\t\t\n")
    cat("\t|\t\t\t\n")
    cat("Sample_basedir\n")
    cat("(basedir)\n")
    cat("\t|\n")
    cat("\t*-------Sample_prjdir\n")
    cat("\t\t(prjdir)\n")
    cat("\n")
    cat("*************************Directory Description*****************************\n\n")
    cat("basedir : The base directory for users to perform Quantile-Mapping and\n\t")
    cat("  Bias-Correction for daily CMIP5 data.\n\n")
    cat("dbdir : The database directory to store daily-CMIP5 data, gis-boundary data,\n\t")
    cat("observation data, and station information data\n\n")
    cat("cmip5dir : The directory to store Clipped CMIP5 scenario data on daily basis.\n\t")
    cat("   This CMIP5 data is to be downloaded from ADSS, APEC Climate Center\n")
    cat("\t   Data Service System, as NetCDF files\n\n")
    cat("stndir : The directory to store station infomation andclimatological observation data.\n")
    cat("\t There are two ways to prepare observation data\n")
    cat("\t 1. If you have your own custom observation data, put them in this\n")
    cat("\t    directory.\n")
    cat("\t 2. Otherwise, You can use GHCN, Global Historical Climatory Network, \n")
    cat("\t    which provides global climatological observations, such as TMAX/TMIN\n")
    cat("\t    and PRCP etc. They are nationally clipped and served as csv files.\n\n")
    cat("prjdir : The project directory to store results. For each downscaling method,\n")
    cat("\t corresponding subdirectory is created and contains the results.\n\n")
  }
  bb()



  spl_env <- system.file("extdata", "Sample_rSQM.yaml", package = "rSQM")
  spl_stn_info <- system.file("extdata", "Sample_3-Stations.csv", package = "rSQM")
  spl_stn_dat1 <- system.file("extdata", "Sample_ID108.csv", package = "rSQM")
  spl_stn_dat2 <- system.file("extdata", "Sample_ID133.csv", package = "rSQM")
  spl_stn_dat3 <- system.file("extdata", "Sample_ID159.csv", package = "rSQM")
  spl_script <- system.file("extdata", "Sample_script.R", package = "rSQM")
  cc <- function(){
    cat("\tLoad Sample Observation and Station data.\n")
    ## Sample Data Location Description
    if(!file.copy(spl_env, baseDir))
        { stop("\tAn error occurs when sample data loaded, reinstall package and try again.\n\tIf does not work again, contact <pablito@apcc21.org>, the maintainer.") }
    if(!file.copy(spl_stn_info, stndir))
        { stop("\tAn error occurs when sample data loaded, reinstall package and try again.\n\tIf does not work again, contact <pablito@apcc21.org>, the maintainer.") }
    if(!file.copy(spl_stn_dat1, stndir))
        { stop("\tAn error occurs when sample data loaded, reinstall package and try again.\n\tIf does not work again, contact <pablito@apcc21.org>, the maintainer.") }
    if(!file.copy(spl_stn_dat2, stndir))
        { stop("\tAn error occurs when sample data loaded, reinstall package and try again.\n\tIf does not work again, contact <pablito@apcc21.org>, the maintainer.") }
    if(!file.copy(spl_stn_dat3, stndir))
        { stop("\tAn error occurs when sample data loaded, reinstall package and try again.\n\tIf does not work again, contact <pablito@apcc21.org>, the maintainer.") }
    if(!file.copy(spl_script, baseDir))
        { stop("\tAn error occurs when sample data loaded, reinstall package and try again.\n\tIf does not work again, contact <pablito@apcc21.org>, the maintainer.") }
    deco()
    cat("\n")
    cat("*************************Sample Station and Observation Data Loaded********************************\n")
    cat("\tSample station infomation and obseravation data are loaded in", stndir,",(stndir).\n")
    cat("\tand the R script(Sample_script.R) to run the sample project with sample data\n")
    cat("\t is located in", baseDir,",(basedir). Have a look and enjoy it!\n\n")
    cat("\t APEC Climate Center. www.apcc21.org \n")
  }
  cc()






} # End of RunSampleProject()

