#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
create_clock -period 8.000  -name CLK_125     [get_ports CLOCK_125_p]
create_clock -period 20.000 -name CLK_50_B5B  [get_ports CLOCK_50_B5B]
create_clock -period 20.000 -name CLK_50_B6A  [get_ports CLOCK_50_B6A]
create_clock -period 20.000 -name CLK_50_B7A  [get_ports CLOCK_50_B7A]
create_clock -period 20.000 -name CLK_50_B8A  [get_ports CLOCK_50_B8A]

#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks

set sysClk100   [get_clocks sys_pll*general[0]*divclk]
set sysClk12    [get_clocks sys_pll*general[1]*divclk]
set sysClk75    [get_clocks sys_pll*general[2]*divclk]
set afiHalfClk  [get_clocks lpddr2_cntrlr*pll0|pll5*divclk]

set lpddr2CntrlrSwRst [get_registers  rst_sync:cntrlr_sw_rst_sync_inst|sync_vec_f[1]]

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
#set_false_path  -from [get_clocks lpddr2_cntrlr*] -to [get_clocks sys_pll*]
#set_false_path  -from [get_clocks sys_pll*]       -to [get_clocks lpddr2_cntrlr*]

set_clock_groups -exclusive -group  $afiHalfClk \
                            -group  $sysClk100  \
                            -group  $sysClk12   \
                            -group  $sysClk75   \


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************
set_max_delay -from [get_registers *sys_mem_arb_rr*]  -to [get_registers *lpddr2_cntrlr*]   5.000
set_max_delay -from [get_registers *lpddr2_cntrlr*]   -to [get_registers *sys_mem_arb_rr*]  5.000

set_max_delay -from $lpddr2CntrlrSwRst  -to [get_registers  *lpddr2_cntrlr*]  6.000

#**************************************************************
# Set Minimum Delay
#**************************************************************
set_min_delay -from [get_registers  *sys_mem_arb_rr*]   -to [get_registers  *lpddr2_cntrlr*]  0.500
set_min_delay -from [get_registers  *lpddr2_cntrlr*]    -to [get_registers  *sys_mem_arb_rr*] 0.500

set_min_delay -from $lpddr2CntrlrSwRst  -to [get_registers  *lpddr2_cntrlr*]  0.500

#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************



