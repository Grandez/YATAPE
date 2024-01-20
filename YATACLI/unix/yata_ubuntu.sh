function exec_apt {
   blank=" "
   CMD="apt-get"
   if [[ $1 -eq 0 ]] ; then CMD="apt" ; fi
   PKGS="$(mktemp -p /dev/shm/)"        
   dpkg -l > PKGS
   INC=$(( 100 * $# / 100 ))
   DONE=0
   echo "DONE Hecho"
   for pkg in $@ ; do
       tok=${blank}${pkg}${blank}
       grep -q $tok PKGS
       if [[ $? -ne 0 ]] ; then
          msg "Instalando " $pkg # " - " $DONE # >> $LOGFILE && echo -e $DONE && sleep 1
          $CMD -y install  $pkg >&2
          rc=$?
          if [[ $rc -gt 0 ]] ; then error "ERROR " $rc " Instalando " $pkg ; fi
       fi
   done 
}
function add_keys {
  msg adding keys
  cfg_keys
  VAR_SFX=1
  SRV=$(seq_var_value server $VAR_SFX)
  while [ -n "$SRV" ] ; do
     KEY=$(seq_var_value key $VAR_SFX)
     VAR_SFX=$(( $VAR_SFX + 1 ))
     apt-key adv --keyserver $SRV --recv-keys $KEY
     SRV=$(seq_var_value server $VAR_SFX)
  done
}
function add_repos {
   msg adding repos
   cfg_repos
   VAR_SFX=1
   REP=$(seq_var_value repo $VAR_SFX)

   while [ -n "$REP" ] ; do
      msg adding repo ${REP[@]}
      echo "antes del sudo"
      add-apt-repository \'${REP[@]}\'
      VAR_SFX=$(( $VAR_SFX + 1 ))
      REP=$(seq_var_value repo $VAR_SFX)
   done
    
}
function add_packages {
    msg Adding packages
    cfg_linux
    exec_apt 0 $apt
    exec_apt 1 $get      
}
function init_linux {
    add_keys
    add_repos
    add_packages
}
