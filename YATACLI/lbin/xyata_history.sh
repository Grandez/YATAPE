################################################################################
# Script to launch the process for update currencies
#
# Author:  Grandez
# Version: 1.0
#
# Notes:
#   Sometimes process fail because remote system returns busy (FLOOD) o so on
#   then we wait to restore the remote
#   Good return codes are:
#      0 - OK       - There was updates
#      2 - RUNNING  - Process is already running
#      4 - NODATA   - Run OK but not data retrieved (no new info)
#      7 - KILLED   - Process stopped by user
################################################################################

while true ; do
  Rscript --default-packages="YATABatch" -e "YATABatch::update_history()" 
  rc=$?
  if [ $rc -lt 8 ] ; then exit $rc ; done
  sleep 1800
done