.getParm = function(req, parm, default) {
    p  = req$parameters_query[[parm]]
    ifelse(is.null(p), dafult, p)
}
.setResponse = function (.res, data, status) {
    rc = 200
    if (is.null(data) || nrow(data) == 0) rc = 204 # NO DATA
    .res$set_status_code(rc)
    .res$set_body(jsonlite::toJSON(data, data.frame = "rows"))
#    .res$set_content_type("text/plain")
}
.setResponse2 = function (.res, data, status) {
    rc = 200
    if (is.null(data) || nrow(data) == 0) rc = 204 # NO DATA
    .res$set_response(rc, jsonlite::toJSON(data, data.frame = "rows"), "text/plain")
}
.missingParms = function (.res, ...) {
    resp = list(message="Missing parameters", rc=400)
    resp = jgg_list_merge(resp, list(...))
    .sendError(.res, 400, resp)
}
.invalidParms = function(.res, ...) {
    resp = list(message="Invalid parameters", rc=400)
    resp = jgg_list_merge(resp, list(...))
    .sendError(.res, 400, resp)
}
.notFound = function(.res, txt) {
    .res$set_status_code(204)
    .res$set_content_type("text/plain")
    .res$set_body(txt)
}
.setError = function(.res, cond) {
    .sendError(.res, 500, as.list(cond))
}
.sendError = function(.res, rc, data) {
    .res$set_status_code(rc)
    .res$set_content_type("application/json")
    .res$set_body(data)
}
