YATAStrings = R6::R6Class("YATA.BASE.STRINGS"
   ,portable  = FALSE
   ,cloneable = FALSE
   ,lock_class = TRUE
   ,public = list(
       titleCase = function(texts, locale="es") { stringr::str_to_title(texts, locale) }
      ,toLower   = function(texts) { base::tolower(texts) }
      ,toUpper   = function(texts) { base::toupper(texts) }
      ,number2string = function(value, dec=-1, round=FALSE) {
          if (round && value > 100) value = round(value)
          if (dec > -1) format(value, nsmall=dec, big.mark=".", decimal.mark=",", mode="character", scientific=FALSE)
          else          format(value, big.mark=".", decimal.mark=",", mode="character", scientific=FALSE)
       }
      ,percentage2string = function(value, calc=FALSE, dec=2, symbol=TRUE) {
          if (calc) {
             if (value >= 1) {
                value = value - 1
             } else if (value <  1 && value > 0) {
                value = (1 - value) * -1
             }
          }
          txt = format(round(value * 100, dec), nsmall=dec, big.mark=".", decimal.mark=",", mode="character", scientific=FALSE)
          sfx = ifelse(symbol, " %","")
          sprintf("%s%s", txt, sfx)
      }
      ,translate = function(patterns, file=NULL, data) {
         if (!is.null(file)) data = readLines(file)
         pat = regexpr("__[0-9a-zA-Z]{1}[0-9a-zA-Z_]*[0-9a-zA-Z]+__", data)
         ind = which(pat != -1)
         if (length(pat) == 0 || length(ind) == 0) return (data)
         attrs = attr(pat, "match.length")
         for (n in 1:length(ind)) {
            idx = ind[n]
            key = substr(data[idx], pat[idx], attrs[idx] + pat[idx] - 1)
            value = patterns[[substr(key, 3, nchar(key) - 2)]]
            data = gsub(key, value, data)
         }
         data
      }
   )
   ,private = list(
   )
)

jgg_to_title = function(text) {
    text = gsub("_", " ", text)
    stringr::str_to_title(text)
}
jgg_to_lower = function(text) { stringr::str_to_lower(text) }
jgg_to_upper = function(text) { stringr::str_to_upper(text) }
jgg_as_title = function(text) { stringr::str_to_title(text) }
