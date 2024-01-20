# Retrieve current values from currencies
# Parm 1 = Maximum of CTC according rank
# Author: Grandez
#
max=0
if [ $# gt 1] ; then max=$1 ; fi
Rscript --default-packages="YATABatch" -e "YATABatch::updateTickers(max=$max)"

