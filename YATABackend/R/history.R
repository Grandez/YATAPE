get_history = function(.req, .res) {
    id   = .getParm(.req, "id")
    from = .getParm(.req, "from")
    to   = .getParm(.req, "to")

    if (is.null(id) || is.null(from)) return (.missingParms(.res))
    if (is.null(to)) to = as.character(Sys.Date())

    chk = tryCatch({
        dt = as.Date(from)
        dt = as.Date(to)
        FALSE
    }, error = function (cond) { TRUE })
    if (chk) return (.invalidParms(.res, descr="Invalid or malformed dates"))

    tryCatch({
        factory   = YATADBCore::DBFactory$new()
        tbl = factory$getTable("History")
        df = tbl$recordset(id=list(value=id), tms=list(op="between", value=c(from, to)))
        .setResponse(.res, df)
    }, error = function(cond) {
        browser()
        .setError(.res, cond)
    }, finally = function() {
        factory$destroy()
    })
}
