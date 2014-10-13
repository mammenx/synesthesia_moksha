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
 -- Module Name       : lb_splitter
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module splits incoming local bus transactions
                        into different children.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module lb_splitter #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME       = "LB_SPLITTER",
  parameter LB_DATA_W         = 32,
  parameter LB_ADDR_W         = 12,
  parameter LB_CHLD_ADDR_W    = 8,
  parameter NUM_CHILDREN      = 1,
  parameter REGISTER_OUTPUTS  = 0,
  parameter DEFAULT_DATA_VAL  = 'hdeadbabe

) (

  //--------------------- Ports -------------------------
  input                       clk,
  input                       rst_n,

  input                       lb_wr_en,
  input                       lb_rd_en,
  input   [LB_ADDR_W-1:0]     lb_addr,
  input   [LB_DATA_W-1:0]     lb_wr_data,
  output                      lb_wr_valid,
  output                      lb_rd_valid,
  output  [LB_DATA_W-1:0]     lb_rd_data,

  output  [NUM_CHILDREN-1:0]  chld_lb_wr_en,
  output  [NUM_CHILDREN-1:0]  chld_lb_rd_en,
  output  [LB_CHLD_ADDR_W-1:0]chld_lb_addr  [NUM_CHILDREN-1:0],
  output  [LB_DATA_W-1:0]     chld_lb_wr_data [NUM_CHILDREN-1:0],
  input   [NUM_CHILDREN-1:0]  chld_lb_wr_valid,
  input   [NUM_CHILDREN-1:0]  chld_lb_rd_valid,
  input   [LB_DATA_W-1:0]     chld_lb_rd_data [NUM_CHILDREN-1:0]

);

//----------------------- Local Parameters Declarations -------------------
  localparam  LB_BLK_W        = LB_ADDR_W - LB_CHLD_ADDR_W;

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------
  generate
  begin
    if(REGISTER_OUTPUTS)
    begin
      reg                     lb_wr_valid;
      reg                     lb_rd_valid;
      reg [LB_DATA_W-1:0]     lb_rd_data;

      reg [NUM_CHILDREN-1:0]  chld_lb_wr_en;
      reg [NUM_CHILDREN-1:0]  chld_lb_rd_en;
      reg [LB_CHLD_ADDR_W-1:0]chld_lb_addr  [NUM_CHILDREN-1:0];
      reg [LB_DATA_W-1:0]     chld_lb_wr_data [NUM_CHILDREN-1:0];
    end
    else  //~REGISTER_OUTPUTS
    begin
      reg [LB_DATA_W-1:0]     lb_rd_data;
    end
  endgenerate


//----------------------- Internal Register Declarations ------------------


//----------------------- Internal Wire Declarations ----------------------
  wire  [LB_BLK_W-1:0]        lb_add_blk;
  wire  [LB_CHLD_ADDR_W-1:0]  lb_child_addr;
  wire  [NUM_CHILDREN-1:0]    blk_sel_vec;
  wire  [LB_DATA_W-1:0]       lb_rd_data_nxt;

  genvar  i;
  integer n;

//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------



//----------------------- Start of Code -----------------------------------

  assign  {lb_add_blk,lb_child_addr}  = lb_addr;

  generate
  begin
    if(REGISTER_OUTPUTS)
    begin
      generate
      begin
        for(i=0;  i<NUM_CHILDREN; i++)
        begin : gen_child
          assign  blk_sel_vec[i]  = (lb_add_blk ==  i)  ? 1'b1  : 1'b0;
        end
      end
      endgenerate

      always@(posedge clk,  negedge rst_n)
      begin
        if(~rst_n)
        begin
          lb_wr_valid         <=  0;
          lb_rd_valid         <=  0;
          lb_rd_data          <=  0;

          chld_lb_wr_en       <=  0;
          chld_lb_rd_en       <=  0;
          chld_lb_addr        <=  0;
          chld_lb_wr_data     <=  0;
        end
        else
        begin
          lb_wr_valid         <=  |chld_lb_wr_valid;
          lb_rd_valid         <=  |chld_lb_rd_valid;

          for(n=0;  n<NUM_CHILDREN; n++)
          begin
            chld_lb_wr_en[i]  <=  blk_sel_vec[i]  & lb_wr_en;
            chld_lb_rd_en[i]  <=  blk_sel_vec[i]  & lb_rd_en;
            chld_lb_addr[i]   <=  lb_child_addr;
            chld_lb_wr_data[i]<=  lb_wr_data;
          end

          lb_rd_data          <=  lb_rd_data_nxt;
        end
      end
    end
    else  //~REGISTER_OUTPUTS
    begin
      generate
      begin
        for(i=0;  i<NUM_CHILDREN; i++)
        begin : gen_child
          assign  blk_sel_vec[i]  = (lb_add_blk ==  i)  ? 1'b1  : 1'b0;

          assign  chld_lb_wr_en[i]    = blk_sel_vec[i]  & lb_wr_en;
          assign  chld_lb_rd_en[i]    = blk_sel_vec[i]  & lb_rd_en;
          assign  chld_lb_addr[i]     = lb_child_addr;
          assign  chld_lb_wr_data[i]  = lb_wr_data;
        end
      end
      endgenerate

      assign  lb_wr_valid         =   |chld_lb_wr_valid;
      assign  lb_rd_valid         =   |chld_lb_rd_valid;

      assign  lb_rd_data          =   lb_rd_data_nxt;
    end
  end
  endgenerate

  always@(*)
  begin
    if(blk_sel_vec  ==  0)
    begin
      lb_rd_data_nxt  = DEFAULT_DATA_VAL;
    end
    else
    begin
      lb_rd_data_nxt  = 0;

      for(n=0;  n<NUM_CHILDREN; n++)
      begin
        lb_rd_data_nxt  = lb_rd_data_nxt  | (chld_lb_rd_data[n] & {LB_DATA_W{blk_sel_vec[n]}});
      end
    end
  end
 
endmodule // lb_splitter

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[13-10-2014  10:05:37 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
