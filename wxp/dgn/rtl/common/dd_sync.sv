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
 -- Module Name       : dd_sync
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : Basic N-Stage DFLOP synchronizer
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module dd_sync  #(
  //--------------------- Global parameters Declarations ------------------
  parameter SIGNAL_W          = 1,
  parameter P_NO_SYNC_STAGES  = 2

) (
    clk,
    rst_n,

    signal_id,

    signal_od
  );

//----------------------- Input Declarations ------------------------------
  input                       clk;
  input                       rst_n;

  input   [SIGNAL_W-1:0]      signal_id;


//----------------------- Output Declarations -----------------------------
  output  [SIGNAL_W-1:0]      signal_od;

//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg   [P_NO_SYNC_STAGES-1:0]  sync_f  [SIGNAL_W-1:0];

  genvar  i;

//----------------------- Internal Wire Declarations ----------------------



//----------------------- Start of Code -----------------------------------

  generate
    for(i=0;  i<SIGNAL_W; i++)
    begin : gen_dd_sync
      always@(posedge clk, negedge rst_n)
      begin
        if(~rst_n)
        begin
          sync_f[i]           <=  {P_NO_SYNC_STAGES{1'b0}};
        end
        else
        begin
          sync_f[i]           <=  {sync_f[i][P_NO_SYNC_STAGES-2:0],signal_id[i]};
        end
      end

      assign  signal_od[i]    =   sync_f[i][P_NO_SYNC_STAGES-1];
    end
  endgenerate

endmodule // dd_sync

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/
