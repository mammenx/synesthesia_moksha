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
 -- Module Name       : sys_mem_hst_acc
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module allows the host to read/write from
                        system memory via local bus.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module sys_mem_hst_acc #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME         = "SYS_MEM_HST_ACC",
  parameter LB_DATA_W           = 32,
  parameter LB_ADDR_W           = 8,
  parameter LB_ADDR_BLK_W       = 4,
  parameter SYS_MEM_DATA_W      = 32,
  parameter SYS_MEM_ADDR_W      = 27,
  parameter SYS_MEM_START_ADDR  = 0,
  parameter SYS_MEM_STOP_ADDR   = 921599,

  parameter DEFAULT_REG_VAL     = 'hdeadbabe
 
) (

  //--------------------- Ports -------------------------
    input                       clk,
    input                       rst_n,

    input                       lb_wr_en,
    input                       lb_rd_en,
    input   [LB_ADDR_W-1:0]     lb_addr,
    input   [LB_DATA_W-1:0]     lb_wr_data,
    output  reg                 lb_wr_valid,
    output  reg                 lb_rd_valid,
    output  reg [LB_DATA_W-1:0] lb_rd_data,

    input                       sys_mem_wait,
    output  reg                 sys_mem_wren,
    output  reg                 sys_mem_rden,
    output  [SYS_MEM_ADDR_W-1:0]sys_mem_addr,
    output  [SYS_MEM_DATA_W-1:0]sys_mem_wdata,
    input                       sys_mem_rd_valid,
    input   [SYS_MEM_DATA_W-1:0]sys_mem_rdata

);

//----------------------- Local Parameters Declarations -------------------
  `include  "sys_mem_hst_acc_regmap.svh"


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg [SYS_MEM_ADDR_W-1:0]    mem_addr;
  reg [SYS_MEM_DATA_W-1:0]    mem_data;

//----------------------- Internal Wire Declarations ----------------------


//----------------------- Start of Code -----------------------------------


  /*  Local bus logic */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      lb_wr_valid             <=  0;
      lb_rd_valid             <=  0;
      lb_rd_data              <=  0;

      mem_addr                <=  0;
      mem_data                <=  0;
    end
    else
    begin
      if(lb_wr_en)
      begin
        case(lb_addr)
          SYS_MEM_HST_ACC_ADDR_REG  :
          begin
            mem_addr          <=  lb_wr_data[SYS_MEM_ADDR_W-1:0];
          end

          SYS_MEM_HST_ACC_DATA_REG  :
          begin
            mem_data          <=  lb_wr_data[SYS_MEM_DATA_W-1:0];
          end
        endcase
      end

      lb_wr_valid             <=  lb_wr_en;

      if(lb_rd_en)
      begin
        case(lb_addr)
          SYS_MEM_HST_ACC_STATUS_REG  :
          begin
            lb_rd_data        <=  {{(LB_DATA_W-2){1'b0}}, sys_mem_rden, sys_mem_wren};
          end

          SYS_MEM_HST_ACC_ADDR_REG  :
          begin
            lb_rd_data        <=  {{(LB_DATA_W-SYS_MEM_ADDR_W){1'b0}},  mem_addr};
          end

          SYS_MEM_HST_ACC_DATA_REG  :
          begin
            lb_rd_data        <=  {{(LB_DATA_W-SYS_MEM_DATA_W){1'b0}},  mem_data};
          end

          default :
          begin
            lb_rd_data        <=  DEFAULT_REG_VAL;
          end
 
        endcase
      end

      lb_rd_valid             <=  lb_rd_en;
    end
  end


  /*  Sys Mem interface logic */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      sys_mem_wren            <=  0;
      sys_mem_rden            <=  0;
    end
    else
    begin
      if(sys_mem_wren)
      begin
        sys_mem_wren          <=  sys_mem_wait;
      end
      else
      begin
        sys_mem_wren          <=  (lb_addr  ==  SYS_MEM_HST_ACC_DATA_REG) ? lb_wr_en  : 1'b0;
      end

      if(sys_mem_rden)
      begin
        sys_mem_rden          <=  sys_mem_wait;
      end
      else
      begin
        sys_mem_rden          <=  (lb_addr  ==  SYS_MEM_HST_ACC_ADDR_REG) ? lb_wr_en  : 1'b0;
      end
    end
  end

  assign  sys_mem_addr        =   mem_addr;
  assign  sys_mem_wdata       =   mem_data;




endmodule // sys_mem_hst_acc

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[11-01-2015  01:07:10 PM][mammenx] Fixed misc issues found in simulation

[10-01-2015  11:49:47 AM][mammenx] Fixed Compilation Errors

[08-01-2015  07:13:10 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
