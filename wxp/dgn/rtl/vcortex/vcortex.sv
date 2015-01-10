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
 -- Module Name       : vcortex
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This is the top level Visual Cortex Module.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps

`include  "mem_utils.svh"
`include  "lb_utils.svh"

module vcortex #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME         = "VCORTEX",
  parameter LB_DATA_W           = 32,
  parameter LB_ADDR_W           = 12,
  parameter LB_ADDR_BLK_W       = 4,
  parameter SYS_MEM_NUM_AGENTS  = 2,
  parameter SYS_MEM_DATA_W      = 32,
  parameter SYS_MEM_ADDR_W      = 27,
  parameter SYS_MEM_START_ADDR  = 0,
  parameter SYS_MEM_STOP_ADDR   = 921599,

  parameter DEFAULT_REG_VAL     = 'hdeadbabe
 
) (

  //--------------------- Ports -------------------------
    input                       clk,
    input                       clk_hdmi,
    input                       rst_n,
    input                       hdmi_rst_n,

    input                       lb_wr_en,
    input                       lb_rd_en,
    input   [LB_ADDR_W-1:0]     lb_addr,
    input   [LB_DATA_W-1:0]     lb_wr_data,
    output                      lb_wr_valid,
    output                      lb_rd_valid,
    output  [LB_DATA_W-1:0]     lb_rd_data,

    input   [SYS_MEM_NUM_AGENTS-1:0]  sys_mem_wait,
    output  [SYS_MEM_NUM_AGENTS-1:0]  sys_mem_wren,
    output  [SYS_MEM_NUM_AGENTS-1:0]  sys_mem_rden,
    output  [SYS_MEM_ADDR_W-1:0]      sys_mem_addr  [SYS_MEM_NUM_AGENTS-1:0],
    output  [SYS_MEM_DATA_W-1:0]      sys_mem_wdata [SYS_MEM_NUM_AGENTS-1:0],
    input   [SYS_MEM_NUM_AGENTS-1:0]  sys_mem_rd_valid,
    input   [SYS_MEM_DATA_W-1:0]      sys_mem_rdata [SYS_MEM_NUM_AGENTS-1:0],

    output  [23:0]              HDMI_TX_D,
    output                      HDMI_TX_DE,
    output                      HDMI_TX_HS,
    input                       HDMI_TX_INT,
    output                      HDMI_TX_VS

);

//----------------------- Local Parameters Declarations -------------------
  `include  "vcortex_regmap.svh"

  localparam  CHILD_LB_DATA_W = LB_DATA_W;
  localparam  CHILD_LB_ADDR_W = LB_ADDR_W - LB_ADDR_BLK_W;
  localparam  NUM_LB_CHILDREN = 2;

  localparam  SYS_MEM_HST_ACC_ID        = 0;
  localparam  SYS_MEM_ADV7513_CNTRLR_ID = 1;


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------


//----------------------- Internal Wire Declarations ----------------------
  `drop_lb_splitter_wires(CHILD_LB_DATA_W,CHILD_LB_ADDR_W,NUM_LB_CHILDREN,lb_chld_,_w)


//----------------------- Internal Interface Declarations -----------------




//----------------------- Start of Code -----------------------------------


  /*  Local Bus Logic */
  lb_splitter #(
    .LB_DATA_W         (LB_DATA_W),
    .LB_ADDR_W         (LB_ADDR_W),
    .LB_CHLD_ADDR_W    (CHILD_LB_ADDR_W),
    .NUM_CHILDREN      (NUM_LB_CHILDREN),
    .REGISTER_OUTPUTS  (0),
    .DEFAULT_DATA_VAL  (DEFAULT_REG_VAL)

  ) lb_splitter_inst  (

    .clk                      (clk),
    .rst_n                    (rst_n),

    `drop_lb_ports(lb_, ,lb_, )
    ,
    `drop_lb_ports(chld_lb_, ,lb_chld_,_w)

  );

  /*  Instantiate System Memory Host Access */
  sys_mem_hst_acc #(
    .LB_DATA_W           (CHILD_LB_DATA_W),
    .LB_ADDR_W           (CHILD_LB_ADDR_W),
    .SYS_MEM_DATA_W      (SYS_MEM_DATA_W),
    .SYS_MEM_ADDR_W      (SYS_MEM_ADDR_W),
    .SYS_MEM_START_ADDR  (SYS_MEM_START_ADDR),
    .SYS_MEM_STOP_ADDR   (SYS_MEM_STOP_ADDR),
    .DEFAULT_REG_VAL     (DEFAULT_REG_VAL)
   
  ) sys_mem_hst_acc_inst  (

    .clk                (clk),
    .rst_n              (rst_n),

    `drop_lb_ports_split(VCORTEX_HST_ACCESS_BLK_CODE,lb_, ,lb_chld_,_w)
    ,

    .sys_mem_wait       (sys_mem_wait[SYS_MEM_HST_ACC_ID]),
    `drop_mem_ports(sys_mem_, ,sys_mem_,[SYS_MEM_HST_ACC_ID])

  );


  /*  Instantiate ADV7513 Driver  */
  adv7513_cntrlr #(
    .LB_DATA_W           (CHILD_LB_DATA_W),
    .LB_ADDR_W           (CHILD_LB_ADDR_W),
    .SYS_MEM_DATA_W      (SYS_MEM_DATA_W),
    .SYS_MEM_ADDR_W      (SYS_MEM_ADDR_W),
    .SYS_MEM_START_ADDR  (SYS_MEM_START_ADDR),
    .SYS_MEM_STOP_ADDR   (SYS_MEM_STOP_ADDR),
    .DEFAULT_REG_VAL     (DEFAULT_REG_VAL)
   
  ) adv7513_cntrlr_inst (

    .clk                (clk),
    .clk_hdmi           (clk_hdmi),
    .rst_n              (rst_n),
    .hdmi_rst_n         (hdmi_rst_n),

    `drop_lb_ports_split(VCORTEX_ADV7513_CNTRLR_BLK_CODE,lb_, ,lb_chld_,_w)
    ,

    .sys_mem_wait       (sys_mem_wait[SYS_MEM_ADV7513_CNTRLR_ID]),
    `drop_mem_ports(sys_mem_, ,sys_mem_,[SYS_MEM_ADV7513_CNTRLR_ID])
    ,

    .HDMI_TX_D          (HDMI_TX_D  ),
    .HDMI_TX_DE         (HDMI_TX_DE ),
    .HDMI_TX_HS         (HDMI_TX_HS ),
    .HDMI_TX_INT        (HDMI_TX_INT),
    .HDMI_TX_VS         (HDMI_TX_VS )

  );


endmodule // vcortex

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[10-01-2015  11:49:47 AM][mammenx] Fixed Compilation Errors

[08-01-2015  07:13:10 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
