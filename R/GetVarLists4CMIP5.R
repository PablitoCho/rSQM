GetVarLists4CMIP5 <- function(cmip5dir, coln) {


  srchstr = "*.nc"
  flist = list.files(cmip5dir, pattern = glob2rx(srchstr), full.names = F)
  varnm = sapply(strsplit(flist, "_"), function(x) x[[coln]])
  varnm = unique(varnm)

  return(varnm)

}
