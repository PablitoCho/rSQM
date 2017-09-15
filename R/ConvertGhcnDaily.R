ConvertGhcnDaily <- function(dlydir, csvdir, dlyfile, csvfile) {

  DlyDFile <- paste(dlydir, "/", dlyfile, sep ="")
  CsvDFile <- paste(csvdir, "/", csvfile, sep ="")

  data <- read.fwf(DlyDFile, header = F, widths = c(11, 6, 4, rep(c(5, 3), 31)))
  data <- data[, c(1:3, seq(4, 64, by=2))]
  colnames(data) <- c("ID", "yearmon", "varnm", seq(1, 31))
  data[data == "-9999"] <- NA

  varnms <- c("PRCP", "TMAX", "TMIN", "AWND", "PSUN", "TAVG")
  varcnt <- length(varnms)

  sdate <- as.Date(sprintf("%s-%s-01", substr(data[1, "yearmon"], 1, 4), substr(data[1, "yearmon"], 5, 6)))
  daycnt <- NumberOfDays(as.Date(paste(substr(data[nrow(data), "yearmon"], 1, 4), "-", substr(data[nrow(data), "yearmon"], 5, 6), "-01", sep="")))
  edate <- as.Date(sprintf("%s-%s-%02d", substr(data[nrow(data), "yearmon"], 1, 4), substr(data[nrow(data), "yearmon"], 5, 6), daycnt))
  dates <- as.data.frame(seq(sdate, edate, by = "day"))
  colnames(dates) <- "date"
  dates$date <- as.character(dates$date)

  flag <- TRUE
  for(i in 1:varcnt){

    varnm <- varnms[i]
    val <- as.vector(t(data[which(data$varnm == varnm), 4:34]))

    if(length(val) > 0){

      if(varnm == "PSUN") {
        val <- as.numeric(val) / 100.0
      } else {
        val <- as.numeric(val) / 10.0
      }

      yearmon <- data[which(data$varnm == varnm), "yearmon"]
      yearmonstr <- rep(yearmon, each=31)
      daystr <- sprintf("%02d",rep(seq(1:31), length(yearmon)))
      datestr <- paste(substr(yearmonstr, 1, 4), "-", substr(yearmonstr, 5, 6), "-", daystr, sep="")

      if(flag){
        varout <- cbind(datestr, val)
        colnames(varout) <- c("date", varnm)
        flag <- FALSE
      } else {
        imsi <- cbind(datestr, val)
        colnames(imsi) <- c("date", varnm)
        varout <- merge(varout, imsi, all=T)
      }
    }

  }

  out <- merge(dates, varout)

  out[is.na(out)] <- "-99.00"
  out$Year <- substr(out$date, 1, 4)
  out$Mon <- substr(out$date, 6, 7)
  out$Day <- substr(out$date, 9, 10)

  if(!("PRCP" %in% colnames(out))) out$PRCP <- "-99.00"
  if(!("TMAX" %in% colnames(out))) out$TMAX <- "-99.00"
  if(!("TMIN" %in% colnames(out))) out$TMIN <- "-99.00"
  if(!("TAVG" %in% colnames(out))) out$TAVG <- "-99.00"
  if(!("AWND" %in% colnames(out))) out$AWND <- "-99.00"
  if(!("PSUN" %in% colnames(out))) out$PSUN <- "-99.00"
  if(!("SRAD" %in% colnames(out))) out$SRAD <- "-99.00"
  if(!("RHUM" %in% colnames(out))) out$RHUM <- "-99.00"
  if(!("CLOD" %in% colnames(out))) out$CLOD <- "-99.00"

  out <- out[c("Year", "Mon", "Day", "PRCP", "TMAX", "TMIN", "AWND", "RHUM", "SRAD", "PSUN", "CLOD", "TAVG")]
  colnames(out) <- c("Year", "Mon", "Day", "Pcp(mm)", "Tmax(c)", "Tmin(c)", "WSpeed(m/s)", "RHumidity(fr)", "SRad(MJ/m2)", "SShine(hr)", "Cloud(1/10)", "Tavg(c)")

  write.csv(out, CsvDFile, row.names = F)

}
