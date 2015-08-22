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
 -- Module Name       : ff_ptr_mngr
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module maintains the read & write pointers for
                        a FIFO based memory.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module ff_ptr_mngr #(
  //----------------- Parameters  -----------------------
    parameter MODULE_NAME = "FF_PTR_MNGR"
  , parameter FF_DEPTH    = 16
  , parameter NUM_INTFS   = 1

  , parameter FF_PTR_W    = $clog(FF_DEPTH) //Do not override

) (

  //--------------------- Ports -------------------------
    input                       clk
  , input                       rst_n

  , input       [NUM_INTFS-1:0] ff_wr_en
  , output  reg [FF_PTR_W-1:0]  ff_wr_ptr [NUM_INTFS-1:0]
  , output  reg [NUM_INTFS-1:0] ff_full

  , input       [NUM_INTFS-1:0] ff_rd_en
  , output  reg [FF_PTR_W-1:0]  ff_rd_ptr [NUM_INTFS-1:0]
  , output  reg [NUM_INTFS-1:0] ff_empty

  , output  reg [FF_PTR_W-1:0]  ff_occ  [NUM_INTFS-1:0]

);

//----------------------- Local Parameters Declarations -------------------


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  genvar  i;


//----------------------- Internal Wire Declarations ----------------------



//----------------------- Start of Code -----------------------------------

  generate
    for(i=0;  i<NUM_INTFS;  i++)
    begin : gen_ptrs
      always@(posedge clk,  negedge rst_n)
      begin
        if(~rst_n)
        begin
          ff_wr_ptr[i]        <=  0;
          ff_full[i]          <=  0;

          ff_rd_ptr[i]        <=  0;
          ff_empty[i]         <=  1'b1;

          ff_occ[i]           <=  0;
        end
        else
        begin
          case({ff_wr_en[i],ff_rd_en[i]})

            2'b00 : //Idle
            begin
              ff_wr_ptr[i]    <=  ff_wr_ptr[i];
              ff_rd_ptr[i]    <=  ff_rd_ptr[i];
              ff_occ[i]       <=  ff_occ[i];
              ff_empty[i]     <=  ff_empty[i];
              ff_full[i]      <=  ff_full[i];
            end

            2'b01 : //Read only
            begin
              ff_wr_ptr[i]    <=  ff_wr_ptr[i];
              ff_rd_ptr[i]    <=  ff_rd_ptr[i] + (~ff_empty[i]);
              ff_occ[i]       <=  ff_occ[i] - (~ff_empty[i]);
              ff_empty[i]     <=  (ff_occ[i] ==  1)  ? 1'b1  : ff_empty[i];
              ff_full[i]      <=  1'b0;
            end

            2'b10 : //Write only
            begin
              ff_wr_ptr[i]    <=  ff_wr_ptr[i] + (~ff_full[i]);
              ff_rd_ptr[i]    <=  ff_rd_ptr[i];
              ff_occ[i]       <=  ff_occ[i]  + (~ff_full[i]);
              ff_empty[i]     <=  1'b0;
              ff_full[i]      <=  (ff_occ ==  (FF_DEPTH-1)) ? 1'b1  : ff_full[i];
            end

            2'b11 : //Read & Write
            begin
              ff_wr_ptr[i]    <=  ff_wr_ptr[i] + (~ff_full[i]);
              ff_rd_ptr[i]    <=  ff_rd_ptr[i] + (~ff_empty[i]);
              ff_occ[i]       <=  ff_occ[i];
              ff_empty[i]     <=  ff_empty[i];
              ff_full[i]      <=  ff_full[i];
            end

          endcase
        end
      end
    end
  endgenerate

endmodule // ff_ptr_mngr

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[22-08-2015  11:29:36 AM][mammenx] Fixed ff_empty logic

[22-08-2015  02:09:38 AM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
