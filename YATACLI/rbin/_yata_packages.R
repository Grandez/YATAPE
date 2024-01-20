#!/usr/bin/env Rscript
library(YATASetup)
process = function() {
    setup = YATASetup$new()
    rc = setup$updatePackages()
    invisible(rc)
}
process()
