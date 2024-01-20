init = function() {
   unloadNamespace("YATABatch")
   unloadNamespace("YATADBCore")
   unloadNamespace("YATADB")
   unloadNamespace("YATAProviders")
   unloadNamespace("YATATools")
   library(YATABatch)
   message("Ready")
}
