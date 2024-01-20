#!/usr/bin/env Rscript
library(YATASetup)
process = function() {
    setup = YATASetup$new()
    rc = setup$updateServices()
    invisible(rc)
}
process()