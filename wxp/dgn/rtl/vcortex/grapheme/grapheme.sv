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
 -- Module Name       : grapheme
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This is the Grapheme top module
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps

`include  "lb_utils.svh"
`include  "mem_utils.svh"
`include "grapheme_node_utils.svh"

module grapheme #(
  //----------------- Parameters  -----------------------
    parameter MODULE_NAME     = "GRAPHEME"
  , parameter LB_DATA_W       = 32
  , parameter LB_ADDR_W       = 8
  , parameter LB_ADDR_BLK_W   = 4
  , parameter SYS_MEM_DATA_W  = 32
  , parameter SYS_MEM_ADDR_W  = 27

  , parameter DEFAULT_REG_VAL = 'hdeadbabe
)
  import  grapheme_node_prot_pkg::*;
)

  //--------------------- Ports -------------------------
    input                     clk
  , input                     rst_n

  , input                     lb_wr_en
  , input                     lb_rd_en
  , input   [LB_ADDR_W-1:0]   lb_addr
  , input   [LB_DATA_W-1:0]   lb_wr_data
  , output                    lb_wr_valid
  , output                    lb_rd_valid
  , output  [LB_DATA_W-1:0]   lb_rd_data

  , input                         sys_mem_wait
  , output                        sys_mem_wren
  , output                        sys_mem_rden
  , output  [SYS_MEM_ADDR_W-1:0]  sys_mem_addr
  , output  [SYS_MEM_DATA_W-1:0]  sys_mem_wdata
  , input                         sys_mem_rd_valid
  , input   [SYS_MEM_DATA_W-1:0]  sys_mem_rdata


);

//----------------------- Local Parameters Declarations -------------------
  `include  "grapheme_regmap.svh"

  localparam  CHILD_LB_DATA_W = LB_DATA_W;
  localparam  CHILD_LB_ADDR_W = LB_ADDR_W - LB_ADDR_BLK_W;
  localparam  NUM_LB_CHILDREN = 2;

  localparam  NUM_NODES       = 2;
  localparam  NODE_BFFR_SIZE  = 5;

  localparam  NODE_ID_HST_ACC = 0;
  localparam  NODE_ID_PXL_GW  = 1;

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------


//----------------------- Internal Wire Declarations ----------------------
  `drop_lb_splitter_wires(CHILD_LB_DATA_W,CHILD_LB_ADDR_W,NUM_LB_CHILDREN,lb_chld_,_w)

  wire  [NUM_NODES-1:0]     gnode_en;
  wire  [NUM_NODES-1:0]     gnode_clear_flags;
  wire  [LB_DATA_W-1:0]     gnode_status  [NUM_NODES-1:0];

  `drop_gnode_wires(NUM_NODES,gnode_prot_cmd_t,GNODE_PROT_DATA_W,eng_ingr_,_w)
  `drop_gnode_wires(NUM_NODES,gnode_prot_cmd_t,GNODE_PROT_DATA_W,eng_egr_,_w)



//----------------------- Start of Code -----------------------------------

  /*  LB  Splitter  */
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


  /*  Local Bus Decoder */
  grapheme_lb #(
     .NUM_NODES         (NUM_NODES)
    ,.LB_DATA_W         (LB_DATA_W)
    ,.LB_ADDR_W         (LB_CHLD_ADDR_W)
    ,.DEFAULT_REG_VAL   (DEFAULT_REG_VAL)

  ) grapheme_lb_inst (

     .clk                 (clk)
    ,.rst_n               (rst_n)

    `drop_lb_ports_split(GRAPHEME_LB_BLK_CODE,lb_, ,lb_chld_,_w)

    ,.gnode_en            (gnode_en         )
    ,.gnode_clear_flags   (gnode_clear_flags)
    ,.gnode_status        (gnode_status     )

  );

  /*  Node Chain  */
  grapheme_node_chain #(
     .NUM_NODES           (NUM_NODES)
    ,.TERMINATE_CHAIN     (0)
    ,.FLOP_STAGES         (0)

  ) node_chain_inst (

     .clk                 (clk)
    ,.rst_n               (rst_n)

    ,.ingr_cmd            (eng_egr_cmd  )
    ,.ingr_data           (eng_egr_data )
    ,.ingr_ready          (eng_egr_ready)

    ,.egr_cmd             (eng_ingr_cmd  )
    ,.egr_data            (eng_ingr_data )
    ,.egr_ready           (eng_ingr_ready)

  );


  /*  Host Access GNODE */
  assign  gnode_status[NODE_ID_HST_ACC] = DEFAULT_REG_VAL;  //Host Acc has its own LB bus

  grapheme_hst_acc #(
     .LB_DATA_W           (LB_DATA_W)
    ,.LB_ADDR_W           (LB_ADDR_W)
    ,.NODE_ID             (NODE_ID_HST_ACC)
    ,.BFFR_SIZE           (NODE_BFFR_SIZE)

  ) hst_acc_gnode_inst (

     .clk                 (clk)
    ,.rst_n               (rst_n)

    `drop_lb_ports_split(GRAPHEME_HST_ACCNODE_ID_HST_ACC_BLK_CODE,lb_, ,lb_chld_,_w)
    ,
    `drop_gnode_ports(ingr_, ,eng_ingr_,_w{NODE_ID_HST_ACC})
    ,
    `drop_gnode_ports(egr_, ,eng_egr_,_w[NODE_ID_HST_ACC])

    ,.node_en             (gnode_en[NODE_ID_HST_ACC])

  );


  /*  Pixel Gateway GNODE */
  grapheme_pxl_gw_1280x720 #(
     .NODE_ID             (NODE_ID_PXL_GW)
    ,.BFFR_SIZE           (NODE_BFFR_SIZE)
    ,.MEM_DATA_W          (SYS_MEM_DATA_W)
    ,.MEM_ADDR_W          (SYS_MEM_ADDR_W)
    ,.STATUS_W            (LB_DATA_W)

  ) pxl_gw_node_inst  (

    //--------------------- Ports -------------------------
     .clk                 (clk)
    ,.rst_n               (rst_n)

    ,.mem_wait            (sys_mem_wait)
    `drop_mem_ports(mem_, ,sys_mem_, )
    ,
    `drop_gnode_ports(ingr_, ,eng_ingr_,_w[NODE_ID_PXL_GW])
    ,
    `drop_gnode_ports(egr_, ,eng_egr_,_w[NODE_ID_PXL_GW])

    ,.node_en             (gnode_en[NODE_ID_PXL_GW])

    ,.clear_flags         (gnode_clear_flags[NODE_ID_PXL_GW])
    ,.status              (gnode_status[NODE_ID_PXL_GW]);

  );



endmodule // grapheme

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[22-08-2015  02:58:53 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
