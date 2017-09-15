#' ReadNetCDF4
#'
#' Read NetCDF file and extract necessary information
#'
#' @param wdir Work directory path
#' @param ncfile NetCDF file name
#'
#' @return outList Output list which includes longitude, latitude, variable, and NC file information
#' @export
#'
ReadNetCDF4 <- function(wdir, ncfile) {

  tmp <- getwd()
  setwd(wdir)

  fin = ncdf4::nc_open(ncfile)

  # Get the file information into array
  finfo = capture.output(print(fin))

  # Get the dimension, variable name, dimension names
  nrow=length(finfo[])
  for(i in 1:nrow){
    str = finfo[i]
    str = stringr::str_split_fixed(str,"float ",2)[2]
    if(!(str == "")){
      varnm = stringr::str_split_fixed(str, stringr::fixed("["), 2)[1]
      str = stringr::str_split_fixed(str, stringr::fixed("["), 2)[2]
      str = stringr::str_split_fixed(str, stringr::fixed("]"), 2)[1]
      dimsz = stringr::str_count(str, stringr::fixed(",")) + 1
      dimnms = stringr::str_split_fixed(str, stringr::fixed(","), dimsz)
    }
  }

  lon = ncdf4::ncvar_get(fin, dimnms[1])
  lat = ncdf4::ncvar_get(fin, dimnms[2])
  variable = ncdf4::ncvar_get(fin,varnm)

  # In the case of multiple layers, get the first layer (surface ) values
  if(varnm == 'hur'){
    variable = variable[,,1,]
  }

  outList = list("x"=lon, "y"=lat, "var"=variable, "fin"=finfo)

  ncdf4::nc_close(fin)
	
  setwd(tmp);rm(tmp)
  return(outList)

}
