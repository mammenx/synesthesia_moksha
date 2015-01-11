@echo off


SETLOCAL
echo Cleaning Up Workspace
if exist .qsys_edit (
    rmdir /S /Q .qsys_edit 2> nul
)

if exist db (
    rmdir /S /Q db 2> nul
)

if exist greybox_tmp (
    rmdir /S /Q greybox_tmp 2> nul
)

if exist incremental_db (
    rmdir /S /Q incremental_db 2> nul
)

if exist hc_output (
    rmdir /S /Q hc_output 2> nul
)

del /f /q *.xml
del /f /q *.qdf
del /f /q *.pin
del /f /q *.dpf
del /f /q *.htm
del /f /q *.txt
del /f /q *.rpt
del /f /q *.log
del /f /q *.summary
rem del /f /q *.jdi
rem del /f /q *.sof
rem del /f /q *.pof
del /f /q *.done
del /f /q *.smsg
del /f /q *.csv
del /f /q *.qws
