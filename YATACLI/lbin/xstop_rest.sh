# Start REST Server in Linux
# Author: Grandez
#
# Goger el proceso del puerto
#coger el pid del proceso
kill -KILL -- pid
RCMD="Rscript --no-save --no-restore "
$RCMD -e "YATAREST::start(9090)"
