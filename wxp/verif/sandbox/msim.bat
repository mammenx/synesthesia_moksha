@echo off


SETLOCAL

rem set TEST_NAME=syn_acortex_base_test
rem set TEST_NAME=syn_acortex_i2c_test
set TEST_NAME=syn_acortex_mclk_test

set TB_TOP=syn_acortex_tb_top

set DGN_LIB=dgn.lib
set LINT_OPT=-lint
set PREPROCESS_OPT=
rem set PREPROCESS_OPT=-Epretty dgn.preprocess.v

set MSIM_DIR=C:\altera\msim\6.5e\modelsim_ase
set MSIM_INC_DIR=%MSIM_DIR%\include
set MSIM_WIN32_DIR=%MSIM_DIR%\win32aloem

echo Cleaning Up Workspace
if exist work (
    rmdir /S /Q work 2> nul
)

if exist logs (
    rmdir /S /Q logs 2> nul
)

if exist  %DGN_LIB% (
    rmdir /S /Q %DGN_LIB% 2> nul
)

del /f /q *.ini
del /f /q *.log
del /f /q *.wlf
del /f /q *.obj
del /f /q *.log
del /f /q *.h
del /f /q *.obj
del /f /q *.dll
del /f /q *.ppm
del /f /q *.raw

mkdir logs



echo  MSIM_DIR : %MSIM_DIR%
echo  MSIM_INC_DIR : %MSIM_INC_DIR%
echo  MSIM_WIN32_DIR : %MSIM_WIN32_DIR%

vlib work
vmap work work

rem pause

echo  Compiling Design to %DGN_LIB%
vlib %DGN_LIB%
vmap %DGN_LIB% work
vlog -work %DGN_LIB% -sv -f dgn.list -timescale "1ns / 10ps" %LINT_OPT% %PREPROCESS_OPT% > dgn.vlog.log | type dgn.vlog.log

echo  Compiling TB
vlog -f verif.list +define+SIMULATION -sv -incr -timescale "1ns / 10ps" > tb.vlog.log | type tb.vlog.log

echo  Compiling DPI-C files
gcc -c -g ../tb/dpi/ppm.c -o ppm.obj
gcc -c -g ../tb/dpi/raw.c -o raw.obj
gcc -c -g ../tb/dpi/fft.c -o fft.obj
gcc -c -g ../tb/dpi/syn_dpi.c -o syn_dpi.obj -I%MSIM_INC_DIR%

echo  Building DLLs
gcc -shared -g -Bsymbolic -I. -I%MSIM_INC_DIR% -L.  -L../tb/dpi -L%MSIM_WIN32_DIR% -o syn_dpi_lib.dll syn_dpi.obj ppm.obj raw.obj fft.obj -lmtipli

echo  Running test : %TEST_NAME%
vsim -c -novopt +OVM_TESTNAME=%TEST_NAME% -sv_lib syn_dpi_lib %TB_TOP% +define+SIMULATION -l %TEST_NAME%.vsim.log -permit_unmatched_virtual_intf -do "add wave -r /*;run -all"


pause
