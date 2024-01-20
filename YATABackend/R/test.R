test_get = function(endpoint, ...) {
    browser()
    app = YATARest$new()
    request = Request$new(path = paste0("/", endpoint), parameters_query = list(...))
    response = app$process_request(request)
browser()
cat("Response status:", response$status)
#> Response status: 200 OK
cat("Response body:", response$body)
#> Response body: 55
}

test_post = function(endpoint, data) {
    browser()
    app = YATARest$new()
    if (missing(data)) data = NULL
    request = Request$new(path = paste0("/", endpoint), method="POST", body=data, content_type="text/plain")
    response = app$process_request(request)
browser()
cat("Response status:", response$status)
#> Response status: 200 OK
cat("Response body:", response$body)
#> Response body: 55
}
