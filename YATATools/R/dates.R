YATADates = R6::R6Class("YATA.BASE.DATES"
   ,portable  = FALSE
   ,cloneable = FALSE
   ,lock_class = TRUE
   ,public = list(
       asPosix   = function(epoch) { anytime(epoch)   }
      ,asDate    = function(epoch) { anydate(epoch)   }
      ,asTMS     = function(epoch) { format(epoch, format = "%Y-%m-%d-%H:%M:%S") }
      ,asUnix    = function(date)  {
           if (("POSIXct" %in% class(date))) return (as.numeric(date))

           if (class(date) == "Date") date = as.POSIXct(paste(date, "01:00:00 UTC"))
#           else                       date = anytime(date)

           hora = strftime(date, format="%H:%M:%S")
           if (hora == "00:00:00") hora = "01:00:00"
#           as.numeric(as.POSIXct("2013-09-16 2:13:46 EST"))
           as.numeric(anytime(paste(strftime(date, format="%Y/%m/%d"), hora)))
       }
# Redondea la fecha al intervalo dado en segundos
# prev Redondea a la fecha anterior o igual
#      Redondea a la fecha posterior o igual
      ,round2Epoch = function(date, interval, prev=TRUE) {
           org = asUnix(date)
           dif = org %% interval
           res =  org - dif
           if (!prev) res = res + interval
           res
       }
      ,round2Posix = function(date, interval, prev=TRUE) {
          org = asUnix(date)
          dif = org %% interval
          res =  org - dif
          if (!prev) res = res + interval
          as.POSIXct(res)
       }
      ,elapsed = function(start, end) {
          dsec    = as.numeric(difftime(end, start, unit = "secs"))
          hours   = floor(dsec / 3600)
          minutes = floor((dsec - 3600 * hours) / 60)
          seconds = dsec - 3600*hours - 60*minutes
          paste0( sapply(c(hours, minutes, seconds), function(x) {
                         formatC(x, width = 2, format = "d", flag = "0")
                 }), collapse = ":")
      }
   )
)
