YATANS = function (namespace, id = NULL)
{
    if (length(namespace) == 0)
        ns_prefix <- character(0)
    else ns_prefix <- paste(namespace, collapse = ns.sep)
    f <- function(id) {
        if (length(id) == 0)
            return(ns_prefix)
        if (length(ns_prefix) == 0)
            return(id)
        paste(ns_prefix, id, sep = ns.sep)
    }
    if (missing(id)) {
        f
    }
    else {
        f(id)
    }
}
