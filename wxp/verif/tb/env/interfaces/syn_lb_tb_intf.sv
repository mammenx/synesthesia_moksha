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
 -- Interface Name    : syn_lb_tb_intf
 -- Author            : mammenx
 -- Function          : This interface encapsulates the internal local bus
                        signals used to decode read/write transactions
                        from a host master to slave. Used by TB only.
 --------------------------------------------------------------------------
*/


interface syn_lb_tb_intf #(DATA_W  = 32, ADDR_W  = 12) (input logic  clk_ir, rst_il);

  //parameter DATA_W  = 32;
  //parameter ADDR_W  = 8;

  //Read-Write signals
  logic                 rd_en;
  logic                 wr_en;
  logic [ADDR_W-1:0]    addr;
  logic                 wr_valid;
  logic [DATA_W-1:0]    wr_data;
  logic                 rd_valid;
  logic [DATA_W-1:0]    rd_data;

  clocking  cb@(posedge  clk_ir);
    default input #2ns output #2ns;

    inout   rd_en;
    inout   wr_en;
    inout   addr;
    inout   wr_data;

    input   wr_valid;
    input   rd_valid;
    input   rd_data;

  endclocking : cb



  modport TB  (clocking cb, input clk_ir, rst_il);



endinterface  //  syn_lb_tb_intf

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[15-10-2014  11:44:12 PM][mammenx] Initial Commit

 --------------------------------------------------------------------------
*/


