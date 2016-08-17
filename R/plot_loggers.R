#' Plot microclimate logger output
#'
#' @param x a microclim object
#'
#' @return a plot
#' @export
plot.microclim <- function(x){
  # store old par
  old.par <- par(no.readonly=TRUE)
  par(mfrow=c(2,1))
  plot(x$df_env$Timestamp, x$df_env$Temp.C, type = "l", col='red', xlab = "Time", ylab= "Temp", main = unique(x$df_env$Logger.SN))
  plot(x$df_env$Timestamp, x$df_env$RH.perc, type = "l", col='blue', xlab = "Time", ylab="RH")
  # restore old par
  par(old.par)
}
