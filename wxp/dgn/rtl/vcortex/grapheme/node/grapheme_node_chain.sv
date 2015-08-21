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
 -- Module Name       : grapheme_node_chain
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module chains together the prot interfaces of
                        different nodes.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module grapheme_node_chain #(
  //----------------- Parameters  -----------------------
    parameter MODULE_NAME       = "GRAPHEME_NODE_CHAIN"
  , parameter NUM_NODES         = 1
  , parameter TERMINATE_CHAIN   = 0 //1->Do not connect first & last nodes to form a ring
                                    //0->Connect first & last nodes to form a ring
  , parameter FLOP_STAGES       = 0

) 
  import  grapheme_node_prot_pkg::*;
(

  //--------------------- Ports -------------------------
    input                     clk
  , input                     rst_n

  , input   gnode_prot_cmd_t          ingr_cmd  [NUM_NODES-1:0]
  , input   [GNODE_PROT_DATA_W-1:0]   ingr_data [NUM_NODES-1:0]
  , output  [NUM_NODES-1:0]           ingr_ready

  , output  gnode_prot_cmd_t          egr_cmd   [NUM_NODES-1:0]
  , output  [GNODE_PROT_DATA_W-1:0]   egr_data  [NUM_NODES-1:0]
  , input   [NUM_NODES-1:0]           egr_ready

);

//----------------------- Local Parameters Declarations -------------------


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  genvar  i;

  gnode_prot_cmd_t                int_ingr_cmd  [NUM_NODES-1:0];
  logic [GNODE_PROT_DATA_W-1:0]   int_ingr_data [NUM_NODES-1:0];
  logic [NUM_NODES-1:0]           int_egr_ready;


//----------------------- Internal Wire Declarations ----------------------




//----------------------- Start of Code -----------------------------------

  generate
    if(FLOP_STAGES  ==  1)
    begin
      for(i=0;  i<NUM_NODES;  i++)
      begin : flop_stages
        always@(posedge clk,  negedge rst_n)
        begin
          if(~rst_n)
          begin
            int_ingr_cmd[i]   <=  IDLE;
            int_ingr_data[i]  <=  0;
            int_egr_ready[i]  <=  0;
          end
          else
          begin
            int_ingr_cmd[i]   <=  ingr_cmd[i];
            int_ingr_data[i]  <=  ingr_data[i];
            int_egr_ready[i]  <=  egr_ready[i];
          end
        end
      end
    end
    else  //FLOP_STAGES ==  0
    begin
      assign  int_ingr_cmd[i] =  ingr_cmd[i];
      assign  int_ingr_data[i]=  ingr_data[i];
      assign  int_egr_ready[i]=  egr_ready[i];
    end


    for(i=0;  i<(NUM_NODES-1);  i++)
    begin : chain_connect
      assign  egr_cmd[i+1]    = int_ingr_cmd[i];
      assign  egr_data[i+1]   = int_ingr_data[i];
      assign  ingr_ready[i]   = int_egr_ready[i+1];
    end

    if(TERMINATE_CHAIN  ==  0)
    begin
      assign  egr_cmd[0]              = int_ingr_cmd[NUM_NODES-1];
      assign  egr_data[0]             = int_ingr_data[NUM_NODES-1];
      assign  ingr_ready[NUM_NODES-1] = int_egr_ready[0];
    end
    else  //TERMINATE_CHAIN ==  1
    begin
      assign  egr_cmd[0]              = IDLE;
      assign  egr_data[0]             = 0;
      assign  ingr_ready[NUM_NODES-1] = 1'b1;
    end
  endgenerate


endmodule // grapheme_node_chain

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>


 --------------------------------------------------------------------------
*/
