#!/usr/bin/env Rscript
library(YATASetup)
yata_update = function() {
    # CAmbiado otra
    setup = YATASetup$new()
    browser()
    rc = setup$updateYATA()
    # rc = setup$git$pull()
    # 
    # if (rc != 0) setup$fatal(127, "Error en el pull")
    # browser()
    # pkgs = setup$getPackages()
    # browser()
#    makeBinaries(git$getBinaries())
#    makePackages(git$getPackages())
    rc
}