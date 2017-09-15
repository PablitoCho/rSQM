#' NumberOfDays
#'
#' Decide number of days within the given month (date)
#'
#' @param date Input date
#'
#' @return nday Number of days within the given month
#' @export
#'
NumberOfDays <- function(date) {

  m <- format(date, format="%m")
  while (format(date, format="%m") == m)
  {
    date <- date + 1
  }
  nday <- as.integer(format(date - 1, format="%d"))
  return(nday)
}
