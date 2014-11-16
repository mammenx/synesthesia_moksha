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
 -- Module Name       : rst_cntrl
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module is used by SW to control the individual
                        resets to different blocks.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module rst_cntrl #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME     = "RST_CNTRL",
  parameter NUM_RESETS      = 1,
  parameter LB_DATA_W       = 32,
  parameter LB_ADDR_W       = 12,
  parameter DEFAULT_REG_VAL = 'hdeadbabe
) (

  //--------------------- Ports -------------------------
  input                       rst_n,
  input                       clk,

  input                       lb_wr_en,
  input                       lb_rd_en,
  input   [LB_ADDR_W-1:0]     lb_addr,
  input   [LB_DATA_W-1:0]     lb_wr_data,
  output  reg                 lb_wr_valid,
  output  reg                 lb_rd_valid,
  output  reg [LB_DATA_W-1:0] lb_rd_data,

  output  reg [NUM_RESETS-1:0]cntrl_rst_n

);

//----------------------- Local Parameters Declarations -------------------
  `include  "rst_cntrl.svh"

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------


//----------------------- Internal Wire Declarations ----------------------


//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------



//----------------------- Start of Code -----------------------------------

  /*  LB Decode Logic */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      lb_wr_valid             <=  0;
      lb_rd_valid             <=  0;
      lb_rd_data              <=  0;

      cntrl_rst_n             <=  0;
    end
    else
    begin
      if(lb_wr_en & (lb_addr  ==  RST_CNTRL_REG_ADDR))
      begin
        cntrl_rst_n           <=  lb_wr_data[NUM_RESETS-1:0];
      end

      lb_wr_valid             <=  lb_wr_en;

      if(lb_rd_en)
      begin
        if(lb_addr  ==  RST_CNTRL_REG_ADDR)
        begin
          lb_rd_data          <=  {{(LB_DATA_W-NUM_RESETS){1'b0}},cntrl_rst_n};
        end
        else
        begin
          lb_rd_data          <=  DEFAULT_REG_VAL;
        end
      end

      lb_rd_valid             <=  lb_rd_en;
    end
  end

endmodule // rst_cntrl

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>


 --------------------------------------------------------------------------
*/
