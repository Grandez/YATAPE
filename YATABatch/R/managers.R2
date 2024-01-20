# Metodo comun para lanzar y parar procesos en modo asincrono
yata_start = function(process, ...) {
   if (missing(process)) {
       message("Missing process to start")
       return (invisible(12))
   }
   args = list(...)
   logLevel  = ifelse(is.null(args$logLevel),  0, args$logLevel)
   logOutput = ifelse(is.null(args$logOutput), 0, args$logOutput)

   batch   = YATABatch$new(process, logLevel, logOutput)
   logger = batch$logger

   if (batch$running) {
      logger$running()
      return (invisible(batch$rc$RUNNING))
   }

   # if (process == "history") update_history()
}
yata_stop = function(process, clean = FALSE) {
   if (missing(process)) {
       message("Missing process to stop")
       return (invisible(12))
   }
   batch   = YATABatch$new(process, 0, 0)
   if (!batch$running) {
       message(paste(process, "does not appears running"))
       rc = batch$rc$NODATA
       batch$destroy()
       return(invisible(rc))
   }
   stop_batch(process, clean)
   batch$destroy()
   invisible (0)
}

# Chequea el estado de un proceso o demonio en base a su pid file
# 0 - Ejecutando
# 1 - No activo
# 4 - Activo pero pendiente de detenerse
check_process = function (process = "yata") {
   rc = 0
   pidfile = paste0(Sys.getenv("YATA_SITE"), "/data/wrk/", process, ".pid")
   if (!file.exists(pidfile)) {
      rc = 1
      message(paste("Process", process, "is NOT active"))
   } else {
      data = readLines(pidfile)
      res  = grep("stop", data, ignore.case = TRUE)
      if (length(res) == 0) {
         message(paste("Process", process, "is ACTIVE"))
      } else {
         message(paste("Process", process, "is PENDING to be stopped"))
         rc = 4
      }

   }
   return (invisible(rc))
}
stop_batch = function (process = "yata", clean = FALSE) {
   rc = 0
   wd = getDirectory("wrk")
   pidfile = normalizePath(file.path(wd, paste0(process, ".pid")))
   if (file.exists(pidfile)) {
      message(paste("Sending kill message to", process))
      cat("stop", file=pidfile)
      if (clean) unlink(pidfile, force = TRUE)
   } else {
      message(paste("Process", process, "is not active"))
      rc = 4
   }

   invisible(rc)
}
stop_process = function(process = "yata", clean = FALSE) {
   stop_batch(process, clean)
}
