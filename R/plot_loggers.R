#' Plot microclimate logger output
#'
#' @param x a microclim object
#' @param ... further arguments to plot
#' @importFrom graphics par plot
#'
#' @return a plot
#' @export
plot.microclim <- function(x, ...){
  # store old par
  old.par <- par(no.readonly=TRUE)
  # determine which data series are present & plot
  series <- x$df_units$variable
  par(mfrow = c(length(series), 1))
  if("Temp" %in% series) {
    plot(x$df_env$Timestamp, x$df_env$Temp, type = "l", col = 'red',
         xlab = "Time",
         ylab = paste("Temp", x$df_units[x$df_units$variable == "Temp", "unit"]),
         main = unique(x$df_env$Logger.SN), ...)
  }
  if("RH.perc" %in% series) {
    plot(x$df_env$Timestamp, x$df_env$RH.perc, type = "l", col = 'blue',
         xlab = "Time",
         ylab = "RH %", ...)
  }
  if("Illum" %in% series) {
    plot(x$df_env$Timestamp, x$df_env$Illum, type = "l", col = 'gold',
         xlab = "Time",
         ylab = paste("Illum", x$df_units[x$df_units$variable == "Illum", "unit"]),
         main = unique(x$df_env$Logger.SN), ...)
  }
  # restore old par
  par(old.par)
}
