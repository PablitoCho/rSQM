#' LoadCmip5DataFromAdss
#'
#' Download clipped national level CMIP5 data from APCC's ADSS
#' Apec Climate Center Data Service System
#'
#' @param dbdir directory where downloaded data located
#' @param NtlCode 2 digit country(national) code
#'
#' @export
#'
LoadCmip5DataFromAdss <- function(dbdir, NtlCode) {

  fname <- paste("cmip5_daily_", NtlCode, ".zip", sep="")

  if(nchar(NtlCode)==4 && substr(NtlCode,1,2)=="US"){
    adss <- "ftp://cis.apcc21.org/CMIP5DB/US/"
  }else{
    adss <- "ftp://cis.apcc21.org/CMIP5DB/"
  }

  srcfname <- paste(adss, fname, sep="")
  dstfname <- paste(dbdir, "/", fname, sep = "")
  download.file(srcfname, dstfname, mode = "wb")
  unzip(dstfname, exdir = dbdir)
  unlink(dstfname, force = T)
  cat("CMIP5 scenario data at",NtlCode,"is successfully loaded.\n")
}

