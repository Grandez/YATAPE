#!/usr/bin/bash 
# Make backups for operationral tables
# Author: Grandez
#
# Use: yata_backup [tables]
# If missing tables all tables are backed

DATA=${YATA_SITE}/data
function makebackup {
    while [ -n "$1" ] ; do
       CWD=`pwd`
       WD=${DATA}/wrk
       sql=${WD}/$1.sql
       mysqldump -cfnt -u YATA -pyata -r $sql $1
       rc=$?
       if [ $rc -gt 0 ] ; then
          echo "ERROR " $rc "making backup of " $1 
       else 
          out=${DATA}/bck/$1_`date +%Y%m%d`.zip
          cd $WD
          zip -q $out $1.sql
          rc=$?
          cd $CWD
          if [ $rc -ne 0 ] ; then 
              echo "ERROR " $rc " ZIPPING FILE " $1.sql 
          else
              rm $sql
          fi
       fi
       shift  
    done
}

if [ $# -gt 0 ] ; then
    makebackup $*
else 
    makebackup YATA YATATest YATASimm
fi

