#  #!/usr/bin/env Rscript
unloadNamespace("YATAREST")
library(RestRserve)
library(YATAREST)

startYATARest = function(port=9090) {
    YATARest = YATAREST$new()
    backend = BackendRserve$new()
    backend$start(YATARest, http_port = port)    
}

startYATARest()