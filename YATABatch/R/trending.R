#' Actualiza la tendencia de las monedas
#' Proceso Diario
#'
#'
#'
update_trending = function(logLevel = 5, logOutput = 1) {
   factory = NULL
   batch   = YATABatch$new("trending", logLevel, logOutput)
   logger  = batch$logger

   if (batch$running) {
      logger$running()
      return (invisible(batch$rc$RUNNING))
   }

   rc = tryCatch({
      browser()
      factory = Factory$new()
      tbl = factory$getTable("Trending")
      prov    = factory$getDefaultProvider()
      for (per in c("day", "week", "month")) {
           logger$log(1, "Getting trending for %s", per)
           .getTrending(tbl, prov, per)
      }
      batch$rc$OK
   }, YATAError = function (cond) {
      tbl$db$rollback()
      batch$rc$SEVERE
   }, error = function(cond) {
        tbl$db$rollback()
      batch$rc$FATAL
   })
      batch$destroy()
      message(paste("update_currencies ending with rc =", rc))
      invisible(rc)
}
.getTrending = function(tbl, prov, period, top=30) {
      pos = which(period == c("day", "week", "month"))
      df = prov$getTrending(period, top)
      df$prty = seq(1,nrow(df))
      df$period = pos
      tbl$db$begin()
      tbl$delete(period = period)
      tbl$bulkAdd(df)
      tbl$db$commit()
}
