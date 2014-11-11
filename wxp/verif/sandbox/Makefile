#TEST_NAME=syn_acortex_base_test
TEST_NAME=syn_acortex_i2c_test
#TEST_NAME=syn_acortex_pcm_test

TB_TOP=syn_acortex_tb_top

DGN_LIB=dgn.lib
LINT_OPT=-lint
PREPROCESS_OPT=
#PREPROCESS_OPT=-Epretty dgn.preprocess.v

MSIM_DIR=/altera/modelsim/6.5e/modelsim_ase
MSIM_INC_DIR=$(MSIM_DIR)/include
MSIM_WIN32_DIR=$(MSIM_DIR)/linuxaloem

all: clean show_dir dgn tb dpi dll sim

clean:
	rm -rf work
	rm -rf logs
	rm -rf snaps
	rm -f *.ini transcript* *.wlf *.obj *.log *.h *.v *.dll *.so *.ppm *.raw *.gif
	rm -rf $(DGN_LIB)
	mkdir logs
	mkdir snaps
	vlib work
	vmap work work

show_dir:
	echo  MSIM_DIR : $(MSIM_DIR)
	echo  MSIM_INC_DIR : $(MSIM_INC_DIR)
	echo  MSIM_WIN32_DIR : $(MSIM_WIN32_DIR)

git:
	rm -rf work
	rm -rf logs
	rm -rf snaps
	rm -f *.ini transcript* *.wlf *.obj *.log *.h *.dll *.so *.ppm *.raw
	rm -rf $(DGN_LIB)

dgn_lib:
	echo	"Compiling RTL into $(DGN_LIB) library"
	vlib $(DGN_LIB)
	vmap $(DGN_LIB) work
	vlog -work $(DGN_LIB) -sv -f dgn.list -timescale "1ns / 10ps" $(LINT_OPT) $(PREPROCESS_OPT) | tee dgn.vlog.log

dgn:
	echo	"Compiling RTL"
	vlog -sv -f dgn.list -timescale "1ns / 10ps" $(LINT_OPT) $(PREPROCESS_OPT) | tee dgn.vlog.log

tb:
	echo "Compiling TB"
	vlog -f verif.list +define+SIMULATION -sv -incr -timescale "1ns / 10ps"  | tee	tb.vlog.log

dpi:
	echo  Compiling DPI-C files
	gcc -m32 -c -g -fPIC ../tb/dpi/ppm.c -o ppm.obj
	gcc -m32 -c -g -fPIC ../tb/dpi/raw.c -o raw.obj
	gcc -m32 -c -g -fPIC ../tb/dpi/fft.c -o fft.obj
	gcc -m32 -c -g -fPIC ../tb/dpi/syn_dpi.c -o syn_dpi.obj -I$(MSIM_INC_DIR)

dll:
	echo  Building DLLs
	gcc -m32 -shared -g -Bsymbolic -I. -I$(MSIM_INC_DIR) -L.  -L../tb/dpi -L$(MSIM_WIN32_DIR) -o syn_dpi_lib.so syn_dpi.obj ppm.obj raw.obj fft.obj

sim:
	echo  Running test : $(TEST_NAME)
	vsim -c -novopt +OVM_TESTNAME=$(TEST_NAME) -sv_lib syn_dpi_lib $(TB_TOP) +define+SIMULATION -l $(TEST_NAME).vsim.log -permit_unmatched_virtual_intf -do "add wave -r /*;run -all"

gui:
	vsim vsim.wlf
