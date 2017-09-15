#' ExtractPointValue
#'
#' Read NetCDF file and extract time-series of grid values based on latitude and longitude information
#'
#' @param xin Longitude in decimal degree
#' @param yin Latitue in decimal degree
#' @param ncfile File name of NetCDF file
#' @param wdir Directory path which contatins NetCDF files
#'
#' @return var Original values extracted from NetCDF files
#' @export
#'
ExtractPointValue <- function(xin, yin, ncfile, wdir) {

  # get x and y information
  nc = ReadNetCDF4(wdir, ncfile)
  x = nc$x
  y = nc$y
  var = nc$var

  ncols = length(x)
  nrows = length(y)

  xcoord = array(0, dim = c(ncols, 2))
  ycoord = array(0, dim = c(nrows, 2))

  for(i in 1:ncols){
    if(i == ncols){
      xcoord[i,1] = x[i] - (x[i]-x[i-1])/2.0
      xcoord[i,2] = x[i] + (x[i]-x[i-1])/2.0
    }else{
      xcoord[i,1] = x[i] - (x[i+1]-x[i])/2.0
      xcoord[i,2] = x[i] + (x[i+1]-x[i])/2.0
    }
  }

  for(i in 1:nrows){
    if(i == nrows){
      ycoord[i,1] = y[i] - (y[i]-y[i-1])/2.0
      ycoord[i,2] = y[i] + (y[i]-y[i-1])/2.0
    }else{
      ycoord[i,1] = y[i] - (y[i+1]-y[i])/2.0
      ycoord[i,2] = y[i] + (y[i+1]-y[i])/2.0
    }
  }

  colnum = which(xin >= xcoord[,1] & xin < xcoord[,2])
  rownum = which(yin >= ycoord[,1] & yin < ycoord[,2])

  if(length(dim(var)) == 3){
    var = var[colnum, rownum, ]
  } else if (length(dim(var)) == 4){
    var = var[colnum, rownum, , ]
  } else {
    print("Dimensions of the variable is greather than 4!")
  }

  return(var)

}
