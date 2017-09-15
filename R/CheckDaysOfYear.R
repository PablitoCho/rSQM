CheckDaysOfYear <- function(sdate, edate, nday) {


  sdate = as.Date(sdate)
  edate = as.Date(edate)

  difcald = as.integer(edate - sdate + 1)
  difmon = (zoo::as.yearmon(edate)- zoo::as.yearmon(sdate))*12 + 1
  dif360d = as.integer(difmon + 0.5) * 30
  dif365d = as.integer(difmon + 0.5) /12  * 365

  if(abs(nday - difcald) <5) { str = "cald" }
  if (abs(nday - dif365d) <5) { str = "365d" }
  if (abs(nday - dif360d) <5) { str = "360d" }

  return(str)

}
