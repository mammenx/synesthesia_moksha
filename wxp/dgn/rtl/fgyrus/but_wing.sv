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
 -- Module Name       : but_wing
 -- Author            : mammenx
 -- Associated modules: complex_mult
 -- Function          : This block implements a simple FFT butterfly, which
                        accepts two input samples & twiddle factor.
 --------------------------------------------------------------------------
*/


`timescale 1ns / 10ps

`include  "fft_utils.svh"

module but_wing #(
  parameter MODULE_NAME       = "BUT_WING",
  parameter SAMPLE_W          = 32,
  parameter TWDL_W            = 10,
  parameter P_MUL_LAT         = 3,  //Multiplier latency
  parameter MUL_RES_DATA_W = 42

) (

  input                       clk,
  input                       rst_n,

  input   [SAMPLE_W-1:0]      sample_a_re,
  input   [SAMPLE_W-1:0]      sample_a_im,
  input   [SAMPLE_W-1:0]      sample_b_re,
  input   [SAMPLE_W-1:0]      sample_b_im,
  input   [TWDL_W-1:0]        twdl_re,
  input   [TWDL_W-1:0]        twdl_im,
  input                       sample_rdy,

  output  reg [SAMPLE_W-1:0]  res_re,
  output  reg [SAMPLE_W-1:0]  res_im,
  output  reg                 res_rdy,

  output                      bffr_ovrflw,
  output                      bffr_underflw

);

//----------------------- Global parameters Declarations ------------------
  localparam  P_PST_W         = P_MUL_LAT + 2;
  localparam  P_DIV           = TWDL_W  - 2;

//----------------------- Input Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  logic   [P_PST_W-1:0]       pst_vec_f;

  logic   [SAMPLE_W:0]  mul_res_norm_im_f;
  logic   [SAMPLE_W:0]  mul_res_norm_real_f;
  logic   [SAMPLE_W:0]  mul_res_inv_im_f;
  logic   [SAMPLE_W:0]  mul_res_inv_real_f;

//----------------------- Internal Wire Declarations ----------------------
  logic   [MUL_RES_DATA_W-1:0]     mul_res_im_w;
  logic   [MUL_RES_DATA_W-1:0]     mul_res_real_w;

  logic   [MUL_RES_DATA_W-1:0]     mul_res_norm_im_w;
  logic   [MUL_RES_DATA_W-1:0]     mul_res_norm_real_w;

  logic   [SAMPLE_W:0]       mul_res_inv_im_c;
  logic   [SAMPLE_W:0]       mul_res_inv_real_c;

  logic   [SAMPLE_W+1:0]     data_0_real_c;
  logic   [SAMPLE_W+1:0]     data_0_im_c;
  logic   [SAMPLE_W+1:0]     data_1_real_c;
  logic   [SAMPLE_W+1:0]     data_1_im_c;

  logic   [(SAMPLE_W*2)-1:0] bffr_rd_data_w;
  logic   [(SAMPLE_W*2)-1:0] bffr_wr_data_w;
  `drop_complex_set(reg,SAMPLE_W,bffr_sample_a_,_w)
  logic                            bffr_full_w;
  logic                            bffr_empty_w;


//----------------------- Start of Code -----------------------------------

  /*
    *               Butterfly Structure
    *
    *              +------+                           +---+
    * sample_a  ---|buffer|-------------------------->| + |--------------->
    *              +------+                   \   /   +---+   data_0_out
    *                                          \ /
    *                                           X
    *                               +----------/ \
    *                              /              \
    *               +---+         /       +----+   \
    *               | m |        /        |    |    \ +---+   data_1_out
    * sample_b  --->| u |---------------->| -1 |----->| + |--------------->
    *               | l |                 |    |      +---+
    * twiddle   --->| t |                 +----+
    *               +---+
    *
  */

  /*
    * PST vector generation logic
  */
  always_ff@(posedge clk, negedge rst_n)
  begin : pst_vec_logic
    if(~rst_n)
    begin
      pst_vec_f               <=  {P_PST_W{1'b0}};
    end
    else
    begin
      pst_vec_f[0]            <=  sample_rdy;

      pst_vec_f[P_PST_W-1:1]  <=  pst_vec_f[P_PST_W-2:0]; //shift register
    end
  end

  //Normalize the multiplier output - division
  assign  mul_res_norm_im_w   =   {{P_DIV{mul_res_im_w[MUL_RES_DATA_W-1]}},    mul_res_im_w[MUL_RES_DATA_W-1:P_DIV]};
  assign  mul_res_norm_real_w =   {{P_DIV{mul_res_real_w[MUL_RES_DATA_W-1]}},  mul_res_real_w[MUL_RES_DATA_W-1:P_DIV]};

  //Calculating negative value of multiplier output - 2's compliment
  assign  mul_res_inv_im_c    =   ~mul_res_norm_im_w[SAMPLE_W:0]   + 1'b1;
  assign  mul_res_inv_real_c  =   ~mul_res_norm_real_w[SAMPLE_W:0] + 1'b1;

  /*
    * Intermediate Stage
  */
  always_ff@(posedge clk, negedge rst_n)
  begin : pipe_stage1_logic
    if(~rst_n)
    begin
      mul_res_norm_im_f       <=  {SAMPLE_W+1{1'b0}};
      mul_res_norm_real_f     <=  {SAMPLE_W+1{1'b0}};
      mul_res_inv_im_f        <=  {SAMPLE_W+1{1'b0}};
      mul_res_inv_real_f      <=  {SAMPLE_W+1{1'b0}};
    end
    else
    begin
      mul_res_norm_im_f       <=  pst_vec_f[P_MUL_LAT-1]  ? mul_res_norm_im_w[SAMPLE_W:0] : mul_res_norm_im_f;
      mul_res_norm_real_f     <=  pst_vec_f[P_MUL_LAT-1]  ? mul_res_norm_real_w[SAMPLE_W:0] : mul_res_norm_real_f;
      mul_res_inv_im_f        <=  pst_vec_f[P_MUL_LAT-1]  ? mul_res_inv_im_c  : mul_res_inv_im_f;
      mul_res_inv_real_f      <=  pst_vec_f[P_MUL_LAT-1]  ? mul_res_inv_real_c  : mul_res_inv_real_f;
    end
  end

  //Final Stage sum
  assign  data_0_real_c = {{2{bffr_sample_a_re_w[SAMPLE_W-1]}},bffr_sample_a_re_w}  + {{2{mul_res_norm_real_f[SAMPLE_W]}},mul_res_norm_real_f[SAMPLE_W-1:0]};
  assign  data_0_im_c   = {{2{bffr_sample_a_im_w[SAMPLE_W-1]}},bffr_sample_a_im_w}  + {{2{mul_res_norm_im_f[SAMPLE_W]}},mul_res_norm_im_f[SAMPLE_W-1:0]};
  assign  data_1_real_c = {{2{bffr_sample_a_re_w[SAMPLE_W-1]}},bffr_sample_a_re_w}  + {{2{mul_res_inv_real_f[SAMPLE_W]}},mul_res_inv_real_f[SAMPLE_W-1:0]};
  assign  data_1_im_c   = {{2{bffr_sample_a_im_w[SAMPLE_W-1]}},bffr_sample_a_im_w}  + {{2{mul_res_inv_im_f[SAMPLE_W]}},mul_res_inv_im_f[SAMPLE_W-1:0]};


  /*
    * Output Data Muxing Logic
    * data_0 will come first followed data_1
  */
  always_ff@(posedge clk, negedge rst_n)
  begin : output_logic
    if(~rst_n)
    begin
      res_re         <=  {SAMPLE_W{1'b0}};
      res_im         <=  {SAMPLE_W{1'b0}};
      res_rdy        <=  1'b0;
    end
    else
    begin
      if(pst_vec_f[P_MUL_LAT])
      begin
        res_re       <=  data_0_real_c[SAMPLE_W-1:0];
        res_im       <=  data_0_im_c[SAMPLE_W-1:0];
      end
      else if(pst_vec_f[P_MUL_LAT+1])
      begin
        res_re       <=  data_1_real_c[SAMPLE_W-1:0];
        res_im       <=  data_1_im_c[SAMPLE_W-1:0];
      end

      res_rdy        <=  |(pst_vec_f[P_MUL_LAT+1:P_MUL_LAT]);
    end
  end

  /*
    * Instantiating Multiplier
  */
  complex_mult    complex_mult_inst
  (
	  .aclr         (~rst_n),  //active high port
	  .clock        (clk),
	  .dataa_imag   (sample_b_im),
	  .dataa_real   (sample_b_re),
	  .datab_imag   (twdl_im),
	  .datab_real   (twdl_re),
	  .result_imag  (mul_res_im_w),
	  .result_real  (mul_res_real_w)
  );


  /*
    * Instantiating Fifo
  */
  ff_64x256_fwft  buffer_inst
  (
	  .aclr         (~rst_n),
	  .clock        (clk),
	  .data         (bffr_wr_data_w),
	  .rdreq        (pst_vec_f[P_MUL_LAT+1]),
	  .wrreq        (sample_rdy),
	  .empty        (bffr_empty_w),
	  .full         (bffr_full_w),
	  .q            (bffr_rd_data_w),
	  .usedw        ()
  );

  assign  bffr_wr_data_w      = {sample_a_re,  sample_a_im};

  assign  bffr_sample_a_re_w = bffr_rd_data_w[(SAMPLE_W*2)-1:SAMPLE_W];
  assign  bffr_sample_a_im_w = bffr_rd_data_w[SAMPLE_W-1:0];

  //Generate Over/Under flow conditions
  assign  bffr_ovrflw    = sample_rdy & bffr_full_w;
  assign  bffr_underflw  = pst_vec_f[P_MUL_LAT]  & bffr_empty_w;

endmodule // but_wing

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

 --------------------------------------------------------------------------
*/

