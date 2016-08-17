
#' Read HOBO loggers
#'
#' @param csv_file path to input csv file
#' @importFrom lubridate mdy_hms
#' @importFrom stringr str_extract
#' @importFrom tidyr separate
#'
#' @return a data.frame
#' @export
read_hobo_csv <- function(csv_file){
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
  tz <- stringr::str_extract(header_bits[grep("Date Time", header_bits)], "GMT[+-][0-9][0-9]")
  if (substr(tz,5,5)==0) {
    olsontz <- paste("Etc/", substr(tz,1,4),substr(tz,6,6), sep='')
    } else {
      olsontz <- paste("Etc/", tz, sep='')
    }

  #read data
  hobofile <- read.csv(csv_file, skip=2, header=FALSE, stringsAsFactors = FALSE, na.strings = "")
  #parse timestamp
  hobofile$timestamp <- lubridate::mdy_hms(hobofile[,2], tz=olsontz)
  #set up output dataframe
  df_out <- data.frame(Timestamp=hobofile$timestamp, Logger.SN = rep(SN, nrow(hobofile)))
  #separate out time stamp
  hobofile <- tidyr::separate(hobofile, timestamp, c("Year", "Month", "Day", "Hour", "Minute", "Second"), remove=FALSE)
  #add timezone column
  hobofile$tz <- rep(tz, nrow(hobofile))
  #Find and add environmental variables to output
  if(length(grep('Temp', header_bits))>0) df_out$Temp.C <- hobofile[,grep('Temp', header_bits)]
  if(length(grep('RH', header_bits))>0) df_out$RH.perc <- hobofile[,grep('RH', header_bits)]
  #bind variables, timestamp, and timezone
  df_out <- cbind(subset(hobofile, select = c("Year", "Month", "Day", "Hour", "Minute", "Second", "tz")), df_out)

  #Find and process logger events
  logger_events <- numeric(4)
  HOBO_names <- c('Host Connected', 'Coupler Detached', 'Coupler Attached', 'End Of File')
  df_names <- stringr::str_replace_all(HOBO_names, ' ', '')
  for (i in 1:4){
    if(length(grep(HOBO_names[i], header_bits))>0) {
    names(hobofile)[grep(HOBO_names[i], header_bits)] <- df_names[i]
    logger_events[i] <- grep(HOBO_names[i], header_bits)
    }
  }

  if(sum(logger_events) > 0){
    df_logger <- tidyr::gather(hobofile, logger, event, logger_events, factor_key = TRUE)
    df_logger <- subset(df_logger[!is.na(df_logger$event),], select = c("timestamp", "logger"))
    df_logger$Logger.SN = rep(SN, nrow(df_logger))
  } else {
    df_logger <- NULL
  }



  #separate environmental data and logger events
  df_env <- df_out[complete.cases(df_out),]
  return(list(df_env = df_env, df_logger = df_logger))
}

#' Read Ecuadorean USB loggers
#'
#' @param csv_file input path
#' @param parse_name function that tries to extract metadata from the file name
#'
#' @return a data.frame
#' @export
read_usb_logger <- function(csv_file, parse_name = NULL){

}

#' Read iButton Hygrochron files
#'
#' @param csv_file input path
#' @param parse_name function that tries to extract metadata from the file name
#'
#' @return a data.frame
#' @export
#'
read_ibutton_csv <- function(csv_file, parse_name = NULL){

}