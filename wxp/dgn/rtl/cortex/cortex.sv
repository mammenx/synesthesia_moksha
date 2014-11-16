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
 -- Module Name       : cortex
 -- Author            : mammenx
 -- Associated modules: lb_splitter,  acortex
 -- Function          : This is the top module for Cortex acceleration
                        engine.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps

`include  "lb_utils.svh"

module cortex #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME       = "CORTEX",
  parameter LB_DATA_W         = 32,
  parameter LB_ADDR_W         = 16,
  parameter LB_ADDR_BLK_W     = 4,
  parameter NUM_AUD_SAMPLES   = 128,
  parameter DEFAULT_DATA_VAL  = 'hdeadbabe

) (

  //--------------------- Ports -------------------------
    input                       clk,
    input                       rst_n,

    input                       lb_wr_en,
    input                       lb_rd_en,
    input   [LB_ADDR_W-1:0]     lb_addr,
    input   [LB_DATA_W-1:0]     lb_wr_data,
    output                      lb_wr_valid,
    output                      lb_rd_valid,
    output  [LB_DATA_W-1:0]     lb_rd_data,

    output                      scl,
    inout                       sda,

    input                       AUD_ADCDAT,
    output                      AUD_ADCLRCK,
    output                      AUD_BCLK,
    output                      AUD_DACDAT,
    output                      AUD_DACLRCK


);

//----------------------- Local Parameters Declarations -------------------
  `include  "cortex_regmap.svh"

  localparam  LB_CHLD_DATA_W      = LB_DATA_W;
  localparam  LB_CHLD_ADDR_W      = LB_ADDR_W - LB_ADDR_BLK_W;
  localparam  LB_CHLD_ADDR_BLK_W  = 4;
  localparam  NUM_LB_CHILDREN     = 2;

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------


//----------------------- Internal Wire Declarations ----------------------
  `drop_lb_splitter_wires(LB_CHLD_DATA_W,LB_CHLD_ADDR_W,NUM_LB_CHILDREN,lb_chld_,_w)

  wire  [NUM_LB_CHILDREN-2:0] cortex_rst_vec;

//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------



//----------------------- Start of Code -----------------------------------

  /*  Local Bus Logic */
  lb_splitter #(
    .LB_DATA_W         (LB_DATA_W),
    .LB_ADDR_W         (LB_ADDR_W),
    .LB_CHLD_ADDR_W    (LB_CHLD_ADDR_W),
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

  rst_cntrl #(
    .NUM_RESETS       (NUM_LB_CHILDREN-1),
    .LB_DATA_W        (LB_CHLD_DATA_W),
    .LB_ADDR_W        (LB_CHLD_ADDR_W),
    .DEFAULT_REG_VAL  (DEFAULT_DATA_VAL)

  ) rst_cntrl_inst  (

    .rst_n            (rst_n),
    .clk              (clk),

    `drop_lb_ports_split(RST_SYNC_BLK,lb_, ,lb_chld_,_w)
    ,

    .cntrl_rst_n      (cortex_rst_vec)

  );

  /*  Instantiate Acortex */
  acortex #(
    .LB_DATA_W          (LB_CHLD_DATA_W      ),
    .LB_ADDR_W          (LB_CHLD_ADDR_W      ),
    .LB_ADDR_BLK_W      (LB_CHLD_ADDR_BLK_W  ),
    .NUM_SAMPLES        (NUM_AUD_SAMPLES     ),
    .DEFAULT_DATA_VAL   (DEFAULT_DATA_VAL    )

  ) acortex_inst  (

    .clk                      (clk),
    .rst_n                    (cortex_rst_vec[ACORTEX_BLK]),
                                                        
    `drop_lb_ports_split(ACORTEX_BLK,lb_, ,lb_chld_,_w)
    ,

    .acortex2fgyrus_pcm_rdy   (),
    .fgyrus2acortex_addr      (0),
    .acortex2fgyrus_pcm_data  (),

    .scl                      (scl),
    .sda                      (sda),

    .AUD_ADCDAT               (AUD_ADCDAT),
    .AUD_ADCLRCK              (AUD_ADCLRCK),
    .AUD_BCLK                 (AUD_BCLK),
    .AUD_DACDAT               (AUD_DACDAT),
    .AUD_DACLRCK              (AUD_DACLRCK)

  );

endmodule // cortex

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[11-11-2014  07:53:04 PM][mammenx] Fixed synthesis errors

[11-11-2014  07:52:04 PM][mammenx] Initial Version

 --------------------------------------------------------------------------
*/
