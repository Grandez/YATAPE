# data = httr::GET("https://coinmarketcap.com/currencies/cardano/historical-data/")
# page = content(data, "text")

historical = function(idCurrency, from, to ) {
         # Scrapping de la pagina
         url = "https://web-api.coinmarketcap.com/v1/cryptocurrency/ohlcv/historical"

         headers = c(
             `User-Agent`      = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:86.0) Gecko/20100101 Firefox/86.0"
            ,`Accept-Language` = "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3"
            ,Accept          = "application/json, text/plain, */*"             
            ,Origin          = "https://coinmarketcap.com"
            ,Referer         = "https://coinmarketcap.com/"
            ,TE              = "Trailers"
         )
         parms = list(
             convert    = "EUR"
            ,id         = idCurrency
            ,time_start = asUnix(from)
            ,time_end   = asUnix(to)
         )
         page = GET(url, add_headers(.headers=headers), query=parms)
         if (http_error(page)) stop("ERROR EN EL GET")
         browser()
         resp = httr::content(page, type="application/json")
         # 1 - Header response
         # 2 - Data
         
         # 1 - id
         # 2 - name
         # 3 - symbol
         # 4 - data
         body = resp[[2]]
         data = body[[4]]
         data2 = lapply(data, function(x) x[[5]])
         data3 = lapply(data2, function(x) x[[1]])
         df1 = as.data.frame(sapply(data3, unlist))
         df = t(df1)
         row.names(df) = NULL
         df = as.data.frame(df)
         # La ultima columna es el timestamp
         df1 = df[,1:ncol(df) - 1]
         df1 = as.data.frame(sapply(df1,as.numeric))
         tms = anytime::anytime(df[,ncol(df)])
         df = cbind(tms=tms,df1)
      }
