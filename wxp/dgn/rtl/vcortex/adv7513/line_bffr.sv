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
  parameter SYS_MEM_STOP_ADDR   = 921599
 
) (

  //--------------------- Ports -------------------------
  input                       clk,
  input                       clk_hdmi,
  input                       rst_n,

  input                       line_bffr_en;
  output  reg                 bffr_ovrflw,
  output  reg                 bffr_undrflw,

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
  localparam  BFFR_DEPTH      = 2**11;

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg   [PXL_NUM_CNTR_W-1:0]  pxl_cntr;

//----------------------- Internal Wire Declarations ----------------------
  wire                        bffr_rst_n;
  wire                        wrfull;
  wire  [10:0]                rdusedw;
  wire                        rdempty_sync;
  wire                        rdreq_sync;
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
      if~(line_bffr_en)
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
      bffr_undrflw            <=  0;
    end
    else
    begin
      bffr_ovrflw             <=  bffr_ovrflw   | (sys_mem_rd_valid & wrfull);
      bffr_undrflw            <=  bffr_undrflw  | (rdreq_sync & rdempty_sync);
    end
  end

  /*  Instantiate Buffer  */
  assign  bffr_rst_n          =   rst_n & line_bffr_en;
  assign  bffr_afull          =   (rdusedw  > (BFFR_DEPTH - 32))  ? 1'b1  : 1'b0;

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
    .rdusedw              (rdusedw),
    .wrfull               (wrfull),
    .wrusedw              ()
  );

  dd_sync                 rdfull_sync_inst
  (
    .clk                  (clk),
    .rst_n                (rst_n),

    .signal_id            (ff_empty),

    .signal_od            (rdempty_sync)
  );

  dd_sync                 rdreq_sync_inst
  (
    .clk                  (clk),
    .rst_n                (rst_n),

    .signal_id            (ff_rd_en),

    .signal_od            (rdreq_sync)
  );



endmodule // line_bffr

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[18-12-2014  08:51:48 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
