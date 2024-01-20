# Provider para la cotizacion del Euro
# No Devuelve datos en fin de semana o festivos
# Asi que cuando queramos coger un dato cargaremos al menos una semana antes
# Y rellenaremos los dias
PROVEuro = R6::R6Class("PROV.EURO"
   ,inherit    = ProviderBase
   ,portable   = FALSE
   ,cloneable  = FALSE
   ,lock_class = FALSE
   ,public = list(
      initialize = function(code, eurusd, dbf) {
           super$initialize(code, "Euro", NULL, dbf)
       }
      ,exchanges = function(base, counter, from, to) {
          # No da datos en fin de semana o festivos
          # Pedimos siempre una semana anterior de manera que haya datos
          # y rellenamos
          fiats = c("USDT", "USDC")
          bb = ifelse(base    %in% fiats, "USD", base)
          cc = ifelse(counter %in% fiats, "USD", counter)
          from2 = from - as.difftime(7, unit="days")

          url = paste0(urlbase, sprintf("/history?start_at=%s&end_at=%s", from2, to))

         resp = get(url)
         data = resp[[1]]
         tms = names(data)
         names(data) = NULL
         df = ldply(data, data.frame)
         base = rep(base, nrow(df))
         df = cbind(tms, base, df)
         df = df[,c(1,2,which(colnames(df) == "USD"))]
         df$tms = as.Date(df$tms)

         # Secuencia de fecha y relleno
         dfdt = data.frame(tms=seq.Date(from2,to,by="day"))
         df2 = left_join(dfdt, df, "tms")
         df2 = df2 %>% fill(base) %>% fill(USD)
         df = df2[df2$tms >= from, ]
         # exchangerates dice EUR/USD = 1.2
         if (bb == "EUR") df$USD = 1 / df$USD
         df
      }
      ,getCloseSession = function(base, counter, day) {
          url = paste0(urlbase, "/", day)
          resp = get(url)
          resp$rates[[counter]]
      }
      ,getSessionDays = function(base, counter, from, to) {
         exchanges(base, counter, from, to)
       }
      ,latest = function(base, counter) {
         if (base == "EUR") {
            url = paste0(urlbase, "/latest")
         }
         else {
            url = paste0(urlbase, sprintf("/latest?base=%s", base))
         }
         resp = get(url)
         resp$rates[[counter]]
      }
   )
   ,private = list(last=NULL
       ,urlbase = "https://api.exchangeratesapi.io"
   )
)
