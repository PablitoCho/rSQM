#' DailyQMapAll
#'
#' Do bias-correction using quantile mapping ans save the bias-corrected outputs for each weather station.
#'
#' @param stndir directory path for station information file
#' @param stnfile file name for station information
#' @param qmapdir directory path for bias-corrected output files
#' @param prjdir directory path for project
#' @param SimAll logical. TRUE then process goes over all the senarios available
#' @param RcpNames Rcp names to be uses such as rcp45, rcp85
#' @param VarNames variable to be used such as prcp(precipitation), tmax/tmin, solor radiation, wind etc
#' @param syear_obs start year of observation data
#' @param eyear_obs end year of observation data
#' @param syear_his start year of historical period
#' @param eyear_his end year of historical period
#' @param syear_scn start year of climate change scenario
#' @param eyear_scn end year of climate change scenario
#' @param OWrite Flag for overwriting output files (T: Overwrite, F: Skip)
#' @param SRadiation Flag for calculating solar radiation (T: Calculate, F: Skip)
#'
#'
#' @export
#'
#'
DailyQMapAll <- function(stndir, stnfile, qmapdir, prjdir, SimAll, RcpNames, VarNames, syear_obs, eyear_obs, syear_his, eyear_his, syear_scn, eyear_scn, OWrite, SRadiation) {

  HistSDate <- as.Date(paste(syear_his, "-01-01", sep=""))
  HistEDate <- as.Date(paste(eyear_his, "-12-31", sep=""))
  SDates <- as.Date(paste(syear_scn, "-01-01", sep=""))
  EDates <- as.Date(paste(eyear_scn, "-12-31", sep=""))
  OWrite <- as.logical(OWrite)
  SRadiation <- as.logical(SRadiation)
  SimAll <- as.logical(SimAll)

  # Decide Common period option
  if(syear_obs == syear_his & eyear_obs == eyear_his) {
    CPeriod <- TRUE
  } else {
    CPeriod <- FALSE
  }

  if(SimAll == TRUE){
    varnms = c("prcp", "tmax", "tmin", "wspd", "rhum", "rsds")
    scnnms <- c('historical', 'rcp26', 'rcp45', 'rcp60', 'rcp85')
  } else {
    VarAll = c("pr", "tasmax", "tasmin", "sfcWind", "rhs", "rsds")
    FixedVarNms <- c("prcp", "tmax", "tmin", "wspd", "rhum", "rsds")
    LocNum = grep(paste(VarNames, collapse = "|"), VarAll)
    varnms <- FixedVarNms[LocNum]

    scnnms <- unique(c('historical', RcpNames))
  }

  # Observed output folder
  obsoutdir <- file.path(prjdir, "Downscale", "OBS")
  unlink(obsoutdir, recursive = T)
  SetWorkingDir(obsoutdir)

  varcnt <- length(varnms)
  scncnt <- length(scnnms)

  ###### Get Station ID, lat, and Lon information
  stninfo <- read.csv(file.path(stndir, stnfile), header=T)
  stninfo <- stninfo[,c("ID", "Lon", "Lat")]
  stnnms <- matrix(stninfo$ID)
  stncnt <- length(stnnms)

  ###### Get model names
  ModelNames <- list.dirs(qmapdir, recursive = F)
  Model_Matrix <- matrix(unlist(strsplit(ModelNames, "/")), nrow=length(ModelNames), byrow=T)
  ModelNames <- Model_Matrix[,ncol(Model_Matrix)]
  Model_Cnt <- length(ModelNames)

  for (mm in 1:Model_Cnt) {
    Model_Name <- ModelNames[mm]

    # Check the file exists(check the last station file)
    stnnmlast <- stnnms[length(stnnms)]
    ofiletest <- paste(qmapdir, "/", Model_Name, "/",  stnnmlast, "_SQM_", Model_Name, "_historical.csv", sep="")
    fcheck <- file.exists(ofiletest)

    # if final outfile already exists
    if((!fcheck)|OWrite) {

      indir <- paste(qmapdir, "/", Model_Name, '/365adj', sep="")
      outdir <- paste(qmapdir, "/", Model_Name, sep="")

      #### Repeated for converting to date type and can be deleted
      HistSDate <- as.Date(HistSDate)
      HistEDate <- as.Date(HistEDate)
      # Start & End date for future scenarios
      SDates <- as.Date(SDates)
      EDates <- as.Date(EDates)

      for (k in 1:stncnt) {

        stnid <- stnnms[k]
        rcpdata <- Cmip5Var2Stn(stnid, varnms, scnnms[1], indir, Model_Name)
        obsdata <- ReadObsData(stnid, stndir)  #read obs data(read -99.0 as NA)
        colnames(obsdata) <- c("year", "mon", "day", "yearmon", "date", "prcp", "tmax", "tmin", "wspd", "rhum", "rsds")

        if(SRadiation){
          obsdata <- CalSradiation(obsdata, stnid, stndir, stnfile)
        }

        if(CPeriod){
          mrgdata <- GetCommonPeriod(obsdata, rcpdata)
          if(nrow(mrgdata)==0) {next}

          # Maximum common period between Obs and RCP dataset
          comsdate <- min(mrgdata[, "date"])
          comedate <- max(mrgdata[, "date"])

          # Print original values
          SetWorkingDir(outdir)

          # Extract Obs & Rcp data for common period
          rcpdata <- rcpdata[which(rcpdata[, "date"]>=comsdate & rcpdata[, "date"]<=comedate),]
          obsdata <- obsdata[which(obsdata[, "date"]>=comsdate & obsdata[, "date"]<=comedate),]
          obsdata[is.na(obsdata)] <- "-99"

          # Write RCP data without BC
          #obsoutdir <- file.path(prjdir, "OBS")
          #SetWorkingDir(obsoutdir)
          outfile <- paste(obsoutdir, "/", stnid, "_observed.csv", sep="")
          #outfile = paste(Model_Name,"_",stnid,"_original.csv", sep="")
          if(!file.exists(outfile) | OWrite == T){
            write.csv(obsdata[, !(names(obsdata) %in% c("yearmon", "date"))], outfile, row.names=F)
          }


          # Write Obs data without BC
          outfile <- paste(qmapdir, "/", Model_Name, "/",  stnid, "_SQM_", Model_Name, "_historical_original.csv", sep="")
          write.csv(rcpdata[, !(names(rcpdata) %in% c("yearmon", "date"))], outfile, row.names=F)

          # summary for before the bias correction
          mrgdata <- mrgdata[which(mrgdata[, "date"] >= HistSDate & mrgdata[, "date"] <= HistEDate),]


        } else {   # If common period is False

          # Print original values
          SetWorkingDir(outdir)

          colnames(obsdata) <- c("year", "mon", "day", "yearmon", "date", "obs_prcp", "obs_tmax", "obs_tmin", "obs_wspd", "obs_rhum", "obs_rsds")
          ObsSDate <- as.Date(paste(syear_obs, "-01-01", sep=""))
          ObsEDate <- as.Date(paste(eyear_obs, "-12-31", sep=""))
          obsdata <- obsdata[which(obsdata$date >= ObsSDate & obsdata$date <= ObsEDate), ]

          #obsoutdir <- file.path(prjdir, "OBS")
          #SetWorkingDir(obsoutdir)
          obsprint <- obsdata
          colnames(obsprint) <- c("year", "mon", "day", "yearmon", "date", "prcp", "tmax", "tmin", "wspd", "rhum", "rsds")
          outfile <- paste(obsoutdir, "/", stnid, "_observed.csv", sep="")
          if(!file.exists(outfile) | OWrite == T){
            write.csv(obsprint[, !(names(obsprint) %in% c("yearmon", "date"))], outfile, row.names=F)
          }


          # Use historical period (1976~2005)
          rcpdata <- rcpdata[which(rcpdata[ ,"date"] >= HistSDate & rcpdata[ ,"date"] <= HistEDate),]

          #outfile = paste(Model_Name,"_",stnid,"_original.csv", sep="")
          #write.csv(rcpdata[-c(1:3)], outfile, row.names=F)
          outfile <- paste(qmapdir, "/", Model_Name, "/",  stnid, "_SQM_", Model_Name, "_historical_original.csv", sep="")
          write.csv(rcpdata[, !(names(rcpdata) %in% c("yearmon", "date"))], outfile, row.names=F)



          # if CPeriod is False, monthly graph is not provided

        } # End of if(CPeriod)

        ############ Calculate QMapping fit
        for(i in 1:varcnt){
          varnm <- varnms[i]
          for(j in 1:12){
            qmfnm <- paste("qmf", varnms[i],j, sep = "_")

            if(CPeriod){
              assign(qmfnm, GetQmapFit(mrgdata, varnm, j))
            } else {
              assign(qmfnm, GetQmapFit2(obsdata, rcpdata, varnm, j))
            }
          }
        }

        ##############################################################################
        ############ QMapping for historical period

        # Final start & end period based on Comsdate, comedate, HistSDate, HistEDate)
        if(CPeriod){
          sdate <- min(mrgdata[, "date"])
          edate <- max(mrgdata[, "date"])
        } else {
          sdate <- HistSDate
          edate <- HistEDate
        }

        for(j in 1:12){ # j for month
          for(i in 1:varcnt){
            varnm <- varnms[i]
            qmf <- paste("qmf", varnm, j, sep = "_")

            ### It takes error"Error in get(qmf) : object 'qmf_prcp_1' not found"
            # So, run QMapping without function
            #rcpimsi = DoQmap(qmf, rcpdata, varnm, j, sdate, edate)
            sdate <- as.Date(sdate); edate <- as.Date(edate)
            monid <- j
            qmf <- get(qmf)

            rcpprd <- rcpdata[which(rcpdata[ ,"mon"] == monid & rcpdata[ ,"date"] >= sdate & rcpdata[ ,"date"] <= edate), which(colnames(rcpdata) == varnm)]
            date <- rcpdata[which(rcpdata[ ,"mon"] == monid & rcpdata[ ,"date"] >= sdate & rcpdata[ ,"date"] <= edate),"date"]

            if(all(is.na((qmf$par)$fitq)) | length(table((qmf$par)$fitq)) == 1){
              rcpimsi <- rcpprd; rcpimsi[] = -99
            } else {
              # if all rcp data is missing(NA: -99)
              if(sum(!(rcpprd == -99))>0){
                rcpimsi <- qmap::doQmap(rcpprd, qmf)
              }else {
                rcpimsi <- rcpprd; rcpimsi[] = -99
              }
            }

            rcpimsi <- cbind.data.frame(date, rcpimsi)
            colnames(rcpimsi) <- c("date", varnm)
            ### End of QMapping

            if(i == 1){
              rcpadj <- rcpimsi
            } else {
              #rcpadj = cbind.data.frame(rcpadj, rcpimsi[,varnm])
              rcpadj <- merge(rcpadj, rcpimsi)
            }
          }
          if(j == 1) {
            rcphist <- rcpadj
          }else {
            rcphist <- rbind(rcphist, rcpadj)
          }

        }
        rcphist <- rcphist[order(rcphist["date"]),]
        #colnames(rcphist) = c("date",varnms)
        rcphist <- FillDate(rcphist)

        # replace with -99 if the variable is missing
        if(length(unique(rcpdata$prcp)) == 1) {rcphist$prcp = -99.0}
        if(length(unique(rcpdata$tmax)) == 1) {rcphist$tmax = -99.0}
        if(length(unique(rcpdata$tmin)) == 1) {rcphist$tmin = -99.0}
        if(length(unique(rcpdata$wspd)) == 1) {rcphist$wspd = -99.0}
        if(length(unique(rcpdata$rhum)) == 1) {rcphist$rhum = -99.0}
        if(length(unique(rcpdata$rsds)) == 1) {rcphist$rsds = -99.0}


        SetWorkingDir(outdir)
        #outfile = paste(Model_Name,"_",stnid,"_",scnnms[1],".csv", sep="")
        #write.csv(rcphist[-c(1:3)], outfile, row.names=F)
        outfile <- paste(qmapdir, "/", Model_Name, "/",  stnid, "_SQM_", Model_Name, "_", scnnms[1], ".csv", sep="")
        write.csv(rcphist[, !(names(rcphist) %in% c("yearmon", "date"))], outfile, row.names=F)

        if(CPeriod == T){
          # Check the bias-corrected data using graph (Only when CPeriod  is True)
          mrgdata = GetCommonPeriod(obsdata, rcphist)
        }


        ############### QMapping for scenario period
        for (n in 1:4) {

          srchstr <- paste("*", scnnms[(n+1)],"*prcp.csv", sep="")
          flist <- list.files(indir, pattern = glob2rx(srchstr), full.names = F)
          nfile <- length(flist)

          if(nfile==0) {
            cat(sprintf("## Missing all variables in RCP=%s \n", scnnms[(n+1)]))
          } else {

            rcpdata <- Cmip5Var2Stn(stnid, varnms, scnnms[(n+1)], indir, Model_Name)
            outfile <- paste(qmapdir, "/", Model_Name, "/",  stnid, "_SQM_", Model_Name, "_", scnnms[(n+1)], "_original.csv", sep="")
            write.csv(rcpdata[, !(names(rcpdata) %in% c("yearmon", "date"))], outfile, row.names=F)
            for (m in 1:length(SDates[])){
              sdate <- SDates[m]
              edate <- EDates[m]
              for(j in 1:12){
                for(i in 1:varcnt){
                  varnm <- varnms[i]
                  qmf <- paste("qmf", varnm, j, sep = "_")
                  #rcpimsi = DoQmap(qmf, rcpdata, varnm, j, sdate, edate)
                  ### It takes error"Error in get(qmf) : object 'qmf_prcp_1' not found"
                  # So, run QMapping without function
                  sdate <- as.Date(sdate)
                  edate <- as.Date(edate)
                  monid <- j
                  qmf <- get(qmf)
                  rcpprd <- rcpdata[which(rcpdata[, "mon"]==monid & rcpdata[, "date"]>=sdate & rcpdata[, "date"]<=edate),which(colnames(rcpdata)==varnm)]
                  date <- rcpdata[which(rcpdata[, "mon"]==monid & rcpdata[, "date"]>=sdate & rcpdata[, "date"]<=edate),  "date"]

                  if(all(is.na((qmf$par)$fitq)) | length(table((qmf$par)$fitq)) == 1){
                    rcpimsi = rcpprd; rcpimsi[] <- -99
                  } else {
                    # if all rcp data is missing(NA: -99)
                    if(sum(!(rcpprd == -99))>0){
                      rcpimsi <- qmap::doQmap(rcpprd, qmf)
                    }else {
                      rcpimsi <- rcpprd; rcpimsi[] = -99
                    }
                  }
                  rcpimsi <- cbind.data.frame(date, rcpimsi)
                  colnames(rcpimsi) <- c("date", varnm)
                  ### End of QMapping

                  # combine variable output
                  if(i == 1){
                    rcpadj <- rcpimsi
                  } else {
                    #rcpadj = merge(rcpadj, rcpimsi)
                    rcpadj <- merge(rcpadj, rcpimsi)
                  }
                }
                # combine monthly output
                if(j == 1) {
                  rcpperiod <- rcpadj
                } else {
                  rcpperiod <- rbind(rcpperiod, rcpadj)
                }
              }

              # Combine scenario periods
              if(m == 1) {
                rcpscn <- rcpperiod
              } else {
                rcpscn <- rbind(rcpscn, rcpperiod)
              }

              cat(sprintf("Completed Models=%s  Station=%s  RCPs=%s  Periods=%s\n", Model_Name, stnid, scnnms[n+1], m))
            }
            rcpscn <- rcpscn[order(rcpscn["date"]),]
            #colnames(rcpscn) = c("date",varnms)
            rcpscn <- FillDate(rcpscn)

            # replace with -99 if the variable is missing
            if(length(unique(rcpdata$prcp)) == 1) rcphist$prcp <- -99.0
            if(length(unique(rcpdata$tmax)) == 1) rcphist$tmax <- -99.0
            if(length(unique(rcpdata$tmin)) == 1) rcphist$tmin <- -99.0
            if(length(unique(rcpdata$wspd)) == 1) rcphist$wspd <- -99.0
            if(length(unique(rcpdata$rhum)) == 1) rcphist$rhum <- -99.0
            if(length(unique(rcpdata$rsds)) == 1) rcphist$rsds <- -99.0


            SetWorkingDir(outdir)
            outfile <- paste(qmapdir, "/", Model_Name, "/",  stnid, "_SQM_", Model_Name, "_", scnnms[n+1], ".csv", sep="")
            write.csv(rcpscn[, !(names(rcpscn) %in% c("yearmon", "date"))], outfile, row.names=F)
          } # end of IF
        } # Scenario LOOP
        cat(sprintf("Station = %s process has been completed!\n\n", stnid))
      } # Station Loop
    } else {
      cat(sprintf("Model(%s) final output already exists and process has been skipped.\n\n", Model_Name))
    } # outfile exist and OWrite = F

    # Delete 365adj folders
    adjnm <- file.path(qmapdir, Model_Name, "365adj")
    unlink(adjnm, recursive = T)

  } # Model Loop
}
