json_to = function(data, name) {
   cad = jsonlite::toJSON(data)
   if (missing(name)) return (cad)
   paste0('{"', name, '":', cad, '}')
}
json_name = function (name, data) {
   paste0('{"', name, '":', data, '}')
}
json_append = function(json1, json2) {
   paste0(substr(json1,1,nchar(json1) - 1), ",", substr(json2,2,nchar(json2)))
}
json_from = function (data) {
   jsonlite::fromJSON(data)
}
