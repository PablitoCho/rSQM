Fill365Date <- function(df, sdate) {

  sdate = as.Date(sdate)
  #edate = as.Date(edate)
  syear = as.numeric (format(sdate,"%Y"))
  nrow = length(df[,1])
  eyear = syear+ nrow/365 - 1
  #  as.numeric (format(edate,"%Y"))
  nyear = eyear - syear + 1

  year = c(syear:eyear)
  years = sapply(year, function (x) rep(x,365))
  years = as.vector(years)
  years = as.data.frame(years)
  colnames(years) = "year"

  mons = rep(c(rep(1,31), rep(2,28), rep(3,31), rep(4,30), rep(5,31), rep(6,30), rep(7,31), rep(8,31), rep(9,30), rep(10,31), rep(11,30), rep(12,31)),nyear)
  #mons = as.vector(mon)
  mons = as.data.frame(mons)
  colnames(mons) = "month"

  days = rep(c(c(1:31),c(1:28),c(1:31),c(1:30),c(1:31),c(1:30),c(1:31),c(1:31),c(1:30),c(1:31),c(1:30),c(1:31)),nyear)
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
