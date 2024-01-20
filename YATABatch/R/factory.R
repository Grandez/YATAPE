# Factoria para Obtener diferentes objetos
# Los dejamos en lazy para no crear referencias circulares con los

Factory = R6::R6Class("YATA.BACKEND.FACTORY"
   ,portable  = FALSE
   ,cloneable = FALSE
   ,lock_class = TRUE
   ,public = list(
       print = function()     { message("Object's factory for BackEnd") }
      ,initialize = function() {
          private$DBFactory   = YATADBCore::DBFactory$new()
          private$ProvFactory = YATAProviders::ProviderFactory$new()
       }
      ,finalize    = function() { destroy() }
      ,destroy     = function(){
         if (!is.null(DBFactory)) DBFactory$destroy()
      }
     ,getDefaultProvider = function() { ProvFactory$getDefaultProvider() }
     ,getTable    = function(name, force = FALSE) { DBFactory$getTable(name, force) }
     ,getObject   = function(name, force = FALSE) {
         # Pasamos la propia factoria como referencia
         if (force) return ( eval(parse(text=paste0("OBJ", name, "$new(self)"))))
         if (is.null(objects$get(name)))
             private$objects$put(name,eval(parse(text=paste0("OBJ", name, "$new(self)"))))
             objects$get(name)
         }
   )
   ,private = list(
       DBFactory   = NULL
      ,ProvFactory = NULL
   )
)

