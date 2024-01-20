: Start REST Server in Windows
: Author: Grandez
: 4005 Falla
@echo off
SET RCMD=C:\SDK\R\R-4.1.2\bin\Rscript.exe
%RCMD%  --arch x64 --default-packages="YATAREST" -e YATAREST::start(4005)
