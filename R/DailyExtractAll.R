#' DailyExtractAll
#'
#' Extract daily time series for every combination of varialbes, GCM models, and RCP scenarios as text format
#'
#' @param cmip5dir directory name contating daily CMIP5 data as NetCDF format
#' @param stndir directory name contating station information file
#' @param stnfile file name for station information
#' @param qmapdir directory name for storing extracted daily time series output
#' @param SimAll logical. TRUE then process goes over all the senarios available
#' @param ModelNames string vector contains climate change scenario models to be used
#' @param RcpNames Rcp names to be uses such as rcp45, rcp85
#' @param VarNames variable to be used such as prcp(precipitation), tmax/tmin, solor radiation, wind etc
#' @param OWrite Flag for overwriting output files (T: Overwrite, F: Skip)
#'
#'
#' @export
#'
DailyExtractAll <- function(cmip5dir, stndir, stnfile, qmapdir, SimAll, ModelNames, RcpNames, VarNames, OWrite) {

  SimAll <- as.logical(SimAll)
  OWrite <- as.logical(OWrite)

  # Empty qmapdir
  obsoutdir <- gsub("/SQM", "/OBS", qmapdir)
  unlink(obsoutdir, recursive = T)
  unlink(qmapdir, recursive = T)

  if(SimAll == TRUE){
    ModelNames <- GetVarLists4CMIP5(cmip5dir, 3)
    varn <- c('pr','tasmax','tasmin', 'sfcWind', 'rhs', 'rsds')
    rcpn <- c('historical', 'rcp26','rcp45', 'rcp60', 'rcp85')
  } else {
    varn <- VarNames
    rcpn <- unique(c('historical', RcpNames))
  }

  Model_Cnt <- length(ModelNames)
  for (i in 1:Model_Cnt) {

    Model_Name <- ModelNames[i]

    srchstr <- paste("*", Model_Name, "*.nc", sep="")
    flist <- list.files(cmip5dir, pattern = glob2rx(srchstr), full.names = F)
    nfile <- length(flist)

    if(nfile > 0) {

      # In order to use fixed variable names regardless selected models
      fixvarn <- c("prcp", "tmax", "tmin", "wspd", "rhum", "rsds")

      # Input and output directory based on selected model
      mdldir <- paste(qmapdir, "/", Model_Name, "/365adj", sep="")

      # Get Station ID, lat, and Lon information
#      setwd(stndir)
      stns <- read.csv(file.path(stndir, stnfile), header=T)
      stns <- stns[,c("ID", "Lon", "Lat")]

      #=========== Loop for RCP scenarios =================
      nscn <- length(rcpn)
      for (m in 1:nscn) {

        #=========== Loop for variables =================
        nvar <- length(varn)
        for (k in 1:nvar) {

          srchstr <- paste(varn[k], "*", Model_Name, "_", rcpn[m],"*.nc", sep="")
          flist <- list.files(cmip5dir, pattern = glob2rx(srchstr), full.names = F)
          nfile <- length(flist)

          # if rhs file doen not exist get the bottom layer value of hur data
          if(nfile == 0 & varn[k]=='rhs'){
            srchstr <- paste("hur*", Model_Name, "_", rcpn[m],"*.nc", sep="")
            flist <- list.files(cmip5dir, pattern = glob2rx(srchstr), full.names = F)
            nfile <- length(flist)
          }

          # if there is no selected files
          if(nfile==0) {

            cat(sprintf("Data is not available: Model=%s RCP=%s Variable=%s \n", Model_Name, rcpn[m], varn[k]))

            # if there is selected NetCDF files
          } else {

            outfile <- paste(Model_Name,"_",rcpn[m],"_",fixvarn[k],".csv", sep="")
            outfname <- file.path(mdldir, outfile)


            # if output .csv file exits
            if(file.exists(outfname) & OWrite == F){

              cat(sprintf("%s  %s already exists!\n", Model_Name, outfile))

              # if there is not output csv file
            } else {

              #=========== Loop for number of files for ecah variable ======
              for (j in 1:nfile){

                fname <- flist[j]

                # get the start date and end date information from the file name (ex "XXXXXXX_18500101-20051231.nc")
                splitstrs <- unlist(strsplit(flist[j], "_"))
                dateinfo <- splitstrs[length(splitstrs)]
                splitstrs <- unlist(strsplit(dateinfo, ".nc"))
                splitstrs <- unlist(strsplit(dateinfo, "-"))
                sdatecur <- as.Date(splitstrs[[1]],"%Y%m%d")
                edatecur <- as.Date(splitstrs[[2]],"%Y%m%d")
                #strat and end date for the overall simulation period
                if(j == 1) {sdate = sdatecur}
                if(j == nfile) {edate = edatecur}

                #============= Loop for stations
                nstn <- nrow(stns)
                for (n in 1:nstn) {
                  stnid <- stns[n,1]
                  x <- stns[n,2]
                  if(x < 0){
                    cat(sprintf("Longitude should be greater than zero. Please, convert with the range between 0 ~ 360.!\n"))
                  }
                  y <- stns[n,3]
                  # get the value of GCM grid based on the lat lon coordinate of stations and combine into columns
                  if (n == 1){
                    var <- data.frame(ExtractPointValue(x, y, fname, cmip5dir))
                  } else {
                    imsi <- data.frame(ExtractPointValue(x, y, fname, cmip5dir))
                    var <- cbind.data.frame(var, imsi)
                  }
                } # end of Station Loop
                colnames(var) <- stns$ID

                if (j == 1) {
                  varrbnd <- var
                } else {
                  imsi <- var
                  varrbnd <- rbind.data.frame(varrbnd, imsi)
                }
                cat(sprintf("Completed RCP=%s Variable=%s File=%s\n", rcpn[m], varn[i],flist[j]))
              } # end of NetCDF file Loop
              # unit conversion
              curvar = varn[k]
              # kg/m2/s --> mm/day
              if (curvar == "pr"){ varrbnd = varrbnd*86400.0 }
              # K --> C
              if ((curvar == "tasmax") | (curvar == "tasmin")){varrbnd= varrbnd-272.15}
              # % --> fraction
              if (curvar == "rhs"){varrbnd= varrbnd/100.0}
              # W/m2 --> MJ/m2
              if (curvar == "rsds"){varrbnd= varrbnd*0.0864}

              # check number of days per year
              nday <- nrow(varrbnd)
              str <- CheckDaysOfYear(sdate, edate, nday)

              if(str == "360d"){
                var <- Fill360Date(varrbnd, sdate)
                var <- Interpolate360Days2Caldendar(var, sdate)
              } else if (str == "365d") {
                var <- Fill365Date(varrbnd, sdate)
                var <- Interpolate365Days2Calendar(var, sdate)
              } else if (str == "cald") {
                var <- FillDate(varrbnd, sdate)
                var <- var[,-c(1:4)]
              } else {
                cat(sprintf("Error: exit loop=%s\n", fname))
              }

              # define format for print
              var <- format(var, digits = 4, nsmall=2, trim=T)
              #outfile = paste(Model_Name,"_",rcpn[m],"_",fixvarn[i],".csv", sep="")
              SetWorkingDir(mdldir)
              write.csv(var, file.path(mdldir, outfile), row.names=F)
              cat(sprintf("File=%s has been successfully created!\n\n", outfile))
            } # If outfile exists
          }  # If netCDF files exists
        } # end of Variable Loop
      } # end of Scenario Loop
    } else {
      warning("No nc file available. Try downloading again.")
    }
  }
}
