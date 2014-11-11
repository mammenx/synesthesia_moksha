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
 -- Component Name    : syn_acortex_tb_top
 -- Author            : mammenx
 -- Function          : TB top module which instantiates acortex DUT.
 --------------------------------------------------------------------------
*/


`ifndef __SYN_ACORTEX_TB_TOP
`define __SYN_ACORTEX_TB_TOP

  /////////////////////////////////////////////////////
  // Importing OVM Packages                          //
  /////////////////////////////////////////////////////

  `include "ovm.svh"
  import ovm_pkg::*;

  `timescale  1ns/100ps

  module syn_acortex_tb_top();

    parameter LB_DATA_W = 32;
    parameter LB_ADDR_W = 12;
    parameter PCM_MEM_DATA_W  = 32;
    parameter PCM_MEM_ADDR_W  = 8;


    `include  "acortex_tb.list"


    //Clock Reset signals
    logic   sys_clk_50;
    logic   sys_clk_100;
    logic   sys_rst;



    //Interfaces
    syn_lb_tb_intf#(LB_DATA_W,LB_ADDR_W) lb_tb_intf(sys_clk_100,sys_rst);

    syn_wm8731_intf                   wm8731_intf(sys_rst);

    syn_pcm_mem_intf_s#(PCM_MEM_DATA_W,PCM_MEM_ADDR_W,2)  pcm_mem_intf(sys_clk_100,sys_rst);


    /////////////////////////////////////////////////////
    // Clock, Reset Generation                         //
    /////////////////////////////////////////////////////
    initial
    begin
      sys_clk_50    = 1;

      #111;

      forever #10ns sys_clk_50  = ~sys_clk_50;
    end

    initial
    begin
      sys_clk_100   = 1;

      #100;

      forever #5ns sys_clk_100  = ~sys_clk_100;
    end

    initial
    begin
      sys_rst   = 1;

      #123;

      sys_rst   = 0;

      #321;

      sys_rst   = 1;

    end



    /*  DUT */
    acortex #(
      .LB_DATA_W      (LB_DATA_W),
      .LB_ADDR_W      (LB_ADDR_W),
      .LB_ADDR_BLK_W  (4),
      .NUM_MCLKS      (2),
      .NUM_SAMPLES    (128)

    ) acortex_inst  (

      .clk                        (sys_clk_100),
      .rst_n                      (sys_rst),

      .lb_wr_en                   (lb_tb_intf.wr_en   ),
      .lb_rd_en                   (lb_tb_intf.rd_en   ),
      .lb_addr                    (lb_tb_intf.addr    ),
      .lb_wr_data                 (lb_tb_intf.wr_data ),
      .lb_wr_valid                (lb_tb_intf.wr_valid),
      .lb_rd_valid                (lb_tb_intf.rd_valid),
      .lb_rd_data                 (lb_tb_intf.rd_data ),

      .mclk_vec                   (),

      .acortex2fgyrus_pcm_rdy     (pcm_mem_intf.pcm_data_rdy),
      .fgyrus2acortex_addr        (pcm_mem_intf.pcm_addr),
      .acortex2fgyrus_pcm_data    (pcm_mem_intf.pcm_rdata),

      .scl                        (wm8731_intf.scl),
      .sda                        (wm8731_intf.sda),

      .AUD_ADCDAT                 (wm8731_intf.adc_dat),
      .AUD_ADCLRCK                (wm8731_intf.adc_lrc),
      .AUD_BCLK                   (wm8731_intf.bclk),
      .AUD_DACDAT                 (wm8731_intf.dac_dat),
      .AUD_DACLRCK                (wm8731_intf.dac_lrc),
      .AUD_XCK                    (wm8731_intf.mclk)

    );



    initial
    begin
      #1;
      run_test();
    end

  endmodule

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[16-10-2014  09:47:25 PM][mammenx] Misc changes to fix issues found during syn_acortex_base_test

[16-10-2014  12:52:42 AM][mammenx] Fixed compilation errors

[15-10-2014  11:44:12 PM][mammenx] Initial Commit

 --------------------------------------------------------------------------
*/


