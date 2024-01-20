get_currencies = function (.req, .res) {
    type = .getParm(.req, "type", "all")
    all  = .getParm(.req, "all")

    tryCatch({
       factory   = YATADBCore::DBFactory$new()
       tbl = factory$getTable("Currencies")
       df  = tbl$table()
       if (type != "all") {
           tok = ifelse(type == "token", 1, 0)
           df = df[df$token == tok,]
       }
       if (is.null(all)) all = "false"
       all = ifelse(all == 1 || all == "true", TRUE, FALSE)
       if (!all) df = df[df$active == 1,]
       .setResponse(.res, df)
   }, error = function(cond) {
        .setError(.res, cond)
   }, finally = function() {
        factory$destroy()
   })

}

post_names = function (.req, .res) {
# Si no se le pasan identificadores, devuelve todo
   tryCatch({
      factory   = YATADBCore::DBFactory$new()
      tbl = factory$getTable("Currencies")
      ids = NULL
      if (!is.null(.req$body)) ids = strsplit(.req$body, "[,;]")[[1]]
      if (length(ids) == 0) {
          data = tbl$table()
      } else {
          data = tbl$recordset(id=list(op="in", value=ids))
      }

      data = data[,c("id", "symbol", "name", "type", "active")]
      .setResponse2(.res, data)
  }, error = function(cond) {
     .setError(.res, cond)
  }, finally = function() {
        factory$destroy()
  })

}
