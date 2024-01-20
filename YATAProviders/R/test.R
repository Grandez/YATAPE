# Proveedor de pruebas
# No se conecta a internet
PROVTest = R6::R6Class("PROV.TEST"
   ,inherit    = ProviderBase
   ,portable   = FALSE
   ,cloneable  = FALSE
   ,lock_class = FALSE
   ,public = list(
        initialize = function(code, eurusd, path, config) {
           super$initialize(code, "Poloniex", eurusd, path, config)
           loadTickers()
        }
       ,getPath = function(base, counter) {
           searchPath(base, counter)
        }
       # ,ticker     = function(base, counter) {
       #     now = Sys.time()
       #     if (difftime(now, private$last, unit="mins") > private$interval) {
       #        private$last = now
       #        loadTickers()
       #     }
       #
       #     pTicker(base, counter, private$dft)
       # }
       # ,currencies = function() {
       #    url = "%sreturnTicker"
       #    data = get(sprintf(url, urlbase))
       #    cols = unlist(strsplit(names(data), "_", fixed=TRUE))
       #    cols[seq(2, length(cols), by=2)]
       # }
       # ,session    = function(base, counter, interval, from, to, period) {
       #    # Aqui hay que buscar el par adecuado y luego ajustar cambios
       #    # Por ejemplo:
       #    # EUR/BTC - No existe
       #    #    -> USD/BTC - En Poloniex tampoco
       #    #    -> USDC/BTC - Este si existe
       #    # Hacemos el cambio USDC/USD Ya tenemos USD/BTC
       #    # Hacemos el cambio USD/EUR  Ya tenemos EUR/BTC
       #    url = "%sreturnChartData&currencyPair=%s&start=%d&end=%d&period=%d"
       #    start = as.numeric(from)
       #    end = as.numeric(ifelse(missing(to), Sys.time(), to))
       #    pair = paste(base, counter, sep="_")
       #    #interval = switch(period,)
       #
       #    data = get(sprintf(url, urlbase, pair, start, end, period))
       #    # si recupera datos, devuelve el data frame
       #    if (!("data.frame" %in% class(data))) { # Cambiar el orden
       #        pair = paste(counter, base, "_")
       #        data = get(sprintf(url, pair, start, end, period))
       #    }
       #    else {
       #       # Poloniex da los datos al reves
       #       # Ej: USD/BTC da 23000 es decir deberia ser BTC/USD
       #       cols = c("high", "low", "open", "close")
       #       data[,cols] = 1/data[,cols]
       #    }
       #    data$date = as.POSIXct(data$date, origin="1970-01-01")
       #    data$quoteVolume = NULL
       #    names(data)[names(data) == "weightedAverage"] = "average"
       #    prov = rep("POL", nrow(data))
       #    base = rep(base, nrow(data))
       #    counter = rep(counter, nrow(data))
       #    df0 = data.frame(provider=prov, base=base, counter=counter)
       #    df = cbind(df0, data)
       # }
       # ,getCloseSession = function(base, counter, day) {
       #    if (is.character(day)) day = as.Date(day)
       #    # Cogemos los datos del dia y del dia anterior
       #    strTo   = sprintf("%s %d:00:00", day, config$closeTime)
       #    strFrom = sprintf("%s %d:00:00", day - days(1), config$closeTime)
       #    dtFrom  = as.integer(as.POSIXct(strFrom))
       #    dtTo    = as.integer(as.POSIXct(strTo))
       #    ctc = findPath(counter, base)
       #    # En Polonies va al reves
       #    if (is.null(ctc)) return (NULL)
       #    #Al menos  hay dos
       #    df = session(ctc[1], ctc[2], from=dtFrom, to=dtTo, period=86400)
       #    df = df = df[nrow(df),]
       #    for (idx in 2:(length(ctc) - 1)) {
       #        change = ifelse(ctc[idx] == "EUR", EUR$getCloseSession("EUR", "USD", day), df$close)
       #        df = session(ctc[idx], ctc[idx + 1], from=dtFrom, to=dtTo, period=86400)
       #        df = df[nrow(df),]
       #        df = df[,c("high", "low", "open", "close")] * change
       #    }
       #    df
       # }
   )
   ,private = list(
        urlbase = "https://poloniex.com/public?command="
       ,loadTickers = function() {
           df = data.frame(base=character(), counter=character(), last=numeric(), high=numeric(), low=numeric())
           df = rbind(df, list(base="AAA", counter="BBB", last=1, high=2, low=1))
           df = rbind(df, list(base="AAA", counter="CCC", last=2, high=2, low=1))
           df = rbind(df, list(base="AAA", counter="DDD", last=2, high=2, low=1))

           df = rbind(df, list(base="000", counter="111", last=2, high=2, low=1))
           df = rbind(df, list(base="000", counter="222", last=2, high=2, low=1))
           df = rbind(df, list(base="111", counter="666", last=2, high=2, low=1))
           df = rbind(df, list(base="666", counter="999", last=2, high=2, low=1))
           df = rbind(df, list(base="888", counter="999", last=2, high=2, low=1))

           # df = rbind(df, list(base="AAA", counter="OOO", last=2, high=2, low=1))
           # df = rbind(df, list(base="BBB", counter="XXX", last=2, high=2, low=1))
           # df = rbind(df, list(base="CCC", counter="YYY", last=2, high=2, low=1))
           # df = rbind(df, list(base="DDD", counter="EEE", last=2, high=2, low=1))
           # df = rbind(df, list(base="DDD", counter="FFF", last=2, high=2, low=1))
           # df = rbind(df, list(base="DDD", counter="GGG", last=2, high=2, low=1))
           # df = rbind(df, list(base="FFF", counter="JJJ", last=2, high=2, low=1))
           # df = rbind(df, list(base="FFF", counter="KKK", last=2, high=2, low=1))
           # df = rbind(df, list(base="FFF", counter="LLL", last=2, high=2, low=1))
           # df = rbind(df, list(base="GGG", counter="HHH", last=2, high=2, low=1))
           # df = rbind(df, list(base="GGG", counter="III", last=2, high=2, low=1))
           # df = rbind(df, list(base="HHH", counter="III", last=2, high=2, low=1))
           # df = rbind(df, list(base="III", counter="RRR", last=2, high=2, low=1))
           # df = rbind(df, list(base="YYY", counter="ZZZ", last=2, high=2, low=1))
           # df = rbind(df, list(base="XXX", counter="ZZZ", last=2, high=2, low=1))
           df = rbind(df, list(base="MMM", counter="NNN", last=2, high=2, low=1))
           df = rbind(df, list(base="OOO", counter="PPP", last=2, high=2, low=1))
           private$dfTickers = df
       }
   )
)
