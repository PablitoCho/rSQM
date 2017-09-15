#' ReadObsData
#'
#' Read observed data and add column of yearmon, date columns. The column order of input file should be "year", "month", "day", "Precipitation(mm)", "Max. Temperature (C)", "Min. Temperature (C)", "Wind speed(m/s)", "Relative Humidity (fr)",  "Solar Radiation (MJ/m2)".
#'
#' @param stnid station identification code
#' @param wdir Working directory
#'
#' @return data daily time series data after adding "yearmon" and "date" columns and delete "day" column. The column order of output file is ""year", "month", "yearmon", "date", "prcp", "tmax", "tmin", "wspd", "rhum", "rsds"
#' @export
#'
ReadObsData <- function(stnid, wdir) {

  tmp <- getwd()
  setwd(wdir)

  srchstr = paste("*", stnid, "*.csv", sep="")
  obsfile <- list.files(wdir, pattern = glob2rx(srchstr), full.names=F)

  obs = read.csv(obsfile, header=T, na.strings = c("-99.00", "-99.0", "-99", -99, "NA", NA))

  datestr <- paste(obs[[1]],obs[[2]],obs[[3]],sep="-")
  date <- as.Date(datestr,"%Y-%m-%d")
  obs = cbind(date, obs[,c(4:9)])

  year=as.numeric (format(obs[,1],"%Y"))
  mon=as.numeric (format(obs[,1],"%m"))
  day=as.numeric (format(obs[,1],"%d"))
  yearmon=as.character (format(obs[,1],"%Y-%m"))

  data <- cbind(year, mon, day, yearmon, obs)
  setwd(tmp); rm(tmp)
  return(data)
}
