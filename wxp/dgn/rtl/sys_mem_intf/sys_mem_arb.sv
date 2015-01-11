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

  parameter ARB_TOTAL_WEIGHT    = 16,
  parameter bit [NUM_AGENTS-1:0]  [31:0]  ARB_WEIGHT_LIST = '{8,8},

  parameter AGENT_ID_W          = $clog2(NUM_AGENTS)  //Do not override

) (

  //--------------------- Ports -------------------------
  input                           clk,
  input                           rst_n,

  input                           cntrlr_clk,
  input                           cntrlr_rst_n,

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
  localparam  BFFR_DEPTH          = 32;
  localparam  BFFR_USED_W         = $clog2(BFFR_DEPTH);
  localparam  BFFR_AFULL_VAL      = BFFR_DEPTH  - 4;
  localparam  BFFR_OCC_W          = 2 + MEM_ADDR_W  + MEM_DATA_W;
  localparam  BFFR_DELAY          = 2;

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg   [NUM_AGENTS-1:0]  [ARB_WEIGHT_CNTR_W-1:0] arb_run_cntr_f;
  reg   [ARB_WEIGHT_CNTR_W-1:0]   arb_total_cnt_c;
  reg   [BFFR_DELAY-1:0]          ingr_bffr0_del_f;
  reg                             ingr_bffr0_oflw_f;
  reg                             ingr_bffr0_uflw_f;
  reg                             egr_bffr0_oflw_f;
  reg                             egr_bffr0_uflw_f;

//----------------------- Internal Wire Declarations ----------------------
  wire  [ARB_WEIGHT_CNTR_W-1:0]   arb_high_cnt_list_c [NUM_AGENTS-1:0];
  wire  [ARB_WEIGHT_CNTR_W-1:0]   arb_low_cnt_list_c  [NUM_AGENTS-1:0];
  wire  [ARB_WEIGHT_CNTR_W-1:0]   least_arb_high_cnt;
  wire  [ARB_WEIGHT_CNTR_W-1:0]   least_arb_low_cnt;
  wire  [AGENT_ID_W-1:0]          next_agent_id_high;
  wire  [AGENT_ID_W-1:0]          next_agent_id_low;

  wire                            arb_cntr_rst_c;
  wire  [NUM_AGENTS-1:0]          arb_slot_valid_c;
  wire  [NUM_AGENTS-1:0]          arb_req_c;
  wire  [NUM_AGENTS-1:0]          agent_priority_high_n_low_c;

  wire                            ingr_bffr0_wr_en;
  wire  [BFFR_W-1:0]              ingr_bffr0_wdata;
  wire                            ingr_bffr0_rd_en;
  wire  [BFFR_W-1:0]              ingr_bffr0_rdata;
  wire                            ingr_bffr0_full;
  wire                            ingr_bffr0_empty;
  wire  [BFFR_USED_W-1:0]         ingr_bffr0_used;
  wire                            ingr_bffr0_afull;

  wire                            ingr_bffr1_wr_en;
  wire  [BFFR_W-1:0]              ingr_bffr1_wdata;
  wire                            ingr_bffr1_rd_en;
  wire  [BFFR_W-1:0]              ingr_bffr1_rdata;
  wire                            ingr_bffr1_full;
  wire                            ingr_bffr1_empty;
  wire  [BFFR_USED_W-1:0]         ingr_bffr1_used;
  wire                            ingr_bffr1_afull;

  wire                            egr_bffr0_wr_en;
  wire  [9:0]                     egr_bffr0_wdata;
  wire                            egr_bffr0_rd_en;
  wire  [9:0]                     egr_bffr0_rdata;
  wire                            egr_bffr0_full;
  wire                            egr_bffr0_empty;

  wire                            egr_bffr1_wr_en;
  wire  [BFFR_W-1:0]              egr_bffr1_wdata;
  wire                            egr_bffr1_rd_en;
  wire  [BFFR_W-1:0]              egr_bffr1_rdata;
  wire                            egr_bffr1_full;
  wire                            egr_bffr1_empty;
  wire  [BFFR_USED_W-1:0]         egr_bffr1_used;

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

      egr_bffr0_oflw_f        <=  0;
      egr_bffr0_uflw_f        <=  0;
      ingr_bffr0_oflw_f       <=  0;
      ingr_bffr0_uflw_f       <=  0;
    end
    else
    begin
      lb_wr_valid             <=  lb_wr_en;

      if(lb_rd_en)
      begin
        case(lb_addr)

          SYS_MEM_ARB_STATUS_REG  :
          begin
            lb_rd_data        <=  { {(LB_DATA_W-4){1'b0}},
                                    egr_bffr0_uflw_f,
                                    egr_bffr0_oflw_f,
                                    ingr_bffr0_uflw_f,
                                    ingr_bffr0_oflw_f
                                  };
          end

          default :
          begin
            lb_rd_data        <=  DEFAULT_DATA_VAL;
          end

        endcase
      end

      lb_rd_valid             <=  lb_rd_en;

      if(ingr_bffr0_uflw_f)
      begin
        ingr_bffr0_uflw_f     <=  (lb_addr  ==  SYS_MEM_ARB_STATUS_REG) ? ~lb_rd_en : ingr_bffr0_uflw_f;
      end
      else
      begin
        ingr_bffr0_uflw_f     <=  ingr_bffr0_rd_en & ingr_bffr0_empty;
      end

      if(ingr_bffr0_oflw_f)
      begin
        ingr_bffr0_oflw_f     <=  (lb_addr  ==  SYS_MEM_ARB_STATUS_REG) ? ~lb_rd_en : ingr_bffr0_oflw_f;
      end
      else
      begin
        ingr_bffr0_oflw_f     <=  ingr_bffr0_wr_en & ingr_bffr0_full;
      end
 
      if(egr_bffr0_uflw_f)
      begin
        egr_bffr0_uflw_f      <=  (lb_addr  ==  SYS_MEM_ARB_STATUS_REG) ? ~lb_rd_en : egr_bffr0_uflw_f;
      end
      else
      begin
        egr_bffr0_uflw_f      <=  egr_bffr0_rd_en & egr_bffr0_empty;
      end

      if(egr_bffr0_oflw_f)
      begin
        egr_bffr0_oflw_f      <=  (lb_addr  ==  SYS_MEM_ARB_STATUS_REG) ? ~lb_rd_en : egr_bffr0_oflw_f;
      end
      else
      begin
        egr_bffr0_oflw_f      <=  egr_bffr0_wr_en & egr_bffr0_full;
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
          arb_run_cntr_f[i]   <=  0;
        end
        else
        begin
          if(arb_cntr_rst_c)
          begin
            arb_run_cntr_f[i] <=  0;
          end
          else if(arb_run_cntr_f[i] < ARB_WEIGHT_LIST[i])
          begin
            arb_run_cntr_f[i] <=  arb_run_cntr_f[i] + arb_slot_valid_c[i];
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
      arb_total_cnt_c = arb_total_cnt_c + arb_run_cntr_f[n];
    end
  end

  assign  arb_cntr_rst_c  = (arb_total_cnt_c  ==  ARB_TOTAL_WEIGHT) ? 1'b1  : 1'b0;


  /*  Generate Priorities */
  generate
  begin
    for(i=0;  i<NUM_AGENTS; i++)
    begin : gen_agent_priority
      assign  agent_priority_high_n_low_c[i]  = (arb_run_cntr_f[i]  < ARB_WEIGHT_LIST[i]) ? 1'b1  : 1'b0;
    end
  end
  endgenerate

  /*  Prepare list of high/low cnts to be sent to least filter  */
  generate
    for(i=0;  i<NUM_AGENTS; i++)
    begin : gen_cnt_list
      assign  arb_high_cnt_list_c[i]  = (agent_priority_high_n_low_c[i] & arb_req_c[i])   ? arb_run_cntr_f[i] :
                                                                                            {ARB_WEIGHT_CNTR_W{1'b1}};

      assign  arb_low_cnt_list_c[i]   = (~agent_priority_high_n_low_c[i] & arb_req_c[i])  ? arb_run_cntr_f[i] :
                                                                                            {ARB_WEIGHT_CNTR_W{1'b1}};
    end
  endgenerate

  /*
    * Decde Agent ID
    * Method:
    *   - Agents are classified into high & low priorities based on the credits consumed in
            the present arbitration cycle
        - The next agent is selected for each of the two groups based on least credits consumed
        - Final choice between the two agents selected from the two groups is made
  */

  least_filter #(
    .NUM_DATA     (NUM_AGENTS),
    .DATA_W       (ARB_WEIGHT_CNTR_W)
  ) least_filter_high_inst  (

    .clk          (clk),
    .rst_n        (rst_n),

    .data_i       (arb_high_cnt_list_c),

    .data_o       (least_arb_high_cnt),
    .data_idx_o   (next_agent_id_high)
  );

  least_filter #(
    .NUM_DATA     (NUM_AGENTS),
    .DATA_W       (ARB_WEIGHT_CNTR_W)
  ) least_filter_low_inst  (

    .clk          (clk),
    .rst_n        (rst_n),

    .data_i       (arb_low_cnt_list_c),

    .data_o       (least_arb_low_cnt),
    .data_idx_o   (next_agent_id_low)
  );


  always@(*)
  begin
    //Select final agent
    agent_id  = |(agent_priority_high_n_low_c & arb_req_c)  ? next_agent_id_high  : next_agent_id_low;
  end

  /*  Traffic Management Logic  */
  generate
    for(i=0;  i<NUM_AGENTS; i++)
    begin : traffic_mgmt_gen
      assign  agent_wait[i]   =   arb_req_c[i]  ? ((agent_id == i)  ? (ingr_bffr0_afull | ingr_bffr1_afull) : 1'b1)
                                                : 1'b0;
    end
  endgenerate

  /*  Buffer arbitrated xtn */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      ingr_bffr0_del_f        <=  0;
    end
    else
    begin
      ingr_bffr0_del_f[BFFR_DELAY-1:1] <=  ingr_bffr0_del_f[BFFR_DELAY-2:0];
      ingr_bffr0_del_f[0]              <=  ingr_bffr0_wr_en;
    end
  end

  assign  ingr_bffr0_wr_en  = |arb_slot_valid_c;
  assign  ingr_bffr0_wdata  = { {(BFFR_W-BFFR_OCC_W){1'b0}},
                               agent_wren[agent_id],
                               agent_rden[agent_id],
                               agent_wdata[agent_id],
                               agent_addr[agent_id]
                             };

  ff_80x32_fwft         ingr_bffr0_inst
  (
    .aclr               (~rst_n),
    .data               (ingr_bffr0_wdata),
    .rdreq              (ingr_bffr0_rd_en),
    .clock              (clk),
    .wrreq              (ingr_bffr0_wr_en),
    .q                  (ingr_bffr0_rdata),
    .empty              (ingr_bffr0_empty),
    .full               (ingr_bffr0_full),
    .usedw              (ingr_bffr0_used)
  );
  assign  ingr_bffr0_afull  = (ingr_bffr1_used  >=  BFFR_AFULL_VAL) ? 1'b1  : 1'b0;

  assign  ingr_bffr0_rd_en = ingr_bffr0_del_f[BFFR_DELAY-1];


  assign  ingr_bffr1_wr_en  = ingr_bffr0_del_f[BFFR_DELAY-1];
  assign  ingr_bffr1_wdata[BFFR_W-1:MEM_ADDR_W] = ingr_bffr0_rdata[BFFR_W-1:MEM_ADDR_W];
  assign  ingr_bffr1_wdata[MEM_ADDR_W-1:0]      = ingr_bffr0_rdata[MEM_ADDR_W-1:0]  + agent_offset;

  ff_80x32_fwft_async   ingr_bffr1_inst
  (
    .aclr               (~rst_n),
    .data               (ingr_bffr1_wdata),
    .rdclk              (cntrlr_clk),
    .rdreq              (ingr_bffr1_rd_en),
    .wrclk              (clk),
    .wrreq              (ingr_bffr1_wr_en),
    .q                  (ingr_bffr1_rdata),
    .rdempty            (ingr_bffr1_empty),
    .rdusedw            (),
    .wrfull             (ingr_bffr1_full),
    .wrusedw            (ingr_bffr1_used)
  );
  assign  ingr_bffr1_afull  = (ingr_bffr1_used  >=  BFFR_AFULL_VAL) ? 1'b1  : 1'b0;

  assign  ingr_bffr1_rd_en  = ~ingr_bffr1_empty & ~cntrlr_wait;

  assign  cntrlr_wren     = ingr_bffr1_rdata[BFFR_OCC_W-1]  & ingr_bffr1_rd_en;
  assign  cntrlr_rden     = ingr_bffr1_rdata[BFFR_OCC_W-2]  & ingr_bffr1_rd_en;
  assign  cntrlr_wdata    = ingr_bffr1_rdata[BFFR_OCC_W-3:MEM_ADDR_W];
  assign  cntrlr_addr     = ingr_bffr1_rdata[MEM_ADDR_W-1:0];


  assign  egr_bffr0_wr_en  = |(agent_rden  & ~agent_wait);
  assign  egr_bffr0_wdata  = {{(10-AGENT_ID_W){1'b0}}, agent_id};

  ff_10x1024_fwft         egr_bffr0_inst
  (
    .aclr                 (~rst_n),
    .data                 (egr_bffr0_wdata),
    .rdreq                (egr_bffr0_rd_en),
    .clock                (clk),
    .wrreq                (egr_bffr0_wr_en),
    .q                    (egr_bffr0_rdata),
    .empty                (egr_bffr0_empty),
    .full                 (egr_bffr0_full),
    .usedw                ()
  );

  assign  egr_bffr0_rd_en  = ~egr_bffr1_empty;


  assign  egr_bffr1_wr_en = cntrlr_rd_valid;
  assign  egr_bffr1_wdata = {{(BFFR_W-MEM_DATA_W){1'b0}}, cntrlr_rdata};

  ff_80x32_fwft_async   egr_bffr1_inst
  (
    .aclr               (~rst_n),
    .data               (egr_bffr1_wdata),
    .rdclk              (clk),
    .rdreq              (egr_bffr1_rd_en),
    .wrclk              (cntrlr_clk),
    .wrreq              (egr_bffr1_wr_en),
    .q                  (egr_bffr1_rdata),
    .rdempty            (egr_bffr1_empty),
    .rdusedw            (),
    .wrfull             (egr_bffr1_full),
    .wrusedw            (egr_bffr1_used)
  );

  assign  egr_bffr1_rd_en = ~egr_bffr1_empty; //self emptying

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
          agent_rd_valid[i]   <=  (egr_bffr0_rdata[AGENT_ID_W-1:0] ==  i)  ? ~egr_bffr1_empty : 1'b0;
          agent_rdata[i]      <=  egr_bffr1_rdata[MEM_DATA_W-1:0];
        end
      end
    end
  endgenerate

endmodule // sys_mem_arb

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[11-01-2015  06:18:40 PM][mammenx] Converted system memory controller interface to seperate clock domain

[11-01-2015  05:34:59 PM][mammenx] Added one more FIFO in the ingress path to fix address offset issue

[11-01-2015  01:08:31 PM][mammenx] Fixed arbitration logic based on simulation

[14-12-2014  07:55:45 PM][mammenx] Fixed misc compilation errors

[14-12-2014  06:48:46 PM][mammenx] Initial COmmit


 --------------------------------------------------------------------------
*/
