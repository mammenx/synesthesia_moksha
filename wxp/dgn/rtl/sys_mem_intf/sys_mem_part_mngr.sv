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
 -- Module Name       : sys_mem_part_mngr
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module holds the partition information in terms
                        of start & end addresses for all the agents.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module sys_mem_part_mngr #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME       = "SYS_MEM_PART_MNGR",
  parameter MEM_ADDR_W        = 27,
  parameter NUM_AGENTS        = 2,
  parameter LB_DATA_W         = 32,
  parameter LB_ADDR_W         = 8,
  parameter DEFAULT_DATA_VAL  = 'hdeadbabe,

  parameter AGENT_ID_W        = $clog2(NUM_AGENTS)  //Do not override

) (

  //--------------------- Ports -------------------------
  input                         clk,
  input                         rst_n,

  input                         lb_wr_en,
  input                         lb_rd_en,
  input       [LB_ADDR_W-1:0]   lb_addr,
  input       [LB_DATA_W-1:0]   lb_wr_data,
  output  reg                   lb_wr_valid,
  output  reg                   lb_rd_valid,
  output  reg [LB_DATA_W-1:0]   lb_rd_data,

  input       [AGENT_ID_W-1:0]  agent_id,

  output      [MEM_ADDR_W-1:0]  mem_start_addr,
  output      [MEM_ADDR_W-1:0]  mem_end_addr

);

//----------------------- Local Parameters Declarations -------------------
  `include  "sys_mem_part_mngr_regmap.svh"

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg                         mode;
  reg   [AGENT_ID_W-1:0]      hst_addr;

//----------------------- Internal Wire Declarations ----------------------
  wire  [7:0]                 ram_addr_c;
  wire  [39:0]                ram_wdata_w;
  wire                        start_ram_wr_en_c;
  wire                        end_ram_wr_en_c;
  wire  [39:0]                start_ram_rdata_w;
  wire  [39:0]                end_ram_rdata_w;


//----------------------- Start of Code -----------------------------------

  /*  LB Decode Logic */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      lb_wr_valid             <=  0;
      lb_rd_valid             <=  0;
      lb_rd_data              <=  0;

      mode                    <=  0;  //0->Normal, 1->Config
      hst_addr                <=  0;
    end
    else
    begin
      if(lb_wr_en)
      begin
        case(lb_addr)

          SYS_MEM_PART_MNGR_CNTRL_REG :
          begin
            mode              <=  lb_wr_data[0];
          end

          SYS_MEM_PART_MNGR_ADDR_REG  :
          begin
            hst_addr          <=  lb_wr_data[AGENT_ID_W-1:0];
          end

        endcase
      end

      lb_wr_valid             <=  lb_wr_en;

      if(lb_rd_en)
      begin
        case(lb_addr)

          SYS_MEM_PART_MNGR_CNTRL_REG :
          begin
            lb_rd_data        <=  {{(LB_DATA_W-1){1'b0}}, mode};
          end

          SYS_MEM_PART_MNGR_NUM_AGENTS_REG  :
          begin
            lb_rd_data        <=  NUM_AGENTS;
          end

          SYS_MEM_PART_MNGR_ADDR_REG  :
          begin
            lb_rd_data        <=  {{(LB_DATA_W-AGENT_ID_W){1'b0}},  hst_addr};
          end

          SYS_MEM_PART_MNGR_START_DATA_REG  :
          begin
            lb_rd_data        <=  {{(LB_DATA_W-MEM_ADDR_W){1'b0}},  mem_start_addr};
          end

          SYS_MEM_PART_MNGR_END_DATA_REG  :
          begin
            lb_rd_data        <=  {{(LB_DATA_W-MEM_ADDR_W){1'b0}},  mem_end_addr};
          end

          default :
          begin
            lb_rd_data        <=  DEFAULT_DATA_VAL;
          end

        endcase
      end

      lb_rd_valid             <=  lb_rd_en;
    end
  end

  assign  ram_addr_c[7:AGENT_ID_W]    = 0;
  assign  ram_addr_c[AGENT_ID_W-1:0]  = mode  ? hst_addr  : agent_id;

  assign  ram_wdata_w[39:MEM_ADDR_W]  = 0;
  assign  ram_wdata_w[MEM_ADDR_W-1:0] = lb_wr_data[MEM_ADDR_W-1:0];

  assign  start_ram_wr_en_c           = (lb_addr  ==  SYS_MEM_PART_MNGR_START_DATA_REG) ? lb_wr_en  : 1'b0;
  assign  end_ram_wr_en_c             = (lb_addr  ==  SYS_MEM_PART_MNGR_END_DATA_REG)   ? lb_wr_en  : 1'b0;

  assign  mem_start_addr              = start_ram_rdata_w[MEM_ADDR_W-1:0];
  assign  mem_end_addr                = end_ram_rdata_w[MEM_ADDR_W-1:0];


  /*  Instantiate Memories  */
  sync_spram_40W_256D   start_ram_inst
  (
    .address            (ram_addr_c),
    .clock              (clk),
    .data               (ram_wdata_w),
    .wren               (start_ram_wr_en_c),
    .q                  (start_ram_rdata_w)
  );

  sync_spram_40W_256D   end_ram_inst
  (
    .address            (ram_addr_c),
    .clock              (clk),
    .data               (ram_wdata_w),
    .wren               (end_ram_wr_en_c),
    .q                  (end_ram_rdata_w)
  );


endmodule // sys_mem_part_mngr

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[14-12-2014  07:55:45 PM][mammenx] Fixed misc compilation errors

[11-12-2014  06:54:58 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
