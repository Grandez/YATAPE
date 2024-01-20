get_best = function(req, .res) {
# Parameters:
#   period: session/day/middle/week/fortnight/month/bimonth/quarter
#   type:   price/volume
#   top; rows
#
    period = .getParm(req, "period",  "day")
    top    = .getParm(req, "top",  30)
    type   = .getParm(req, "type", "price")

    periods = c("session", "day","middle","week","fortnight","month","bimonth","quarter")
    matchPeriod = function (period) {
       idx = which(period %in% periods)
       sprintf("%02d", idx)
    }
    checkParms = function() {
       res = which(period %in% periods)
       if (length(res) == 0) stop(paste("Invalid parameter: period =", period))
       if (!is.numeric(top)) stop(paste("Invalid parameter: top =", top))
       if (top < 1)          stop(paste("Invalid parameter: top =", top))
       if (type != "price" && type != "volume") stop(paste("Invalid parameter: type =", type))
    }

    tryCatch({
        browser()
        checkParms()

        factory   = YATADBCore::DBFactory$new()
        tbl = factory$getTable("Variations")
        fld = ifelse(type == "price", "p", "v")
        fld = paste0(fld, matchPeriod(period))
        df = tbl$ordered(fld, "desc", limit=top)
        .setResponse(.res, df)
    }, error = function(cond) { browser(); .setError(.res, cond) })

    factory$destroy()
}
