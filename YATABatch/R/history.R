#' Recupera los datos historicos de las sesiones
#' Proceso Diario
#'
#' JGG Limitamos los datos a 150 monedas
#'
update_history = function(reverse = FALSE, logLevel = 255, logOutput = 3) {
   browser()
   module = "history"
   factory = NULL
   batch   <<- YATABatch$new(module, logLevel, logOutput)
   # batch$setCounters(c( input     ="Monedas leidas"
   #                     ,processed = "Monedas procesadas"))
   logger = batch$logger
   # items  = 0

   if (batch$running) {
      logger$warn(paste("Process", module, "already running"))
      return (invisible(batch$rc$RUNNING))
   }

   rc = tryCatch({
      factory = Factory$new()

      tblctc = factory$getTable("Currencies")
      dfctc  = tblctc$table(active = 1)
      if (nrow(dfctc) == 0) {
          logger$warn(paste("No hay monedas para procesar"))
          return (invisible(batch$rc$NODATA))
      }

      df = dfctc[order(dfctc$rank),]
      df = df[1:150,]
      .updateHistory(factory, logger, df, reverse)
      #ifelse(batch$counters$processed > 0, batch$rc$OK, batch$rc$NODATA)
      batch$rc$OK
   }, error = function (cond) {
      if (!is.null(factory)) factory$destroy()
      rc = batch$rc$FATAL
      if ("YATAERROR" %in% class(cond)) rc = batch$rc$SEVERE
      if ("FLOOD"     %in% class(cond)) rc = batch$rc$FLOOD
      if ("KILLED"    %in% class(cond)) rc = batch$rc$KILLED
      rc
   })
   batch$destroy()
   invisible(rc)
}

.updateHistory = function (factory, logger, dfCTC, reverse) {
   tryCatch({
      prov    = factory$getDefaultProvider()
      tblCTC  = factory$getTable("Currencies")
      tblHist = factory$getTable("History")
      tables  = list(hist=tblHist, ctc=tblCTC)
      today   = Sys.Date()
   }, error   = function (cond) {
      YATATools::propagateError(cond)
   })

   rows = 1:nrow(dfCTC)
   if (reverse) rows = nrow(dfCTC):1
   # batch$counters$input = nrow(rows)
   # batch$counters$processed = 0

   for (row in rows) {
        last = dfCTC[row,"last"]
        if (is.na(last)) last = dfCTC[row,"since"] # Sys.Date() - 20
        logger$doing(5, "%5d - Retrieving %-15s", row, dfCTC[row,"symbol"])
        if (as.integer(today - last) < 2) {
            logger$done(5, "- skip")
            next
        }
        to    = today
        if (logger$level < 5) {
            logger$doing(1, "%5d - Retrieving %-12s", row, substr(dfCTC[row,"symbol"],1,12))
        }
        # Recuperar solo de mes en mes
        if (to - last > 30) to = last + 30

        data = prov$getHistorical(as.integer(dfCTC[row,"id"]), last + 1, to )
        txt = ifelse(is.null(data), "No info", "OK")
        logger$done(1, "- %s", txt)
        if (!is.null(data)) {
#            batch$counters$processed = batch$counters$processed + 1
           .updateData(data, as.list(dfCTC[row,]), tables)
        }
        if ( is.null(data)) .updateLastDate(to, as.list(dfCTC[row,]), tables)
        .wait(row)
   }
}
.updateData = function(data, ctc, tables) {
    data$id     = ctc$id
    data$symbol = ctc$symbol
    tblhist = tables$hist
    tblctc  = tables$ctc
    tryCatch({
       tblhist$db$begin()
       tblhist$bulkAdd(data)
       tblctc$select(id = ctc$id)
       tblctc$set(last= substr(data[nrow(data), "timestamp"], 1,10))
       tblctc$apply()
       tblhist$db$commit()
    }, error = function(cond) {
       tblhist$db$rollback()
       YATATools::propagateError(cond)
    })
}
.updateLastDate = function(to, ctc, tables) {
    tblctc  = tables$ctc
    tryCatch({
       tblctc$db$begin()
       tblctc$select(id = ctc$id)
       tblctc$set(last = as.character(to))
       tblctc$apply()
       tblctc$db$commit()
    }, error = function (cond) {
       tblctc$db$rollback()
       YATATools::propagateError(cond)
    })
}
.wait = function (row) {
   wait = 1
   batch$signaled(TRUE)

   if      ((row %% 200) == 0)  wait = 10
   else if ((row %% 100) == 0)  wait = 10
   else if ((row %%  10) == 0)  wait =  5
   Sys.sleep(wait)
}
