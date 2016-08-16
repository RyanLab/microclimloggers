
#' Read HOBO loggers
#'
#' @param csv_file path to input csv file
#' @param strip_logger_events logical, defaults to TRUE. Remove events relating to connecting/disconnecting the coupler and return only the environmental variables
#'
#' @return a data.frame
#' @export
read_hobo_csv <- function(csv_file, strip_logger_events=TRUE){
  #read first two lines using an encoding that removes BOM characters at strat of file if present
  con <- file(csv_file, encoding="UTF-8-BOM")
  header <- readLines(con=con, n=2)
  close(con)
  #split up the second header line which contains column names as well as the logger serial number and the time zone
  header_bits <- unlist(strsplit(header[2], '",\\"'))
  #extract serial numbers
  SNs <- stringr::str_extract(header_bits, '(?<=S\\/N:\\s)[0-9]+')
  SN <- unique(SNs[!is.na(SNs)])
  if(length(SN) > 1) stop("multiple serial numbers in file header")
  #extract timezone
  warning("timezone support not implemented")


  #read data
  hobofile <- read.csv(csv_file, skip=2, header=FALSE, stringsAsFactors = FALSE, na.strings = "")
  #parse timestamp
  hobofile$timestamp <- lubridate::mdy_hms(hobofile[,2], tz="Etc/GMT-4")
  #set up output dataframe
  df_out <- data.frame(Timestamp=hobofile$timestamp, Logger.SN = rep(SN, nrow(hobofile)))
  #separate out time stamp
  hobofile <- tidyr::separate(hobofile, timestamp, c("Year", "Month", "Day", "Hour", "Minute", "Second"))
  #Find and add environmental variables to output
  if(length(grep('Temp', header_bits))>0) df_out$Temp.C <- hobofile[,grep('Temp', header_bits)]
  if(length(grep('RH', header_bits))>0) df_out$RH.perc <- hobofile[,grep('RH', header_bits)]
  #bind variables and timestamp
  df_out <- cbind(subset(hobofile, select = c("Year", "Month", "Day", "Hour", "Minute", "Second")), df_out)
  if(strip_logger_events){
    return(df_out[complete.cases(df_out),])
  } else {
    warning("Logger events not fully implemented. Returning environmental variables with NAs.")
    return(df_out)
  }

}

#' Read Ecuadorean USB loggers
#'
#' @param csv_file
#' @param parse_name
#'
#' @return
#' @export
read_usb_logger <- function(csv_file, parse_name = NULL){

}

#' Read iButton Hygrochron files
#'
#' @param csv_file
#' @param parse_name
#'
#' @return
#' @export
#'
read_ibutton_csv <- function(csv_file, parse_name = NULL){

}
