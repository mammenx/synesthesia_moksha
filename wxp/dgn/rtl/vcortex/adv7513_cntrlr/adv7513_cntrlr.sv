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
 -- Module Name       : adv7513_cntrlr
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module holds logic for interfacing with the
                        ADV7513 HDMI Transceiver.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps

`include  "ff_utils.svh"
`include  "mem_utils.svh"

module adv7513_cntrlr #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME         = "ADV7513_CNTRLR",
  parameter LB_DATA_W           = 32,
  parameter LB_ADDR_W           = 8,
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
  output  reg                 lb_wr_valid,
  output  reg                 lb_rd_valid,
  output  reg [LB_DATA_W-1:0] lb_rd_data,

  input                       sys_mem_wait,
  output                      sys_mem_wren,
  output                      sys_mem_rden,
  output  [SYS_MEM_ADDR_W-1:0]sys_mem_addr,
  output  [SYS_MEM_DATA_W-1:0]sys_mem_wdata,
  input                       sys_mem_rd_valid,
  input   [SYS_MEM_DATA_W-1:0]sys_mem_rdata,

  output  [23:0]              HDMI_TX_D,
  output                      HDMI_TX_DE,
  output                      HDMI_TX_HS,
  output                      HDMI_TX_VS

);

//----------------------- Local Parameters Declarations -------------------
  `include  "adv7513_cntrlr_regmap.svh"

  localparam  LBFFR_DEPTH   = 2**11;
  localparam  LBFFR_USED_W  = $clog2(LBFFR_DEPTH);

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg                         line_bffr_en;
  reg                         drvr_en;

//----------------------- Internal Wire Declarations ----------------------
  `drop_ff_rd_wires(24,bffr_,_w)

  wire                        bffr_ovrflw;
  wire                        bffr_undrflw;

  wire  [LBFFR_USED_W-1:0]    bffr_occ;

//----------------------- Start of Code -----------------------------------

  /*  Local Bus Logic */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      lb_wr_valid             <=  0;
      lb_rd_valid             <=  0;
      lb_rd_data              <=  0;

      line_bffr_en            <=  0;
      drvr_en                 <=  0;
    end
    else
    begin
      if(lb_wr_en)
      begin
        case(lb_addr)

          ADV7513_CNTRLR_CONFIG_REG :
          begin
            line_bffr_en      <=  lb_wr_data[0];
            drvr_en           <=  lb_wr_data[1];
          end

        endcase
      end

      lb_wr_valid             <=  lb_wr_en;

      if(lb_rd_en)
      begin
        case(lb_addr)

          ADV7513_CNTRLR_CONFIG_REG :
          begin
            lb_rd_data        <=  {{(LB_DATA_W-2){1'b0}}, drvr_en,  line_bffr_en};
          end

          ADV7513_CNTRLR_STATUS_REG :
          begin
            lb_rd_data        <=  {{(LB_DATA_W-2){1'b0}}, bffr_undrflw, bffr_ovrflw};
          end

          ADV7513_CNTRLR_LBFFR_OCC_REG:
          begin
            lb_rd_data        <=  {{(LB_DATA_W-LB_DATA_W){1'b0}}, bffr_occ};
          end

          default :
          begin
            lb_rd_data        <=  DEFAULT_REG_VAL;
          end

        endcase
      end

      lb_rd_valid             <=  lb_rd_en;
    end
  end


  /*  Instantiate Line  Buffer  */
  line_bffr #(
    .SYS_MEM_DATA_W      (32),
    .SYS_MEM_ADDR_W      (27),
    .SYS_MEM_START_ADDR  (0),
    .SYS_MEM_STOP_ADDR   (921599),

    .BFFR_DEPTH          (LBFFR_DEPTH)

  ) line_bffr_inst  (

    .clk                (clk),
    .clk_hdmi           (clk_hdmi),
    .rst_n              (rst_n),
    .rst_hdmi_n         (hdmi_rst_n),

    .line_bffr_en       (line_bffr_en),
    .bffr_ovrflw        (bffr_ovrflw),
    .bffr_undrflw       (bffr_undrflw),
    .bffr_occ           (bffr_occ),

    `drop_ff_rd_ports(ff_, ,bffr_,_w)
    ,

    .sys_mem_wait       (sys_mem_wait),
    `drop_mem_ports     (sys_mem_, ,sys_mem_, )

  );


  /*  Instantiate Video Driver  */
  adv7513_video_drvr #(
    .SYNC_ACTIVE_HIGH_N_LOW  (0),

    //HD 720p paramters
    .HVALID_W        (1280),
    .HFP_W           (110),
    .HSYNC_W         (40),
    .HBP_W           (220),

    .VVALID_W        (720),
    .VFP_W           (5),
    .VSYNC_W         (5),
    .VBP_W           (20)

  ) video_drvr_inst (

    .clk            (clk_hdmi),
    .rst_n          (hdmi_rst_n),

    .drvr_en        (drvr_en),

    `drop_ff_rd_ports(ff_, ,bffr_,_w)
    ,

    .HDMI_TX_D      (HDMI_TX_D  ),
    .HDMI_TX_DE     (HDMI_TX_DE ),
    .HDMI_TX_HS     (HDMI_TX_HS ),
    .HDMI_TX_VS     (HDMI_TX_VS )

  );



endmodule // adv7513_cntrlr

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[10-01-2015  11:49:47 AM][mammenx] Fixed Compilation Errors

[18-12-2014  09:34:05 PM][mammenx] Moved to adv7513_cntrlr directory

[18-12-2014  09:32:17 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
