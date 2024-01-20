library(YATACoreBatch)

YATAUpdateCurrenciesID = function(pattern="P:/R/YATA2/ext/data/mktcap", verbose="detail") {
    browser()
  YATACoreBatch::updateID(pattern,verbose)
}
