
# (C) 2001-2015 Altera Corporation. All rights reserved.
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

# ACDS 13.1 162 win32 2015.03.23.14:35:43

# ----------------------------------------
# Auto-generated simulation script

# ----------------------------------------
# Initialize variables
if ![info exists SYSTEM_INSTANCE_NAME] { 
  set SYSTEM_INSTANCE_NAME ""
} elseif { ![ string match "" $SYSTEM_INSTANCE_NAME ] } { 
  set SYSTEM_INSTANCE_NAME "/$SYSTEM_INSTANCE_NAME"
}

if ![info exists TOP_LEVEL_NAME] { 
  set TOP_LEVEL_NAME "lpddr2_cntrlr"
}

if ![info exists QSYS_SIMDIR] { 
  set QSYS_SIMDIR "./../"
}

if ![info exists QUARTUS_INSTALL_DIR] { 
  set QUARTUS_INSTALL_DIR "C:/altera/13.1/quartus/"
}

# ----------------------------------------
# Initialize simulation properties - DO NOT MODIFY!
set ELAB_OPTIONS ""
set SIM_OPTIONS ""
if ![ string match "*-64 vsim*" [ vsim -version ] ] {
} else {
}

set Aldec "Riviera"
if { [ string match "*Active-HDL*" [ vsim -version ] ] } {
  set Aldec "Active"
}

if { [ string match "Active" $Aldec ] } {
  scripterconf -tcl
  createdesign "$TOP_LEVEL_NAME"  "."
  opendesign "$TOP_LEVEL_NAME"
}

# ----------------------------------------
# Copy ROM/RAM files to simulation directory
alias file_copy {
  echo "\[exec\] file_copy"
  file copy -force $QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_sequencer_mem.hex ./
  file copy -force $QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_AC_ROM.hex ./
  file copy -force $QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_inst_ROM.hex ./
}

# ----------------------------------------
# Create compilation libraries
proc ensure_lib { lib } { if ![file isdirectory $lib] { vlib $lib } }
ensure_lib      ./libraries     
ensure_lib      ./libraries/work
vmap       work ./libraries/work
ensure_lib                       ./libraries/altera_ver           
vmap       altera_ver            ./libraries/altera_ver           
ensure_lib                       ./libraries/lpm_ver              
vmap       lpm_ver               ./libraries/lpm_ver              
ensure_lib                       ./libraries/sgate_ver            
vmap       sgate_ver             ./libraries/sgate_ver            
ensure_lib                       ./libraries/altera_mf_ver        
vmap       altera_mf_ver         ./libraries/altera_mf_ver        
ensure_lib                       ./libraries/altera_lnsim_ver     
vmap       altera_lnsim_ver      ./libraries/altera_lnsim_ver     
ensure_lib                       ./libraries/cyclonev_ver         
vmap       cyclonev_ver          ./libraries/cyclonev_ver         
ensure_lib                       ./libraries/cyclonev_hssi_ver    
vmap       cyclonev_hssi_ver     ./libraries/cyclonev_hssi_ver    
ensure_lib                       ./libraries/cyclonev_pcie_hip_ver
vmap       cyclonev_pcie_hip_ver ./libraries/cyclonev_pcie_hip_ver
ensure_lib               ./libraries/dll0         
vmap       dll0          ./libraries/dll0         
ensure_lib               ./libraries/oct0         
vmap       oct0          ./libraries/oct0         
ensure_lib               ./libraries/c0           
vmap       c0            ./libraries/c0           
ensure_lib               ./libraries/s0           
vmap       s0            ./libraries/s0           
ensure_lib               ./libraries/p0           
vmap       p0            ./libraries/p0           
ensure_lib               ./libraries/pll0         
vmap       pll0          ./libraries/pll0         
ensure_lib               ./libraries/lpddr2_cntrlr
vmap       lpddr2_cntrlr ./libraries/lpddr2_cntrlr

# ----------------------------------------
# Compile device library files
alias dev_com {
  echo "\[exec\] dev_com"
  vlog +define+SKIP_KEYWORDS_PRAGMA "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v"                    -work altera_ver           
  vlog                              "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"                             -work lpm_ver              
  vlog                              "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"                                -work sgate_ver            
  vlog                              "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"                            -work altera_mf_ver        
  vlog                              "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"                        -work altera_lnsim_ver     
  vlog                              "$QUARTUS_INSTALL_DIR/eda/sim_lib/aldec/cyclonev_atoms_ncrypt.v"          -work cyclonev_ver         
  vlog                              "$QUARTUS_INSTALL_DIR/eda/sim_lib/aldec/cyclonev_hmi_atoms_ncrypt.v"      -work cyclonev_ver         
  vlog                              "$QUARTUS_INSTALL_DIR/eda/sim_lib/cyclonev_atoms.v"                       -work cyclonev_ver         
  vlog                              "$QUARTUS_INSTALL_DIR/eda/sim_lib/aldec/cyclonev_hssi_atoms_ncrypt.v"     -work cyclonev_hssi_ver    
  vlog                              "$QUARTUS_INSTALL_DIR/eda/sim_lib/cyclonev_hssi_atoms.v"                  -work cyclonev_hssi_ver    
  vlog                              "$QUARTUS_INSTALL_DIR/eda/sim_lib/aldec/cyclonev_pcie_hip_atoms_ncrypt.v" -work cyclonev_pcie_hip_ver
  vlog                              "$QUARTUS_INSTALL_DIR/eda/sim_lib/cyclonev_pcie_hip_atoms.v"              -work cyclonev_pcie_hip_ver
}

# ----------------------------------------
# Compile the design files in correct order
alias com {
  echo "\[exec\] com"
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/altera_mem_if_dll_cyclonev.sv"                            -work dll0         
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/altera_mem_if_oct_cyclonev.sv"                            -work oct0         
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/altera_mem_if_hard_memory_controller_top_cyclonev.sv"     -work c0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0.v"                                       -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/altera_avalon_mm_bridge.v"                                -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/altera_avalon_sc_fifo.v"                                  -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/altera_avalon_st_pipeline_base.v"                         -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/altera_mem_if_sequencer_cpu_cv_sim_cpu_inst.v"            -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/altera_mem_if_sequencer_cpu_cv_sim_cpu_inst_test_bench.v" -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/altera_mem_if_sequencer_mem_no_ifdef_params.sv"           -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/altera_mem_if_sequencer_rst.sv"                           -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/altera_mem_if_simple_avalon_mm_bridge.sv"                 -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/altera_merlin_arbitrator.sv"                              -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/altera_merlin_burst_uncompressor.sv"                      -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/altera_merlin_master_agent.sv"                            -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/altera_merlin_master_translator.sv"                       -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/altera_merlin_reorder_memory.sv"                          -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/altera_merlin_slave_agent.sv"                             -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/altera_merlin_slave_translator.sv"                        -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/altera_merlin_traffic_limiter.sv"                         -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_irq_mapper.sv"                           -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0.v"                     -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_addr_router.sv"        -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_addr_router_001.sv"    -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_addr_router_002.sv"    -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_cmd_xbar_demux.sv"     -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_cmd_xbar_demux_001.sv" -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_cmd_xbar_demux_002.sv" -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_cmd_xbar_mux.sv"       -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_cmd_xbar_mux_003.sv"   -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_id_router.sv"          -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_id_router_002.sv"      -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_id_router_003.sv"      -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_rsp_xbar_mux.sv"       -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_rsp_xbar_mux_001.sv"   -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_0_rsp_xbar_mux_002.sv"   -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_1.v"                     -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_1_addr_router.sv"        -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_1_cmd_xbar_demux.sv"     -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_1_cmd_xbar_mux.sv"       -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_1_id_router.sv"          -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_1_rsp_xbar_demux.sv"     -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_s0_mm_interconnect_1_rsp_xbar_mux.sv"       -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/sequencer_reg_file.sv"                                    -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/sequencer_scc_acv_phase_decode.v"                         -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/sequencer_scc_acv_wrapper.sv"                             -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/sequencer_scc_mgr.sv"                                     -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/sequencer_scc_reg_file.v"                                 -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/sequencer_scc_siii_phase_decode.v"                        -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/sequencer_scc_siii_wrapper.sv"                            -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/sequencer_scc_sv_phase_decode.v"                          -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/sequencer_scc_sv_wrapper.sv"                              -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/sequencer_trk_mgr.sv"                                     -work s0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_clock_pair_generator.v"                  -work p0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_acv_hard_addr_cmd_pads.v"                -work p0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_acv_hard_memphy.v"                       -work p0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_acv_ldc.v"                               -work p0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_acv_hard_io_pads.v"                      -work p0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_generic_ddio.v"                          -work p0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_reset.v"                                 -work p0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_reset_sync.v"                            -work p0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_phy_csr.sv"                              -work p0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_iss_probe.v"                             -work p0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0.sv"                                      -work p0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_p0_altdqdqs.v"                              -work p0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/altdq_dqs2_acv_connect_to_hard_phy_cyclonev_lpddr2.sv"    -work p0           
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_pll0.sv"                                    -work pll0         
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr/lpddr2_cntrlr_0002.v"                                     -work lpddr2_cntrlr
  vlog  "$QSYS_SIMDIR/lpddr2_cntrlr.v"                                                                           
}

# ----------------------------------------
# Elaborate top level design
alias elab {
  echo "\[exec\] elab"
  eval vsim +access +r -t ps $ELAB_OPTIONS -L work -L dll0 -L oct0 -L c0 -L s0 -L p0 -L pll0 -L lpddr2_cntrlr -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver $TOP_LEVEL_NAME
}

# ----------------------------------------
# Elaborate the top level design with -dbg -O2 option
alias elab_debug {
  echo "\[exec\] elab_debug"
  eval vsim -dbg -O2 +access +r -t ps $ELAB_OPTIONS -L work -L dll0 -L oct0 -L c0 -L s0 -L p0 -L pll0 -L lpddr2_cntrlr -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver $TOP_LEVEL_NAME
}

# ----------------------------------------
# Compile all the design files and elaborate the top level design
alias ld "
  dev_com
  com
  elab
"

# ----------------------------------------
# Compile all the design files and elaborate the top level design with -dbg -O2
alias ld_debug "
  dev_com
  com
  elab_debug
"

# ----------------------------------------
# Print out user commmand line aliases
alias h {
  echo "List Of Command Line Aliases"
  echo
  echo "file_copy                     -- Copy ROM/RAM files to simulation directory"
  echo
  echo "dev_com                       -- Compile device library files"
  echo
  echo "com                           -- Compile the design files in correct order"
  echo
  echo "elab                          -- Elaborate top level design"
  echo
  echo "elab_debug                    -- Elaborate the top level design with -dbg -O2 option"
  echo
  echo "ld                            -- Compile all the design files and elaborate the top level design"
  echo
  echo "ld_debug                      -- Compile all the design files and elaborate the top level design with -dbg -O2"
  echo
  echo 
  echo
  echo "List Of Variables"
  echo
  echo "TOP_LEVEL_NAME                -- Top level module name."
  echo
  echo "SYSTEM_INSTANCE_NAME          -- Instantiated system module name inside top level module."
  echo
  echo "QSYS_SIMDIR                   -- Qsys base simulation directory."
  echo
  echo "QUARTUS_INSTALL_DIR           -- Quartus installation directory."
}
file_copy
h
