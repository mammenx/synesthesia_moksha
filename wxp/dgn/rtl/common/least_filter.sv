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
 -- Module Name       : least_filter
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module extracts the least value out of a set of
                        N inputs.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module least_filter #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME = "LEAST_FILTER",
  parameter NUM_DATA    = 2,
  parameter DATA_W      = 8,

  parameter DATA_IDX_W  = $clog2(NUM_DATA)  //Do not override

) (

  //--------------------- Ports -------------------------
  input                       clk,
  input                       rst_n,

  input   [DATA_W-1:0]        data_i  [NUM_DATA-1:0],

  output  [DATA_W-1:0]        data_o,
  output  [DATA_IDX_W-1:0]    data_idx_o


);

//----------------------- Local Parameters Declarations -------------------


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------


//----------------------- Internal Wire Declarations ----------------------
  wire  [DATA_W-1:0]          cmp_res_c [NUM_DATA-1:0];
  wire  [DATA_IDX_W-1:0]      cmp_idx_res_c [NUM_DATA-1:0];


  genvar  i;

//----------------------- Internal Interface Declarations -----------------



//----------------------- Start of Code -----------------------------------

  generate
  begin
    for(i=0;  i<NUM_DATA; i++)
    begin : gen_cmp
      if(i  ==  0)
      begin
        assign  cmp_res_c[i]      = data_i[0];
        assign  cmp_idx_res_c[i]  = 0;
      end
      else
      begin
        assign  cmp_res_c[i]      = (data_i[i]  < cmp_res_c[i-1]) ? data_i[i] : cmp_res_c[i-1];
        assign  cmp_idx_res_c[i]  = (data_i[i]  < cmp_res_c[i-1]) ? i         : cmp_idx_res_c[i-1];
      end
    end
  end
  endgenerate

  assign  data_o      = cmp_res_c[NUM_DATA-1];
  assign  data_idx_o  = cmp_idx_res_c[NUM_DATA-1];

endmodule // least_filter

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[10-01-2015  07:19:31 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
