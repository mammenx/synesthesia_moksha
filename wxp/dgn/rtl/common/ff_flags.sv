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
 -- Module Name       : ff_flags
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module generates FIFO underflow & overflow
                        flags.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module ff_flags #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME     = "FF_FLAGS",
  parameter NUM_INTFS       = 1

) (

  //--------------------- Ports -------------------------
  input                       clear_clk,
  input                       clear_clk_rst_n,

  input                       wr_clk,
  input                       wr_clk_rst_n,

  input                       rd_clk,
  input                       rd_clk_rst_n,

  input   [NUM_INTFS-1:0]     clear_flags,

  input   [NUM_INTFS-1:0]     ff_wren,
  input   [NUM_INTFS-1:0]     ff_full,

  input   [NUM_INTFS-1:0]     ff_rden,
  input   [NUM_INTFS-1:0]     ff_empty,

  output  reg [NUM_INTFS-1:0] ff_ovrflw,
  output  reg [NUM_INTFS-1:0] ff_undrflw

);

//----------------------- Local Parameters Declarations -------------------


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  genvar  i;

//----------------------- Internal Wire Declarations ----------------------
  wire  [NUM_INTFS-1:0]       clear_flags_wr_clk_sync;
  wire  [NUM_INTFS-1:0]       clear_flags_rd_clk_sync;



//----------------------- Start of Code -----------------------------------

  pulse_toggle_sync   wr_clk_sync
  (
    .in_clk           (clear_clk),
    .in_rst_n         (clear_clk_rst_n),

    .out_clk          (wr_clk),
    .out_rst_n        (wr_clk_rst_n),

    .pulse_in         (clear_flags),

    .pulse_out        (clear_flags_wr_clk_sync)

  );

  pulse_toggle_sync   rd_clk_sync
  (
    .in_clk           (clear_clk),
    .in_rst_n         (clear_clk_rst_n),

    .out_clk          (rd_clk),
    .out_rst_n        (rd_clk_rst_n),

    .pulse_in         (clear_flags),

    .pulse_out        (clear_flags_rd_clk_sync)

  );


  generate
    for(i=0;  i<NUM_INTFS;  i++)
    begin : gen_ff_flags
      always@(posedge wr_clk,  negedge wr_clk_rst_n)
      begin
        if(~wr_clk_rst_n)
        begin
          ff_ovrflw[i]        <=  0;
        end
        else
        begin
          if(clear_flags_wr_clk_sync[i])
          begin
            ff_ovrflw[i]      <=  0;
          end
          else
          begin
            ff_ovrflw[i]      <=  ff_wren[i]  & ff_full[i];
          end
        end
      end

      always@(posedge rd_clk,  negedge rd_clk_rst_n)
      begin
        if(~rd_clk_rst_n)
        begin
          ff_undrflw[i]       <=  0;
        end
        else
        begin
          if(clear_flags_rd_clk_sync[i])
          begin
            ff_undrflw[i]     <=  0;
          end
          else
          begin
            ff_undrflw[i]     <=  ff_rden[i]  & ff_empty[i];
          end
        end
      end
    end
  endgenerate


endmodule // ff_flags

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>


 --------------------------------------------------------------------------
*/
