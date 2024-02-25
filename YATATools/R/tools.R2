yataGetDirectory = function (name="log") {
   site = Sys.getenv("YATA_SITE")
   if (nchar(site) == 0) {
       site = "/tmp"
       os   = Sys.info()
       if (os["sysname"] == "windows") site = Sys.getenv("temp")
       site = normalizePath(file.path(site, "YATA"))
   }
   dir.create(site, showWarnings = FALSE)
   dirWrk = normalizePath(file.path(site, "data", name))
   dir.create(dirWrk, showWarnings = FALSE)
   dirWrk
}
yataActiveNS = function(id) {
    data = strsplit(id, "-")
    data[[1]][length(data[[1]])]
}
