logging_middleware = Middleware$new(
  process_request = function(.req, .res) {
      parms = "none"
      if (length(.req$parameters_query) > 0) {
          data = .req$parameters_query
          items = lapply(1:length(data), function(i) paste(names(data)[i], data[[i]], sep="="))
          parms = paste(unlist(items), collapse="&")
      }
      message(sprintf("%s;%s;%s;%s", Sys.time(), .req$method, substring(.req$path,2), parms))
    # msg = list(
    #   middleware = "logging_middleware",
    #   request_id = .req$id,
    #   request = list(headers = .req$headers, method = .req$method, path = .req$path),
    #   timestamp = Sys.time()
    # )
    # msg = RestRserve::to_json(msg)
    # cat(msg, sep = '\n')
  },
  process_response = function(.req, .res) {
    # msg = list(
    #   middleware = "logging_middleware",
    #   # we would like to have a request_id for each response in order to correlate
    #   # request and response
    #   request_id = .req$id,
    #   response = list(headers = .res$headers, status_code = .res$status_code, body = .res$body),
    #   timestamp = Sys.time()
    # )
    # msg = to_json(msg)
    # cat(msg, sep = '\n')
  },
  id = "logging"
)
