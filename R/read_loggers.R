
#' Read HOBO loggers
#'
#' @param csv_file path to input csv file
#' @importFrom lubridate mdy_hms
#' @importFrom stringr str_extract str_replace_all
#' @importFrom tidyr separate gather
#' @importFrom stats complete.cases
#' @importFrom utils read.csv
#'
#' @return a microclim object
#' @export
read_hobo_csv <- function(csv_file){
  #read first two lines using an encoding that removes BOM characters at start of file if present
  con <- file(csv_file, encoding="UTF-8")
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
  hobofile <- tidyr::separate(hobofile, timestamp, c("Year", "Month", "Day", "Hour", "Minute", "Second"), remove=FALSE, convert=TRUE)
  #add timezone column
  hobofile$tz <- rep(tz, nrow(hobofile))
  #Find and add environmental variables to output
  if(length(grep('Temp', header_bits))>0) df_out$Temp.C <- hobofile[,grep('Temp', header_bits)]
  if(length(grep('RH', header_bits))>0) df_out$RH.perc <- hobofile[,grep('RH', header_bits)]
  #bind variables, timestamp, and timezone
  df_out <- cbind(subset(hobofile, select = c("Year", "Month", "Day", "Hour", "Minute", "Second", "tz")), df_out)
  #separate environmental data and NAs from logger events
  df_env <- df_out[complete.cases(df_out),]

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

  return(structure(list(df_env = df_env, df_logger = df_logger), class="microclim"))
}

#' Read Ink-Bird THC-4 data logger textfile
#'
#' @param txt_file input path
#' @param parse_name function that tries to extract metadata from the file name
#' @param tz string a timezone designation that is compatible with the Olson time zones. See ?timezones for more details.
#' @importFrom lubridate ymd_hms
#' @importFrom tidyr separate
#' @importFrom utils read.table
#'
#' @return a microclim object
#' @export
read_inkbird_txt <- function(txt_file, parse_name = NULL, tz=NA){
  #read bulk data
  txtfile <- read.table(txt_file, skip=14, header=FALSE, stringsAsFactors = FALSE)
  txtfile <- tidyr::unite(txtfile, timestamp, V2, V3)
  txtfile$Timestamp <- lubridate::ymd_hms(txtfile$timestamp)
  txtfile <- tidyr::separate(txtfile, Timestamp, c("Year", "Month", "Day", "Hour", "Minute", "Second"), remove=FALSE, convert=TRUE)
  #add timezone column
  txtfile$tz <- rep(tz, nrow(txtfile))

  #read header
  #read first two lines using an encoding that removes BOM characters at strat of file if present
  con <- file(txt_file, encoding="UTF-8-BOM")
  header <- readLines(con=con, n=14)
  close(con)
  col_names <- unlist(strsplit(header[[14]], '\\s{2,}'))[-1]#-1 necessary b/c of leading space in the column name line

  #set up output dataframe
  df_env <- data.frame(Timestamp=txtfile$Timestamp, Logger.SN = rep(NA, nrow(txtfile)))

  #Find and add environmental variables to output
  if(length(grep('Temp', col_names))>0) df_env$Temp.C <- txtfile[,grep('Temp', col_names)]
  if(length(grep('Humidity', col_names))>0) df_env$RH.perc <- txtfile[,grep('Humidity', col_names)]
  #bind variables, timestamp, and timezone
  df_env <- cbind(subset(txtfile, select = c("Year", "Month", "Day", "Hour", "Minute", "Second", "tz")), df_env)
  return(structure(list(df_env = df_env, df_logger = NULL), class="microclim"))

}

#' Read iButton Hygrochron multi-logger files
#'
#' Function to read csv files containing data dumps of multiple iButtons.
#'
#' @param csv_file input path
#' @param parse_name function that tries to extract metadata from the file name
#'
#' @return a data.frame
#' @importFrom plyr ldply
#' @export
#'
read_ibutton_csv <- function(csv_file, parse_name = NULL){
  #change system locale to enable graceful string handling for files containing non-ascii characters
  Sys.setlocale('LC_ALL','C')

  con <- file(csv_file)
  all_lines <- readLines(con=con)
  close(con)

  #find start of individual data sets
  if(any(grepl("Date/time logger downloaded:", all_lines))){
    start_of_set <- grep("Date/time logger downloaded:", all_lines)
  } else {
    stop("Could not determine start of data set. Tried keyword 'Date/time logger downloaded:'.")
  }
  #find end of individual data set
  if(any(grepl("download complete", all_lines))){
    end_of_file <- grep("download complete", all_lines)
  } else {
    if(any(grepl("-end-", all_lines))){
      end_of_file <- grep("-end-", all_lines)
    } else {
      stop("Could not determine end of data set. Tried keywords 'download complete' and '-end-'.")
    }
  }
  #datasets end two lines above the start of the next dataset, so we are using the start line indices to find the end lines.
  #last data set ends one line before end of file
  end_of_set <- c(start_of_set[-1]-2, end_of_file-1)
  if(length(start_of_set)!=length(end_of_set)) stop("Unequal number of dataset headers and footers. File format not as expected.")

  #create list of subfiles
  sets <- lapply(seq_along(start_of_set), function(x) all_lines[start_of_set[x]:end_of_set[x]])
  #parse individual sets
  df_env <- plyr::ldply(sets, parse_ibutton_list)

  #restore system locale to operating system default
  Sys.setlocale('LC_ALL','')

  return(structure(list(df_env = df_env, df_logger = NULL), class="microclim"))
}

#' Internal function that parses an individual logger data block from a multilogger iButton file
#'
#' @param x list
#' @importFrom lubridate parse_date_time
#'
#' @return a data.frame
#' @export
#'
parse_ibutton_list <- function(x){
  #find individual header lengths
  data_start <- min(grep(",[0-9]+.[0-9]+,[0-9]+.[0-9]+", x))
  #determine column numbers
  n_columns <- length(stringr::str_split(x[data_start], ",")[[1]])
  #determine data column names
  col_names <- c("Timestamp","Temp.C","RH.perc", rep("NULL", n_columns - 3))
  warning("using static column name order")
  #parse data portion
  tf <- textConnection(x[data_start:length(x)])
  df_env <- read.csv(tf, stringsAsFactors = FALSE, header = FALSE, colClasses = c("character", "numeric", "numeric", rep("NULL", n_columns - 3)), col.names = col_names)
  df_env$Timestamp <- parse_date_time(df_env$Timestamp, orders = c("ymd HMS","mdy HM"))
  #find logger serial number
  logger_serial_pos <- grep("Logger serial number:", x)
  #remove quotes and split string retaining only the serial number
  logger_serial <- stringr::str_split(x[logger_serial_pos], ',', simplify = TRUE)[1,2]
  df_env$Logger.SN <- rep(logger_serial, nrow(df_env))
  df_env <- tidyr::separate(df_env, Timestamp, c("Year", "Month", "Day", "Hour", "Minute", "Second"), remove=FALSE, convert=TRUE)
  return(df_env)
}

#' Read iButton Hygrochron single-logger files
#'
#' Function to read csv files containing data dumps of individual iButtons. Accounting for possible corruption in the date column.
#'
#' @param csv_file input path
#' @param parse_name function that tries to extract metadata from the file name
#'
#' @return a data.frame
#' @importFrom plyr ldply
#' @export
#'
read_ibutton_single_csv <- function(csv_file, parse_name = NULL, excel_origin = "1899-12-30"){
  #change system locale to enable graceful string handling for files containing non-ascii characters
  Sys.setlocale('LC_ALL','C')

  con <- file(csv_file)
  all_lines <- readLines(con=con)
  close(con)

  #find start of individual data sets
  if(any(grepl("Date/time logger downloaded:", all_lines))){
    start_of_set <- grep("Date/time logger downloaded:", all_lines)
  } else {
    start_of_set <- 1
    warning("Could not determine start of data set. Tried keyword 'Date/time logger downloaded:'. Using line 1.")
  }
  #find end of individual data set
  if(any(grepl("download complete", all_lines))){
    end_of_file <- grep("download complete", all_lines)
  } else {
    if(any(grepl("-end-", all_lines))){
      end_of_file <- grep("-end-", all_lines)
    } else {
      stop("Could not determine end of data set. Tried keywords 'download complete' and '-end-'.")
    }
  }

  #parse individual sets
  #find individual header lengths
  if (any(grepl("[0-9]{4}/[0-9]{2}/[0-9]{2}\\s[0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{2}", all_lines))){
    data_start <- min(grep("[0-9]{4}/[0-9]{2}/[0-9]{2}\\s[0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{2}", all_lines))
    excel_date <- FALSE
  } else {
    if (any(grepl("[0-9]+.[0-9]+,[0-9]{2}", all_lines))){
      data_start <- min(grep("[0-9]+.[0-9]+,[0-9]{2}", all_lines))
      excel_date <- TRUE
    } else {
    stop("unrecognized timestamp format, or timestamp not in first column")
  }}

  #determine data column names
  col_names <- c("Timestamp","Temp.C","RH.perc")
  warning("using static column name order")
  #parse data portion
  tc <- textConnection(all_lines[data_start:(end_of_file-1)])
  if (!excel_date) {
    #parse timestamp automatically
    df_env <- read.csv(tc, stringsAsFactors = FALSE, header=FALSE, colClasses = c("POSIXct", "numeric","numeric"), col.names = col_names)
  } else {
    df_env <- read.csv(tc, stringsAsFactors = FALSE, header=FALSE, colClasses = c("numeric", "numeric","numeric"), col.names = col_names)
    df_env$Timestamp <- as.POSIXct(df_env$Timestamp * (60*60*24), origin = excel_origin)
  }
  #find logger serial number
  if (any(grepl("Serial No", all_lines))){
    logger_serial_pos <- grep("Serial No", all_lines)
  } else {
    stop("No logger serial number fund using keyword 'Serial No'")
  }
  #remove quotes and split string retaining only the serial number
  logger_serial <- stringr::str_split_fixed(stringr::str_replace_all(all_lines[logger_serial_pos], pattern='\"', ''), ',', 2)[1,2]
  df_env$Logger.SN <- rep(logger_serial, nrow(df_env))
  df_env <- tidyr::separate(df_env, Timestamp, c("Year", "Month", "Day", "Hour", "Minute", "Second"), remove=FALSE, convert=TRUE)

  #restore system locale to operating system default
  Sys.setlocale('LC_ALL','')

  return(structure(list(df_env = df_env, df_logger = NULL), class="microclim"))
}
