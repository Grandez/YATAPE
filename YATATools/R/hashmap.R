YATAMap = R6::R6Class("YATA.TOOLS.MAP"
    ,public = list(
         initialize = function()           { private$hmap = hash() }
        ,get        = function(key)        { private$hmap[[as.character(key)]] }
        ,put        = function(key, value) { private$hmap[[as.character(key)]] = value }
        ,remove     = function(key)        { private$hmap(as.character(key),hmap)  }
        ,keys       = function()           { keys(private$hmap)   }
        ,values     = function()           { values(private$hmap) }
        ,length     = function()           { length(private$hmap)}
    )
    ,private = list(
        hmap = NULL
    )
)
