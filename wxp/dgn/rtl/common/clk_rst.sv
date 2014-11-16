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
 -- Module Name       : clk_rst
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module synchronizes a common asynchronous reset
                        to different clocks.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module clk_rst #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME     = "CLK_RST",
  parameter NUM_CLKS        = 1,
  parameter NUM_SYNC_STAGES = 2

) (

  //--------------------- Ports -------------------------
  input                   async_rst_n,
  input   [NUM_CLKS-1:0]  clk,

  output  [NUM_CLKS-1:0]  sync_rst_n


);

//----------------------- Local Parameters Declarations -------------------


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------


//----------------------- Internal Wire Declarations ----------------------
  genvar  i;

//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------



//----------------------- Start of Code -----------------------------------

  generate
    for(i=0;  i<NUM_CLKS; i++)
    begin : rst_sync_gen
      always@(posedge clk[i],  negedge async_rst_n)
      begin
        if(~async_rst_n)
        begin
          sync_rst_n[i]       <=  0;
        end
        else
        begin
          sync_rst_n[i]       <=  1;
        end
      end
    end
  endgenerate

endmodule // clk_rst


/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>


 --------------------------------------------------------------------------
*/
