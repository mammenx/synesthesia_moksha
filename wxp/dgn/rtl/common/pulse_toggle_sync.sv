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
 -- Module Name       : pulse_toggle_sync
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module has logic to synchronize pulses accross
                        clock domains using a toggling signal.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module pulse_toggle_sync #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME     = "PULSE_TOGGLE_SYNC",
  parameter NUM_SYNC_STAGES = 2,
  parameter REGISTER_OUTPUT = 1

) (

  //--------------------- Ports -------------------------
  input                       in_clk,
  input                       in_rst_n,

  input                       out_clk,
  input                       out_rst_n,

  input                       pulse_in,

  output                      pulse_out

);

//----------------------- Local Parameters Declarations -------------------


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------
  generate
  begin
    if(REGISTER_OUTPUT)
    begin
      reg                     pulse_out;
    end
  end
  endgenerate


//----------------------- Internal Register Declarations ------------------
  reg                         in_tggl;
  reg                         out_tggl_1d;


//----------------------- Internal Wire Declarations ----------------------
  wire                        out_tggl;


//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------



//----------------------- Start of Code -----------------------------------

  always@(posedge in_clk, negedge in_rst_n)
  begin
    if(~in_rst_n)
    begin
      in_tggl                 <=  0;
    end
    else
    begin
      in_tggl                 <=  in_tggl ^ pulse_in;
    end
  end

  /*  Instantiate DD Sync */
  dd_sync #(.P_NO_SYNC_STAGES(NUM_SYNC_STAGES)) dd_sync_inst
  (
    .clk          (out_clk),
    .rst_n        (out_rst_n),

    .signal_id    (in_tggl),

    .signal_od    (out_tggl)
  );

  always@(posedge out_clk, negedge out_rst_n)
  begin
    if(~out_rst_n)
    begin
      out_tggl_1d             <=  0;
    end
    else
    begin
      out_tggl_1d             <=  out_tggl;
    end
  end

  generate
  begin
    if(REGISTER_OUTPUT)
    begin
      always@(posedge out_clk, negedge out_rst_n)
      begin
        if(~out_rst_n)
        begin
          pulse_out           <=  0;
        end
        else
        begin
          pulse_out           <=  out_tggl  ^ out_tggl_1d;
        end
      end
    end
    else  //~REGISTER_OUTPUT
    begin
      assign  pulse_out       =   out_tggl  ^ out_tggl_1d;
    end
  end
  endgenerate



endmodule // pulse_toggle_sync

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[12-10-2014  02:12:20 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
