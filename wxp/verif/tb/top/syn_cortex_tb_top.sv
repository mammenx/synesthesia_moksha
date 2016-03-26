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
 -- Component Name    : syn_cortex_tb_top
 -- Author            : mammenx
 -- Function          : TB top module which instantiates cortex DUT.
 --------------------------------------------------------------------------
*/


`ifndef __SYN_CORTEX_TB_TOP
`define __SYN_CORTEX_TB_TOP

  /////////////////////////////////////////////////////
  // Importing OVM Packages                          //
  /////////////////////////////////////////////////////

  `include "ovm.svh"
  import ovm_pkg::*;

  `timescale  1ns/100ps

  module syn_cortex_tb_top();

    parameter LB_DATA_W = 32;
    parameter LB_ADDR_W = 16;
    parameter PCM_MEM_DATA_W  = 32;
    parameter PCM_MEM_ADDR_W  = 8;
    parameter SYS_MEM_DATA_W  = 32;
    parameter SYS_MEM_ADDR_W  = 27;


    `include  "cortex_tb.list"


    //Clock Reset signals
    logic   sys_clk_50;
    logic   sys_clk_100;
    logic   sys_clk_150;
    logic   hdmi_clk_74_25;
    logic   sys_rst;



    //Interfaces
    syn_lb_tb_intf#(LB_DATA_W,LB_ADDR_W) lb_tb_intf(sys_clk_100,sys_rst);

    syn_wm8731_intf                   wm8731_intf(sys_rst);

    syn_sys_mem_intf#(SYS_MEM_DATA_W,SYS_MEM_ADDR_W,1)  sys_mem_intf(sys_clk_150,sys_rst);


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
      sys_clk_150   = 1;

      #100;

      forever #3.33ns sys_clk_150  = ~sys_clk_150;
    end


    initial
    begin
      hdmi_clk_74_25  = 1;

      #100;

      forever #13ns hdmi_clk_74_25 = ~hdmi_clk_74_25;
    end

    initial
    begin
      sys_rst   = 1;

      #123;

      sys_rst   = 0;

      #321;

      sys_rst   = 1;

    end


    tri0  sda_debug;


    /*  DUT */
    cortex #(
      .LB_DATA_W        (LB_DATA_W),
      .LB_ADDR_W        (LB_ADDR_W),
      .LB_ADDR_BLK_W    (4),
      .NUM_AUD_SAMPLES  (128),
      .SYS_MEM_DATA_W   (SYS_MEM_DATA_W),
      .SYS_MEM_ADDR_W   (SYS_MEM_ADDR_W)

    ) cortex_inst  (

      .clk                        (sys_clk_100),
      .rst_n                      (sys_rst),

      .clk_hdmi                   (hdmi_clk_74_25),
      .hdmi_rst_n                 (sys_rst),

      .cntrlr_clk                 (sys_clk_150),
      .cntrlr_rst_n               (sys_rst),

      .lb_wr_en                   (lb_tb_intf.wr_en   ),
      .lb_rd_en                   (lb_tb_intf.rd_en   ),
      .lb_addr                    (lb_tb_intf.addr    ),
      .lb_wr_data                 (lb_tb_intf.wr_data ),
      .lb_wr_valid                (lb_tb_intf.wr_valid),
      .lb_rd_valid                (lb_tb_intf.rd_valid),
      .lb_rd_data                 (lb_tb_intf.rd_data ),

      .sys_mem_cntrlr_rdy         (~sys_mem_intf.mem_wait    ),
      .sys_mem_cntrlr_wren        (sys_mem_intf.mem_wren     ),
      .sys_mem_cntrlr_rden        (sys_mem_intf.mem_rden     ),
      .sys_mem_cntrlr_addr        (sys_mem_intf.mem_addr     ),
      .sys_mem_cntrlr_wdata       (sys_mem_intf.mem_wdata    ),
      .sys_mem_cntrlr_rd_valid    (sys_mem_intf.mem_rd_valid ),
      .sys_mem_cntrlr_rdata       (sys_mem_intf.mem_rdata    ),

      .scl                        (wm8731_intf.scl),
      .sda                        (wm8731_intf.sda),

      .AUD_ADCDAT                 (wm8731_intf.adc_dat),
      .AUD_ADCLRCK                (wm8731_intf.adc_lrc),
      .AUD_BCLK                   (wm8731_intf.bclk),
      .AUD_DACDAT                 (wm8731_intf.dac_dat),
      .AUD_DACLRCK                (wm8731_intf.dac_lrc),

      .HDMI_TX_D                  (),
      .HDMI_TX_DE                 (),
      .HDMI_TX_HS                 (),
      .HDMI_TX_VS                 ()

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

[11-01-2015  06:19:45 PM][mammenx] Added cntrlr_clk

[11-01-2015  01:20:27 PM][mammenx] .

[11-01-2015  01:15:50 PM][mammenx] .

[11-01-2015  01:13:54 PM][mammenx] Added sys_mem_agent & fixed misc simulation issues


 --------------------------------------------------------------------------
*/


