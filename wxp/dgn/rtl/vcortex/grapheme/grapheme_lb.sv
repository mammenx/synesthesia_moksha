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
 -- Module Name       : grapheme_lb
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This block decodes LB transactions for grapheme
                        nodes.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module grapheme_lb #(
  //----------------- Parameters  -----------------------
    parameter MODULE_NAME     = "GRAPHEME_LB"
  , parameter NUM_NODES       = 1
  , parameter LB_DATA_W       = 32
  , parameter LB_ADDR_W       = 4   //Should accomodate NUM_NODES*2

  , parameter DEFAULT_REG_VAL = 'hdeadbabe

) (

  //--------------------- Ports -------------------------
    input                       clk
  , input                       rst_n

  , input                       lb_wr_en
  , input                       lb_rd_en
  , input   [LB_ADDR_W-1:0]     lb_addr
  , input   [LB_DATA_W-1:0]     lb_wr_data
  , output  reg                 lb_wr_valid
  , output  reg                 lb_rd_valid
  , output  reg [LB_DATA_W-1:0] lb_rd_data

  , output  reg [NUM_NODES-1:0] gnode_en
  , output  reg [NUM_NODES-1:0] gnode_clear_flags
  , input   [LB_DATA_W-1:0]     gnode_status  [NUM_NODES-1:0]

);

//----------------------- Local Parameters Declarations -------------------


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  genvar  i;
  integer n;


//----------------------- Internal Wire Declarations ----------------------
  wire  [LB_DATA_W-1:0]       gnode_cntrl   [NUM_NODES-1:0];





//----------------------- Start of Code -----------------------------------

  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      lb_wr_valid             <=  0;
      lb_rd_valid             <=  0;
      lb_rd_data              <=  0;

      for(n=0;  n<NUM_NODES;  n++)
      begin
        gnode_en[n]           <=  0;
        gnode_clear_flags[n]  <=  0;
      end
    end
    else
    begin
      if(lb_wr_en & ~lb_addr[0])
      begin
        gnode_en[lb_addr[LB_ADDR_W-1:1]]          <=  lb_wr_data[0];
        gnode_clear_flags[lb_addr[LB_ADDR_W-1:1]] <=  lb_wr_data[1];
      end

      lb_wr_valid             <=  lb_wr_en;

      if(lb_rd_en)
      begin
        lb_rd_data            <=  lb_addr[0]  ? gnode_status[lb_addr[LB_ADDR_W-1:1]]
                                              : gnode_cntrl[lb_addr[LB_ADDR_W-1:1]];
      end

      lb_rd_valid             <=  lb_rd_en;
    end
  end

  generate
    for(i=0;  i<NUM_NODES;  i++)
    begin : build_gnode_cntrl
      assign  gnode_cntrl[i]  =   {   {(LB_DATA_W-3){1'b0}}
                                    , gnode_clear_flags[i]
                                    , gnode_en[i]
                                  };
    end
  endgenerate

endmodule // grapheme_lb

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[22-08-2015  02:58:53 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
