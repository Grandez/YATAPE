ERROR  = function (msg, condition, ...) { .error(msg, subclass="YATA", origin=condition, ...) }
HTTP   = function(msg, ...) { .error  (msg, subclass="HTTP",  ...)  }
EXEC   = function(msg, ...) { .error  (msg, subclass="EXEC",  ...)  }
MODEL  = function(msg, ...) { .error  (msg, subclass="MODEL", ...)  }
KILLED = function(msg, ...) { .error  (msg, subclass="KILLED", ...) }
FLOOD  = function(msg, ...) { .error  (msg, subclass=c("FLOOD", "HTTP"),  ...) }
SQL    = function(msg, ...) {
   data = list(...)
   msg = paste0(msg, " (", data$sqlcode, ")")
   .error(msg, subclass="SQL", ...)
}

WARN   = function(msg, ...) { .warning(msg, subclass, ...)          }

LOGICAL = function(msg, ...) {
   # Errores logicos y de validaciones
     .error(msg, subclass="LOGICAL", ...)
}
propagateError = function(cond) {
   condErr = unlist(cond)
   classes = class(cond)
   condErr = as.list(condErr)
   if (is.null(condErr$message)) condErr$message = "Unkonw Message"
   errdata = structure( condErr, class = classes)
   stop(errdata)
}
.error = function(msg, subclass, ...) {
   data = list(...)
   data$message = msg
   data$subclass = subclass
   conds = c("YATAERROR", subclass, "error", "condition")
   errdata = structure( data, class = conds)
   stop(errdata)
}

.warning = function(msg, subclass=NULL, ...) {
   warn = structure(list(message=msg, ...),class = c("YATAWARNING",subclass,"warning","condition"))
   warning(warn)
}

