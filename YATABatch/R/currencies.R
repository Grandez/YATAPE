#' Realiza la carga inicial o recarga de la tabla de monedas
#' Proceso Diario
#'
#' Hay que hacer un matching para detectar altas y bajas
#' @param console Se ejecuta en una consola (interactivo)
#' @param log     Nivel de detalle de los mensajes
#'
update_currencies = function(logLevel = 2, logOutput = 2) {
   factory = NULL
   batch   = YATABatch$new("currencies", logLevel, logOutput)
   logger  = batch$logger

   if (batch$running) {
      logger$running()
      return (invisible(batch$rc$RUNNING))
   }

   rc = tryCatch({
      factory = Factory$new()
      prov    = factory$getDefaultProvider()
      tbl     = factory$getTable("Currencies")

      logger$doing(3, "Retrieving currencies from net:\t")
      df  = prov$getCurrencies()
      df = df %>% arrange(id)
      logger$done(3, "%5d", nrow(df))

      logger$doing(3, "Retrieving currencies from system:\t")
      ctc = tbl$table() %>% arrange(id)
      logger$done(3, "%5d", nrow(ctc))

      itbl = 1
      idf  = 1

      results = list(added = 0, updated = 0, deleted = 0)
      tbl$db$begin()
      while (itbl <= nrow(ctc) && idf <= nrow(df)) {
         if (ctc[itbl, "id"] == df[idf, "id"]) { # Update
            results$update = results$update + .itemUpdate(tbl, df[idf,"id"], as.list(df[idf,]), logger)
            itbl = itbl + 1
            idf  = idf  + 1
         } else if (ctc[itbl, "id"]  < df[idf, "id"]) { # Baja
            if (ctc[itbl, "active"] == 1) {
                results$deleted = results$deleted + .itemDelete(tbl, ctc, itbl, logger)
            }
            itbl = itbl + 1
         } else { # Alta
            results$added = results$added + .itemAdd(tbl, as.list(df[idf,]), logger)
            idf = idf + 1
         }
         if (itbl %% 25 == 0) {
             tbl$db$commit()
             if (batch$stop_process()) return (invisible(batch$rc$KILLED))
             tbl$db$begin()
         }
      }
      tbl$db$commit()
      if (itbl <= nrow(ctc)) { # Bajas
          tbl$db$begin()
          while (itbl <= nrow(ctc)) {
             results$deleted = results$deleted + .itemDelete(tbl, ctc, itbl, logger)
             itbl = itbl + 1
          }
          tbl$db$commit()
      }
      if (idf <= nrow(df)) { # Altas
          tbl$db$begin()
          while (idf <= nrow(df)) {
            results$added = results$added + .itemAdd(tbl, as.list(df[idf,]), logger)
            idf = idf + 1
          }
          tbl$db$commit()
      }
      batch$rc$OK
   }, YATAERROR = function (cond) {
              message(cond$message)
      tbl$db$rollback()
         batch$rc$FATAL
   }, error = function (cond) {
              message(cond$message)
      tbl$db$rollback()
         if (!is.null(factory)) factory$destroy()
         batch$rc$SEVERE
   })
   #    logger$executed(rc, begin, "Executed")
      if (!is.null(factory)) factory$destroy()
      batch$destroy()
      message(paste("update_currencies ending with rc =", rc))
      invisible(rc)
}
.itemAdd    = function (tbl, data, logger) {
   logger$log(5, paste("Creating", data$symbol, "with id", data$id))
   tbl$insert(data)
   1
}
.itemUpdate = function(tbl, id, data, logger) {
    changed = FALSE
    tbl$select(id = id)
    if (data$active != tbl$current$active) {
        tbl$setField("active", data$active)
        changed = TRUE
    }
    if (data$rank != tbl$current$rank) {
        tbl$setField("rank", data$rank)
        changed = TRUE
    }
    if (is.na(tbl$current$mktcap) || data$mktcap != tbl$current$mktcap) {
        tbl$setField("mktcap" ,data$mktcap)
        changed = TRUE
    }
    if (as.Date(data$since, origin="1970-01-01") != tbl$current$since) {
        tbl$setField("since", as.Date(data$since, "1970-01-01"))
        changed = TRUE
    }
    if (data$audited != tbl$current$audited) {
        tbl$setField("audited", data$audited)
        changed = TRUE
    }
    if (changed) {
       logger$log(5, paste("Updating", tbl$current$symbol))
       tbl$apply()
    }
    ifelse (changed, 1, 0)
}
.itemDelete = function(tbl, ctc, itbl, logger) {
    logger$log(5, paste("Deleting", ctc[itbl, "symbol"]))
    tbl$select(id = ctc[itbl, "id"])
    tbl$setField("active", -1)
    tbl$setField("since", as.character(Sys.Date()))
    tbl$apply()
    1
}
