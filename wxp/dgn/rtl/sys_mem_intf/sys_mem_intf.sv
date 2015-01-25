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
 -- Module Name       : sys_mem_intf
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module is used to arbitrate between different
                        agents to access a common system memory.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps

`include  "mem_utils.svh"
`include  "lb_utils.svh"

module sys_mem_intf #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME             = "SYS_MEM_INTF",
  parameter LB_DATA_W               = 32,
  parameter LB_ADDR_W               = 12,
  parameter LB_ADDR_BLK_W           = 4,
  parameter MEM_DATA_W              = 32,
  parameter MEM_ADDR_W              = 27,
  parameter NUM_AGENTS              = 2,
  parameter REGISTER_CNTRLR_OUTPUTS = 0,
  parameter DEFAULT_DATA_VAL        = 'hdeadbabe,

  parameter AGENT_ID_W              = $clog2(NUM_AGENTS)  //Do not override

) (

  //--------------------- Ports -------------------------
  input                           clk,
  input                           rst_n,

  input                           cntrlr_clk,
  input                           cntrlr_rst_n,

  input                           lb_wr_en,
  input                           lb_rd_en,
  input       [LB_ADDR_W-1:0]     lb_addr,
  input       [LB_DATA_W-1:0]     lb_wr_data,
  output                          lb_wr_valid,
  output                          lb_rd_valid,
  output      [LB_DATA_W-1:0]     lb_rd_data,

  output      [NUM_AGENTS-1:0]    agent_wait,
  input       [NUM_AGENTS-1:0]    agent_wren,
  input       [NUM_AGENTS-1:0]    agent_rden,
  input       [MEM_ADDR_W-1:0]    agent_addr  [NUM_AGENTS-1:0],
  input       [MEM_DATA_W-1:0]    agent_wdata [NUM_AGENTS-1:0],
  output      [NUM_AGENTS-1:0]    agent_rd_valid,
  output      [MEM_DATA_W-1:0]    agent_rdata [NUM_AGENTS-1:0],

  input                           cntrlr_rdy,
  output                          cntrlr_wren,
  output                          cntrlr_rden,
  output      [MEM_ADDR_W-1:0]    cntrlr_addr,
  output      [MEM_DATA_W-1:0]    cntrlr_wdata,
  input                           cntrlr_rd_valid,
  input       [MEM_DATA_W-1:0]    cntrlr_rdata

);

//----------------------- Local Parameters Declarations -------------------
  `include  "sys_mem_intf_regmap.svh"

  localparam  CHILD_LB_DATA_W = LB_DATA_W;
  localparam  CHILD_LB_ADDR_W = LB_ADDR_W - LB_ADDR_BLK_W;
  localparam  NUM_LB_CHILDREN = 2;

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------


//----------------------- Internal Wire Declarations ----------------------
  `drop_lb_splitter_wires(CHILD_LB_DATA_W,CHILD_LB_ADDR_W,NUM_LB_CHILDREN,lb_chld_,_w)

  wire  [AGENT_ID_W-1:0]      agent_id_w;

  wire  [MEM_ADDR_W-1:0]      mem_start_addr_w,mem_end_addr_w;

//----------------------- Internal Interface Declarations -----------------




//----------------------- Start of Code -----------------------------------

  /*  Local Bus Logic */
  lb_splitter #(
    .LB_DATA_W         (LB_DATA_W),
    .LB_ADDR_W         (LB_ADDR_W),
    .LB_CHLD_ADDR_W    (CHILD_LB_ADDR_W),
    .NUM_CHILDREN      (NUM_LB_CHILDREN),
    .REGISTER_OUTPUTS  (0),
    .DEFAULT_DATA_VAL  (DEFAULT_DATA_VAL)

  ) lb_splitter_inst  (

    .clk                      (clk),
    .rst_n                    (rst_n),

    `drop_lb_ports(lb_, ,lb_, )
    ,
    `drop_lb_ports(chld_lb_, ,lb_chld_,_w)

  );


  sys_mem_arb_rr #(
    .LB_DATA_W                (CHILD_LB_DATA_W),
    .LB_ADDR_W                (CHILD_LB_ADDR_W),
    .MEM_DATA_W               (MEM_DATA_W),
    .MEM_ADDR_W               (MEM_ADDR_W),
    .NUM_AGENTS               (NUM_AGENTS),
    .REGISTER_CNTRLR_OUTPUTS  (REGISTER_CNTRLR_OUTPUTS),
    .DEFAULT_DATA_VAL         (DEFAULT_DATA_VAL)

  ) sys_mem_arb_inst  (

    .clk                      (clk),
    .rst_n                    (rst_n),

    .cntrlr_clk               (cntrlr_clk),
    .cntrlr_rst_n             (cntrlr_rst_n),

    `drop_lb_ports_split(SYS_MEM_INTF_ARB_BLK_CODE,lb_, ,lb_chld_,_w)
    ,

    .agent_wait               (agent_wait),
    `drop_mem_ports(agent_, ,agent_, )
    ,

    .agent_id                (agent_id_w),
    .agent_start_addr        (mem_start_addr_w),
    .agent_end_addr          (mem_end_addr_w),

    .cntrlr_rdy              (cntrlr_rdy),
    `drop_mem_ports(cntrlr_, ,cntrlr_, )

  );


  sys_mem_part_mngr #(
    .MEM_ADDR_W        (MEM_ADDR_W),
    .NUM_AGENTS        (NUM_AGENTS),
    .LB_DATA_W         (CHILD_LB_DATA_W),
    .LB_ADDR_W         (CHILD_LB_ADDR_W),
    .DEFAULT_DATA_VAL  (DEFAULT_DATA_VAL)

  ) sys_mem_part_mngr_inst  (

    .clk                      (clk),
    .rst_n                    (rst_n),

    .cntrlr_clk               (cntrlr_clk),
    .cntrlr_rst_n             (cntrlr_rst_n),

    `drop_lb_ports_split(SYS_MEM_INTF_PART_BLK_CODE,lb_, ,lb_chld_,_w)
    ,

    .agent_id                (agent_id_w),

    .mem_start_addr          (mem_start_addr_w),
    .mem_end_addr            (mem_end_addr_w)

  );


endmodule // sys_mem_intf

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[11-01-2015  06:18:41 PM][mammenx] Converted system memory controller interface to seperate clock domain

[11-01-2015  01:07:10 PM][mammenx] Fixed misc issues found in simulation

[14-12-2014  07:55:45 PM][mammenx] Fixed misc compilation errors

[14-12-2014  07:19:08 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
