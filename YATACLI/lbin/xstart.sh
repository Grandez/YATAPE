# Script to launch batch processes

showHelp () {
  echo "Use $1 process"
  echo "Process: "
  echo "\thistory"
  echo "\tcurrencies"
  echo "\session"
  exit 1   
}
if [ $# -eq 0 ] ; then
    echo "Missing process to start"
    echo "Use $0 --help"
    exit 12
fi

if [ "$1" == "-h" ]     ; then showHelp $0 ; fi
if [ "$1" == "--help" ] ; then showHelp $0 ; fi
    

Rscript --default-packages="YATABatch" -e "YATABatch::updateCurrencies()"

