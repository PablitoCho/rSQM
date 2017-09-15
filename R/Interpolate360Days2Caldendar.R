Interpolate360Days2Caldendar <- function(df, sdate) {
  sdate <- as.Date(sdate)
  # convert end date of 360 day(1979-12-30) to end date of calendar day (1979-12-31)
  edate <- df[length(df[,1]),1]
  # create continuous time series (full dates) as data frame
  fdate <- data.frame(seq(sdate, edate, by=1))
  colnames(fdate) <- "date"
  # merge data using all=T
  df <- merge(fdate, df, by="date", all=T)
  # interpolate NA between two existing values by excluding date column
  df <- zoo::na.approx(df[2:length(df[1,])], na.rm=F)
  # fill the last row of missing data using previous values
  df[which(is.na(df[,1])),] <- df[which(is.na(df[,1]))-1,]
  # add date column again
  df <- cbind(fdate,df)
  return(df)
}
