globalVariables(c("Mon", "value", "variable"))
#' ObsDataSummary
#'
#' @param obsdir directory path for station information file
#' @param stnfile file name for station information
#' @param VarNames string vector contains variables names
#' @param syear_obs start year of observation data
#' @param eyear_obs end year of observation data
#'
#' @export
#'
#'
ObsDataSummary  <- function(obsdir, stnfile, VarNames, syear_obs, eyear_obs) {

  options(stringsAsFactors = FALSE)

  stninfo <- read.csv(file.path(obsdir, stnfile), header = T)

  smrydir <- sprintf("%s/summary", obsdir)
  if(!dir.exists(smrydir)){dir.create(smrydir, recursive = F, showWarnings = F)}

  for(j in 1:length(VarNames)){

    summarytbl <- matrix(NA,12, nrow(stninfo)*2)
    varnm <- VarNames[j]

    for(i in 1:nrow(stninfo)){
      stnid <- stninfo[i, "ID"]
      FDname <- sprintf("%s/%s.csv", obsdir, stnid)
      obsdata <- read.csv(FDname, header=TRUE, stringsAsFactors = FALSE, na.strings = c("-99",-99))
      colnames(obsdata) <- c("Year","Mon","Day","pr","tasmax", "tasmin", "sfcWind", "rhs", "rsds", "shine", "cloud", "tavg")
      obsdata$Date <- as.Date(sprintf("%d-%02d-%02d", obsdata$Year, obsdata$Mon, obsdata$Day))

      sdate <- as.Date(sprintf("%d-01-01", syear_obs))
      edate <- as.Date(sprintf("%d-12-31", eyear_obs))
      Date <- as.data.frame(seq(sdate, edate, by ="day"))
      colnames(Date) <- c("Date")

      tempobs <- merge(Date, obsdata, all=T)
      tempobs <- tempobs[which(tempobs$Date >= sdate & tempobs$Date <= edate), c("Mon", varnm)]

      aggdata <- aggregate(.~Mon, data=tempobs, FUN=mean,na.rm=TRUE)
      #colnames(aggdata) <- c("mon", stnid)

      summarytbl[, i] <- aggdata[,2]


      #########count NA's in data
      nadata <- matrix(NA,12,length(varnm))
      for(i_month in 1:12){
        wh1 <- which(tempobs[,"Mon"]== i_month)
        nadata[i_month,1] <- (sum(is.na(tempobs[wh1,c(varnm)]))/length(wh1))*100
      }
      summarytbl[,(i+nrow(stninfo))] <- nadata[,1]
    }

    colnames(summarytbl) <- c(stninfo$ID, paste(stninfo$ID, "(NA%)", sep=""))
    month = as.data.frame(seq(1, 12, 1)); colnames(month) = c("Mon")
    summarytbl <- cbind(month, summarytbl)

    OutDFile <- paste(smrydir,"/", varnm ,".csv",sep="")
    write.csv(summarytbl, OutDFile, row.names = FALSE)

    PlotDFile <- paste(smrydir,"/", varnm ,".png",sep="")
    temp <- summarytbl[,c("Mon", stninfo$ID)]
    PData <- reshape2::melt(temp, id= c("Mon"))

    g <- ggplot(data=PData, aes(x=Mon,y=value))+
      geom_line(aes(colour=variable)) + geom_point(aes(colour=variable)) +
      labs(title = varnm) + theme(plot.title = element_text(hjust=0.5))
    ggsave(PlotDFile, g)

  }


}


