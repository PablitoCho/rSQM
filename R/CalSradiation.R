CalSradiation <- function(obs, stnid, stndir, stnfile) {

  if(!any(is.na(obs$tmin)) & !any(is.na(obs$tmax))){
    obs$tmin[obs$tmin > obs$tmax] = obs$tmax[obs$tmin > obs$tmax]
  }
  stns <- read.csv(file.path(stndir, stnfile) ,header=T)
  stns <- stns[,c("ID","Y")]
  colnames(stns) <- c('ID', 'Lat')
  lat <- stns[which(stnid == stns[,1]),2]
  jday <- strptime(obs[,c("date")], "%Y-%m-%d")$yday+1

  isNA <- which(is.na(obs[,"rsds"]) & !is.na(obs[,"tmax"]) & !is.na(obs[,"tmin"]))
  if(length(isNA[]) >= 1) {
    obs[isNA,"rsds"] = EcoHydRology::Solar(lat,jday[isNA], obs[isNA,"tmax"], obs[isNA,"tmin"], latUnits='degrees')/1000.0
    # 1000: Unit conversion kj/m2/day --> MJ/m2 (Default unit of Solar() is Kj/m2)
  }
  return(obs)
}
