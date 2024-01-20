
YATARest = R6::R6Class("YATA.BACKEND.REST"
    ,inherit    = RestRserve::Application
    ,lock_class = TRUE
    ,public = list(
        initialize = function(port, logLevel, logOuput) {
            super$initialize()
            self$logger$set_printer(FUN = function(timestamp, level, logger_name, pid, message, ...) {
    message(sprintf("%s - %s - %5d - %s", level, logger_name, pid, message))
})
            self$logger$set_log_level("error")
            private$initREST()
            private$setMiddleware()
            # private$setDoc()
        }
        ,getPort = function() {
            servers = factory$parms$getServers()
            servers$REST$port
         }
    )
   ,private = list(
        factory = NULL
       ,initREST = function() {
         super$add_get ("/alive"      , alive)
         super$add_get ("/best"       , get_best)
         super$add_get ("/history"    , get_history)
         super$add_get ("/latest"     , get_latest)
         super$add_get ("/session"    , get_session)
         super$add_get ("/trending"   , get_trending)
         super$add_get ("/currencies" , get_currencies)
         super$add_post("/names"      , post_names)
       }
      ,setMiddleware = function() {
         json_middleware = Middleware$new( process_response = function(.req, .res) {
             .res$content_type = "application/json"}
        )
        self$append_middleware(json_middleware)
      }
       # ,setDoc = function() {
       #     doc_file = system.file("doc/yatarest.yaml", package = packageName())
       #     super$add_openapi(path = "/yatarest.yaml", file_path = doc_file)
       #     super$add_swagger_ui(path = "/doc", path_openapi = "/yatarest.yaml", use_cdn = TRUE)
       # }
   )
)
