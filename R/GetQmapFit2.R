#' GetQmapFit2
#'
#' Get Quantile Mapping Fitting information when CommonPeriod option is Fale
#'
#' @param obsdata Observed data
#' @param rcpdata Scenario data
#' @param varnm name among "prcp", "tmax", "tmin", "wspd", "rhum", "rsds"
#' @param monid Month in integer
#'
#' @return qmf Fitting information by quantile mapping
#' @export
#'
GetQmapFit2 <- function(obsdata, rcpdata, varnm, monid) {

  #vars = c("prcp", "tmax", "tmin", "wspd", "rhum", "rsds")
  ovarnm = paste("obs_",varnm,sep="")
  rvarnm = varnm

  obsmon = obsdata[which(obsdata[,2]==monid),which(colnames(obsdata)==ovarnm)]
  obsmon = as.numeric(obsmon[!is.na(obsmon)])
  rcpmon = rcpdata[which(rcpdata[,2]==monid),which(colnames(rcpdata)==rvarnm)]

  if(varnm == "prcp"){
    qmf = qmap::fitQmap(obsmon, rcpmon, method="QUANT", qstep=0.01, wet.day=T, na.rm=T)
  } else {
    qmf = qmap::fitQmap(obsmon, rcpmon, method="QUANT", qstep=0.01, wet.day=F, na.rm=T)
  }


  return(qmf)
}
