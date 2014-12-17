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
 -- Module Name       : sys_mem_arb
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module arbitrates between different agents for
                        accessing the sys_mem.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module sys_mem_arb #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME         = "SYS_MEM_ARB",
  parameter LB_DATA_W           = 32,
  parameter LB_ADDR_W           = 8,
  parameter MEM_DATA_W          = 32,
  parameter MEM_ADDR_W          = 27,
  parameter NUM_AGENTS          = 2,
  parameter DEFAULT_DATA_VAL    = 'hdeadbabe,

  parameter int ARB_WEIGHT_LIST [NUM_AGENTS-1:0]  = '{8,8},
  parameter ARB_TOTAL_WEIGHT    = 16,

  parameter AGENT_ID_W          = $clog2(NUM_AGENTS)  //Do not override

) (

  //--------------------- Ports -------------------------
  input                           clk,
  input                           rst_n,

  input                           lb_wr_en,
  input                           lb_rd_en,
  input       [LB_ADDR_W-1:0]     lb_addr,
  input       [LB_DATA_W-1:0]     lb_wr_data,
  output  reg                     lb_wr_valid,
  output  reg                     lb_rd_valid,
  output  reg [LB_DATA_W-1:0]     lb_rd_data,

  output      [NUM_AGENTS-1:0]    agent_wait,
  input       [NUM_AGENTS-1:0]    agent_wren,
  input       [NUM_AGENTS-1:0]    agent_rden,
  input       [MEM_ADDR_W-1:0]    agent_addr  [NUM_AGENTS-1:0],
  input       [MEM_DATA_W-1:0]    agent_wdata [NUM_AGENTS-1:0],
  output reg  [NUM_AGENTS-1:0]    agent_rd_valid,
  output reg  [MEM_DATA_W-1:0]    agent_rdata [NUM_AGENTS-1:0],

  output reg  [AGENT_ID_W-1:0]    agent_id,
  input       [MEM_ADDR_W-1:0]    agent_offset,

  input                           cntrlr_wait,
  output                          cntrlr_wren,
  output                          cntrlr_rden,
  output      [MEM_ADDR_W-1:0]    cntrlr_addr,
  output      [MEM_DATA_W-1:0]    cntrlr_wdata,
  input                           cntrlr_rd_valid,
  input       [MEM_DATA_W-1:0]    cntrlr_rdata

);

//----------------------- Local Parameters Declarations -------------------
  `include  "sys_mem_arb_regmap.svh"

  localparam  ARB_WEIGHT_CNTR_W   = $clog2(ARB_TOTAL_WEIGHT);
  localparam  BFFR_W              = 80;
  localparam  BFFR_OCC_W          = 2 + MEM_ADDR_W  + MEM_DATA_W;
  localparam  BFFR_DELAY          = 2;

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg   [ARB_WEIGHT_CNTR_W-1:0]   arb_run_cntr [NUM_AGENTS-1:0];
  reg   [ARB_WEIGHT_CNTR_W-1:0]   arb_total_cnt_c;
  reg   [BFFR_DELAY-1:0]          ingr_bffr_del_f;
  reg                             ingr_bffr_oflw_f;
  reg                             ingr_bffr_uflw_f;
  reg                             egr_bffr_oflw_f;
  reg                             egr_bffr_uflw_f;

//----------------------- Internal Wire Declarations ----------------------
  wire                            arb_cntr_rst_c;
  wire  [NUM_AGENTS-1:0]          arb_slot_valid_c;
  wire  [NUM_AGENTS-1:0]          arb_req_c;

  wire                            ingr_bffr_wr_en;
  wire  [BFFR_W-1:0]              ingr_bffr_wdata;
  wire                            ingr_bffr_rd_en;
  wire  [BFFR_W-1:0]              ingr_bffr_rdata;
  wire                            ingr_bffr_full;
  wire                            ingr_bffr_empty;

  wire                            egr_bffr_wr_en;
  wire  [9:0]                     egr_bffr_wdata;
  wire                            egr_bffr_rd_en;
  wire  [9:0]                     egr_bffr_rdata;
  wire                            egr_bffr_full;
  wire                            egr_bffr_empty;

  genvar  i;
  integer n;



//----------------------- Start of Code -----------------------------------

  /*  Local Bus Logic */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      lb_wr_valid             <=  0;
      lb_rd_valid             <=  0;
      lb_rd_data              <=  0;

      egr_bffr_oflw_f         <=  0;
      egr_bffr_uflw_f         <=  0;
      ingr_bffr_oflw_f        <=  0;
      ingr_bffr_uflw_f        <=  0;
    end
    else
    begin
      lb_wr_valid             <=  lb_wr_en;

      if(lb_rd_en)
      begin
        case(lb_addr)

          SYS_MEM_ARB_STATUS_REG  :
          begin
            lb_rd_data        <=  {{(LB_DATA_W-4){1'b0}},egr_bffr_uflw_f,egr_bffr_oflw_f,ingr_bffr_uflw_f,ingr_bffr_oflw_f};
          end

          default :
          begin
            lb_rd_data        <=  DEFAULT_DATA_VAL;
          end

        endcase
      end

      lb_rd_valid             <=  lb_rd_en;

      if(ingr_bffr_uflw_f)
      begin
        ingr_bffr_uflw_f      <=  (lb_addr  ==  SYS_MEM_ARB_STATUS_REG) ? ~lb_rd_en : ingr_bffr_uflw_f;
      end
      else
      begin
        ingr_bffr_uflw_f      <=  ingr_bffr_rd_en & ingr_bffr_empty;
      end

      if(ingr_bffr_oflw_f)
      begin
        ingr_bffr_oflw_f      <=  (lb_addr  ==  SYS_MEM_ARB_STATUS_REG) ? ~lb_rd_en : ingr_bffr_oflw_f;
      end
      else
      begin
        ingr_bffr_oflw_f      <=  ingr_bffr_wr_en & ingr_bffr_full;
      end
 
      if(egr_bffr_uflw_f)
      begin
        egr_bffr_uflw_f       <=  (lb_addr  ==  SYS_MEM_ARB_STATUS_REG) ? ~lb_rd_en : egr_bffr_uflw_f;
      end
      else
      begin
        egr_bffr_uflw_f       <=  egr_bffr_rd_en & egr_bffr_empty;
      end

      if(egr_bffr_oflw_f)
      begin
        egr_bffr_oflw_f       <=  (lb_addr  ==  SYS_MEM_ARB_STATUS_REG) ? ~lb_rd_en : egr_bffr_oflw_f;
      end
      else
      begin
        egr_bffr_oflw_f       <=  egr_bffr_wr_en & egr_bffr_full;
      end
 
    end
  end

  /*  Arbitration Running Counter Logic */
  generate
    for(i=0;  i<NUM_AGENTS; i++)
    begin : arb_gen
      assign  arb_req_c[i]        = agent_wren[i]  | agent_rden[i];
      assign  arb_slot_valid_c[i] = arb_req_c[i]   & ~agent_wait[i];

      always@(posedge clk,  negedge rst_n)
      begin
        if(~rst_n)
        begin
          arb_run_cntr[i]     <=  0;
        end
        else
        begin
          if(arb_cntr_rst_c)
          begin
            arb_run_cntr[i]   <=  0;
          end
          else if(arb_run_cntr[i] < ARB_WEIGHT_LIST[i])
          begin
            arb_run_cntr[i]   <=  arb_run_cntr[i] + arb_slot_valid_c[i];
          end
        end
      end
    end
  endgenerate

  always@(*)
  begin
    arb_total_cnt_c = 0;

    for(n=0;  n<NUM_AGENTS; n++)
    begin
      arb_total_cnt_c = arb_total_cnt_c + arb_run_cntr[n];
    end
  end

  assign  arb_cntr_rst_c  = (arb_total_cnt_c  ==  ARB_TOTAL_WEIGHT) ? 1'b1  : 1'b0;


  /*  Decde Agent ID */
  always@(*)
  begin
    agent_id  = 0;

    for(n=1;  n<NUM_AGENTS; n++)  //Select agent with least run time count from
    begin                         //list of competing agents
      if(arb_req_c[n] & (arb_run_cntr[n]  < arb_run_cntr[agent_id]))
      begin
        agent_id  = n;
      end
    end
  end

  /*  Traffic Management Logic  */
  generate
    for(i=0;  i<NUM_AGENTS; i++)
    begin : traffic_mgmt_gen
      assign  agent_wait[i]   =   arb_req_c[i]  ? ((agent_id == i)  ? cntrlr_wait : 1'b1)
                                                : 1'b0;
    end
  endgenerate

  /*  Buffer arbitrated xtn */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      ingr_bffr_del_f         <=  0;
    end
    else
    begin
      if(~cntrlr_wait)
      begin
        ingr_bffr_del_f       <=  {ingr_bffr_del_f[BFFR_DELAY-2:0],ingr_bffr_wr_en};
      end
    end
  end

  assign  ingr_bffr_wr_en  = |arb_slot_valid_c;
  assign  ingr_bffr_wdata  = { {(BFFR_W-BFFR_OCC_W){1'b0}},
                               agent_wren[agent_id],
                               agent_rden[agent_id],
                               agent_wdata[agent_id],
                               agent_addr[agent_id]
                             };

  ff_80x32_fwft   ingr_bffr_inst
  (
    .aclr         (~rst_n),
    .clock        (clk),
    .data         (ingr_bffr_wdata),
    .rdreq        (ingr_bffr_rd_en),
    .wrreq        (ingr_bffr_wr_en),
    .empty        (ingr_bffr_empty),
    .full         (ingr_bffr_full),
    .q            (ingr_bffr_rdata),
    .usedw        ()
  );

  assign  ingr_bffr_rd_en = ingr_bffr_del_f[BFFR_DELAY-1]  & ~cntrlr_wait;

  assign  cntrlr_wren     = ingr_bffr_rdata[BFFR_OCC_W-1]  & ingr_bffr_rd_en;
  assign  cntrlr_rden     = ingr_bffr_rdata[BFFR_OCC_W-2]  & ingr_bffr_rd_en;
  assign  cntrlr_wdata    = ingr_bffr_rdata[BFFR_OCC_W-3:MEM_ADDR_W];
  assign  cntrlr_addr     = ingr_bffr_rdata[MEM_ADDR_W-1:0]  + agent_offset;



  assign  egr_bffr_wr_en  = |(agent_rden  & ~agent_wait);
  assign  egr_bffr_wdata  = {{(10-AGENT_ID_W){1'b0}}, agent_id};

  ff_10x1024_fwft egr_bffr_inst
  (
    .aclr         (~rst_n),
    .clock        (clk),
    .data         (egr_bffr_wdata),
    .rdreq        (egr_bffr_rd_en),
    .wrreq        (egr_bffr_wr_en),
    .empty        (egr_bffr_empty),
    .full         (egr_bffr_full),
    .q            (egr_bffr_rdata),
    .usedw        ()
  );

  assign  egr_bffr_rd_en  = cntrlr_rd_valid;

  generate
    for(i=0;  i<NUM_AGENTS; i++)
    begin
      always@(posedge clk,  negedge rst_n)
      begin
        if(~rst_n)
        begin
          agent_rd_valid[i]   <=  0;
          agent_rdata[i]      <=  0;
        end
        else
        begin
          agent_rd_valid[i]   <=  (egr_bffr_rdata[AGENT_ID_W-1:0] ==  i)  ? cntrlr_rd_valid : 1'b0;
          agent_rdata[i]      <=  cntrlr_rdata;
        end
      end
    end
  endgenerate

endmodule // sys_mem_arb

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[14-12-2014  07:55:45 PM][mammenx] Fixed misc compilation errors

[14-12-2014  06:48:46 PM][mammenx] Initial COmmit


 --------------------------------------------------------------------------
*/
