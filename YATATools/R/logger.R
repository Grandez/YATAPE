# En fichero usamos tms;tipo_mensaje
# Segun sea el tipo del mensaje, asi es el registro
# Log Level
#   1 - Summary
#
# tipo:mensaje es:
#    1 - Process (Batch, Session, etc)
#    5 - Batch Process
#   10 - Logging/info:
#      tms;10;nivel;datos
#   99 - ERROR
# Salida (out) es
#   - 0 - Nada
#   - 1 - Fichero
#   - 2 - Consola
#
YATALogger = R6::R6Class("YATA.LOGGER"
   ,cloneable  = FALSE
   ,lock_class = FALSE
   ,portable   = FALSE
   ,active = list(
       level  = function(value) {
          if (!missing(value)) private$.level = value
          .level
       }
      ,output = function(value) {
          if (!missing(value)) private$.output = value
          .output
       }
   )
  ,public = list(
      valid   = TRUE
     ,lastErr = NULL
     ,type = list(PROCESS =  1,BATCH   =  5,LOG     = 10,SUMMARY = 11, ACT=20, ERROR=99)
     ,print        = function() { message("Generic Logger class") }
     ,initialize   = function(module="general", level=0, output=1, shared=FALSE) {
         private$modName   = module
         .initLogger(level, output, shared)
     }
     ,finalize     = function()       {
        if (!is.null(logFile) && isOpen(logFile)) close(logFile)
      }
     ,setLogLevel  = function(level)  {
        private$.level = level
        invisible(self)
      }
     ,setLogOutput = function(output) {
          private$.output = output
          invisible(self)
       }
     ,log          = function(level, fmt,...) {
        .println(self$type$LOG, level, .mountMessage(fmt, ...))
      }
     ,logn         = function(level, fmt,...) {
        .print(self$type$LOG, level, .mountMessage(fmt, ...))
     }
     ,warning      = function(fmt, ...) { message(.mountMessage(fmt, ...)) }
     ,doing = function(level, fmt, ...) {
       # Proceso en marcha, espera un done. Fichero se guarda
         .print(self$type$ACT, level, .mountMessage(fmt, ...))
         private$.cont = TRUE
      }
     ,done = function(level, fmt, ...) {
        .println(self$type$ACT, level, .mountMessage(fmt, ...))
      }
     ,batch = function(fmt, ...) {
          .println(self$type$BATCH, 0, .mountMessage(fmt,...))
       }
     ,process   = function(level, fmt, ...) {
          if (level > .level) return (invisible(self))
          msg = .mountMessage(fmt,...)
          .println(2, level, msg)
          invisible(self)
       }
       ,info      = function(level, fmt, ...) {
          if (level > .level) return (invisible(self))
          msg = .mountMessage(fmt,...)
          .println(3, level, msg)
          invisible(self)
       }
       ,executed  = function(rc, begin, fmt, ...) {
          diff = as.numeric(Sys.time()) - begin
          diff = round(diff, 0)
          pattern = paste0("%d;%d;", fmt)
          .println(self$type$PROCESS, 0, .mountMessage(pattern, rc, diff, ...))
           if (.level > 0) {
               .toConsole(self$type$SUMMARY, 1, paste("Elapsed time:", diff))
               .toConsole(self$type$SUMMARY, 1, paste("Return code :", rc))
          }
          invisible(self)
      }
       ,message   = function(fmt, ...) {
         .println(5, 3, .mountMessage(fmt, ...))
         invisible(self)
       }
       ,beg       = function(name, level = 0) {
           if (level > .level) return (invisible(self))
           idx = length(logTimers)
           if (idx == 0) {
               private$logTimers = as.integer(Sys.time())
               private$logNames  = name
           } else {
               private$logTimers = c(logTimers, as.integer(Sys.time()))
               private$logNames  = c(logNames, name)
           }
           idx = length(logTimers)
           message("BEG - %d - %s", logTimers[idx], name)
           invisible(self)
       }
       ,end       = function(name) {
           idx = which.max(logNames)
           if (length(idx) == 0) return (invisible(self))
           idx = idx[1]
           from = length(longNames)
           while (from > idx ) {
              diff = as.integer(Sys.time()) - logTimers[from]
              message("END - %d - %d - %s", as.integer(Sys.time()), diff, logNames[from])
              from = from - 1
           }
           diff = as.integer(Sys.time()) - logTimers[idx]
           message("END - %d - %d - %s", as.integer(Sys.time()), diff, name)
           if (idx == 1) {
               private$logTimers = c()
               private$logNames  = c()
           } else {
               private$logTimers = logTimers[1:(idx - 1)]
               private$logNames  = logNames [1:(idx - 1)]
           }
           invisible(self)
       }
       ,fail = function(cond) {
          data=""
          tags = names(cond)
          for (idx in 1:length(tags)) {
             data=paste0(data,";",tags[idx],": ", cond[[idx]])
          }
          # .toFile(self$type$ERROR, 0, sprintf( "Class: %s;Message: %s;Fields: %d;%s"
          #                                     ,class(cond)[2], cond, length(tags),data))
       }
     ,running = function () {
        # Friendly method for processes active
        message(paste("Process",  modName, "already running"))
     }
     #######################################################################
     # Only for console
     #######################################################################
    ,lbl = function(fmt, ...) {
        if ((.output %% 2) == 1) cat(sprintf(fmt, ...))
        invisible(self)
    }
    ,out = function(fmt, ...) {  # message to stdout
       # message to stdout
        if ((.output %% 2) == 1) cat(.mountMessage(fmt, ...))
        invisible(self)
    }
    ,outln = function(fmt, ...) {
       if ( missing(fmt)) out("\n")
       if (!missing(fmt)) out(paste0(sprintf(fmt, ...), "\n"))
       invisible(self)
    }
    ,ok = function (txt) {
       lbl = ifelse(missing(txt), "OK", txt)
       lbl = paste0("\t", lbl, "\n")
       if ((.output %% 2) == 1) cat(crayon::bold(lbl))
       invisible(self)
    }
    ,ko = function (txt) {
       lbl = ifelse(missing(txt), "KO", txt)
       lbl = paste0("\t", lbl, "\n")
       if ((.output %% 2) == 1) cat(crayon::bold(crayon::red(lbl)))
       invisible(self)
    }

  )
    ,private = list(
        logFile  = NULL
       ,.level  = 0
       ,.output   = 0
       ,.cont = FALSE
       ,modName  = "YATA"
       ,logTimers = NULL
       ,logNames  = NULL
       ,.println = function(type, level, msg, ansi=.void) {
          .print(type, level, msg,  ansi)
          private$.cont = TRUE
          .print(type, level, "\n", ansi)
          private$.cont = FALSE
       }
       ,.print = function(type, level, msg, ansi=.void) {
          if (bitwAnd(.output, 2) > 0) .toFile   (type, level, msg)
          if (bitwAnd(.output, 1) > 0) .toConsole(type, level, msg, ansi)
       }
       ,.toFile = function(type, level, txt, ...) {
           if (level > .level) return()
           str = ""
           if (!.cont) {
               str = Sys.time()
               str = sub(" ", "-", str)
           }
           line = paste(str,modName,type,level,txt, sep=";")
           rest = paste(list(...), collapse=";")
           if (nchar(rest) > 0) line = paste0(line, ";",rest)
           cat(paste0(line, "\n"), file=logFile, append=TRUE)
       }
       ,.toConsole = function(type, level, txt, ansi=.void) {
          if (level > .level) return()
          msg = txt
          if (!.cont) {
              str  = format(Sys.time(), "%H:%M:%S")
              msg  = gsub("\\n","          \n", txt)
#           prfx = NULL
#           if (type == self$type$LOG) prfx = sprintf("LOG%02d -", level)
              msg = paste(str, "-", txt)
          }
          cat(ansi(msg))
       }
       ,.void = function(txt) { txt }

       ,.initLogger = function (level, output, shared) {
           value = Sys.getenv("YATA_LOG_LEVEL")
           value = suppressWarnings(as.integer(value))
           if (!is.na(value)) private$.level  = value

           if (!missing(level)) private$.level  = level

           value = Sys.getenv("YATA_LOG_OUTPUT")
           value = suppressWarnings(as.integer(value))
           if (!is.na(value))    private$.output = value
           if (!missing(output)) private$.output = output

           if (bitwAnd(.output, 2) > 0) {
               wd      = yataGetDirectory("log")
               logfile = ifelse(shared, "YATA", modName)
               logfile = normalizePath(file.path(wd, paste0(logfile, ".log")), mustWork = FALSE)
               private$logFile = file(logfile, open="at", blocking = FALSE)
           }
       }
       ,.mountMessage = function(fmt, ...) {
          #JGG Mantener como funcion por si usamos mensajes preescritos
           txt = sprintf(fmt, ...)
           gsub("/t", "    ", txt, fixed=TRUE)
       }
    )
)
