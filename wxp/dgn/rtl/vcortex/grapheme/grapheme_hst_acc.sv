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
 -- Module Name       : grapheme_hst_acc
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module converts local bus transactions from
                        host into the grapheme node protocol.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module grapheme_hst_acc #(
  //----------------- Parameters  -----------------------
    parameter MODULE_NAME         = "GRAPHEME_HST_ACC"
  , parameter LB_DATA_W           = 32
  , parameter LB_ADDR_W           = 8
  , parameter LB_ADDR_BLK_W       = 4

) 
  import  grapheme_node_prot_pkg::*;
(

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

  , input   gnode_prot_cmd_t          ingr_cmd
  , input   [GNODE_PROT_DATA_W-1:0]   ingr_data
  , output                            ingr_ready

  , output  gnode_prot_cmd_t          egr_cmd
  , output  [GNODE_PROT_DATA_W-1:0]   egr_data
  , input                             egr_ready


);

//----------------------- Local Parameters Declarations -------------------


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------


//----------------------- Internal Wire Declarations ----------------------


//----------------------- Internal Interface Declarations -----------------





//----------------------- Start of Code -----------------------------------

endmodule // grapheme_hst_acc

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>


 --------------------------------------------------------------------------
*/
