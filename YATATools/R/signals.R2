sig_term = function (pid) {
  nfo = Sys.info()
  os = tolower(nfo["sysname"])
  if (os == "windows") return (sig_kill(pid))
  ps::ps_terminate(ps::ps_handle(pid))
}
sig_kill = function (pid) { ps::ps_kill(ps::ps_handle(pid)) }
kill    = function (pid) {
  nfo = Sys.info()
  os = tolower(nfo["sysname"])
  if (os == "windows") {
     sig_term(pid)
  } else {
     sig_kill(pid)
  }
}
