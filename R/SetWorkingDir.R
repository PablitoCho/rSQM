SetWorkingDir <- function(wdir) {

  # Creat working dir if not exists
  if(!dir.exists(wdir))
  {
	dir.create(wdir, showWarnings=F,recursive=T)
  }
}
