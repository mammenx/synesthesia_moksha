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
 -- Interface Name    : syn_pcm_mem_intf_s
 -- Author            : mammenx
 -- Function          : This interace contains all the signals required to
                        transfer PCM data from Acortex to Fgyrus.
 --------------------------------------------------------------------------
*/

interface syn_pcm_mem_intf_s  #(DATA_W=32,ADDR_W=8,RD_DELAY=2) (input logic clk_ir,rst_il);

  //Logic signals
  logic                     pcm_data_rdy;
  logic [ADDR_W-1:0]        pcm_addr;
  logic                     pcm_rden;
  logic [DATA_W-1:0]        pcm_rdata;
  logic                     pcm_rd_valid;
  logic [ADDR_W-1:0]        pcm_raddr;

  //Clocking Blocks
  clocking  cb  @(posedge clk_ir);
    default input #2ns  output  #2ns;

    input   pcm_data_rdy;
    output  pcm_addr;
    output  pcm_rden;
    input   pcm_rdata;
    input   pcm_rd_valid;

  endclocking : cb

  clocking  cb_mon  @(posedge clk_ir);
    default input #2ns  output  #2ns;

    input pcm_data_rdy;
    input pcm_addr;
    input pcm_rden;
    input pcm_rdata;
    input pcm_rd_valid;
    input pcm_raddr;  //to be used only by monitor

  endclocking : cb_mon



  /*  Read address delay logic  */
  logic [(ADDR_W*RD_DELAY)-1:0]  pcm_raddr_del;
  logic [RD_DELAY-1:0]           pcm_rden_del;

  always_ff@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      pcm_raddr_del <=  0;
      pcm_rden_del  <=  0;
    end
    else
    begin
      pcm_raddr_del <=  {pcm_raddr_del[(ADDR_W*(RD_DELAY-1))-1:0],pcm_addr};
      pcm_rden_del  <=  {pcm_rden_del[RD_DELAY-2:0],pcm_rden};
    end
  end

  assign  pcm_raddr     = pcm_raddr_del[(ADDR_W*(RD_DELAY-1)) +:  ADDR_W];
  assign  pcm_rd_valid  = pcm_rden_del[RD_DELAY-1];


  //Modports
  modport TB_DRVR   (input   clk_ir,rst_il, clocking  cb);
  modport TB_MON    (input   clk_ir,rst_il, clocking  cb_mon);


endinterface  //  syn_pcm_mem_intf_s

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[02-11-2014  07:53:10 PM][mammenx] Misc changes for PCM Test

[16-10-2014  09:46:11 PM][mammenx] Split into seperate interfaces for master & slave

[15-10-2014  11:44:12 PM][mammenx] Initial Commit

 --------------------------------------------------------------------------
*/


