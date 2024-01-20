# Poloniex da datos cada
# 300  	    5	minutos
# 900	      15	minutos
# 1800	   30	minutos
# 7200	  120	   2  Horas
# 14400    240	   4  Horas
# 386400	 1440	   1  Dia
# La parte 1 hora la hacemos con 2 de 30
# La parte 8 horas con 2 de 4

# UDSC cotiza en USDT
# No Hay USD/USDT

PROVPoloniex = R6::R6Class("PROV.POLONIEX"
   ,inherit    = ProviderBase
   ,portable   = FALSE
   ,cloneable  = FALSE
   ,lock_class = FALSE
   ,public = list(
        initialize = function(code, eurusd) {
           super$initialize(code, "Poloniex", eurusd)
           private$lastGet = as.POSIXct(1, origin="1970-01-01")
           loadTickers()
        }
       ,getCurrencies = function() {
           url = "%sreturnCurrencies"
           data = get(sprintf(url, urlbase))
           sym = names(data)
           nam = names(data)
           ids = lapply(data, function(x) x$id)
           df = data.frame(symbol=sym, name=nam,id=unlist(ids))
           row.names(df) = NULL
           df
      }
       ,currencies = function() {
          url = "%sreturnTicker"
          data = get(sprintf(url, urlbase))
          cols = unlist(strsplit(names(data), "_", fixed=TRUE))
          cols[seq(2, length(cols), by=2)]
       }
       ,getSession    = function(base, counter, from, to, period) {
           # Poloniex da las sessiones redondeadas alintervalo

          url   = "%sreturnChartData&currencyPair=%s&start=%f&end=%f&period=%d"
          start = round2Epoch(from, period)
          end   = round2Epoch(ifelse(missing(to), Sys.time(), to), period, FALSE)

          path = .getPath(base, counter)
          # Al menos debe haber 1

          pair = c(path[1], path[2])
          data = get(sprintf(url, urlbase, paste(pair[1],pair[2], sep="_"), start, end, period))
          colnames(data)[1] = "tms"
          if (path[3] == "INV") data = .invert(data)
          idx  = 4
          while (idx < length(path)) {
             pair = c(path[idx], path[idx+1])
             ndata = get(sprintf(url, urlbase, paste(pair[1],pair[2], sep="_"), start, end, period))
             if (path[idx+2] == "INV") ndata = .invert(ndata)
             data = .adjust(ndata, data[,"close"])
             idx = idx + 3
          }
          if (!base %in% pair) data = .applyFiat(data, base, pair[1], asDate(start), asDate(end))
          .adjustDFSession("POL", base, counter, data)
       }
      # ,getSessionDays = function(base, counter, from, to) {
      #     getSession(base, counter, from, to, 86400)
      #  }
       ,getCloseSession = function(base, counter, day) {
          if (is.character(day)) day = as.Date(day)
          # Cogemos los datos del dia y del dia anterior para que haya dos
          strTo   = sprintf("%s %d:00:00", day, config$closeTime)
          strFrom = sprintf("%s %d:00:00", day - days(1), config$closeTime)
          dtFrom  = as.integer(as.POSIXct(strFrom))
          dtTo    = as.integer(as.POSIXct(strTo))
          df = getSession(base, counter, from=dtFrom, to=dtTo, period=86400)
          path    = getPath(base, counter)
          if (is.null(path)) return (NULL)
          #Al menos  hay dos
          df = getSession(path[1], path[2], from=dtFrom, to=dtTo, period=86400)
          df = df[nrow(df),]
          if (path[3] == "INV")
          for (idx in 2:(length(path) - 1)) {
              change = ifelse(ctc[idx] == "EUR", EUR$getCloseSession("EUR", "USD", day), df$close)
              df = session(ctc[idx], ctc[idx + 1], from=dtFrom, to=dtTo, period=86400)
              df = df[nrow(df),]
              df = df[,c("high", "low", "open", "close")] * change
          }
          df
       }
   )
   ,private = list(
        urlbase = "https://poloniex.com/public?command="
       ,loadTickers = function() {
           now = Sys.time()
           if (difftime(now, lastGet, unit="mins") < interval) return (invisible(self))
           private$lastGet = now
           resp = get("https://poloniex.com/public?command=returnTicker")
           dfv = as.data.frame(list.stack(resp))
           dfv = adjustTicker(dfv)
           max = ncol(dfv)
           dfv[,1:max] = sapply(dfv[,1:max], as.numeric)
           cols = strsplit(names(resp), "_", fixed=TRUE)
           dfc = data.frame(base=sapply(cols, function(x) x[[2]]), counter = sapply(cols, function(x) x[[1]]))
           private$dfTickers = cbind(dfc, dfv)
           # Poloniex lo da correcto: Ejemplo: BTC/USD = 30000
           private$dfTickers$dfx = private$dfTickers$base
           private$dfTickers$base = private$dfTickers$counter
           private$dfTickers$counter = private$dfTickers$dfx
           private$dfTickers = dfTickers[,c(1:(ncol(dfTickers) - 1)),]
           addDefaults()
       }
       ,adjustTicker = function(df) {
           # Pone los nombres esperados a las columnas
          df = df[,-1]
           colnames(df) = c("last", "lowest", "highest", "change", "baseVolume", "quoteVolume", "active", "high", "low")
           df$active = ifelse(df$active == 0, 1, 0)
           df
       }
   )
)
