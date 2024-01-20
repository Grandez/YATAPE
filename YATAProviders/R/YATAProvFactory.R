# Devuelve una instancia de un proveedor de datos
ProviderFactory = R6::R6Class("YATA.FACTORY.PROVIDER"
   ,portable   = FALSE
   ,cloneable  = FALSE
   ,lock_class = FALSE
   ,public = list(
        factory = NULL
       ,initialize = function() {
          # le pasamos la factoria para que obtenga sus datos
#           if (!missing(external)) private$provNames = c(private$provNames, external)
            # if (missing(dbf)) dbf = YATADB::YATADBFactory$new()
            # private$dbf  = dbf
#            private$EUR = get("EUR", "Euro")
            # Por ahora vamos a tirar de MarketCap

            private$mktcap = PROVMarketCap$new("MKTCAP") # , dbf)
        }
       ,finalize = function() {
          private$providers = NULL
          private$dbf = NULL
          private$config = NULL
       }
       ,print              = function() { message("Providers factory") }
       ,getDefaultProvider = function() { private$mktcap               }
       ,get = function(code, provider, force=FALSE) {
          private$mktcap
           # if (force) {
           #     createProvider(code, provider)
           # } else {
           #   if (is.null(private$providers$get(provider)))
           #       providers$put(provider, createProvider(code, provider))
           #   private$providers$get(provider)
           # }
       }
      ,setOnlineInterval = function(value) { private$config$interval     = value }
      ,setCloseTime      = function(value) { private$config$closeTime    = value }
      ,setBaseCurrency   = function(value) { private$config$baseCurrency = value }
      ,setFactory        = function(value) {
          self$factory = value
          private$mktcap$setFactory(value)
       }

   )
   ,private = list(
       providers = YATATools::map()
      ,dbf    = NULL
      ,EUR    = NULL
      ,mktcap = NULL
      ,config = list()
      ,createProvider = function (code, provider) {
         #eval(parse(text=paste0("PROV", provider, "$new(code, EUR, dbf=dbf)")))
          eval(parse(text=paste0("PROV", provider, "$new(code, EUR)")))
      }
   )

)
