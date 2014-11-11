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
  output  reg [LB_DATA_W-1:0] lb_rd_data,

  output  reg [NUM_CHILDREN-1:0]    chld_lb_wr_en,
  output  reg [NUM_CHILDREN-1:0]    chld_lb_rd_en,
  output  reg [LB_CHLD_ADDR_W-1:0]  chld_lb_addr  [NUM_CHILDREN-1:0],
  output  reg [LB_DATA_W-1:0]       chld_lb_wr_data [NUM_CHILDREN-1:0],
  input   [NUM_CHILDREN-1:0]    chld_lb_wr_valid,
  input   [NUM_CHILDREN-1:0]    chld_lb_rd_valid,
  input   [LB_DATA_W-1:0]       chld_lb_rd_data [NUM_CHILDREN-1:0]

);

//----------------------- Local Parameters Declarations -------------------
  localparam  LB_BLK_W        = LB_ADDR_W - LB_CHLD_ADDR_W;

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg   [LB_DATA_W-1:0]       lb_rd_data_nxt  [NUM_CHILDREN-1:0];


//----------------------- Internal Wire Declarations ----------------------
  wire  [LB_BLK_W-1:0]        lb_add_blk;
  wire  [LB_CHLD_ADDR_W-1:0]  lb_child_addr;
  wire  [NUM_CHILDREN-1:0]    blk_sel_vec;

  genvar  i;

//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------



//----------------------- Start of Code -----------------------------------

  assign  {lb_add_blk,lb_child_addr}  = lb_addr;

  generate
  begin
    for(i=0;  i<NUM_CHILDREN; i++)
    begin : gen_child
      assign  blk_sel_vec[i]  = (lb_add_blk ==  i)  ? 1'b1  : 1'b0;
    end
  end
  endgenerate

  generate
  begin
    if(REGISTER_OUTPUTS)
    begin
      reg                     lb_wr_valid_reg;
      reg                     lb_rd_valid_reg;
 
      always@(posedge clk,  negedge rst_n)
      begin
        if(~rst_n)
        begin
          lb_wr_valid_reg     <=  0;
          lb_rd_valid_reg     <=  0;
          lb_rd_data          <=  0;
        end
        else
        begin
          lb_wr_valid_reg     <=  |chld_lb_wr_valid;
          lb_rd_valid_reg     <=  |chld_lb_rd_valid;

          lb_rd_data          <=  lb_rd_data_nxt[NUM_CHILDREN-1];
        end
      end

      for(i=0;  i<NUM_CHILDREN; i++)
      begin : gen_child
        always@(posedge clk,  negedge rst_n)
        begin
          if(~rst_n)
          begin
            chld_lb_wr_en[i]    <=  0;
            chld_lb_rd_en[i]    <=  0;
            chld_lb_addr[i]     <=  0;
            chld_lb_wr_data[i]  <=  0;
          end
          else
          begin
            chld_lb_wr_en[i]  <=  blk_sel_vec[i]  & lb_wr_en;
            chld_lb_rd_en[i]  <=  blk_sel_vec[i]  & lb_rd_en;
            chld_lb_addr[i]   <=  lb_child_addr;
            chld_lb_wr_data[i]<=  lb_wr_data;
          end
        end
      end

      assign  lb_wr_valid     =   lb_wr_valid_reg;
      assign  lb_rd_valid     =   lb_rd_valid_reg;
    end
    else  //~REGISTER_OUTPUTS
    begin
      for(i=0;  i<NUM_CHILDREN; i++)
      begin : gen_child
        always@(*)
        begin
          chld_lb_wr_en[i]    = blk_sel_vec[i]  & lb_wr_en;
          chld_lb_rd_en[i]    = blk_sel_vec[i]  & lb_rd_en;
          chld_lb_addr[i]     = lb_child_addr;
          chld_lb_wr_data[i]  = lb_wr_data;
        end
      end

      assign  lb_wr_valid         =   |chld_lb_wr_valid;
      assign  lb_rd_valid         =   |chld_lb_rd_valid;

      always@(*)
      begin
        lb_rd_data            =   lb_rd_data_nxt[NUM_CHILDREN-1];
      end
    end
  end
  endgenerate

  generate
    for(i=0;  i<NUM_CHILDREN; i++)
    begin : build_lb_rd_data_nxt
      if(i  ==  0)
      begin
        always@(*)
        begin
          lb_rd_data_nxt[i] = (chld_lb_rd_data[i] & {LB_DATA_W{blk_sel_vec[i]}});
        end
      end
      else if(i ==  NUM_CHILDREN-1)
      begin
        always@(*)
        begin
          if(blk_sel_vec  ==  0)
          begin
            lb_rd_data_nxt[i] = DEFAULT_DATA_VAL;
          end
          else
          begin
            lb_rd_data_nxt[i] = lb_rd_data_nxt[i-1] | (chld_lb_rd_data[i] & {LB_DATA_W{blk_sel_vec[i]}});
          end
        end
      end
      else
      begin
        always@(*)
        begin
          lb_rd_data_nxt[i] = lb_rd_data_nxt[i-1] | (chld_lb_rd_data[i] & {LB_DATA_W{blk_sel_vec[i]}});
        end
      end
    end
  endgenerate

endmodule // lb_splitter

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[11-11-2014  12:47:57 AM][mammenx] Fixed synthesis errors

[14-10-2014  12:47:57 AM][mammenx] Fixed compilation errors & warnings

[13-10-2014  10:05:37 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
