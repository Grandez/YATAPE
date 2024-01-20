.getParm = function(req, parm, def=NULL) {
    p  = req$parameters_query[[parm]]
    if (is.null(p)) return (def)
    p
}
