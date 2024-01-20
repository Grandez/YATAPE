localTest <<- TRUE

unloadNamespace("YATAProviders")
unloadNamespace("YATADB")
unloadNamespace("YATATools")

library(YATAProviders)

FACT   <<- YATAProviders::ProviderFactory$new()
