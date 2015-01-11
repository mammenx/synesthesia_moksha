#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
create_clock -period 8 [get_ports CLOCK_125_p]
create_clock -period 20 [get_ports CLOCK_50_B5B]
create_clock -period 20 [get_ports CLOCK_50_B6A]
create_clock -period 20 [get_ports CLOCK_50_B7A]
create_clock -period 20 [get_ports CLOCK_50_B8A]

#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************
set_false_path -from [get_clocks CLOCK_50_B5B] -to [get_clocks {lpddr2_cntrlr_inst|lpddr2_cntrlr_inst|pll0|pll_config_clk}]
set_false_path -from [get_clocks CLOCK_50_B5B] -to [get_clocks {lpddr2_cntrlr_inst|lpddr2_cntrlr_inst|pll0|pll_afi_half_clk}]
set_false_path -from [get_clocks CLOCK_50_B5B] -to [get_clocks {lpddr2_cntrlr_inst|lpddr2_cntrlr_inst|pll0|pll_avl_clk}]
set_false_path -from [get_clocks CLOCK_50_B5B] -to [get_clocks {lpddr2_cntrlr_inst|lpddr2_cntrlr_inst|pll0|pll_afi_clk}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************
set_max_delay -from "cortex:cortex_inst|vcortex:vcortex_inst|adv7513_cntrlr:adv7513_cntrlr_inst|line_bffr:line_bffr_inst|ff_24x2048_fwft_async:bffr_inst|*" \
              -to   "cortex:cortex_inst|sys_mem_intf:sys_mem_intf_inst|sys_mem_arb:sys_mem_arb_inst|ff_10x1024_fwft:egr_bffr0_inst|*" \
              7.000


#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************



