unloadNamespace("YATABatch")
unloadNamespace("YATACore")
unloadNamespace("YATAProviders")
unloadNamespace("YATADB")

library(YATABatch)
testUpdateCurrencies = function() {
    YATABatch::updateCurrencies(33)
}