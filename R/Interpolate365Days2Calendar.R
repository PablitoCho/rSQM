Interpolate365Days2Calendar <- function(df, sdate) {
  sdate <- as.Date(sdate)
  # convert end date of 360 day(1979-12-30) to end date of calendar day (1979-12-31)
  edate <- df[length(df[,1]),1]
  year <- as.numeric (format(edate,"%Y"))
  month <- as.numeric (format(edate,"%m"))
  day <- 31
  datestr <- paste(year,month,day,sep="-")
  edate <- as.Date(datestr,"%Y-%m-%d")
  # create continuous time series (full dates) as data frame
  fdate <- data.frame(seq(sdate, edate, by=1))
  colnames(fdate) <- "date"
  # merge data using all=T
  df <- merge(fdate, df, by="date", all=T)
  # interpolate NA between two existing values by excluding date column
  df <- zoo::na.approx(df[2:length(df[1,])], na.rm=F)
  # add date column again
  df <- cbind(fdate,df)
  return(df)
}
