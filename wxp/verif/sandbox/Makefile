DGN_LIB=dgn.lib
LINT_OPT=-lint
PREPROCESS_OPT=
#PREPROCESS_OPT=-Epretty dgn.preprocess.v

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

git:
	rm -rf work
	rm -rf logs
	rm -rf snaps
	rm -f *.ini transcript* *.wlf *.obj *.log *.h *.dll *.so *.ppm *.raw
	rm -rf $(DGN_LIB)

dgn_lib:
	vlib dgn.lib
	vmap dgn.lib work
	vlog -work $(DGN_LIB) -sv -f dgn.list -timescale "1ns / 10ps" $(LINT_OPT) $(PREPROCESS_OPT) | tee dgn.vlog.log
