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
 -- Module Name       : rst_sync
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module implements a reset synchronizer circuit.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module rst_sync #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME       = "RST_SYNC",
  parameter ACTIVE_LOW_N_HIGH = 1,
  parameter NUM_STAGES        = 2

) (

  //--------------------- Ports -------------------------
  input                       clk,
  input                       rst_async,

  output                      rst_sync

);

//----------------------- Local Parameters Declarations -------------------
  localparam  RST_ACTIVE_VAL    = ACTIVE_LOW_N_HIGH ? 1'b0  : 1'b1;
  localparam  RST_INACTIVE_VAL  = ACTIVE_LOW_N_HIGH ? 1'b1  : 1'b0;

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg   [NUM_STAGES-1:0]      sync_vec_f;

//----------------------- Internal Wire Declarations ----------------------



//----------------------- Start of Code -----------------------------------

  always@(posedge clk,  negedge rst_async)
  begin
    if(~rst_async)
    begin
      sync_vec_f              <=  {NUM_STAGES{RST_ACTIVE_VAL}};
    end
    else
    begin
      sync_vec_f              <=  {sync_vec_f[NUM_STAGES-2:0],RST_INACTIVE_VAL};
    end
  end

  assign  rst_sync            =   sync_vec_f[NUM_STAGES-1];

endmodule // rst_sync

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>


 --------------------------------------------------------------------------
*/
