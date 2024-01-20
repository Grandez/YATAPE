#!/bin/bash
###########################################################################
# Script de instalacion de paquetes
# Usaremos un fichero de configuracion y un fichero de log
###########################################################################

# Check if root
[ $EUID -ne 0 ] && echo "This script must be executed as root" >&2 && exit 127

TITLE="YATA Setup"
WRK=/tmp/yata
LOG=$HOME/yata.log
OUTFILE="$(mktemp -p /dev/shm/)"
LOGFILE="$(mktemp -p /dev/shm/)"
INI=yata.cfg

function dlg_password {
    #DLGPWD=$(dialog --title "$TITLE" --insecure --passwordbox "$@" 0 0 2>&1 >/dev/tty)     
    dialog --title "$TITLE" --insecure --passwordbox "$@" 0 0 2> $OUTFILE
}

function check_section {
   [[ $(type -t $1) == function ]] && return 0
   return 1    
}

function init {
   # scripts auxiliares 
   scripts=( "yata_tools.inc"  "yata_ini.inc" "yata_ubuntu.inc")
   for var in "${scripts[@]}" ; do
        source ${var} # 2> /dev/null
        if [[ $? -gt 0 ]] ; then error "Missing source file: " ${var} ; fi
   done
   if [[ $# -gt 1  ]] ; then error "Too many arguments" ; fi
   if [[ $# -eq 1  ]] ; then INI=$1 ; fi
   if [[ ! -f $INI ]] ; then error "Missing configuration file: " $INI ; fi
   # check_sudo
}

function init_r {
    msg Installing R and Shiny
    cfg_R
    exec_apt 1 r-base
    [ -z "$url" || -z "$shiny" ] && error 2 Missing url or shiny package
    if [[ -n $library ]] ; then 
        export R_LIBS_SITE=$library
        echo export R_LIBS_SITE=$library > /etc/profile.d/R.sh
    fi    
    msg Installing Shiny package
    R -e 'install.packages("shiny", dependencies=TRUE, repos="https://cran.rstudio.com/")'
    rc=$?
    if [ $rc -ne 0 ] ; then error 2 Error $rc instalando Shiny package ; fi
    wget $url$shiny
    if [[ $? -ne 0 ]] ; then error 2 Error downloading $url$shiny ; fi
    gdebi --non-interactive $shiny
    rm -f $shiny
}

        
init $@
cfg_parser $INI
rc=$?
if [[ $rc -ne 0 ]] ; then error 1 "Error " $rc " parsing file " $INI ; fi


dlgsetup=(dialog --title "$TITLE" --separate-output --checklist "Selecciona los grupos a los que pertenece:" 0 0 0)
blocks=(1 "Sistema" on 
 2 "R y Shiny" on
 3 "Desarrollo" on
 4 "YATA" on
 5 "Otro" on
)    

pieces=$("${dlgsetup[@]}" "${blocks[@]}" 2>&1 >/dev/tty)

for block in $pieces ; do
   case $block in
        1)  init_linux  ;;
        2)  init_r      ;;
 3)
 echo "Escogiste la opción 3"
 ;;
 4)
 echo "Escogiste la opción 4"
 ;;
 5)
 echo "Escogiste la opción 5"
 ;;
 6)
 echo "Escogiste la opción 6"
 ;;
 7)
 echo "Escogiste la opción 7"
 ;;
 esac
done


# limpiamos la pantalla
# clear
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
funcheck=(dialog --title "$TITLE" --separate-output --checklist "Selecciona los grupos a los que pertenece:" 0 0 0)


##################################
# PARA PYTHON
# PYTHON 3
# install tk -> Tkinter
# apt install pyton3-pip

### Icono

# I created a desktop file (file location: ~/.local/share/applications/my-tk-app.desktop):
# 
# [Desktop Entry]
# Type=Application
# Terminal=false
# Name=My Tk Application
# Exec=/home/hakon/my-tkapp.py
# Icon=/home/hakon/icons/my-tk-app-icon.png
# StartupWMClass=MyTkApp
# 

# desktop-file-validate  para chequear si esta bien
# For the icon, I just (for the purpose of tes