Fill360Date <- function(df, sdate) {

  sdate = as.Date(sdate)
  #edate = as.Date(edate)
  syear = as.numeric (format(sdate,"%Y"))
  nrow = length(df[,1])
  eyear = syear+ nrow/360
  #  as.numeric (format(edate,"%Y"))
  nyear = eyear - syear + 1

  year = c(syear:eyear)
  years = sapply(year, function (x) rep(x,360))
  years = as.vector(years)
  years = as.data.frame(years)
  colnames(years) = "year"

  mon = sapply(c(1:12), function (x) rep(x,30))
  mon = as.vector(mon)
  mons = rep(mon,nyear)
  mons = as.data.frame(mons)
  colnames(mons) = "month"

  day = c(1:30)
  day = rep(day,12)
  days = rep(day,nyear)
  days = as.data.frame(days)
  colnames(days) = "day"

  datestr = paste(years[[1]],mons[[1]],days[[1]],sep="-")

  date = as.Date(datestr,"%Y-%m-%d")

  srow = which(date[]==sdate)
  nrow = length(df[,1])
  erow = srow + nrow -1

  date = date[srow:erow]

  df = cbind.data.frame(date, df)

  df[,1] = as.Date(df[,1],"%Y-%m-%d")

  df = df[!is.na(df[,1]),]

  return(df)

}
