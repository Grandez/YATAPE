#URL de mercadosde una moneda
# https://api.coinmarketcap.com/data-api/v3/cryptocurrency/market-pairs/latest?slug=bnb&start=1&limit=100&category=spot&sort=cmc_rank_advanced
# URL Para exchanges
# cryptoType = all / coins / tokens
PROVMarketCap = R6::R6Class("YATA.PROV.MARKETCAP"
  ,inherit    = ProviderBase
  ,portable   = FALSE
  ,cloneable  = FALSE
  ,lock_class = FALSE
  ,public = list(
     initialize       = function(code) { # }, dbf) {
#       super$initialize  (code, "CoinMarketCap", factory) #, dbf)
       super$initialize  (code, private$URL, private$API)
     }
    ,getCurrencies    = function() {
        count   =   0
        maxRows = 100 # Numero maximo de filas que devuelve la peticion
        dfc     = NULL
        process = TRUE
        parms = list( start=1)

        makeList = function(x)    {
           since = ifelse(is.null(x$dateAdded), x$lastUpdated, x$dateAdded)
           since = substr(since,1,10)
           if (nchar(x$symbol) > 64) x$symbol = substr(x$symbol,1,64)
           list( id=as.integer(x$id)
                ,name=x$name
                ,symbol=x$symbol
                ,mktcap=x$symbol
                ,slug=x$slug
                ,rank=as.integer(x$cmcRank)
                ,since = since
                ,active = as.integer(x$isActive)
                ,type = ifelse(is.null(x$platform), 0, 1)
                ,audited = ifelse(x$isAudited == "true", 1,0)
               )
        }
        data  = http$json(makeAPI("cryptocurrency/listing"), parms=parms, headers=changeUserAgent())

        while (process) {
             if (count > 0) Sys.sleep(1) # Para no saturar
             data = http$json(makeAPI("cryptocurrency/listing"), parms=parms, headers=changeUserAgent())
             data  = data[[1]]

             items = lapply(data, function(x) makeList(x))
             df    = do.call(rbind.data.frame,as.list(items))
             dfc   = rbind(dfc, df)
             count = count + nrow(df)
             if (nrow(df) < maxRows) process = FALSE
             parms$start = df[nrow(df), "rank"] + 1
        }
        #JGG NOTE A veces genera algun duplicado
        dfc = data.table(dfc)
        unique(dfc, by = "id")
    }

#     ,getCurrencies    = function(from = 1, items = 0, type="all") {
#         url     = "https://api.coinmarketcap.com/data-api/v3/cryptocurrency/listing"
# #https://api.coinmarketcap.com/data-api/v3/topsearch/rank?timeframe=24h&top=30
#         count   =   0
#         until   = 501
#         dfc     = NULL
#         process = TRUE
#         mlimit  = ifelse(items > 0, items, 500)
#         #parms = list( start=from, limit=mlimit, cryptoType=type, tagType=type)
#         parms = list( start=from, limit=mlimit)
#
#         while (process) {
#              if (count > 0) Sys.sleep(1) # Para no saturar
#              heads = changeUserAgent()
#              data  = http$json(url, parms=parms, headers=heads)
#
#              until = ifelse (items > 0, items, data$totalCount)
#              data  = data[[1]]
#              parms$start = parms$start + length(data)
#
#              lst = lapply(data, function(x) {
#                     since = ifelse(is.null(x$dateAdded), x$lastUpdated, x$dateAdded)
#                     since = substr(since,1,10)
#                     if (nchar(x$symbol) > 64) x$symbol = substr(x$symbol,1,64)
#                     list( id=as.integer(x$id)
#                          ,name=x$name
#                          ,symbol=x$symbol
#                          ,mktcap=x$symbol
#                          ,slug=x$slug
#                          ,rank=as.integer(x$cmcRank)
#                          ,since = since
#                          ,active = as.integer(x$isActive)
#                          ,token = ifelse(is.null(x$platform), 0, 1)
#                      )
#                    })
#              df = do.call(rbind.data.frame,as.list(lst))
#              dfc = rbind(dfc, df)
#              count = count + length(data)
#              if (count >= until || length(data) < mlimit) process = FALSE
#         }
#         dfc
#     }
    ,getCurrenciesNumber = function(type=c("all", "coins", "tokens")) {
        url     = "https://api.coinmarketcap.com/data-api/v3/cryptocurrency/listing"
        parms = list( start=1, limit=2, cryptoType=match.arg(type))
        data  = http$json(url, parms=parms, headers=headers)
        as.integer(data$totalCount)
    }
    ,getTickers    = function(start = 1, tickers = 100) {
        # si count = 0 recupera todo
        numRows =   0 # Tickers recuperados
        maxRows = 100 # Numero maximo de filas que devuelve la peticion
        dfc     = NULL
        parms = list( start=start)

        # JGG OJO Los porcentajes son reales, 0,12 es 0,12% no 12%
        makeList = function(x)    {
          quote  = x$quotes[[1]]
          list( id        = x$id
               ,symbol    = x$symbol
               ,rank      = x$cmcRank
               ,price     = toNum(quote$price)
               ,volume    = toNum(quote$volume24)
               ,volday    = toNum(quote$volume24)
               ,volweek   = toNum(quote$volume7d)
               ,volmonth  = toNum(quote$volume30d)
               ,hour      = toNum(quote$percentChange1h)  / 100
               ,day       = toNum(quote$percentChange24h) / 100
               ,week      = toNum(quote$percentChange7d)  / 100
               ,month     = toNum(quote$percentChange30d) / 100
               ,bimonth   = toNum(quote$percentChange60d) / 100
               ,quarter   = toNum(quote$percentChange90d) / 100
               ,dominance = toNum(quote$dominance)
               ,turnover  = toNum(quote$turnover)
               ,updated   = quote$lastUpdated
          )
        }

        process = TRUE
        while (process) {
             if (numRows > 0) Sys.sleep(1) # Para no saturar
             data = http$json(makeAPI("cryptocurrency/listing"), parms=parms, headers=changeUserAgent())
             data  = data[[1]]

             items = lapply(data, function(x) makeList(x))
             df    = do.call(rbind.data.frame,as.list(items))
             dfc   = rbind(dfc, df)
             numRows = numRows + nrow(df)
             # No ha suficientes datos (se acabo el proceso)
             if (nrow(df) < maxRows) process = FALSE
             # Se ha llegado al limite de filas solicitado
             if (tickers > 0 && numRows >= tickers) process = FALSE
             parms$start = df[nrow(df), "rank"] + 1
        }
        if (!is.null(dfc) && nrow(dfc) > 0) {
            dfc = as_tms(dfc,"updated")
            dfc = data.table(dfc)
            #JGG NOTE A veces genera algun duplicado
            dfc = unique(dfc, by = "id")
            if (tickers > 0) dfc = dfc[1:tickers,]
        }
        dfc
    }

    ,getTickers2  = function(from = 1, items = 0) {
        url     = "https://api.coinmarketcap.com/data-api/v3/cryptocurrency/listing"
        count   =   0
        until   = 501
        dfc     = NULL
        process = TRUE
        mlimit  = ifelse(items > 0, items, 500)
        parms = list( start=from, limit=mlimit, cryptoType="all", tagType="all")

#        toNum    = function(item) { ifelse(is.null(item), 0, item) }
        makeList = function(x)    {
          quote  = x$quotes[[1]]
          browser()
          list( id        = x$id
               ,symbol    = x$symbol
               ,rank      = x$cmcRank
               ,price     = toNum(quote$price)
               ,volume    = toNum(quote$volume24)
               ,volday    = toNum(quote$volume24)
               ,volweek   = toNum(quote$volume7d)
               ,volmonth  = toNum(quote$volume30d)
               ,hour      = toNum(quote$percentChange1h)
               ,day       = toNum(quote$percentChange24h)
               ,week      = toNum(quote$percentChange7d)
               ,month     = toNum(quote$percentChange30d)
               ,bimonth   = toNum(quote$percentChange60d)
               ,quarter   = toNum(quote$percentChange90d)
               ,dominance = toNum(quote$dominance)
               ,turnover  = toNum(quote$turnover)
               ,tms       = quote$lastUpdated
          )
        }

        while (process) {
             if (count > 0) Sys.sleep(1) # Para no saturar
             data  = http$json(makeAPI("cryptocurrency/listing"), parms=parms, headers=changeUserAgent())
#             data  = http$json(url, parms=parms, headers=headers)
             until = ifelse (items > 0, items, data$totalCount)
             data  = data[[1]]
             parms$start = parms$start + length(data)
             lst = lapply(data, function(x) makeList(x))
             df = do.call(rbind.data.frame,as.list(lst))
             dfc = rbind(dfc, df)
             count = count + length(data)
             if (count >= until || length(data) < mlimit) process = FALSE
        }
        dfc = as_tms(dfc, c(17))
        dfc
    }
    ,getTrending = function(period=c("day", "week", "month"), top=30) {
        toNum    = function(item) { ifelse(is.null(item), 0, as.numeric(item)) }
        toTms    = function(item) { paste(substr(item, 1, 10), substr(item,12,19), sep="-")}
        makeList = function(x)    {
          changes = x$priceChange
          list( id        = as.integer(x$id)
               ,type      = as.integer(x$dataType)
               ,symbol    = x$symbol
#               ,name      = x$name
               ,rank      = as.integer(x$rank)
               ,marketcap = toNum(x$marketCap)
               ,price     = toNum(changes$price)
               ,pvar01    = toNum(changes$priceChange24h)
               ,pvar07    = toNum(changes$priceChange7d)
               ,pvar30    = toNum(changes$priceChange30d)
               ,vvar01    = toNum(changes$Volume24h)
               ,tms       = toTms(changes$lastUpdate)
          )
        }

        if (top < 10 || top > 30) stop("getTrending top debe ser entre 10 y 30")
        keys = c(day="24h", week="7d", month="30d")

        per = ifelse (missing(period), "day", match.arg(period))
        parms = list(timeframe = keys[per], top=top)
        data  = http$json(makeAPI("topsearch/rank"), parms=parms, headers=changeUserAgent())
        if (is.null(data)) return (NULL)

        data  = data$cryptoTopSearchRanks
        items = lapply(data, function(x) makeList(x))
        do.call(rbind.data.frame,items)
    }

#         # Coinmarketcap maneja entre 10 y 30
#         browser()
# https://api.coinmarketcap.com/data-api/v3/topsearch/rank?timeframe=24h&top=30
#         table = http$html_table("https://coinmarketcap.com/trending-cryptocurrencies/", accept=500)
#         if (is.null(table)) return (NULL)
#
#         dfData  = table[,4:9]
#         for (i in 1:ncol(dfData)) {
#             dfData[,i] = gsub("[\\$\\%,-]", "", dfData[,i])
#             dfData[,i] = as.numeric(dfData[,i])
#         }
#         # Partir nombre y simbolo (fallar si el simbolo tiene numeros)
#         lbls = as.data.frame(table[,3])
#         res = regexpr("[0-9]+[a-zA-Z]+$", lbls[,1])
#         lbls$tmp = res
#         lbls$len = attr(res,"match.length")
#         lbls$name = substr(lbls[,1],1,nchar(lbls[,1]) - lbls[,3])
#         lbls$symbol = substr(lbls[,1],lbls[,2],nchar(lbls[,1]))
#         lbls$tmp     = regexpr("[a-zA-Z]+$", lbls$sym)
#         lbls$symbol = substr(lbls$symbol,lbls$tmp,nchar(lbls$symbol))
#         lbls = lbls[,c("symbol","name")]
#         df = cbind(lbls, dfData)
#         cols = c("symbol", "name", "price", "day", "week", "month", "marketcap", "volume")
#         colnames(df) = cols
#         df
#     }

    ##############################################################################
    # Not checked
    ##############################################################################
    ,getIcons         = function(maximum, force=FALSE) {
        #JGG Revisar
        urlBase = "https://s2.coinmarketcap.com/static/img/coins/200x200/"
        urlBase2 = "https://s2.coinmarketcap.com/static/img/coins/64x64/"
        if (missing(maximum)) maximum=9999
        oldwd = getwd()
        site = Sys.getenv("YATA_SITE")
        site = "P:/R/YATA2/"
        wd = file.path(site, "YATAExternal", "icons")
        setwd(wd)
        files = list.files()
        for (idx in 1:maximum) {
             png = paste0(idx, ".png")
             cat(png)
             if (length(which(files == png)) != 0 && !force) {
                 cat("\tExist\n")
             }
             resp = http$get(paste0(urlBase, png), parms=NULL, headers=headers, accept=500)
             if (resp$status_code != 200) {
                 cat("\tKO\n")
             } else {
               writeBin(resp$content, png)
                 cat("\tOK\n")
             }
        }
        setwd(oldwd)
    }
    # ,getTickers2       = function(from = 1, max = 0) {
    #     toNum    = function(item) { ifelse(is.null(item), 0, item) }
    #     makeList = function(x)    {
    #       quote  = x$quotes[[1]]
    #       list( id        = x$id
    #            ,symbol    = x$symbol
    #            ,rank      = x$cmcRank
    #            ,price     = toNum(quote$price)
    #            ,volume    = toNum(quote$volume24)
    #            ,volday    = toNum(quote$volume24)
    #            ,volweek   = toNum(quote$volume7d)
    #            ,volmonth  = toNum(quote$volume30d)
    #            ,hour      = toNum(quote$percentChange1h)
    #            ,day       = toNum(quote$percentChange24h)
    #            ,week      = toNum(quote$percentChange7d)
    #            ,month     = toNum(quote$percentChange30d)
    #            ,bimonth   = toNum(quote$percentChange60d)
    #            ,quarter   = toNum(quote$percentChange90d)
    #            ,dominance = toNum(quote$dominance)
    #            ,turnover  = toNum(quote$turnover)
    #            ,tms       = quote$lastUpdated
    #       )
    #     }
    #
    #     logfile = paste0(Sys.getenv("YATA_SITE"), "/data/log/mktcap.log")
    #
    #     url =  "https://api.coinmarketcap.com/data-api/v3/cryptocurrency/listing"
    #     until = from + 500
    #     dfc   = NULL
    #     parms = list( start=from, limit=500, cryptoType="all", tagType="all")
    #     resp = list(total=0, from=0, count=0)
    #     while (parms$start < until) {
    #        if (parms$start > 1) Sys.sleep(1) # avoid DoS
    #        tryCatch({
    #          #logger$doing(3, "Getting tickers from %5d ", parms$start)
    #          data = http$json(url, parms=parms, headers=headers)
    #
    #          #logger$done(3)
    #
    #          if (is.null(data) || length(data) == 0) break
    #
    #          resp$total  = as.integer(data$totalCount)
    #          resp$from   = parms$start
    #          resp$count  = length(data$cryptoCurrencyList)
    #          parms$start = parms$start + resp$count
    #          data        = data$cryptoCurrencyList
    #          until       = ifelse (max == 0, resp$total, max)
    #
    #          if (length(data) > 0) {
    #              items = lapply(data, function(x) makeList(x))
    #               df    = do.call(rbind.data.frame,items)
    #               df    = as_tms(df, c(17))
    #               dfc   = rbind(dfc, df)
    #          }
    #        }, error = function (cond) {
    #            cat("ERROR GetTickers", cond$message)
    #           #logger$done(3, FALSE)
    #        })
    #     }
    #     resp$df = dfc
    #     resp
    # }
    ,getHistorical    = function(idCurrency, pfrom, pto ) {
        #JGG PARECE QUE AHORA SOLO DEVUELVE 180/1 DIAS EN LUGAR DE TODO EL RANGO
        #JGG ESTO NO ES PROBLEMA EN CONDICIONES NORMALES QUE SOLO PEDIMOS UNOS DIAS
        #JGG PERO SI PARA PROCESOS MAS MASIVOS, ASI QUE IREMOS POR BUCLES DE 90 DIAS
        #JGG Cogemos en bucles de 25 dias para saltar los limites
        url = "https://api.coinmarketcap.com/data-api/v3/cryptocurrency/historical"
        dfHist = NULL

        logfile = paste0(Sys.getenv("YATA_SITE"), "/data/log/mktcap.log")

        if (is.null(idCurrency)) return(NULL)
        mfrom = pfrom
        mto   = pto
        range = as.integer(mto - mfrom)
        times = 0
        #JGGNOTE Hay que ir al reves
        #JGGNOTE Es decir, cuando no devuelva datos para el proceso
        repeat {
           if (range <  1) break;
           if (range > 25) mto = mfrom + 25
           if (times > 0) Sys.sleep(2) # evitar floods

           heads = changeUserAgent()

           # sometimes psix number is returned in scientific format
           from = format(makePosix(mfrom), scientific = FALSE)
           to   = format(makePosix(mto),   scientific = FALSE)
           parms = list(id = idCurrency, timeStart = from, timeEnd = to,convertId  = 2781) #JGG 2781 = USD 2790-EUR

           data  = http$json(url, parms=parms, headers=heads)
           data  = data$quotes
           # JGG ESto no se para que  s1 = sapply(data, function(item) unlist(item))
           if (length(data) > 0) {
               items = lapply(data, function(item) {
                              l1 = list(timeHigh=item$timeHigh, timeLow=item$timeLow)
                              YATATools::list_merge(item$quote, l1)
                             })
               df     = do.call(rbind.data.frame,items)
               dfHist = rbind(dfHist, df)
           }
           # Coger la fecha del ultimo y chequear si se ha ejecutado para evitar cierres de monedas
           mfrom = mto + 1
           mto = pto
           range = as.integer(mto - mfrom)
           times = times + 1
        }
        if (!is.null(dfHist) && nrow(dfHist)> 0) {
            dfHist$name = NULL                 # JGG: Esto es nuevo
            dfHist = as_tms(dfHist, c(7,8,9))  #Poner los timestamp
        }
        dfHist
    }
    ,getExchanges     = function() {
        # Aparte de 1000 campos devuelve el campo 2
        # Nombre y acabado en un numero a veces (supongo que el id y solo los 10 primeros
        table = http$html_table("https://coinmarketcap.com/rankings/exchanges")
        df = table[,2]
        colnames(df) = "name"
        df$name = gsub("[0-9]+$","",df[,1])
        df
    }
    ,getExchangePairs = function(exchange) {
        colsJson  = c( "exchangeId",  "exchangeName"
                      ,"baseSymbol",  "baseCurrencyId"
                      ,"quoteSymbol", "quoteCurrencyId")
        colsTable = c( "idExch",      "name"
                      ,"base",        "idBase"
                      ,"counter",     "idCounter")

        url   = "https://api.coinmarketcap.com/data-api/v3/exchange/market-pairs/latest"
        parms = list( slug=exchange, category = "spot"
                     ,start=1, limit=500)

        data = http$json(url, parms=parms, headers=headers)

        maxPairs=data$numMarketPairs
        tbl = data$marketPairs
        df = do.call(rbind.data.frame,as.list(tbl))
        if (nrow(df) == 0) return (df)
        dfExch = df[,colsJson]
        colnames(dfExch) = colsTable
        count = nrow(dfExch)
        while(count < maxPairs) {
            parms$start = count + 1
            data = http$json(url, parms=parms, headers=headers)
            data = data$data
            tbl = data$marketPairs
            df = do.call(rbind.data.frame,as.list(tbl))
            dfTmp = df[,colsJson]
            colnames(dfTmp) = colsTable
            count = count + nrow(dfTmp)
            dfExch = rbind(dfExch, dfTmp)
        }
        dfExch
    }

   )
  ,private = list(
     URL   = "https://coinmarketcap.com"
    ,API   = "https://api.coinmarketcap.com/data-api/v3"
    ,getPage = function(page) {
        stop("MarketCap$getPage llamado")
        # el paquete rvest hace cosas muy raras
        # Hacemos scrapping a pelo
        # La columna 3 tiene icono, nombre y simbolo
        # La 4 el precio
        # La 5 variacion diaria
        # La 6 variacion semanal
        url = urlBase
        if (!missing(page)) url = paste0(url, "?page=", page)
        page = httr::GET(url)
        page = content(page, "text")
        beg = str_locate(page, "<tbody")
        end = str_locate(page, "</tbody>")
        table = substr(page, beg[2]+1, end[1])
        rows = strsplit(table, "<tr", fixed=TRUE)
        rows = lapply(rows[[1]], function(x) strsplit(x, "<td", fixed=TRUE))

        tab = page %>% html_nodes("table")
        rows = tab %>% html_nodes("tr")
        data = lapply(rows, function(row) row %>% html_nodes("td"))

        # Coger las filas correctas
        cols = lapply(data, function(x) length(x))
        mask = (cols == 11)
        data = data[mask]

        # col 1 - Estrella
        # col 2 - orden
        # col 3 - Icono, nombre y simbolo
        # La columna 3 tiene nombre y simbolo en div o en span

        # Si busco img me da los 100 elementos
        sims = lapply(data, function(item) extractName(item[[3]]))
        df = as.data.frame(sims, optional=T)
        df = data.table::transpose(df)

        # Las columnas 4,5, 6 tienen precio, var 1 dia y 1 sem
        # Pueden estar en un div (si hay link) o en un span
        values = unlist(lapply(data, function(x) extractValues(x[[4]])))
        df = cbind(df,values)
        values = unlist(lapply(data, function(x) extractValues(x[[5]])))
        df = cbind(df,values)
        values = unlist(lapply(data, function(x) extractValues(x[[6]])))
        df = cbind(df,values)
        colnames(df) = c("base", "counter", "last", "var1", "var7")
        df$base = "EUR"
        private$dfTickers = df
        df
    }
    # ,request = function (url, parms, accept404 = TRUE) {
    #     if (missing(parms) || is.null(parms)) {
    #         page = httr::GET(url, add_headers(.headers=headers))
    #     } else {
    #        page = httr::GET(url, add_headers(.headers=headers), query=parms)
    #     }
    #    resp = httr::content(page, type="application/json")
    #    checkResponse(resp, url, parms, accept404 = FALSE)
    #    resp$data
    # }
  )
)
