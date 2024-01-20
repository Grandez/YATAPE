: Update the currencies list for each camera in sistem
: Author: Grandez
:
@echo off
SET RCMD=C:\SDK\R\R-4.0.4\bin\Rscript.exe
%RCMD%  --arch x64 -e YATABatch::updateCurrencies(%1)