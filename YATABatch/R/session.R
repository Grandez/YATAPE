# Actualiza los datos de session cada interval minutos
update_tickers = function(interval = 15, logLevel = 0, logOutput = 0) {
   factory = NULL
   batch   = YATABatch$new("tickers", logLevel, logOutput)
   logger  = batch$logger

   if (batch$running) {
      logger$running()
      return (invisible(batch$rc$RUNNING))
   }

   rc = tryCatch({
      factory = Factory$new()
      prov    = factory$getDefaultProvider()
      tblCTC  = factory$getTable("Currencies")
      tblHist = factory$getTable("History")
#      coins   = prov$getCurrenciesNumber("all")

      process = TRUE
      while (process) {
         rc = .updateTickers(NULL, logger, factory)
         process = batch$stop_process()
         if (process) {
            message("Waiting")
            Sys.sleep(interval * 60)
         }
      }
      batch$rc$OK
   }, YATAError = function (cond) {
      browser()
      batch$rc$FATAL
   }, error = function (cond) {
      browser()
      batch$rc$SEVERE
   })
   invisible(batch$destroy(rc))
}
clean_tickers = function(logLevel = 5, logOutput = 1) {
   factory = NULL
   batch   = YATABatch$new("clean_tickers", logLevel, logOutput)
   logger  = batch$logger

   if (batch$running) {
      logger$running()
      return (invisible(batch$rc$RUNNING))
   }

   rc = tryCatch({
      factory = Factory$new()
      tblCTC  = factory$getTable("Currencies")
      tblSession$db$begin()
      #delete
      tblSession$db$commit()
      batch$rc$OK
   }, error = function (cond) {
      tblSession$db$rollback()
      ifelse ("YATAError" %in% class(cond), batch$rc$FATAL, batch$rc$SEVERE)
   })
   invisible(batch$destroy(rc))
}
.updateTickers = function(coins, logger, factory) {
    results = list(added = 0, updated=0, items=c())
    block   = 100 # Number of items by request (same as maximum returned)
    beg     = 1

    prov       = factory$getDefaultProvider()
    tblCTC     = factory$getTable("Currencies")
    tblSession = factory$getTable("Session")
    dfCTC      = tblCTC$table()

    rc = tryCatch({
       browser()
       df   = prov$getTickers(beg, block)
       if (nrow(df) == 0) return (batch$rc$NODATA)

       repeat {
          message(paste("Procesando bloque", beg))
          # if (beg > 9220) {
          #    browser()
          # }
          tblSession$db$begin()
          for (row in 1:nrow(df)) {
               data = as.list(df[row,])
               # Si no existe, siguiente
               if (!tblCTC$select(id=data$id)) next

               data$token = tblCTC$current$token
               tblSession$add(data)
              .calculateVariations(data, factory)
          }
          tblSession$db$commit()
          beg = max(df$rank) + 1
          df   = prov$getTickers(beg, block)
          if (nrow(df) < block) break
       }
       batch$rc$NODATA
    }, error = function (cond) {
       tblSession$db$rollback()
       browser()
       YATATools::propagateError(cond)
    })
}
.calculateVariations = function (data, factory) {
   tbl  = factory$getTable("Variations")
   hist = factory$getTable("History")
   # Mantenemos los datos recibidos para compensar/proteger que los datos historicos
   # no esten actualizados
   reg  = list( id = data$id,               symbol      = data$symbol
               ,price       = data$price,   volume      = data$volume
               ,p02 = data$day,     p04 = data$week,    p06 = data$month
               ,p07 = data$bimonth, p08 = data$quarter
   )
   if (hist$select(id=data$id, order=list(tms=list(name="tms", asc=FALSE)), limit = 90)) {
      df = hist$dfCurrent
      rows = nrow(df)
      if (rows >  0) reg$p01 = .calcPercentage(reg$price, df[ 1,"close"] )
      if (rows >  2) reg$p03 = .calcPercentage(reg$price, df[ 3,"close"] )
      if (rows >  6) reg$p05 = .calcPercentage(reg$price, df[ 7,"close"] )
      if (rows > 14) reg$p05 = .calcPercentage(reg$price, df[15,"close"] )

      if (rows >  0) reg$v01 = .calcPercentage(reg$volume,df[ 1,"volume"])
      if (rows >  0) reg$v02 = .calcPercentage(reg$volume,df[ 1,"volume"])
      if (rows >  2) reg$v03 = .calcPercentage(reg$volume,df[ 3,"volume"])
      if (rows >  6) reg$v04 = .calcPercentage(reg$volume,df[ 7,"volume"])
      if (rows > 14) reg$v05 = .calcPercentage(reg$volume,df[15,"volume"])
      if (rows > 29) reg$v06 = .calcPercentage(reg$volume,df[30,"volume"])
      if (rows > 59) reg$v07 = .calcPercentage(reg$volume,df[60,"volume"])
      if (rows > 89) reg$v08 = .calcPercentage(reg$volume,df[90,"volume"])
   }

   if (tbl$select(id = data$id)) { # update
       tbl$set(reg)
       tbl$apply()

   } else { # insert
      tbl$add(reg)
   }
}

.calcPercentage = function (num1,den1) {
   if (is.null(num1) || is.na(num1)) return (NULL)
   if (is.null(den1) || is.na(den1)) return (NULL)
   if (den1 == 0)                    return (NULL)
   res = num1 / den1
   if (res >= 1) return (res - 1)
   (1 - res) * -1

}
