
# (C) 2001-2014 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and 
# other software and tools, and its AMPP partner logic functions, and 
# any output files any of the foregoing (including device programming 
# or simulation files), and any associated documentation or information 
# are expressly subject to the terms and conditions of the Altera 
# Program License Subscription Agreement, Altera MegaCore Function 
# License Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by Altera 
# or its authorized distributors. Please refer to the applicable 
# agreement for further details.

# ACDS 13.1 162 win32 2014.12.11.17:19:58

# ----------------------------------------
# vcsmx - auto-generated simulation script

# ----------------------------------------
# initialize variables
TOP_LEVEL_NAME="lpddr2_cntrlr"
QSYS_SIMDIR="./../../"
QUARTUS_INSTALL_DIR="C:/altera/13.1/quartus/"
SKIP_FILE_COPY=0
SKIP_DEV_COM=0
SKIP_COM=0
SKIP_ELAB=0
SKIP_SIM=0
USER_DEFINED_ELAB_OPTIONS=""
USER_DEFINED_SIM_OPTIONS="+vcs+finish+100"

# ----------------------------------------
# overwrite variables - DO NOT MODIFY!
# This block evaluates each command line argument, typically used for 
# overwriting variables. An example usage:
#   sh <simulator>_setup.sh SKIP_ELAB=1 SKIP_SIM=1
for expression in "$@"; do
  eval $expression
  if [ $? -ne 0 ]; then
    echo "Error: This command line argument, \"$expression\", is/has an invalid expression." >&2
    exit $?
  fi
done

# ----------------------------------------
# initialize simulation properties - DO NOT MODIFY!
ELAB_OPTIONS=""
SIM_OPTIONS=""
if [[ `vcs -platform` != *"amd64"* ]]; then
  :
else
  :
fi

# ----------------------------------------
# create compilation libraries
mkdir -p ./libraries/work/
mkdir -p ./libraries/dll0/
mkdir -p ./libraries/oct0/
mkdir -p ./libraries/c0/
mkdir -p ./libraries/s0/
mkdir -p ./libraries/p0/
mkdir -p ./libraries/pll0/
mkdir -p ./libraries/lpddr2_cntrlr/
mkdir -p ./libraries/altera_ver/
mkdir -p ./libraries/lpm_ver/
mkdir -p ./libraries/sgate_ver/
mkdir -p ./libraries/altera_mf_ver/
mkdir -p ./libraries/altera_lnsim_ver/
mkdir -p ./libraries/cyclonev_ver/
mkdir -p ./libraries/cyclonev_hssi_ver/
mkdir -p ./libraries/cyclonev_pcie_hip_ver/

# ----------------------------------------
# copy RAM/ROM files to simulation directory
if [ $SKIP_FILE_COPY -eq 0 ]; then
  cp -f $QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_sequencer_mem.hex ./
  cp -f $QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_AC_ROM.hex ./
  cp -f $QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_inst_ROM.hex ./
fi

# ----------------------------------------
# compile device library files
if [ $SKIP_DEV_COM -eq 0 ]; then
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v"                       -work altera_ver           
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"                                -work lpm_ver              
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"                                   -work sgate_ver            
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"                               -work altera_mf_ver        
  vlogan +v2k -sverilog "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"                           -work altera_lnsim_ver     
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/synopsys/cyclonev_atoms_ncrypt.v"          -work cyclonev_ver         
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/synopsys/cyclonev_hmi_atoms_ncrypt.v"      -work cyclonev_ver         
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/cyclonev_atoms.v"                          -work cyclonev_ver         
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/synopsys/cyclonev_hssi_atoms_ncrypt.v"     -work cyclonev_hssi_ver    
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/cyclonev_hssi_atoms.v"                     -work cyclonev_hssi_ver    
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/synopsys/cyclonev_pcie_hip_atoms_ncrypt.v" -work cyclonev_pcie_hip_ver
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/cyclonev_pcie_hip_atoms.v"                 -work cyclonev_pcie_hip_ver
fi

# ----------------------------------------
# compile design files in correct order
if [ $SKIP_COM -eq 0 ]; then
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/altera_mem_if_dll_cyclonev.sv"                            -work dll0         
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/altera_mem_if_oct_cyclonev.sv"                            -work oct0         
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/altera_mem_if_hard_memory_controller_top_cyclonev.sv"     -work c0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0.v"                                       -work s0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/altera_avalon_mm_bridge.v"                                -work s0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/altera_avalon_sc_fifo.v"                                  -work s0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/altera_avalon_st_pipeline_base.v"                         -work s0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/altera_mem_if_sequencer_cpu_cv_sim_cpu_inst.v"            -work s0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/altera_mem_if_sequencer_cpu_cv_sim_cpu_inst_test_bench.v" -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/altera_mem_if_sequencer_mem_no_ifdef_params.sv"           -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/altera_mem_if_sequencer_rst.sv"                           -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/altera_mem_if_simple_avalon_mm_bridge.sv"                 -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/altera_merlin_arbitrator.sv"                              -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/altera_merlin_burst_uncompressor.sv"                      -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/altera_merlin_master_agent.sv"                            -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/altera_merlin_master_translator.sv"                       -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/altera_merlin_reorder_memory.sv"                          -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/altera_merlin_slave_agent.sv"                             -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/altera_merlin_slave_translator.sv"                        -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/altera_merlin_traffic_limiter.sv"                         -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_irq_mapper.sv"                           -work s0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0.v"                     -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_addr_router.sv"        -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_addr_router_001.sv"    -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_addr_router_002.sv"    -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_cmd_xbar_demux.sv"     -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_cmd_xbar_demux_001.sv" -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_cmd_xbar_demux_002.sv" -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_cmd_xbar_mux.sv"       -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_cmd_xbar_mux_003.sv"   -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_id_router.sv"          -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_id_router_002.sv"      -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_id_router_003.sv"      -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_rsp_xbar_mux.sv"       -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_rsp_xbar_mux_001.sv"   -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_rsp_xbar_mux_002.sv"   -work s0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_1.v"                     -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_1_addr_router.sv"        -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_1_cmd_xbar_demux.sv"     -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_1_cmd_xbar_mux.sv"       -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_1_id_router.sv"          -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_1_rsp_xbar_demux.sv"     -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_1_rsp_xbar_mux.sv"       -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/sequencer_reg_file.sv"                                    -work s0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/sequencer_scc_acv_phase_decode.v"                         -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/sequencer_scc_acv_wrapper.sv"                             -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/sequencer_scc_mgr.sv"                                     -work s0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/sequencer_scc_reg_file.v"                                 -work s0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/sequencer_scc_siii_phase_decode.v"                        -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/sequencer_scc_siii_wrapper.sv"                            -work s0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/sequencer_scc_sv_phase_decode.v"                          -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/sequencer_scc_sv_wrapper.sv"                              -work s0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/sequencer_trk_mgr.sv"                                     -work s0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_clock_pair_generator.v"                  -work p0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_acv_hard_addr_cmd_pads.v"                -work p0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_acv_hard_memphy.v"                       -work p0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_acv_ldc.v"                               -work p0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_acv_hard_io_pads.v"                      -work p0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_generic_ddio.v"                          -work p0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_reset.v"                                 -work p0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_reset_sync.v"                            -work p0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_phy_csr.sv"                              -work p0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_iss_probe.v"                             -work p0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0.sv"                                      -work p0           
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_altdqdqs.v"                              -work p0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/altdq_dqs2_acv_connect_to_hard_phy_cyclonev_lpddr2.sv"    -work p0           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_pll0.sv"                                    -work pll0         
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_0002.v"                                     -work lpddr2_cntrlr
  vlogan +v2k           "$QSYS_SIMDIR/lpddr2_cntrlr.v"                                                                           
fi

# ----------------------------------------
# elaborate top level design
if [ $SKIP_ELAB -eq 0 ]; then
  vcs -lca -t ps $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS $TOP_LEVEL_NAME
fi

# ----------------------------------------
# simulate
if [ $SKIP_SIM -eq 0 ]; then
  ./simv $SIM_OPTIONS $USER_DEFINED_SIM_OPTIONS
fi
