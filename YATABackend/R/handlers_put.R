update_handler = function(.req, .res) {
    cat("Recibe UPDATE\n")
    message(Sys.time(), "update Called\n")
    tryCatch({
       sess = Factory$getObject(Factory$CODES$object$session)
       sess$updateLatest()
      .res$set_status_code(200)
      .res$set_content_type("text/plain")
      .res$set_body("OK\n")
      cat(Sys.time(), "UPDATE OK\n")
    }, error = function(e) {
        cat("UPDATE ERROR\n")
        message(Sys.time(), "UPDATE ERROR")
        message(Sys.time(), e)
      .res$set_status_code(500)
      .res$set_content_type("text/plain")
      .res$set_body(e)
    })
    .res
}
put_begin = function(.req, .res) {
        cat(paste(Sys.time(),"Recibe begin\n"))
    root = Sys.getenv("YATA_SITE")
    interval = .req$parameters_query[["interval"]]
    alive    = .req$parameters_query[["alive"]]
    if (is.null(interval)) interval = ""
    if (is.null(alive))    alive    = ""

    if (.Platform$OS.type != "windows") {
        res = processx::run(paste0(root, '/bin/yata_mqcli'), c("start", interval, alive), FALSE)
        cat(paste(Sys.time(),"Eejecutado mcli con rc", res$status_code, "\n"))
    }
   .res$set_status_code(200)
   .res$set_body("OK")
}
put_end = function(.req, .res) {
    root = Sys.getenv("YATA_SITE")
    if (.Platform$OS.type != "windows") {
        processx::run( paste0(root, '/bin/yata_mqcli'), "stop", FALSE)
    }
   .res$set_status_code(200)
   .res$set_body("OK")
}
