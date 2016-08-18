test_hobo_RH <- "C:\\Users\\Philipp\\Dropbox\\RyanLabLoggerProject\\DD\\RH_41_073116.csv"
test_hobo_T <- "C:\\Users\\Philipp\\Dropbox\\RyanLabLoggerProject\\DD\\T_01_073116.csv"
test_df<-read_hobo_csv(test_hobo_RH)
plot(test_df)
test_df2<-read_hobo_csv(test_hobo_T)
plot(test_df2)

csv_file=test_hobo_RH

plot(test_df$df_env$Temp.C, test_df$df_env$RH.perc)
plot(test_df$df_env$Hour, test_df$df_env$Temp.C)

test_usb <- "C:\\Users\\Philipp\\Dropbox\\RyanLabLoggerProject\\Datos Sensores USB\\E6R4 casa 1 dentro sensor  07_ABR_16.thc.txt"
txt_file=test_usb
test_inkbird <- read_inkbird_txt(test_usb)
plot(test_inkbird)
str(test_inkbird)

#iButtons
test_ibutton <- "C:\\Users\\Philipp\\Dropbox\\RyanLabLoggerProject\\Casitas_1 month data.csv"
csv_file=test_ibutton
