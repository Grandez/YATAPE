# Rebuild the packages

oldwd=`pwd`
pkgs=( "Tools", "DB", "Providers", "DT", "Core", "WebCore")
for i in "${pkgs[@]}" ; do
  echo "Making YATA${i}"
  cd /hiost/yata/YATA${i}
  R CMD INSTALL --preclean --no-multiarch --with-keep.source YATA${i} >> tmp/pkginstall.log
  if [ $? -ne 0 ] ; then
     echo "ERROR CREANDO PAQUETE YATA${i}" 
     break
  fi
done