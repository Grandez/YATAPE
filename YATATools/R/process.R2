YATAExec = R6::R6Class("YATA.R6.RUN"
   ,cloneable  = FALSE
   ,lock_class = TRUE
   ,portable   = FALSE
   ,active = list(
       wd = function(value) {
           if (missing(value)) {
               return (.wd)
           } else {
               private$.wd = value
           }
       }
   )
   ,public = list(
        install    = function(pkg) {
          args = c('CMD', 'INSTALL', '--no-multiarch', '--with-keep.source', pkg)
          private$.wd = Sys.getenv("YATA_ROOT")
          .run('R', 'CMD', 'INSTALL', '--no-multiarch', '--with-keep.source', pkg)
        }
       ,stdout     = function() { .stdout }
       ,stderr     = function() { .stderr }
       ,run_asis   = function(cmd, ...) {
          processx::run(cmd, as.character(list(...)), FALSE, .wd)
       }
       # Friendly functions
       ,copy        = function (    src, dst) { .run   (    'cp', src, dst) }
       ,copy_su     = function (su, src, dst) { .run_su(su, 'cp', src, dst) }
       ,copyExe     = function (src,  dst) {
            copy (src, dst)
            chmod(dst, 775)
       }
       ,copyExe_su  = function (su, src,  dst) {
            copy_su (su, src, dst)
            chmod_su(su, dst, 775)
       }
       ,chmod       = function (    what, mode) { .run    (   'chmod', mode, what) }
       ,chmod_su    = function (su, what, mode) { .run_su(su, 'chmod', mode, what) }
       ,copyFile    = function (file, from, to, mode=NULL) {
           org = paste(from, file, sep="/")
           dst = paste(to,   file, sep="/")
           copy(org, dst)
           if (!is.null(mode)) chmod(dst, mode)
       }
       ,copyFile_su = function (su, file, from, to, mode=NULL) {
           org = paste(from, file, sep="/")
           dst = paste(to,   file, sep="/")
           copy_su(su, org, dst)
           if (!is.null(mode)) chmod_su(su, dst, mode)
       }
       ,command    = function (    cmd,  ...) { .run   (    cmd, ...) }
       ,command_su = function (su, cmd,  ...) { .run_su(su, cmd, ...) }
       ,exec       = function (    cmd,  ...) { .run   (    cmd, ...) }
       ,exec_su    = function (su, cmd,  ...) { .run_su(su, cmd, ...) }

       ,copy2site = function(pkgs) {
           libuser = Sys.getenv("R_LIBS_USER")
           libsite = Sys.getenv("R_LIBS_SITE")
           lapply(pkgs, function (pkg) {
               from = file.path(libuser, pkg)
               to   = file.path(libsite, pkg)
               file.copy(from, to, overwrite=TRUE, recursive = TRUE)
           })
       }
       ,copy2web  = function(pkgs) {
           libuser = Sys.getenv("YATA_ROOT")
           libweb  = Sys.getenv("R_LIBS_SHINY")
           lapply(pkgs, function (pkg) {
               from = file.path(libuser, pkg)
               to   = file.path(libweb, pkg)
               file.copy(from, to, overwrite=TRUE, recursive = TRUE)
           })
       }
      ,unload = function(what, where) {
         processx::run("curl", args=c("-O", what), FALSE, where)
      }
      ,R = function(script, async = TRUE) {
         site = Sys.getenv("YATA_SITE")
         root = paste0(site,"/ext/scripts/")
         log =  paste0(site,"/data/log/")

         rscript = paste0(root, script, ".R")
         log     = paste0(log,  script, ".log")

         args = c( "CMD", "BATCH", "--no-save", "--no-restore", rscript, log)
         if (async) {
             processx::process$new("R", args=args)
         } else {
            processx::process$new("R", args=args, error_on_status = FALSE)
         }

      }
      # DataBases
       ,import = function(file, database, columns) {
            private$.wd = paste0(Sys.getenv("YATA_SITE"), "/data/tmp")
            args = list( "--local"
                        ,"--replace"
                        ,"--force"
                        ,"--fields-terminated-by=;"
                        ,"--user=YATA"
                        ,"--password=yata"
                        ,paste0("--columns=",paste(columns, collapse=","))
                        ,database
                        ,file
                  )
           .run("mysqlimport", args)
       }
       ,backup = function(database, filename) {
            private$.wd = paste0(Sys.getenv("YATA_SITE"), "/data/tmp")
            args = list( "--local"
                        , "--replace"
                        ,"--fields-terminated-by=;"
                        ,"--user=YATA"
                        ,"--password=yata"
                        ,paste0("--columns=",paste(columns, collapse=","))
                        ,database
                        ,file
                  )
           .run("mysqlimport", args)
           # 1. Ejecutamos el backup en tmp
           # 2. Lo comprimimos con zip (ojo al stdout)
           # zip archivename.zip filename1 filename2 filename3
       }

    )
   ,private = list(
       .wd = NULL
       ,.stdout = NULL
       ,.stderr = NULL
       ,launchException = function(res, cmd, args, type, su = FALSE) {
             YATABase:::EXEC( paste("EXEC:", cmd), action="run"
                                ,command = paste(cmd, paste(args, collapse=" "))
                                ,rc      = res$status
                                ,type    = type
                                ,su      = su
                                ,stdout  = res$stdout
                                ,stderr  = res$stderr)

       }
       ,.run = function(cmd, ...) {
           lst  = list(...)
           if (length(lst) > 0) {
              if (is.list(lst[[1]])) {
                 args = unlist(lst[[1]])
              } else {
                 args  = as.character(lst)
              }
           }

           res = tryCatch({
              processx::run(cmd, args, FALSE, .wd)
           }, error = function(cond) {
              launchException(cond, cmd, args, "system")
           }, finally = function() {
              private$.sdtout = res$stdout
              private$.sdterr = res$stderr
           })

           if (is.na(res$status)) launchException(res, cmd, args, "Killed")
           if (res$status != 0)   launchException(res, cmd, args, "Exec")
           res
       }
       ,.run_su = function(su, cmd, ...) {
           lst  = list(...)
           args  = as.character(lst)
           args = c(su, paste(" | sudo -S", cmd, args))

           res = tryCatch({
              processx::run( 'echo', args, FALSE, .wd)
           }, error = function(cond) {
              launchException(cond, cmd, args, "system", TRUE)
           }, finally = function() {
              private$.sdtout = res$stdout
              private$.sdterr = res$stderr
           })

           if (is.na(res$status)) launchException(res, cmd, args, "Killed", TRUE)
           if (res$status != 0)   launchException(res, cmd, args, "Exec",   TRUE)
           res
       }

    )
)
