get_session = function(.req, .res) {
   # si id entonces el ultimo dato de ese id, si no, todo
   id   = .getParm(.req, "id")

   tryCatch({
      factory   = YATADBCore::DBFactory$new()
      tbl = factory$getTable("Session")
      data = .latest_get_data(tbl, id)
    rc = 200
    if (is.null(data) || nrow(data) == 0) rc = 204 # NO DATA
    .res$set_status_code(rc)
    .res$set_body(data)
  }, error = function(cond) {
      browser()
     .setError(.res, cond)
  }, finally = function() {
        factory$destroy()
  })
}

get_latest = function(.req, .res) {
   # si id entonces el ultimo dato de ese id, si no, todo
   id   = .getParm(.req, "id")

   tryCatch({
      factory   = YATADBCore::DBFactory$new()
      tbl = factory$getTable("Session")
      data = .latest_get_data(tbl, id)
      .setResponse2(.res, data)
  }, error = function(cond) {
      browser()
     .setError(.res, cond)
  }, finally = function() {
        factory$destroy()
  })
}
.latest_get_data = function (tbl, id) {
    parms = NULL
    if (!is.null(id)) parms = list(id = id)
    sqljoin = ifelse( is.null(id)
                     ,"SELECT ID, MAX(TMS) AS UPDATED FROM SESSION GROUP BY(ID)"
                     ,"SELECT ID, MAX(TMS) AS UPDATED FROM SESSION WHERE ID = ?")

    stmt1 =              "SELECT * FROM SESSION AS A "
    stmt  = paste(stmt1, "INNER JOIN (", sqljoin, ") AS B")
    stmt  = paste(stmt,  "ON A.ID = B.ID")
    stmt  = paste(stmt,  "WHERE A.TMS = B.UPDATED")

    df = tbl$raw(stmt, params = parms)
    df = df[,1:(ncol(df) - 2)]
    df = tbl$setColNames(df)
    df
}

