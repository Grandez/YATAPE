YATAHTTP = R6::R6Class("YATA.R6.HTTP"
   ,cloneable  = FALSE
   ,lock_class = TRUE
   ,portable   = FALSE
   ,public = list(
      get  = function (url, parms=NULL, headers=NULL, accept = 0) {
         # accept indica el bloque de errores a aceptar
         # 0 - 200: Solo OK
         heads = character()
         prms=NULL
         if (!is.null(headers)) heads=headers
         if (!is.null(parms))   prms = parms
         #JGG json la page devuelve 0 pero el json no

         page = tryCatch({
                   httr::GET(url, add_headers(.headers=headers), query=prms)
                }, error = function(cond) { checkGetError(url, "GET", parms=parms, cond) })

         if (is.null(page)) {
            HTTP( "HTTP ERROR: No data retrieved", origin=url, action="get"
                            ,message="No data retrieved")
         }
         private$rc = checkPageResponse("get", page, url, parms, accept)
         page
      }
     ,post = function (url, body=NULL, type="text/plain", headers=NULL, accept = 0) {
         # accept indica el bloque de errores a aceptar
         # 0 - 200: Solo OK
         heads = character()
         if (!is.null(headers)) heads=headers
         #JGG json la page devuelve 0 pero el json no

         page = tryCatch({
                   httr::POST(url, add_headers(.headers=headers), body=body, content_type = type)
                }, error = function(cond) { checkGetError(url, "POST", NULL, cond) })

         if (is.null(page)) {
            HTTP( "HTTP ERROR: No data retrieved", origin=url, action="get"
                            ,message="No data retrieved")
         }
         private$rc = checkPageResponse("get", page, url, parms, accept)
         page
      }
     ,json = function (url, parms=NULL, headers=NULL, accept = 0) {
         page = get(url, parms, headers, accept)
         resp = httr::content(page, type="application/json")
         resp$data
      }
     # ,html = function(url, parms=NULL, headers=NULL, accept = 400) {
     #     page = get(url, parms, headers, accept)
     #     httr::content(page, as="parsed")
     # }
     # ,html_table = function(url, parms=NULL, headers=NULL, accept = 500) {
     #     resp = html(url)
     #     if (rc != 0) return (NULL)
     #
     #     tables = resp %>% rvest::html_elements("table")
     #     tables = tables %>% rvest::html_table()
     #     tables[[1]] %>% data.frame()
     # }
   )
   ,private = list(
       resp = NULL
      ,rc = 0
      ,checkPageResponse    = function(method, page, url, parms, accept) {
         code = 999
         if (!is.null(page$status_code)) code = page$status_code
         if (!is.null(page$Status))      code = page$Status
         if (!is.null(page$status))      code = page$status
         rc = (code %/% 100) * 100
         if (rc == 0 || rc == 200) return (0)
         resp = httr::content(page, type=page$headers$`content-type`, encoding="UTF-8")

         HTTP( paste("HTTP ERROR:", resp)
                         ,action=method, code=code
                         ,origin=page$url, message=resp
                         ,parameters = parms
                        )
      }
      ,checkContentResponse = function(method, page, resp, url, parms, accept) {
         # A veces da OK y el mensaje es de error
          code = 999
          if (!is.null(page$status_code)) code = page$status_code
          if (!is.null(page$Status))      code = page$Status
          if (!is.null(page$status))      code = page$status

          rc = as.integer(code)
          rc = (rc %/% 100) * 100
          if (rc == 0 || rc == 200) return (0)
      #    # Hacemos el trycatch para grabar siempre el error
      #    tryCatch({
          if (!is.null(resp$status$error_message)) {
              if (length(grep("busy", resp$status$error_message)) > 0) {
                  FLOOD( paste("HTTP ERROR:", resp$status$error_message)
                                   ,action = method, code    = resp$status_code
                                   ,origin = url,    message = resp$status$error_message
                                   ,parameters = parms
                                 )
              }
          }
          HTTP( paste("HTTP ERROR:", resp$status$error_message)
                            ,action = method, code    = resp$status_code
                            ,origin = url,    message = resp$status$error_message
                            ,parameters = parms
                           )
       }
      ,checkGetError        = function(url, action, parms, cond) {
          urlerr = url
          code = 900
          msg = cond$message
          if (grepl("Timeout", cond$message, ignore.case = TRUE)) {
              code = 408
              msg = "Timeout reached"
              expr = regexpr("\\[.*\\]", cond$message)
              if (expr > 0) urlerr = substr(cond$message, expr + 1, attr(expr, "match.lenght") - 2)
          }
          HTTP( paste("HTTP ERROR:", msg), action = action, code = code
                             ,origin = url,    message = cond$message, parameters = parms)
      }
   )
)
