#
# USADO POR yata_setup.sh
#
function msgs { h=`date +%T`; echo -n $h " - " $@ " " ; }
function msgc { echo -n $@ ;  }
function msge { echo $@ ;     }
function msg  { msgs ; echo ; }

function error {
    local rc=$1
    shift
    msg $@
    exit $rc
}

# seq_var_name  - Crea una variable secuencial usando VAR_SFX
# seq_var_value - Obtiene el valor de una variable secuencial usando VAR_SFX
# Uso: seq_var_xxx preffix init
#      Si init se usa en lugar de VAR_SFX
# El resultado se captura con var=$(seq_var_xxx ....)
function seq_var_name {
   local sfx=0
   local aux
   if [[ $# -eq 2 ]] ; then 
      sfx=$2 
   else 
      VAR_SFX=$(( $VAR_SFX + 1 ))
      sfx=$VAR_SFX
   fi
   eval "aux=`echo $1$sfx`"
   echo $aux
}
function seq_var_value {
   local sfx=0
   local aux
   if [[ $# -eq 2 ]] ; then 
      sfx=$2 
   else 
      VAR_SFX=$(( $VAR_SFX + 1 ))
      sfx=$VAR_SFX
   fi
   eval "aux=`echo $1$sfx`"
   eval "echo \$`echo $aux`"
}