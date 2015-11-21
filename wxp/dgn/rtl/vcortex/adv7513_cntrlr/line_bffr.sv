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
 -- Module Name       : line_bffr
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module caches video pixel data from system
                        memory.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module line_bffr #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME         = "LINE_BFFR",
  parameter SYS_MEM_DATA_W      = 32,
  parameter SYS_MEM_ADDR_W      = 27,
  parameter SYS_MEM_START_ADDR  = 0,
  parameter SYS_MEM_STOP_ADDR   = 921599,
 
  parameter BFFR_DEPTH          = 2**11,
  parameter BFFR_USED_W         = $clog2(BFFR_DEPTH)

) (

  //--------------------- Ports -------------------------
  input                       clk,
  input                       clk_hdmi,
  input                       rst_n,
  input                       rst_hdmi_n,

  input                       line_bffr_en,
  output  reg                 bffr_ovrflw,
  output                      bffr_undrflw,
  output  [BFFR_USED_W-1:0]   bffr_occ,

  output                      ff_empty,
  output      [23:0]          ff_rdata,
  input                       ff_rd_en,

  input                       sys_mem_wait,
  output                      sys_mem_wren,
  output                      sys_mem_rden,
  output  [SYS_MEM_ADDR_W-1:0]sys_mem_addr,
  output  [SYS_MEM_DATA_W-1:0]sys_mem_wdata,
  input                       sys_mem_rd_valid,
  input   [SYS_MEM_DATA_W-1:0]sys_mem_rdata

);

//----------------------- Local Parameters Declarations -------------------
  localparam  PXL_NUM_CNTR_W  = $clog2(SYS_MEM_STOP_ADDR);

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg   [PXL_NUM_CNTR_W-1:0]  pxl_cntr;
  reg                         bffr_undrflw_int;

//----------------------- Internal Wire Declarations ----------------------
  wire                        bffr_rst_n;
  wire                        wrfull;
  wire  [BFFR_USED_W-1:0]     wrusedw;
  wire                        bffr_afull;

//----------------------- Internal Interface Declarations -----------------



//----------------------- Start of Code -----------------------------------

  /*  System Memory Logic */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      pxl_cntr                <=  SYS_MEM_START_ADDR;
    end
    else
    begin
      if(~line_bffr_en)
      begin
        pxl_cntr              <=  SYS_MEM_START_ADDR;
      end
      else if(~sys_mem_wait & sys_mem_rden)
      begin
        pxl_cntr              <=  (pxl_cntr ==  SYS_MEM_STOP_ADDR)  ? SYS_MEM_START_ADDR  : pxl_cntr  + 1'b1;
      end
    end
  end

  assign  sys_mem_wren        =   0;
  assign  sys_mem_rden        =   line_bffr_en  & ~bffr_afull;
  assign  sys_mem_addr        =   {{(SYS_MEM_ADDR_W-PXL_NUM_CNTR_W){1'b0}}, pxl_cntr};
  assign  sys_mem_wdata       =   0;

  /*  Monitor Buffer Status */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      bffr_ovrflw             <=  0;
    end
    else
    begin
      bffr_ovrflw             <=  bffr_ovrflw   | (sys_mem_rd_valid & wrfull);
    end
  end

  always@(posedge clk_hdmi,  negedge rst_hdmi_n)
  begin
    if(~rst_hdmi_n)
    begin
      bffr_undrflw_int        <=  0;
    end
    else
    begin
      bffr_undrflw_int        <=  bffr_undrflw_int  | (ff_rd_en & ff_empty);
    end
  end

  /*  Instantiate Buffer  */
  assign  bffr_rst_n          =   rst_n & line_bffr_en;
  assign  bffr_afull          =   (wrusedw  > (BFFR_DEPTH - 32))  ? 1'b1  : 1'b0;

  ff_24x2048_fwft_async   bffr_inst
  (
    .aclr                 (~bffr_rst_n),
    .data                 (sys_mem_rdata[23:0]),
    .rdclk                (clk_hdmi),
    .rdreq                (ff_rd_en),
    .wrclk                (clk),
    .wrreq                (sys_mem_rd_valid),
    .q                    (ff_rdata),
    .rdempty              (ff_empty),
    .rdusedw              (),
    .wrfull               (wrfull),
    .wrusedw              (wrusedw)
  );

  assign  bffr_occ  = wrusedw;

  dd_sync                 bffr_undrflw_sync_inst
  (
    .clk                  (clk),
    .rst_n                (rst_n),

    .signal_id            (bffr_undrflw_int),

    .signal_od            (bffr_undrflw)
  );



endmodule // line_bffr

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[10-01-2015  11:49:47 AM][mammenx] Fixed Compilation Errors

[18-12-2014  09:34:05 PM][mammenx] Moved to adv7513_cntrlr directory

[18-12-2014  08:51:48 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
