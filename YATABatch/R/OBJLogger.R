#' @title Logger para YATA
#'
#' @description
#' Extiende la clase SDPLogger
#'
#' @import R6
#' @export
YATALogger = R6::R6Class("YATA.LOGGER"
   ,cloneable  = FALSE
   ,lock_class = FALSE
   ,portable   = FALSE
   ,inherit    = SDPLogger
  ,public = list(
     initialize   = function(level=0, output=0) {
         super$initialize(module = "YATA", level = level, output = output, envvars = "YATA")
     }
    )
)
