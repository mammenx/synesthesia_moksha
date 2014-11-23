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
 -- Project Code      : synesthesia_moksha
 -- Module Name       : fft_cache
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module maintains a ping-pong buffer to hold
                        FFT data that can be accessed by both Host & FSM.
 --------------------------------------------------------------------------
*/


`timescale 1ns / 10ps

`include  "fft_utils.svh"

module fft_cache #(
  parameter MODULE_NAME       = "FFT_CACHE",
  parameter SAMPLE_W          = 32,
  parameter BFFR_DATA_W       = 32,
  parameter BFFR_ADDR_W       = 8,
  parameter BFFR_RDELAY     = 2

) (
  //--------------------- Misc Ports (Logic)  -----------
  input                       clk,
  input                       rst_n,

  input   [SAMPLE_W-1:0]      cache_intf_wr_sample_re,
  input   [SAMPLE_W-1:0]      cache_intf_wr_sample_im,
  input                       cache_intf_wr_en,
  input   [BFFR_ADDR_W-1:0]   cache_intf_waddr,
  input   [BFFR_ADDR_W-1:0]   cache_intf_raddr,
  input                       cache_intf_rd_en,
  output  logic                     cache_intf_rd_valid,
  output  logic [SAMPLE_W-1:0]      cache_intf_rd_sample_re,
  output  logic [SAMPLE_W-1:0]      cache_intf_rd_sample_im,
  input                       cache_intf_fft_done,

  input   [BFFR_DATA_W-1:0]   cache_intf_hst_wdata,
  input                       cache_intf_hst_wren,
  input   [BFFR_ADDR_W-1:0]   cache_intf_hst_addr,
  input                       cache_intf_hst_rden,
  output  logic [BFFR_DATA_W-1:0]   cache_intf_hst_rdata,
  output  logic                     cache_intf_hst_rd_valid
 


  //--------------------- Interfaces --------------------


                );

//----------------------- Global parameters Declarations ------------------


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  logic                       hst_bffr_sel_f;

  logic [BFFR_RDELAY-1:0] fsm_rdel_vec_f;
  logic [BFFR_RDELAY-1:0] hst_rdel_vec_f;

//----------------------- Internal Wire Declarations ----------------------
  logic [BFFR_DATA_W-1:0]   fft_real_bffr0_wdata_c;
  logic [BFFR_ADDR_W-1:0]   fft_real_bffr0_raddr_c;
  logic [BFFR_ADDR_W-1:0]   fft_real_bffr0_waddr_c;
  logic                       fft_real_bffr0_wren_c;
  logic [BFFR_DATA_W-1:0]   fft_real_bffr0_rdata_w;

  logic [BFFR_DATA_W-1:0]   fft_real_bffr1_wdata_c;
  logic [BFFR_ADDR_W-1:0]   fft_real_bffr1_raddr_c;
  logic [BFFR_ADDR_W-1:0]   fft_real_bffr1_waddr_c;
  logic                       fft_real_bffr1_wren_c;
  logic [BFFR_DATA_W-1:0]   fft_real_bffr1_rdata_w;

  logic [BFFR_DATA_W-1:0]   fft_im_bffr_wdata_w;
  logic [BFFR_ADDR_W-1:0]   fft_im_bffr_raddr_w;
  logic [BFFR_ADDR_W-1:0]   fft_im_bffr_waddr_w;
  logic                       fft_im_bffr_wren_w;
  logic [BFFR_DATA_W-1:0]   fft_im_bffr_rdata_w;


//----------------------- Start of Code -----------------------------------

  always_ff@(posedge clk, negedge rst_n)
  begin : hst_bffr_sel_logic
    if(~rst_n)
    begin
      hst_bffr_sel_f          <=  0;
      fsm_rdel_vec_f          <=  0;
      hst_rdel_vec_f          <=  0;
    end
    else
    begin
      hst_bffr_sel_f          <=  cache_intf_fft_done ? ~hst_bffr_sel_f : hst_bffr_sel_f;

      fsm_rdel_vec_f          <=  {fsm_rdel_vec_f[BFFR_RDELAY-2:0],cache_intf_rd_en};
      hst_rdel_vec_f          <=  {hst_rdel_vec_f[BFFR_RDELAY-2:0],cache_intf_hst_rden};
    end
  end

  always_comb
  begin : fft_bffr_mux_logic
    fft_im_bffr_wdata_w       =   cache_intf_wr_sample_im;
    fft_im_bffr_raddr_w       =   cache_intf_raddr;
    fft_im_bffr_waddr_w       =   cache_intf_waddr;
    fft_im_bffr_wren_w        =   cache_intf_wr_en;
    cache_intf_rd_valid       =   fsm_rdel_vec_f[BFFR_RDELAY-1];
    cache_intf_rd_sample_im   =   fft_im_bffr_rdata_w;

    cache_intf_hst_rd_valid   =   hst_rdel_vec_f[BFFR_RDELAY-1];

    if(hst_bffr_sel_f)
    begin
      fft_real_bffr0_wdata_c  =   cache_intf_wr_sample_re;
      fft_real_bffr0_raddr_c  =   cache_intf_raddr;
      fft_real_bffr0_waddr_c  =   cache_intf_waddr;
      fft_real_bffr0_wren_c   =   cache_intf_wr_en;
      cache_intf_rd_sample_re =   fft_real_bffr0_rdata_w;

      fft_real_bffr1_wdata_c  =   cache_intf_hst_wdata;
      fft_real_bffr1_raddr_c  =   cache_intf_hst_addr;
      fft_real_bffr1_waddr_c  =   cache_intf_hst_addr;
      fft_real_bffr1_wren_c   =   cache_intf_hst_wren;
      cache_intf_hst_rdata  =   fft_real_bffr1_rdata_w;
    end
    else
    begin
      fft_real_bffr1_wdata_c  =   cache_intf_wr_sample_re;
      fft_real_bffr1_raddr_c  =   cache_intf_raddr;
      fft_real_bffr1_waddr_c  =   cache_intf_waddr;
      fft_real_bffr1_wren_c   =   cache_intf_wr_en;
      cache_intf_rd_sample_re =   fft_real_bffr1_rdata_w;

      fft_real_bffr0_wdata_c  =   cache_intf_hst_wdata;
      fft_real_bffr0_raddr_c  =   cache_intf_hst_addr;
      fft_real_bffr0_waddr_c  =   cache_intf_hst_addr;
      fft_real_bffr0_wren_c   =   cache_intf_hst_wren;
      cache_intf_hst_rdata  =   fft_real_bffr0_rdata_w;
    end
  end

  sync_dpram_32W_256D   fft_real_bffr0_inst
  (
    .clock              (clk),
    .data               (fft_real_bffr0_wdata_c),
    .rdaddress          (fft_real_bffr0_raddr_c),
    .wraddress          (fft_real_bffr0_waddr_c),
    .wren               (fft_real_bffr0_wren_c),
    .q                  (fft_real_bffr0_rdata_w)
  );

  sync_dpram_32W_256D   fft_real_bffr1_inst
  (
    .clock              (clk),
    .data               (fft_real_bffr1_wdata_c),
    .rdaddress          (fft_real_bffr1_raddr_c),
    .wraddress          (fft_real_bffr1_waddr_c),
    .wren               (fft_real_bffr1_wren_c),
    .q                  (fft_real_bffr1_rdata_w)
  );

  sync_dpram_32W_256D   fft_im_bffr_inst
  (
    .clock              (clk),
    .data               (fft_im_bffr_wdata_w),
    .rdaddress          (fft_im_bffr_raddr_w),
    .wraddress          (fft_im_bffr_waddr_w),
    .wren               (fft_im_bffr_wren_w),
    .q                  (fft_im_bffr_rdata_w)
  );

endmodule // fft_cache


/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

 --------------------------------------------------------------------------
*/

