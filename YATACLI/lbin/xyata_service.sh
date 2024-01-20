#!/usr/bin/bash 
#Start REST Server in Linux
# Author: Grandez
#
# Se llama como script paquete puerto accion
local PKG=$1
local PORT=$2

function check {
    line=`echo "yata" | sudo -S netstat -nlp | grep :$PORT`
    if [ -z "$line" ] ; then
        echo "No esta"
        return 0
    fi
    pid=`echo $line | cut -d ' ' -f 7 | cut -d '/' -f 1`
   return $pid
}
function start {
    echo "start"
    if [ check -eq 0 ] ; then
        echo "Arranca"
        Rscript --no-save --no-restore -e "$PKG::start($PORT)"
    fi    
#RCMD="Rscript --no-save --no-restore "
#$RCMD -e "YATAREST::start(9090)"
    
}
function stop {
 echo "stop"   
    pid=check
     while [ $pid ] ; do
        echo "Para"
        # kill -KILL -- $pid
        sleep 1
    fi    

}
function restart {
    echo "restart"
}
ACT="start"
if [ $# gt 1 ] ; then ACT=$1
    
if [ "$ACT" == "restart" ] ; tehn
    stop
    start
else
   if [ "$ACT" == "stop" ] ; then
      stop
   else
      start
   fi
fi             
