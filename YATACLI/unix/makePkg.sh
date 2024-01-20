# Rebuild the packages

oldwd=`pwd`
cd /srv/YATA2
echo "Making YATA${i}"
R CMD INSTALL --preclean --no-multiarch --with-keep.source YATA$1 
cd $oldwd
