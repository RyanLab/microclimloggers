test_hobo_RH <- "C:\\Users\\Philipp\\Dropbox\\RyanLabLoggerProject\\DD\\RH_41_073116.csv"
test_df<-read_hobo_csv(test_hobo_RH)

csv_file=test_hobo_RH
#read first two lines using an encoding that removes BOM characters at strat of file if present
con <- file(csv_file, encoding="UTF-8-BOM")
header <- readLines(con=con, n=2)
close(con)
#split up the second header line which contains column names as well as the logger serial number and the time zone
header_bits <- unlist(strsplit(header[2], '",\\"'))
#read data
hobofile <- read.csv(csv_file, skip=2, header=FALSE, stringsAsFactors = FALSE)
#parse timestamp
hobofile$timestamp <- lubridate::mdy_hms(hobofile[,2], tz="Etc/GMT-4")
#separate out
hobofile <- tidyr::separate(hobofile, timestamp, c("y", "m", "d", "H", "M", "S"))

grep('S\\/N:\\s[0-9]+', header_bits)
#extract serial numbers
SNs <- stringr::str_extract(header_bits, '(?<=S\\/N:\\s)[0-9]+')
SN <- unique(SNs[!is.na(SNs)])
if(length(SN) > 1) stop("multiple serial numbers in file header")
hobofile$Logger.SN <- rep(SN, nrow(hobofile))

#extract timezon



