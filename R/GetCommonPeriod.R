GetCommonPeriod <- function(obs, rcp, sdate=NULL, edate=NULL) {

  colnames(obs) <- c("year", "mon", "day", "yearmon", "date", "obs_prcp", "obs_tmax", "obs_tmin", "obs_wspd", "obs_rhum", "obs_rsds")

  if(!missing(sdate) & !missing(edate)){
    sdate <- as.Date(sdate)
    osdate <- obs[1,"date"]
    rsdate <- rcp[1,"date"]
    edate <- as.Date(edate)
    oedate <- obs[nrow(obs),"date"]
    redate <- rcp[nrow(rcp),"date"]
    if(sdate<osdate | sdate<rsdate | edate>oedate | edate>redate){

      sdate <- max(sdate, osdate, rsdate)
      edate <- min(edate, oedate, redate)
      data <- merge(obs, rcp)
      data <- data[which(data[, "date"]>=sdate & data[, "date"]<=edate),]
      data <- data[order(data["date"]),]
      cat("Warning: Start or end dates are out of range\n")
      cat(sprintf("Data are merged: sdate %s to edate %s\n", sdate, edate))

    }
    else {
      data <- merge(obs, rcp)
      data <- data[which(data[,"date"]>=sdate & data[,"date"]<=edate),]
      data <- data[order(data["date"]),]
    }
  } else {
    data <- merge(obs, rcp)
    data <- data[order(data["date"]),]
    cat(sprintf("Data are merged: sdate %s to edate %s\n", data[1,"date"], data[nrow(data),"date"]))
  }
  return(data)
}
