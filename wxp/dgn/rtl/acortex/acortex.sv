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
 -- Module Name       : acortex
 -- Author            : mammenx
 -- Associated modules: pcm_bffr, ssm2603_drvr, i2c_master
 -- Function          : This is Audio Cortex block top.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module acortex #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME   = "ACORTEX",
  parameter LB_DATA_W     = 32,
  parameter LB_ADDR_W     = 12,
  parameter LB_ADDR_BLK_W = 4,
  parameter NUM_MCLKS     = 2,
  parameter NUM_SAMPLES   = 128,
  parameter MEM_ADDR_W    = $clog2(NUM_SAMPLES) + 1   //Not intended to be overriden

) (

  //--------------------- Ports -------------------------
  input                       acortex_clk,
  input                       acortex_rst_n,

  input                       fgyrus_clk,
  input                       fgyrus_rst_n,

  input                       lb_wr_en,
  input                       lb_rd_en,
  input   [LB_ADDR_W-1:0]     lb_addr,
  input   [LB_DATA_W-1:0]     lb_wr_data,
  output                      lb_wr_valid,
  output                      lb_rd_valid,
  output  [LB_DATA_W-1:0]     lb_rd_data,

  input   [NUM_MCLKS-1:0]     mclk_vec,

  output                      acortex2fgyrus_pcm_rdy,
  input   [MEM_ADDR_W-1:0]    fgyrus2acortex_addr,
  output  [31:0]              acortex2fgyrus_pcm_data,

  output                      scl,
  inout                       sda,

  input                       AUD_ADCDAT,
  output                      AUD_ADCLRCK,
  output                      AUD_BCLK,
  output                      AUD_DACDAT,
  output                      AUD_DACLRCK,
  output                      AUD_XCK

);

//----------------------- Local Parameters Declarations -------------------
  `include  "acortex_regmap.svh"

  `include  "lb_utils.svh"

  localparam  CHILD_LB_DATA_W = LB_DATA_W;
  localparam  CHILD_LB_ADDR_W = LB_ADDR_W - LB_ADDR_BLK_W;
  localparam  NUM_LB_CHILDREN = 3;


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------


//----------------------- Internal Wire Declarations ----------------------
  `drop_lb_splitter_wires(CHILD_LB_DATA_W,CHILD_LB_ADDR_W,NUM_LB_CHILDREN,lb_chld_,_w)

  wire                        adc_pcm_valid;
  wire  [31:0]                adc_lpcm_data;
  wire  [31:0]                adc_rpcm_data;

  wire                        dac_data_rdy;
  wire                        dac_pcm_nxt;
  wire  [31:0]                dac_lpcm_data;
  wire  [31:0]                dac_rpcm_data;

//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------


//----------------------- Start of Code -----------------------------------

  /*  Local Bus Logic */
  lb_splitter #(
    .LB_DATA_W         (LB_DATA_W),
    .LB_ADDR_W         (LB_ADDR_W),
    .LB_CHLD_ADDR_W    (CHILD_LB_ADDR_W),
    .NUM_CHILDREN      (NUM_LB_CHILDREN),
    .REGISTER_OUTPUTS  (0),
    .DEFAULT_DATA_VAL  ('hdeadbabe)

  ) lb_splitter_inst  (

    .clk                      (acortex_clk),
    .rst_n                    (acortex_rst_n),

    `drop_lb_ports(lb_,,lb_,)
    ,
    `drop_lb_ports(chld_lb_,,lb_chld_,_w)

  );


  /*  I2C Master  */
  i2c_master #(
    .LB_DATA_W                (CHILD_LB_DATA_W),
    .LB_ADDR_W                (CHILD_LB_ADDR_W),
    .CLK_DIV_CNT_W            (8),
    .I2C_MAX_DATA_BYTES       (4)

  )   i2c_master_inst  (

    .clk                      (acortex_clk),
    .rst_n                    (acortex_rst_n),

    `drop_lb_ports_split(ACORTEX_I2C_BLK_CODE,lb_,,lb_chld_,_w)
    ,

    .scl                      (scl),
    .sda                      (sda)

  );

  /*  SSM2603 Driver  */
  ssm2603_drvr #(
    .LB_DATA_W                (CHILD_LB_DATA_W),
    .LB_ADDR_W                (CHILD_LB_ADDR_W),
    .NUM_MCLKS                (NUM_MCLKS),
    .BCLK_CNTR_W              (8),
    .FS_CNTR_W                (16)

  ) ssm2603_drvr_inst (

    .clk                      (acortex_clk),
    .rst_n                    (acortex_rst_n),


    `drop_lb_ports_split(ACORTEX_DRVR_BLK_CODE,lb_,,lb_chld_,_w)
    ,

    .mclk_vec                 (mclk_vec),

    .adc_pcm_valid            (adc_pcm_valid),
    .adc_lpcm_data            (adc_lpcm_data),
    .adc_rpcm_data            (adc_rpcm_data),
                                            
    .dac_data_rdy             (dac_data_rdy),
    .dac_pcm_nxt              (dac_pcm_nxt  ),
    .dac_lpcm_data            (dac_lpcm_data),
    .dac_rpcm_data            (dac_rpcm_data),

    .AUD_ADCDAT               (AUD_ADCDAT ),
    .AUD_ADCLRCK              (AUD_ADCLRCK),
    .AUD_BCLK                 (AUD_BCLK   ),
    .AUD_DACDAT               (AUD_DACDAT ),
    .AUD_DACLRCK              (AUD_DACLRCK),
    .AUD_XCK                  (AUD_XCK    )

  );

  /*  PCM Buffer  */
  pcm_bffr #(
    .LB_DATA_W                (CHILD_LB_DATA_W),
    .LB_ADDR_W                (CHILD_LB_ADDR_W),
    .NUM_SAMPLES              (NUM_SAMPLES),
    .MEM_ADDR_W               (MEM_ADDR_W)

  ) pcm_bffr_inst (

    .acortex_clk              (acortex_clk),
    .acortex_rst_n            (acortex_rst_n),

    .fgyrus_clk               (fgyrus_clk),
    .fgyrus_rst_n             (fgyrus_rst_n),


    `drop_lb_ports_split(ACORTEX_PCM_BFFR_CLK_CODE,lb_,,lb_chld_,_w)
    ,

    .adc_pcm_valid            (adc_pcm_valid),
    .adc_lpcm_data            (adc_lpcm_data),
    .adc_rpcm_data            (adc_rpcm_data),

    .dac_data_rdy             (dac_data_rdy),
    .dac_pcm_nxt              (dac_pcm_nxt  ),
    .dac_lpcm_data            (dac_lpcm_data),
    .dac_rpcm_data            (dac_rpcm_data),

    .acortex2fgyrus_pcm_rdy   (acortex2fgyrus_pcm_rdy   ),
    .fgyrus2acortex_addr      (fgyrus2acortex_addr      ),
    .acortex2fgyrus_pcm_data  (acortex2fgyrus_pcm_data  )

  );


endmodule // acortex

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[02-11-2014  07:52:04 PM][mammenx] Fixed issues found in PCM Test

[14-10-2014  12:47:57 AM][mammenx] Fixed compilation errors & warnings

[13-10-2014  10:30:51 PM][mammenx] Modified LB logic to lb_splitter

[12-10-2014  10:02:19 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
