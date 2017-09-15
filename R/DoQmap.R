#' DoQmap
#'
#' Apply quantile mapping information obtained from historical period to the future period
#'
#' @param qmf Quantile mapping information created from historical period using GetQmapFit function
#' @param rcpdata GCM modeled data before bias-correction
#' @param varnm Variable name among "prcp", "tmax", "tmin", "wspd", "rhum", "rsds"
#' @param monid Month in integer
#' @param sdate Starting date for applyig quantile mapping
#' @param edate Ending date for applyig quantile mapping
#'
#' @return rcpadj Bias-corrected output data using quantile mapping
#' @export
#'
DoQmap <- function(qmf, rcpdata, varnm, monid, sdate, edate) {

  sdate = as.Date(sdate)
  edate = as.Date(edate)

  qmf = get(qmf)

  rcpprd = rcpdata[which(rcpdata[,2]==monid & rcpdata[,4]>=sdate & rcpdata[,4]<=edate),which(colnames(rcpdata)==varnm)]

  date = rcpdata[which(rcpdata[,2]==monid & rcpdata[,4]>=sdate & rcpdata[,4]<=edate), 4]

  rcpadj = qmap::doQmap(rcpprd, qmf)
  rcpadj = cbind.data.frame(date, rcpadj)
  colnames(rcpadj) = c("date", varnm)

  rcpadj[,2] = rcpadj[,2]

  return(rcpadj)
}
