: Update the currencies list for each camera in sistem
: Author: Grandez
:
@echo off
SET RCMD=C:\SDK\R\R-4.3.2\bin\Rscript.exe
%RCMD%  --arch x64 -e YATABatch::update_history()