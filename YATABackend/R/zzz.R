library(future)
library(YATABatch)

.onLoad <- function(libname, pkgname){
   #message("Loading YATAREST\n")
   #plan(multisession)
   # if (!exists("YATACodes")) YATACodes <<- YATACore::YATACODES$new()
   # if (!exists("YATAFactory")) YATAFactory <<- YATACore::YATAFACTORY$new()
}
