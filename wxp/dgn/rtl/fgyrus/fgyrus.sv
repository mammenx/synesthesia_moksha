/*
 --------------------------------------------------------------------------
   Synethesia-Moksha - Copyright (C) 2012 Gregory Matthew James.

   This file is part of Synethesia-Moksha.

   Synethesia-Moksha is free; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   Synethesia-Moksha is distributed in the hope that it will be useful,
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
 -- Module Name       : fgyrus
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : Top level Fusiform Gyrus.
 --------------------------------------------------------------------------
*/


`timescale 1ns / 10ps

`include  "lb_utils.svh"
`include  "fft_utils.svh"
`include  "mem_utils.svh"

module fgyrus #(
  parameter MODULE_NAME         = "FGYRUS",
  parameter LB_DATA_W           = 32,
  parameter LB_ADDR_W           = 12,
  parameter PCM_MEM_DATA_W      = 32,
  parameter PCM_MEM_ADDR_W      = 8,
  parameter NUM_SAMPLES         = 128,
  parameter SAMPLE_W            = 32,
  parameter TWDL_W              = 10,
  parameter MEM_RD_DEL          = 2

) (
  //--------------------- Misc Ports (Logic)  -----------
  input                       clk,
  input                       rst_n,

  //Local Bus
  input                       lb_wr_en,
  input                       lb_rd_en,
  input   [LB_ADDR_W-1:0]     lb_addr,
  input   [LB_DATA_W-1:0]     lb_wr_data,
  output                      lb_wr_valid,
  output                      lb_rd_valid,
  output  [LB_DATA_W-1:0]     lb_rd_data,

  //PCM Buffer
  input                         pcm_rdy,

  output  [PCM_MEM_ADDR_W-1:0]  pcm_addr,
  output  [PCM_MEM_DATA_W-1:0]  pcm_wdata,
  output                        pcm_wren,
  output                        pcm_rden,
  input   [PCM_MEM_DATA_W-1:0]  pcm_rdata,
  input                         pcm_rd_valid

  );

//----------------------- Global parameters Declarations ------------------
  localparam  WIN_RAM_DATA_W      = 32;
  localparam  WIN_RAM_ADDR_W      = 7;
  localparam  TWDL_RAM_DATA_W     = 32;
  localparam  TWDL_RAM_ADDR_W     = 7;
  localparam  CORDIC_RAM_DATA_W   = 16;
  localparam  CORDIC_RAM_ADDR_W   = 8;
  localparam  FFT_CACHE_DATA_W    = 32;
  localparam  FFT_CACHE_ADDR_W    = 8;
  localparam  DIV_W               = 32;
  localparam  BUT_DEL             = 4;


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  logic [MEM_RD_DEL-1:0]    win_ram_rdel_vec_f;
  logic [MEM_RD_DEL-1:0]    twdl_ram_rdel_vec_f;
  logic [MEM_RD_DEL-1:0]    cordic_ram_rdel_vec_f;

//----------------------- Internal Wire Declarations ----------------------


//----------------------- Internal Interface Declarations -----------------
  `drop_complex_set(wire,SAMPLE_W,sample_a_,_w)
  `drop_complex_set(wire,SAMPLE_W,sample_b_,_w)
  `drop_complex_set(wire,TWDL_W,twdl_,_w)
  wire                      sample_rdy_w;

  `drop_complex_set(wire,SAMPLE_W,res_,_w)
  wire                      res_rdy;

  wire                      bffr_ovrflw;
  wire                      bffr_underflw;

  `drop_fft_cache_data_intf_set(wire,SAMPLE_W,FFT_CACHE_DATA_W,FFT_CACHE_ADDR_W,cache_intf_,_w)

  `drop_mem_wires(FFT_CACHE_DATA_W,FFT_CACHE_ADDR_W,cache_intf_hst_,_w)

  `drop_mem_wires(WIN_RAM_DATA_W,WIN_RAM_ADDR_W,win_ram_,_w)

  `drop_mem_wires(TWDL_RAM_DATA_W,TWDL_RAM_ADDR_W,twdl_ram_,_w)

  `drop_mem_wires(CORDIC_RAM_DATA_W,CORDIC_RAM_ADDR_W,cordic_ram_,_w)


//----------------------- Start of Code -----------------------------------


  always_ff@(posedge clk, negedge rst_n)
  begin : rd_rdy_logic
    if(~rst_n)
    begin
      win_ram_rdel_vec_f      <=  0;
      twdl_ram_rdel_vec_f     <=  0;
      cordic_ram_rdel_vec_f   <=  0;
    end
    else
    begin
      win_ram_rdel_vec_f      <=  {win_ram_rdel_vec_f[MEM_RD_DEL-2:0],  win_ram_rden_w};
      twdl_ram_rdel_vec_f     <=  {twdl_ram_rdel_vec_f[MEM_RD_DEL-2:0], twdl_ram_rden_w};
      cordic_ram_rdel_vec_f   <=  {cordic_ram_rdel_vec_f[MEM_RD_DEL-2:0], cordic_ram_rden_w};
    end
  end

  assign  win_ram_rd_valid_w     = win_ram_rdel_vec_f[MEM_RD_DEL-1];
  assign  twdl_ram_rd_valid_w    = twdl_ram_rdel_vec_f[MEM_RD_DEL-1];
  assign  cordic_ram_rd_valid_w  = cordic_ram_rdel_vec_f[MEM_RD_DEL-1];


  fgyrus_fsm #(
    .LB_DATA_W           (LB_DATA_W),
    .LB_ADDR_W           (LB_ADDR_W),
    .NUM_SAMPLES         (NUM_SAMPLES),
    .SAMPLE_W            (SAMPLE_W),
    .TWDL_W              (TWDL_W),
    .PCM_MEM_DATA_W      (PCM_MEM_DATA_W),
    .PCM_MEM_ADDR_W      (PCM_MEM_ADDR_W),
    .WIN_RAM_DATA_W      (WIN_RAM_DATA_W),
    .WIN_RAM_ADDR_W      (WIN_RAM_ADDR_W),
    .TWDL_RAM_DATA_W     (TWDL_RAM_DATA_W),
    .TWDL_RAM_ADDR_W     (TWDL_RAM_ADDR_W),
    .CORDIC_RAM_DATA_W   (CORDIC_RAM_DATA_W),
    .CORDIC_RAM_ADDR_W   (CORDIC_RAM_ADDR_W),
    .FFT_CACHE_DATA_W    (FFT_CACHE_DATA_W),
    .FFT_CACHE_ADDR_W    (FFT_CACHE_ADDR_W),
    .DIV_W               (DIV_W),
    .MEM_RD_DEL          (MEM_RD_DEL),
    .BUT_DEL             (BUT_DEL)

  ) fgyrus_fsm_inst (
     .clk                (clk)
    ,.rst_n              (rst_n)

    //Local Bus
    ,`drop_lb_ports(lb_, ,lb_, )

    //Butterfly Wing
    ,`drop_complex_ports(sample_a_, ,sample_a_,_w)
    ,`drop_complex_ports(sample_b_, ,sample_b_,_w)
    ,`drop_complex_ports(twdl_, ,twdl_,_w)
    ,.sample_rdy        (sample_rdy_w)

    ,`drop_complex_ports(res_, ,res_,_w)
    ,.res_rdy           (res_rdy)

    ,.bffr_ovrflw       (bffr_ovrflw)
    ,.bffr_underflw     (bffr_underflw)

    //PCM Buffer
    ,.pcm_rdy           (pcm_rdy)

    ,`drop_mem_ports(pcm_, ,pcm_, )

    //Window RAM
    ,`drop_mem_ports(win_ram_, ,win_ram_,_w)

    //Twiddle RAM
    ,`drop_mem_ports(twdl_ram_, ,twdl_ram_,_w)

    //CORDIC RAM
    ,`drop_mem_ports(cordic_ram_, ,cordic_ram_,_w)

    //FFT Cache
    ,`drop_fft_cache_data_intf_ports(cache_intf_, ,cache_intf_,_w)

    ,`drop_mem_ports(cache_intf_hst_, ,cache_intf_hst_,_w)

  );

  but_wing  #(
    .SAMPLE_W           (SAMPLE_W),
    .TWDL_W             (TWDL_W)

  ) but_wing_inst (

     .clk               (clk)
    ,.rst_n             (rst_n)

    ,`drop_complex_ports(sample_a_, ,sample_a_,_w)
    ,`drop_complex_ports(sample_b_, ,sample_b_,_w)
    ,`drop_complex_ports(twdl_, ,twdl_,_w)
    ,.sample_rdy        (sample_rdy_w)

    ,`drop_complex_ports(res_, ,res_,_w)
    ,.res_rdy           (res_rdy)

    ,.bffr_ovrflw       (bffr_ovrflw)
    ,.bffr_underflw     (bffr_underflw)

  );

  fft_cache #(
    .SAMPLE_W           (SAMPLE_W),
    .BFFR_DATA_W        (FFT_CACHE_DATA_W),
    .BFFR_ADDR_W        (FFT_CACHE_ADDR_W),
    .BFFR_RDELAY        (MEM_RD_DEL)
  
  ) fft_cache_inst  (

     .clk               (clk)
    ,.rst_n             (rst_n)

    ,`drop_fft_cache_data_intf_ports(cache_intf_, ,cache_intf_,_w)

    ,`drop_mem_ports(cache_intf_hst_, ,cache_intf_hst_,_w)

  );

  win_ram       win_ram_inst
  (
    .clock      (clk),
    .data       (win_ram_wdata_w),
    .rdaddress  (win_ram_addr_w),
    .wraddress  (win_ram_addr_w),
    .wren       (win_ram_wren_w),
    .q          (win_ram_rdata_w)
  );

  cordic_ram    cordic_ram_inst
  (
    .clock      (clk),
    .data       (cordic_ram_wdata_w),
    .rdaddress  (cordic_ram_addr_w),
    .wraddress  (cordic_ram_addr_w),
    .wren       (cordic_ram_wren_w),
    .q          (cordic_ram_rdata_w)
  );

  twiddle_ram   twiddle_ram_inst
  (
    .clock      (clk),
    .data       (twdl_ram_wdata_w),
    .rdaddress  (twdl_ram_addr_w),
    .wraddress  (twdl_ram_addr_w),
    .wren       (twdl_ram_wren_w),
    .q          (twdl_ram_rdata_w)
  );

endmodule // fgyrus


/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

 --------------------------------------------------------------------------
*/

