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
 -- Project Code      : synesthesia-moksha
 -- Module Name       : sys_mem_part_mngr
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module holds the partition information in terms
                        of start & end addresses for all the agents.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module sys_mem_part_mngr #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME       = "SYS_MEM_PART_MNGR",
  parameter MEM_ADDR_W        = 27,
  parameter NUM_AGENTS        = 2,
  parameter LB_DATA_W         = 32,
  parameter LB_ADDR_W         = 8,
  parameter DEFAULT_DATA_VAL  = 'hdeadbabe,

  parameter AGENT_ID_W        = $clog2(NUM_AGENTS)  //Do not override

) (

  //--------------------- Ports -------------------------
  input                         clk,
  input                         rst_n,

  input                         cntrlr_clk,
  input                         cntrlr_rst_n,

  input                         lb_wr_en,
  input                         lb_rd_en,
  input       [LB_ADDR_W-1:0]   lb_addr,
  input       [LB_DATA_W-1:0]   lb_wr_data,
  output  reg                   lb_wr_valid,
  output  reg                   lb_rd_valid,
  output      [LB_DATA_W-1:0]   lb_rd_data,

  input       [AGENT_ID_W-1:0]  agent_id,

  output      [MEM_ADDR_W-1:0]  mem_start_addr,
  output      [MEM_ADDR_W-1:0]  mem_end_addr

);

//----------------------- Local Parameters Declarations -------------------
  `include  "sys_mem_part_mngr_regmap.svh"

  localparam  PART_MEM_DATA_W = 40;
  localparam  PART_MEM_ADDR_W = 5;

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------


//----------------------- Internal Wire Declarations ----------------------
  wire                        start_ram_wren_c;
  wire  [PART_MEM_ADDR_W-1:0] start_ram_waddr_w;
  wire  [PART_MEM_DATA_W-1:0] start_ram_wdata_w;
  wire  [PART_MEM_ADDR_W-1:0] start_ram_raddr_w;
  wire  [PART_MEM_DATA_W-1:0] start_ram_rdata_w;

  wire                        end_ram_wren_c;
  wire  [PART_MEM_ADDR_W-1:0] end_ram_waddr_w;
  wire  [PART_MEM_DATA_W-1:0] end_ram_wdata_w;
  wire  [PART_MEM_ADDR_W-1:0] end_ram_raddr_w;
  wire  [PART_MEM_DATA_W-1:0] end_ram_rdata_w;

//----------------------- Start of Code -----------------------------------

  /*  LB Decode Logic */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      lb_wr_valid             <=  0;
      lb_rd_valid             <=  0;
    end
    else
    begin
      lb_wr_valid             <=  lb_wr_en;

      lb_rd_valid             <=  lb_rd_en;
    end
  end

  assign  lb_rd_data          =   DEFAULT_DATA_VAL;


  /*  Instantiate Memories  */

  assign  start_ram_wren_c    = lb_wr_en  & ~lb_addr[PART_MEM_ADDR_W];
  assign  start_ram_waddr_w   = lb_addr[PART_MEM_ADDR_W-1:0];
  assign  start_ram_wdata_w   = {{(PART_MEM_DATA_W-MEM_ADDR_W){1'b0}},  lb_wr_data[MEM_ADDR_W-1:0]};
  assign  start_ram_raddr_w   = {{(PART_MEM_ADDR_W-AGENT_ID_W){1'b0}},  agent_id};
  assign  mem_start_addr      = start_ram_rdata_w[MEM_ADDR_W-1:0];

  async_dpram_40W_32D     start_ram_inst
  (
    .data                 (start_ram_wdata_w),
    .rdaddress            (start_ram_raddr_w),
    .rdclock              (cntrlr_clk),
    .wraddress            (start_ram_waddr_w),
    .wrclock              (clk),
    .wren                 (start_ram_wren_c),
    .q                    (start_ram_rdata_w)
  );

  assign  end_ram_wren_c      = lb_wr_en  & lb_addr[PART_MEM_ADDR_W];
  assign  end_ram_waddr_w     = lb_addr[PART_MEM_ADDR_W-1:0];
  assign  end_ram_wdata_w     = {{(PART_MEM_DATA_W-MEM_ADDR_W){1'b0}},  lb_wr_data[MEM_ADDR_W-1:0]};
  assign  end_ram_raddr_w     = {{(PART_MEM_ADDR_W-AGENT_ID_W){1'b0}},  agent_id};
  assign  mem_end_addr        = end_ram_rdata_w[MEM_ADDR_W-1:0];

  async_dpram_40W_32D     end_ram_inst
  (
    .data                 (end_ram_wdata_w),
    .rdaddress            (end_ram_raddr_w),
    .rdclock              (cntrlr_clk),
    .wraddress            (end_ram_waddr_w),
    .wrclock              (clk),
    .wren                 (end_ram_wren_c),
    .q                    (end_ram_rdata_w)
  );


endmodule // sys_mem_part_mngr

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[14-12-2014  07:55:45 PM][mammenx] Fixed misc compilation errors

[11-12-2014  06:54:58 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
