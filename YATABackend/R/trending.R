get_trending = function(req, .res) {
    period = .getParm(req, "period",  1)
    top    = .getParm(req, "top",  30)
    group  = .getParm(req, "group", 0)

    tryCatch({
        factory   = YATADBCore::DBFactory$new()
        tbl = factory$getTable("Trending")
        df = tbl$table(period = period)
        .setResponse(.res, df)
    }, error = function(cond) {
        .setError(.res, cond)
    }, finally = function() {
        factory$destroy()
    })
}
