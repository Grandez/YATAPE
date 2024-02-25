# Objeto comun para los procesos Batch
# Carga la factoria, el objeto base, logger,etc.
# Para los Logs usaremos un numero de dos digitos
# el primero, para el detalle
# el segundo parael sumario
# Ejemplo:  1 - Imprmir sumario simple
#          32 - Imprimir mensajes de detalle de nievl 3 y resumen de nivel 2
YATABatch = R6::R6Class("YATA.OBJ.BATCH"
    ,cloneable  = FALSE
    ,portable   = FALSE
    ,lock_class = TRUE
    ,public = list(
        running  = FALSE
       # ,fact     = NULL
        ,logger   = NULL
       # ,base     = NULL
       # ,counters = NULL # counters
       ,process  = "YATA"
        # Return codes
        # 0-8 Procesos correctos
        # 9-16 Avisos
        # A partir de 32 Errores (bit 6 activo)
        # 64 Error no controlado
       ,rc = list(OK=0, RUNNING=2, NODATA=4, KILLED=7, NOT_RUNNIG = 9, INVALID=12, FLOOD=17, ERRORS=33, SEVERE=32, FATAL=64)
       ,initialize = function (process="YATA", logLevel = 0, logOutput = 0) {
           private$tmsBeg = Sys.time()
           # if (logLevel > 9) {
           #    quot = logLevel %/% 10
           #    logLevel = logLevel %% 10
           #    if (quot %% 2 >  0) private$elapsed = TRUE
           #    if (quot %% 2 == 0) private$summary = TRUE
           # }
           # process a NULL se utiliza para acceder al objeto sin crear ficheros
           if (!is.null(process)) {
               self$process = process
               get
               self$logger  = YATALogger$new(process, level=logLevel, output=logOutput
                                                    , file=getLogFile(), envvars= "YATA")
               createPID(process)
           }
       }
       ,destroy = function(rc = 0) {
          if (!is.null(pidfile) && file.exists(pidfile)) unlink(pidfile, force = TRUE)
          # if (summary) printSummary()
          # if (elapsed) printElapsed()
          invisible(rc)
       }
       # ,addDataToControlFile = function(...) {
       #     args = list(...)
       #     if (length(args) == 0) return (FALSE)
       #     args = as.character(unlist(args))
       #
       #     wd = yataGetDirectory("wrk")
       #     pidfile = normalizePath(file.path(wd, paste0(process, ".pid")), mustWork = FALSE)
       #     if (!file.exists(pidfile)) return (TRUE) # Error
       #     fpid = file(description = pidfile, open = "at", blocking = FALSE)
       #     writeLines(args,con=fpid)
       #     flush(fpid)
       #     close(fpid)
       #     FALSE
       # }
       # ,check_process = function (process = NULL) {
       #    if (is.null(process)) process = self$process
       #    createPID(process, FALSE)
       #    self$running
       # }
       # ,stop_process = function(exception = FALSE) {
       #     # fichero de control borrado
       #     if (!file.exists(pidfile)) {
       #         if (!exception) return (TRUE)
       #         YATABase:::KILLED(paste(process, "killed by user"))
       #     }
       #     # Existe la palabra stop en el fichero de control
       #     data = readLines(pidfile)
       #     if (length(grep("stop", data, ignore.case = TRUE)) > 0) {
       #         if (!exception) return (TRUE)
       #         YATABase:::KILLED(paste(process, "killed by user"))
       #     }
       #     FALSE
       # }
       # ,getControlFile = function (process = NULL) {
       #     if (is.null(process)) process = self$process
       #     wd = yataGetDirectory("wrk")
       #     pidfile = normalizePath(file.path(wd, paste0(process, ".pid")), mustWork = FALSE)
       #     if (!file.exists(pidfile)) return (NULL)
       #     readLines(pidfile)
       # }
       # ,signaled       = function(exception = FALSE) {
       #    # Chek if process is marked to kill
       #    # kill children process
       #    if (!file.exists(pidfile)) return (FALSE)
       #    data = readLines(pidfile)
       #    if (length(grep("stop", data, ignore.case = TRUE)) == 0) return (FALSE)
       #    if (length(data) > 2) { # Hay varios pid
       #        for (i in 2:length(data)) { # Ignorar el primero (el propio)
       #             pid = suppressWarnings(as.integer(data[i]))
       #             if (!is.na(pid)) tools.pskill(pid)
       #        }
       #    }
       #    if (exception) YATABase::KILLED(paste(self$process, "killed by user"))
       #    TRUE
       # }
       # ,setCounters    = function(counters) {
       #    self$counters = rep(0, length(counters))
       #    names(self$counters) = names(counters)
       #    private$labels = counters
       # }
    )
    ,private = list(
         tmsBeg = 0
        ,tmsEnd = 0
        ,elapsed = FALSE
        ,summary = TRUE
        ,labels   = NULL # Label for counters
        # ,msgDet = 0
        # ,msgSum = 0
        # ,pidfile = NULL
        # ,logfile = NULL
        # ,.msg = function(head="", txt, ...) {
        #    lbl = trimws(paste(head, txt))
        #    sprintf(lbl, ...)
        # }
       ,createPID = function(process, create = TRUE) {
          wd = "/tmp"
          if (sdpr::os_windows()) wd = Sys.getenv("TEMP")
           private$pidfile = normalizePath(file.path(wd, paste0(process, ".pid")), mustWork = FALSE)
           if (file.exists(pidfile)) {
              self$running = TRUE
           } else {
              if (create) cat(paste0(Sys.getpid(),"\n"), file=pidfile)
           }
       }
      ,getLogFile = function ()  {
         fname = "/var/log"
         if (sdpr::os_windows()) fname = Sys.getenv("ProgramData")
         fname = file.path(fname, "YATA")
         if (!dir.exists(fname)) dir.create(fname)
         file.path(fname, "YATA.log")
      }
      #  ,printSummary = function () {
      #     if (is.null(labels)) return()
      #     maxLen = max(nchar(labels))
      #     if (length(labels) == 0) return ()
      #     for (idx in 1:length(labels)) {
      #        txt = labels[idx]
      #        if (nchar(txt) < maxLen) {
      #           fill = maxLen - nchar(txt)
      #           txt = paste0(txt, rep(" ", fill), collpase="")
      #        }
      #        logger$info(1, "%-s:\t%6d", txt, counters[idx])
      #     }
      #  }
      # ,printElapsed = function () {
      #     elapsed = Sys.time() - private$tmsBegin
      #     logger$info(1, "Process %s terminated. Elapsed time: %d", process, elapsed)
      #
      # }
    )
)



