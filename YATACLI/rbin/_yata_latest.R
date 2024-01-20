#!/usr/bin/env Rscript
library(YATASetup)
process = function() {
    setup = YATASetup$new()
    rc = setup$updateYATA()
    invisible(rc)
}
process()
