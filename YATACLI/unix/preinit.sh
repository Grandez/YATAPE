###########################################################################
# Script de instalacion de paquetes
# Usaremos un fichero de configuracion y un fichero de log
###########################################################################

TITLE="YATA Setup"
WRK=/tmp/yata
LOG=$HOME/yata.log
TMPFILE="$(mktemp -p /dev/shm/)"
INI=yata.cfg

function error {
    echo $1
    exit 1
}

function init {
   # scripts auxiliares 
   scripts=( "yata_ini.sh"  "pepe" "juan")
   for var in "${scripts[@]}" ; do
        echo "${var}"
   done
}

init
exit 0
source ini_parser.sh 2> /dev/null
if [[ $? -gt 0 ]] ; then error ""
if [[ $# -gt 2 ]] ; then 
    echo "Demasiados parametros"
    exit 1
fi
if [[ $# -eq 2 ]] ; then INI=$1 ; fi


function setup {
    
}
#test devuelve 1 para falso/error
# dialog <opciones-comunes> <opciones de caja> <ancho-de-caja> <alto-de-caja> <numero-de-opciones-visibles>.

mkdir $WRK 2> /dev/null
# source <(grep = file.ini | sed 's/ *= */=/g')

# Chequea si el bloque se ha ejecutado: keyword y OK    
checkBlock() {
    test -f $LOG || return 1
    LINE=`grep $1 $LOG`
    if [[ $? -gt 0 ]] ; then return 1 ; fi
    echo $LINE | grep OK
    if [[ $? -gt 0 ]] ; then return 1 ; fi
    return 0
}

echo "inicio script"
checkBlock BASE
echo "check devuelve " $?
# if [[ launched ]] ; then echo "Existe el fichero" fi
echo "No existe el fichero" 

# dialog --title "$TITLE" --checklist "Escoge las opciones que desees:" 0 0 0  1 queso on 2 "Mostaza" on  3 anchoas off 2> $WRK/install.txt


# sudo apt     -y install net-tools
# sudo apt-get -y install libxml2-dev          
# sudo apt-get -y install libfontconfig1-dev   
# sudo apt-get -y install libudunits2-dev    
# sudo apt-get -y install libcurl4-openssl-dev
# sudo apt-get -y install libxt-dev        
# sudo apt-get -y install libcairo2-dev
# sudo apt-get -y install libmariadb-dev-compat
# 
# sudo cp /win/wsl/R.sh /etc/profile.d/R.sh

# Cargar el fichero de configuracion
if [[ -f $INI ]] ; then source <(grep = $INI | sed 's/ *= */=/g')
    
blocks=(1 "Sistema" on 
 2 "R y Shiny" on
 3 "Desarrollo" on
 4 "YATA" on
 5 "Otro" on
)    

# Creamos la varaible funcheck en la que almacenamos la 
# orden dialog con la opción --separate-output
funcheck=(dialog --separate-output --checklist "Selecciona los grupos a los que pertenece:" 0 0 0)