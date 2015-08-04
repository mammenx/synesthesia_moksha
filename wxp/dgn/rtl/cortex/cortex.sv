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
 -- Associated modules: lb_splitter, acortex, sys_mem_intf, vcortex
 -- Function          : This is the top module for Cortex acceleration
                        engine.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps

`include  "lb_utils.svh"
`include  "mem_utils.svh"

module cortex #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME       = "CORTEX",
  parameter LB_DATA_W         = 32,
  parameter LB_ADDR_W         = 16,
  parameter LB_ADDR_BLK_W     = 4,
  parameter NUM_AUD_SAMPLES   = 128,
  parameter SYS_MEM_DATA_W    = 32,
  parameter SYS_MEM_ADDR_W    = 27,
  parameter DEFAULT_DATA_VAL  = 'hdeadbabe

) (

  //--------------------- Ports -------------------------
    input                       clk,
    input                       rst_n,

    input                       clk_hdmi,
    input                       hdmi_rst_n,

    input                       cntrlr_clk,
    input                       cntrlr_rst_n,
    output                      cntrlr_sw_rst_n,

    input                       lb_wr_en,
    input                       lb_rd_en,
    input   [LB_ADDR_W-1:0]     lb_addr,
    input   [LB_DATA_W-1:0]     lb_wr_data,
    output                      lb_wr_valid,
    output                      lb_rd_valid,
    output  [LB_DATA_W-1:0]     lb_rd_data,

    output                      scl,
    inout                       sda,

    input                       sys_mem_cntrlr_rdy,
    output                      sys_mem_cntrlr_wren,
    output                      sys_mem_cntrlr_rden,
    output  [SYS_MEM_ADDR_W-1:0]sys_mem_cntrlr_addr,
    output  [SYS_MEM_DATA_W-1:0]sys_mem_cntrlr_wdata,
    input                       sys_mem_cntrlr_rd_valid,
    input   [SYS_MEM_DATA_W-1:0]sys_mem_cntrlr_rdata,

    input                       AUD_ADCDAT,
    output                      AUD_ADCLRCK,
    output                      AUD_BCLK,
    output                      AUD_DACDAT,
    output                      AUD_DACLRCK,

    output  [23:0]              HDMI_TX_D,
    output                      HDMI_TX_DE,
    output                      HDMI_TX_HS,
    input                       HDMI_TX_INT,
    output                      HDMI_TX_VS
);

//----------------------- Local Parameters Declarations -------------------
  `include  "cortex_regmap.svh"

  localparam  LB_CHLD_DATA_W      = LB_DATA_W;
  localparam  LB_CHLD_ADDR_W      = LB_ADDR_W - LB_ADDR_BLK_W;
  localparam  LB_CHLD_ADDR_BLK_W  = 4;
  localparam  NUM_LB_CHILDREN     = 5;
  localparam  NUM_RESETS          = NUM_LB_CHILDREN;
  localparam  PCM_MEM_DATA_W      = 32;
  localparam  PCM_MEM_ADDR_W      = $clog2(NUM_AUD_SAMPLES) + 1;
  localparam  FFT_SAMPLE_W        = 32;
  localparam  FFT_TWDL_W          = 10;
  localparam  NUM_SYS_MEM_AGENTS  = 2;
  localparam  SYS_MEM_VCORTEX_START_ADDR  = 0;
  localparam  SYS_MEM_VCORTEX_STOP_ADDR   = 921599;

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg                         cntrlr_rst_n_sync;

//----------------------- Internal Wire Declarations ----------------------

  `drop_lb_splitter_wires(LB_CHLD_DATA_W,LB_CHLD_ADDR_W,NUM_LB_CHILDREN,lb_chld_,_w)

  wire  [NUM_RESETS-1:0]      cortex_rst_vec;

  wire                        pcm_rdy_w/*synthesis keep*/;
  `drop_mem_wires(PCM_MEM_DATA_W,PCM_MEM_ADDR_W,pcm_,_w /*synthesis keep*/)

  wire  [NUM_SYS_MEM_AGENTS-1:0]  sys_mem_agent_wait_w;
  `drop_mem_wires_multi(SYS_MEM_DATA_W,SYS_MEM_ADDR_W,NUM_SYS_MEM_AGENTS,sys_mem_agent_,_w)


//----------------------- Internal Interface Declarations -----------------
  `ifdef  SIMULATION
    syn_pcm_mem_intf_mon#(PCM_MEM_DATA_W,PCM_MEM_ADDR_W,2)  pcm_mem_intf(clk,rst_n);

    syn_sys_mem_intf#(SYS_MEM_DATA_W,SYS_MEM_ADDR_W,NUM_SYS_MEM_AGENTS) sys_mem_agent_intf(clk,rst_n);
  `endif

//----------------------- FSM Declarations --------------------------------



//----------------------- Start of Code -----------------------------------

  /*  Synchronize sys_mem_controller reset for better reset recovery  */
  always@(posedge cntrlr_clk, negedge cntrlr_rst_n)
  begin
    if(~cntrlr_rst_n)
    begin
      cntrlr_rst_n_sync       <=  0;
    end
    else
    begin
      cntrlr_rst_n_sync       <=  1'b1;
    end
  end

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
    .NUM_RESETS       (NUM_RESETS),
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

    .acortex2fgyrus_pcm_rdy   (pcm_rdy_w),
    .fgyrus2acortex_rden      (pcm_rden_w),
    .fgyrus2acortex_addr      (pcm_addr_w),
    .acortex2fgyrus_pcm_data_valid  (pcm_rd_valid_w),
    .acortex2fgyrus_pcm_data  (pcm_rdata_w),

    .scl                      (scl),
    .sda                      (sda),

    .AUD_ADCDAT               (AUD_ADCDAT),
    .AUD_ADCLRCK              (AUD_ADCLRCK),
    .AUD_BCLK                 (AUD_BCLK),
    .AUD_DACDAT               (AUD_DACDAT),
    .AUD_DACLRCK              (AUD_DACLRCK)

  );

  /*  Instantiate Fgyrus  */
  fgyrus #(
    .LB_DATA_W           (LB_CHLD_DATA_W),
    .LB_ADDR_W           (LB_CHLD_ADDR_W),
    .PCM_MEM_DATA_W      (PCM_MEM_DATA_W),
    .PCM_MEM_ADDR_W      (PCM_MEM_ADDR_W),
    .NUM_SAMPLES         (NUM_AUD_SAMPLES),
    .SAMPLE_W            (FFT_SAMPLE_W),
    .TWDL_W              (FFT_TWDL_W)

  ) fgyrus_inst (
    .clk                 (clk),
    .rst_n               (cortex_rst_vec[FGYRUS_BLK]),

    `drop_lb_ports_split(FGYRUS_BLK,lb_, ,lb_chld_,_w)
    ,

    //PCM Buffer
    .pcm_rdy             (pcm_rdy_w),

    `drop_mem_ports(pcm_, ,pcm_,_w)

  );

  `ifdef  SIMULATION
      assign  pcm_mem_intf.pcm_data_rdy = pcm_rdy_w;
      assign  pcm_mem_intf.pcm_addr     = pcm_addr_w;
      assign  pcm_mem_intf.pcm_rden     = pcm_rden_w;
      assign  pcm_mem_intf.pcm_rdata    = pcm_rdata_w;
      assign  pcm_mem_intf.pcm_rd_valid = pcm_rd_valid_w;
  `endif

  /*  Instantiate System Memory Interface */
  sys_mem_intf #(
    .LB_DATA_W                (LB_CHLD_DATA_W),
    .LB_ADDR_W                (LB_CHLD_ADDR_W),
    .LB_ADDR_BLK_W            (LB_CHLD_ADDR_BLK_W),
    .MEM_DATA_W               (SYS_MEM_DATA_W),
    .MEM_ADDR_W               (SYS_MEM_ADDR_W),
    .NUM_AGENTS               (NUM_SYS_MEM_AGENTS),
    .REGISTER_CNTRLR_OUTPUTS  (0),
    .DEFAULT_DATA_VAL         (DEFAULT_DATA_VAL)

  ) sys_mem_intf_inst (

    .clk                      (clk),
    .rst_n                    (cortex_rst_vec[SYS_MEM_MNGR_BLK]),

    .cntrlr_clk               (cntrlr_clk),
    .cntrlr_rst_n             (cntrlr_rst_n),
    //.cntrlr_rst_n             (cntrlr_rst_n_sync),

    `drop_lb_ports_split(SYS_MEM_MNGR_BLK,lb_, ,lb_chld_,_w)
    ,

    .agent_wait              (sys_mem_agent_wait_w),
    `drop_mem_ports(agent_, ,sys_mem_agent_,_w)
    ,

    .cntrlr_rdy              (sys_mem_cntrlr_rdy),
    `drop_mem_ports(cntrlr_, ,sys_mem_cntrlr_, )

  );

  `ifdef  SIMULATION
    integer i;

    always@(*)
    begin
      for(i=0;  i<NUM_SYS_MEM_AGENTS; i++)
      begin
        sys_mem_agent_intf.mem_wait[i]      = sys_mem_agent_wait_w[i];
        sys_mem_agent_intf.mem_wren[i]      = sys_mem_agent_wren_w[i];
        sys_mem_agent_intf.mem_rden[i]      = sys_mem_agent_rden_w[i];
        sys_mem_agent_intf.mem_addr[i]      = sys_mem_agent_addr_w[i];
        sys_mem_agent_intf.mem_wdata[i]     = sys_mem_agent_wdata_w[i];
        sys_mem_agent_intf.mem_rd_valid[i]  = sys_mem_agent_rd_valid_w[i];
        sys_mem_agent_intf.mem_rdata[i]     = sys_mem_agent_rdata_w[i];
      end
    end

  `endif

  vcortex #(
    .LB_DATA_W            (LB_CHLD_DATA_W),
    .LB_ADDR_W            (LB_CHLD_ADDR_W),
    .LB_ADDR_BLK_W        (LB_CHLD_ADDR_BLK_W),
    .SYS_MEM_NUM_AGENTS   (NUM_SYS_MEM_AGENTS),
    .SYS_MEM_DATA_W       (SYS_MEM_DATA_W),
    .SYS_MEM_ADDR_W       (SYS_MEM_ADDR_W),
    .SYS_MEM_START_ADDR   (SYS_MEM_VCORTEX_START_ADDR),
    .SYS_MEM_STOP_ADDR    (SYS_MEM_VCORTEX_STOP_ADDR),
    .DEFAULT_REG_VAL      (DEFAULT_DATA_VAL)
   
  ) vcortex_inst  (

      .clk                (clk),
      .clk_hdmi           (clk_hdmi),
      .rst_n              (cortex_rst_vec[VCORTEX_BLK]),
      .hdmi_rst_n         (hdmi_rst_n),


      `drop_lb_ports_split(VCORTEX_BLK,lb_, ,lb_chld_,_w)
      ,

      .sys_mem_wait       (sys_mem_agent_wait_w),
      `drop_mem_ports(sys_mem_, ,sys_mem_agent_,_w)
      ,

      .HDMI_TX_D          (HDMI_TX_D),
      .HDMI_TX_DE         (HDMI_TX_DE),
      .HDMI_TX_HS         (HDMI_TX_HS),
      .HDMI_TX_INT        (HDMI_TX_INT),
      .HDMI_TX_VS         (HDMI_TX_VS)

  );

  assign  cntrlr_sw_rst_n   = cortex_rst_vec[SYS_MEM_DDR_SW_RST];


endmodule // cortex

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[11-01-2015  06:18:40 PM][mammenx] Converted system memory controller interface to seperate clock domain

[11-01-2015  01:07:10 PM][mammenx] Fixed misc issues found in simulation

[10-01-2015  11:49:47 AM][mammenx] Fixed Compilation Errors

[08-01-2015  08:01:08 PM][mammenx] Added Vcortex

[14-12-2014  07:55:45 PM][mammenx] Fixed misc compilation errors

[14-12-2014  07:41:11 PM][mammenx] Added sys_mem_intf

[11-11-2014  07:53:04 PM][mammenx] Fixed synthesis errors

[11-11-2014  07:52:04 PM][mammenx] Initial Version

 --------------------------------------------------------------------------
*/
