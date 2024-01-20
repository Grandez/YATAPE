logger = function(endp, beg=TRUE) {
    cat(paste(format(Sys.time(), "%H:%M:%S"), endp, ifelse (beg, "Started", "Ended"), "\n"))
}
best_body = function(top, count, group) {
    logger("best")
    tryCatch({
    fact = YATACore::YATAFACTORY$new()
    sess = fact$getObject(fact$codes$object$session)
    res = sess$getBest(top, count, group)
    fact$clear()
    logger("best", FALSE)
    res
    }, error = function(e) {
        print("ERROR en best: \n")
        cat(e)
        stop(e)
    })
}
top_body = function(top, count) {
    logger("top")
    tryCatch({
    fact = YATACore::YATAFACTORY$new()
    sess = fact$getObject(fact$codes$object$session)
    res = sess$getTop(top, count)
    fact$clear()
    logger("top", FALSE)
    res
    }, error = function(e) {
        print("ERROR en top: \n")
        cat(e)
        stop(e)
    })
}

# latest_body = function() {
#     tryCatch({
#     logger("latest")
#     fact = YATACore::YATAFACTORY$new()
#     sess = fact$getObject(fact$codes$object$session)
#     res = sess$getLatest()
#     fact$clear()
#     logger("latest", FALSE)
#     res
# }, error = function(e) print("ERROR en latest: \n")) #, e, "\n"))
# }
execLatest = function() {
    fact = YATACore::YATAFACTORY$new()
    session = fact$getObject(fact$codesodes$object$session)
    res = session$updateLatest()
    fact$clear()
    res
}
