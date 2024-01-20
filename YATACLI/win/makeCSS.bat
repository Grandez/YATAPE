: Crea las hojas de estilos
: Author: Grandez
:

@echo off
SET CWD=%CD%
CD P:\R\YATA2\YATAWebCore\inst\extdata\www\yata
C:\SDK\SASS\sass yatabootstrap.scss > yatabootstrap.css
CD %CWD%
