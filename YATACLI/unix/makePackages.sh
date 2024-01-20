# Rebuild the packages

oldwd=`pwd`
cd /srv/YATA2
pkgs=( "Tools"  "DB"  "Providers"  "DT"  "Core" "REST" "WebCore")
for i in "${pkgs[@]}" ; do
  echo "Making YATA${i}"
  R CMD INSTALL --preclean --no-multiarch --with-keep.source YATA${i} >> /tmp/pkginstall.log 2>> /tmp/pkginstall.err
  if [ $? -ne 0 ] ; then
     echo "ERROR CREANDO PAQUETE YATA${i}" 
     break
  fi
done
cd $oldwd
