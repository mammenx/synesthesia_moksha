/*
 --------------------------------------------------------------------------
   Synesthesia-Moksha - Copyright (C) 2012 Gregory Matthew James.

   This file is part of Synesthesia-Moksha.

   Synesthesia-Moksha is free; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   Synesthesia-Moksha is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program. If not, see <http://www.gnu.org/licenses/>.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------
 -- Project Code      : synesthesia_moksha
 -- Interface Name    : syn_sys_mem_intf
 -- Author            : mammenx
 -- Function          : This interace contains all the signals in the 
                        system mem.
 --------------------------------------------------------------------------
*/

interface syn_sys_mem_intf  #(DATA_W=32,ADDR_W=27) (input logic clk_ir,rst_il);

  //Logic signals
  logic               mem_wait;
  logic               mem_wren;
  logic               mem_rden;
  logic [ADDR_W-1:0]  mem_addr;
  logic [DATA_W-1:0]  mem_wdata;
  logic               mem_rd_valid;
  logic [DATA_W-1:0]  mem_rdata;


  //Clocking Blocks
  clocking  cb_drvr  @(posedge clk_ir);
    default input #2ns  output  #2ns;

    output  mem_wait;
    input   mem_wren;
    input   mem_rden;
    input   mem_addr;
    input   mem_wdata;
    output  mem_rd_valid;
    output  mem_rdata;

  endclocking : cb_drvr


  //Modports
  modport TB_DRVR   (input   clk_ir,rst_il, clocking  cb_drvr);


endinterface  //  syn_sys_mem_intf

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[11-01-2015  01:23:03 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/


