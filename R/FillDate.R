FillDate <- function(x, sdate=NULL, edate=NULL) {

  if(!missing(sdate) & !missing(edate)){
    sdate = as.Date(sdate)
    edate = as.Date(edate)
    imsi = as.data.frame(seq(sdate, edate, by=1))
    colnames(imsi) = "date"

    x = x[which(x[,1]>=sdate & x[,1]<=edate),]

    data = merge(imsi, x, all=T)

    year=as.numeric (format(data[,1],"%Y"))
    mon=as.numeric (format(data[,1],"%m"))
    day=as.numeric (format(data[,1],"%d"))
    yearmon=as.character (format(data[,1],"%Y-%m"))
    data <- cbind(year, mon, day, yearmon, data)
  }

  if(!missing(sdate) & missing(edate)){
    sdate = as.Date(sdate)
    nrows = length(x[,1])
    date = seq(sdate, sdate+nrows-1, by=1)

    data = cbind.data.frame(date, x)

    year=as.numeric (format(data[,1],"%Y"))
    mon=as.numeric (format(data[,1],"%m"))
    day=as.numeric (format(data[,1],"%d"))
    yearmon=as.character (format(data[,1],"%Y-%m"))
    data <- cbind(year, mon, day, yearmon, data)

  }

  if(missing(sdate) & missing(edate)){
    x[,1]=as.Date(x[,1])
    year=as.numeric (format(x[,1],"%Y"))
    mon=as.numeric (format(x[,1],"%m"))
    day=as.numeric (format(x[,1],"%d"))
    yearmon=as.character (format(x[,1],"%Y-%m"))
    data <- cbind(year, mon, day, yearmon, x)
  }

  return(data)

}
