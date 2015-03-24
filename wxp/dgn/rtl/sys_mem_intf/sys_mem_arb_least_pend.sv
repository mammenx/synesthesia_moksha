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
 -- Module Name       : sys_mem_arb_least_pend
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This arbiter selects the next xtn to controller
                        based on the FIFO with least pending xtns.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module sys_mem_arb_least_pend #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME             = "SYS_MEM_ARB_LEAST_PEND",
  parameter LB_DATA_W               = 32,
  parameter LB_ADDR_W               = 8,
  parameter MEM_DATA_W              = 32,
  parameter MEM_ADDR_W              = 27,
  parameter NUM_AGENTS              = 2,
  parameter REGISTER_CNTRLR_OUTPUTS = 0,
  parameter DEFAULT_DATA_VAL        = 'hdeadbabe,

  parameter AGENT_ID_W              = $clog2(NUM_AGENTS)  //Do not override

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
  output      [NUM_AGENTS-1:0]    agent_rd_valid,
  output      [MEM_DATA_W-1:0]    agent_rdata [NUM_AGENTS-1:0],

  output reg  [AGENT_ID_W-1:0]    agent_id,
  input       [MEM_ADDR_W-1:0]    agent_start_addr,
  input       [MEM_ADDR_W-1:0]    agent_end_addr,

  input                           cntrlr_rdy,
  output reg                      cntrlr_wren,
  output reg                      cntrlr_rden,
  output reg  [MEM_ADDR_W-1:0]    cntrlr_addr,
  output reg  [MEM_DATA_W-1:0]    cntrlr_wdata,
  input                           cntrlr_rd_valid,
  input       [MEM_DATA_W-1:0]    cntrlr_rdata



);

//----------------------- Local Parameters Declarations -------------------
  `include  "sys_mem_arb_regmap.svh"

  localparam  INGR_BFFR_W             = 80;
  localparam  INGR_BFFR_DEPTH         = 32;
  localparam  INGR_BFFR_USED_W        = $clog2(INGR_BFFR_DEPTH);
  localparam  INGR_BFFR_OCC_W         = 2 + MEM_ADDR_W  + MEM_DATA_W;
  localparam  PART_MEM_DELAY          = 2 + 1;

  localparam  EGR_BFFR_0_W            = 10;
  localparam  EGR_BFFR_0_DEPTH        = 1024;

  localparam  EGR_BFFR_1_W            = 40;
  localparam  EGR_BFFR_1_DEPTH        = 32;

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg   [INGR_BFFR_USED_W-1:0] ingr_bffr_rused_norm_f [NUM_AGENTS-1:0];

  reg   [PART_MEM_DELAY-1:0]  part_mem_del_vec_f;

  reg   [MEM_ADDR_W-1:0]      agent_start_addr_f;
  reg   [MEM_ADDR_W-1:0]      agent_end_addr_f;

//----------------------- Internal Wire Declarations ----------------------
  wire  [AGENT_ID_W-1:0]      next_agent_id;

  wire                        clear_ff_flags_c;
  wire  [NUM_AGENTS-1:0]      ingr_bffr_ovrflow;
  wire  [NUM_AGENTS-1:0]      ingr_bffr_undrflow;
  wire  [NUM_AGENTS-1:0]      ingr_bffr_undrflow_sync;
  wire  [1:0]                 ingr_del_bffr_ovrflow;
  wire  [1:0]                 ingr_del_bffr_undrflow;
  wire  [1:0]                 ingr_del_bffr_ovrflow_sync;
  wire  [1:0]                 ingr_del_bffr_undrflow_sync;
  wire                        egr_bffr_0_ovrflow;
  wire                        egr_bffr_0_undrflow;
  wire                        egr_bffr_1_ovrflow;
  wire                        egr_bffr_1_undrflow;

  wire  [NUM_AGENTS-1:0]                    ingr_bffr_wren_c;
  wire  [NUM_AGENTS-1:0] [INGR_BFFR_W-1:0]  ingr_bffr_wdata_w;
  wire  [NUM_AGENTS-1:0]                    ingr_bffr_wfull_w;
  wire  [NUM_AGENTS-1:0]                    ingr_bffr_rden_c;
  wire  [NUM_AGENTS-1:0] [INGR_BFFR_W-1:0]  ingr_bffr_rdata_w;
  wire  [NUM_AGENTS-1:0]                    ingr_bffr_rempty_w;
  wire  [INGR_BFFR_USED_W-1:0] ingr_bffr_rused_w  [NUM_AGENTS-1:0];

  wire  [1:0]                    ingr_del_bffr_wren_c;
  wire  [1:0] [INGR_BFFR_W-1:0]  ingr_del_bffr_wdata_w;
  wire  [1:0]                    ingr_del_bffr_full_w;
  wire  [1:0]                    ingr_del_bffr_rden_c;
  wire  [1:0] [INGR_BFFR_W-1:0]  ingr_del_bffr_rdata_w;
  wire  [1:0]                    ingr_del_bffr_empty_w;
  wire                           ingr_del_bffr_full_all_c;

  wire                        cntrlr_unpack_wren_w;
  wire                        cntrlr_unpack_rden_w;
  wire  [MEM_ADDR_W-1:0]      cntrlr_unpack_addr_w;
  wire  [MEM_DATA_W-1:0]      cntrlr_unpack_wdata_w;

  wire                        egr_bffr_0_wren_c;
  wire  [EGR_BFFR_0_W-1:0]    egr_bffr_0_wdata_w;
  wire                        egr_bffr_0_wfull_w;
  wire                        egr_bffr_0_rden_c;
  wire  [EGR_BFFR_0_W-1:0]    egr_bffr_0_rdata_w;
  wire                        egr_bffr_0_rempty_w;

  wire                        egr_bffr_1_wren_c;
  wire  [EGR_BFFR_1_W-1:0]    egr_bffr_1_wdata_w;
  wire                        egr_bffr_1_wfull_w;
  wire                        egr_bffr_1_rden_c;
  wire  [EGR_BFFR_1_W-1:0]    egr_bffr_1_rdata_w;
  wire                        egr_bffr_1_rempty_w;

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
    end
    else
    begin
      lb_wr_valid             <=  lb_wr_en;

      if(lb_rd_en)
      begin
        case(lb_addr)

          SYS_MEM_ARB_STATUS_REG  :
          begin
            lb_rd_data[7:0]   <=  {
                                    ingr_del_bffr_ovrflow_sync[1],
                                    ingr_del_bffr_undrflow_sync[1],
                                    ingr_del_bffr_ovrflow_sync[0],
                                    ingr_del_bffr_undrflow_sync[0],
                                    egr_bffr_1_ovrflow,
                                    egr_bffr_1_undrflow,
                                    egr_bffr_0_ovrflow,
                                    egr_bffr_0_undrflow
                                  };

            for(n=0;  n<NUM_AGENTS; n++)
            begin
              lb_rd_data[8 + (n*2)]     <=  ingr_bffr_undrflow_sync[n];
              lb_rd_data[8 + (n*2) + 1] <=  ingr_bffr_ovrflow[n];
            end
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

  //Clear FIFO flags each time they are read
  assign  clear_ff_flags_c    =   (lb_addr  ==  SYS_MEM_ARB_STATUS_REG) ? lb_rd_en  : 1'b0;


  /*
    * Ingress Buffer Logic
    * These buffers (one per agent) hold xtns while waiting to be serviced by the arbiter
  */
  generate
    for(i=0;  i<NUM_AGENTS; i++)
    begin : gen_agent_ingr
      assign  ingr_bffr_wren_c[i]   = (agent_wren[i]  | agent_rden[i])  & ~ingr_bffr_wfull_w[i];

      assign  ingr_bffr_wdata_w[i]  = { {(INGR_BFFR_W-INGR_BFFR_OCC_W){1'b0}},
                                        agent_wren[i],
                                        agent_rden[i],
                                        agent_wdata[i],
                                        agent_addr[i]
                                      };

      assign  agent_wait[i]         = ingr_bffr_wfull_w[i];

      ff_80x32_fwft_async   ingr_bffr
      (
        .aclr               (~rst_n),
        .data               (ingr_bffr_wdata_w[i]),
        .rdclk              (cntrlr_clk),
        .rdreq              (ingr_bffr_rden_c[i]),
        .wrclk              (clk),
        .wrreq              (ingr_bffr_wren_c[i]),
        .q                  (ingr_bffr_rdata_w[i]),
        .rdempty            (ingr_bffr_rempty_w[i]),
        .rdusedw            (ingr_bffr_rused_w[i]),
        .wrfull             (ingr_bffr_wfull_w[i]),
        .wrusedw            ()
      );

      assign  ingr_bffr_rden_c[i] = (agent_id ==  i)  ? ~ingr_bffr_rempty_w[i]  & ~ingr_del_bffr_full_all_c
                                                      : 1'b0;

      ff_flags #(
        .NUM_INTFS  (1)

      ) ingr_bffr_flags (

        .clear_clk          (clk),
        .clear_clk_rst_n    (rst_n),

        .wr_clk             (clk),
        .wr_clk_rst_n       (rst_n),

        .rd_clk             (cntrlr_clk),
        .rd_clk_rst_n       (cntrlr_rst_n),

        .clear_flags        (clear_ff_flags_c),

        .ff_wren            (ingr_bffr_wren_c[i]),
        .ff_full            (ingr_bffr_wfull_w[i]),

        .ff_rden            (ingr_bffr_rden_c[i]),
        .ff_empty           (ingr_bffr_rempty_w[i]),

        .ff_ovrflw          (ingr_bffr_ovrflow[i]),
        .ff_undrflw         (ingr_bffr_undrflow[i])

      );

      dd_sync ingr_bffr_undrflow_dd_sync_inst
      (
        .clk          (clk),
        .rst_n        (rst_n),

        .signal_id    (ingr_bffr_undrflow[i]),

        .signal_od    (ingr_bffr_undrflow_sync[i])
      );
    end
  endgenerate


  /*  Arbitration Logic */
  always@(posedge cntrlr_clk, negedge cntrlr_rst_n)
  begin
    if(~cntrlr_rst_n)
    begin
      for(n=0;  n<NUM_AGENTS; n++)
      begin
        ingr_bffr_rused_norm_f[n] <=  0;
      end

      agent_id                <=  0;

      part_mem_del_vec_f      <=  0;

      agent_start_addr_f      <=  0;
      agent_end_addr_f        <=  0;
    end
    else
    begin
      //Normalise the rused value to max if 0
      for(n=0;  n<NUM_AGENTS; n++)
      begin
        ingr_bffr_rused_norm_f[n] <=  (ingr_bffr_rused_w[n] ==  0)  ? {INGR_BFFR_USED_W{1'b1}} : ingr_bffr_rused_w[n];
      end

      agent_id                <=  next_agent_id;

      part_mem_del_vec_f      <=  {part_mem_del_vec_f[PART_MEM_DELAY-2:0],  ingr_bffr_rden_c[agent_id]};

      //Register start/end addresses from part_mngr
      //This will increase pipe delay by 1 clock
      agent_start_addr_f      <=  agent_start_addr;
      agent_end_addr_f        <=  agent_end_addr;
    end
  end

  least_filter #(
    .NUM_DATA     (NUM_AGENTS),
    .DATA_W       (INGR_BFFR_USED_W)
  ) least_filter_inst  (

    .clk          (cntrlr_clk),
    .rst_n        (cntrlr_rst_n),

    .data_i       (ingr_bffr_rused_norm_f),

    .data_o       (),
    .data_idx_o   (next_agent_id)
  );


  /*  
    * Ingress Delay Buffer 0
    * This Fifo holds the arbitrated xtns until the partition manager returns the start/end addresses
  */
  assign  ingr_del_bffr_wren_c[0]   = ingr_bffr_rden_c[agent_id];
  assign  ingr_del_bffr_wdata_w[0]  = ingr_bffr_rdata_w[agent_id];

  ff_80x32_fwft     ingr_del_bffr0_inst
  (
    .aclr           (~cntrlr_rst_n),
    .clock          (cntrlr_clk),
    .data           (ingr_del_bffr_wdata_w[0]),
    .rdreq          (ingr_del_bffr_rden_c[0]),
    .wrreq          (ingr_del_bffr_wren_c[0]),
    .empty          (ingr_del_bffr_empty_w[0]),
    .full           (ingr_del_bffr_full_w[0]),
    .q              (ingr_del_bffr_rdata_w[0]),
    .usedw          ()
  );


  assign  ingr_del_bffr_rden_c[0]   = part_mem_del_vec_f[PART_MEM_DELAY-1];

  assign  ingr_del_bffr_full_all_c  = ingr_del_bffr_full_w[0] | ingr_del_bffr_full_w[1];

  /*  
    * Ingress Delay Buffer 1
    * This Fifo holds the xtn with modified start/end address data from partition manager
  */
  assign  ingr_del_bffr_wren_c[1]   = part_mem_del_vec_f[PART_MEM_DELAY-1];
  assign  ingr_del_bffr_wdata_w[1][INGR_BFFR_W-1:MEM_ADDR_W]  = ingr_del_bffr_rdata_w[0][INGR_BFFR_W-1:MEM_ADDR_W];
  assign  ingr_del_bffr_wdata_w[1][MEM_ADDR_W-1:0]            = ingr_del_bffr_rdata_w[0][MEM_ADDR_W-1:0]  + agent_start_addr_f;

  ff_80x32_fwft     ingr_del_bffr1_inst
  (
    .aclr           (~cntrlr_rst_n),
    .clock          (cntrlr_clk),
    .data           (ingr_del_bffr_wdata_w[1]),
    .rdreq          (ingr_del_bffr_rden_c[1]),
    .wrreq          (ingr_del_bffr_wren_c[1]),
    .empty          (ingr_del_bffr_empty_w[1]),
    .full           (ingr_del_bffr_full_w[1]),
    .q              (ingr_del_bffr_rdata_w[1]),
    .usedw          ()
  );

  assign  ingr_del_bffr_rden_c[1]   = ~ingr_del_bffr_empty_w[1] & cntrlr_rdy;

  assign  { cntrlr_unpack_wren_w,
            cntrlr_unpack_rden_w,
            cntrlr_unpack_wdata_w,
            cntrlr_unpack_addr_w
          } = ingr_del_bffr_rdata_w[1][INGR_BFFR_OCC_W-1:0];

  ff_flags #(
    .NUM_INTFS  (2)

  ) ingr_del_bffr_flags (

    .clear_clk          (clk),
    .clear_clk_rst_n    (rst_n),

    .wr_clk             (cntrlr_clk),
    .wr_clk_rst_n       (cntrlr_rst_n),

    .rd_clk             (cntrlr_clk),
    .rd_clk_rst_n       (cntrlr_rst_n),

    .clear_flags        (clear_ff_flags_c),

    .ff_wren            (ingr_del_bffr_wren_c),
    .ff_full            (ingr_del_bffr_full_w),

    .ff_rden            (ingr_del_bffr_rden_c),
    .ff_empty           (ingr_del_bffr_empty_w),

    .ff_ovrflw          (ingr_del_bffr_ovrflow),
    .ff_undrflw         (ingr_del_bffr_undrflow)

  );

  dd_sync #(.SIGNAL_W(4)) ingr_bffr_flags_dd_sync_inst
  (
    .clk          (clk),
    .rst_n        (rst_n),

    .signal_id    ({ingr_del_bffr_ovrflow,ingr_del_bffr_undrflow}),

    .signal_od    ({ingr_del_bffr_ovrflow_sync,ingr_del_bffr_undrflow_sync})
  );

  generate
    if(REGISTER_CNTRLR_OUTPUTS)
    begin
      always@(posedge cntrlr_clk, negedge cntrlr_rst_n)
      begin
        if(~cntrlr_rst_n)
        begin
          cntrlr_wren             <=  0;
          cntrlr_rden             <=  0;
          cntrlr_addr             <=  0;
          cntrlr_wdata            <=  0;
        end
        else
        begin
          if(cntrlr_wren)
          begin
            cntrlr_wren           <=  cntrlr_rdy  ? ~ingr_del_bffr_empty_w  & cntrlr_unpack_wren_w  : cntrlr_wren;
          end
          else
          begin
            cntrlr_wren           <=  ~ingr_del_bffr_empty_w  & cntrlr_unpack_wren_w;
          end

          if(cntrlr_rden)
          begin
            cntrlr_rden           <=  cntrlr_rdy  ? ~ingr_del_bffr_empty_w  & cntrlr_unpack_rden_w  : cntrlr_rden;
          end
          else
          begin
            cntrlr_rden           <=  ~ingr_del_bffr_empty_w  & cntrlr_unpack_rden_w;
          end

          cntrlr_addr             <=  cntrlr_rdy  ? cntrlr_unpack_addr_w  : cntrlr_addr;
          cntrlr_wdata            <=  cntrlr_rdy  ? cntrlr_unpack_wdata_w : cntrlr_wdata;
        end
      end
    end
    else  //~REGISTER_CNTRLR_OUTPUTS
    begin
      always@(*)
      begin
        cntrlr_wren     = cntrlr_unpack_wren_w  & ~ingr_del_bffr_empty_w[1];
        cntrlr_rden     = cntrlr_unpack_rden_w  & ~ingr_del_bffr_empty_w[1];
        cntrlr_addr     = cntrlr_unpack_addr_w;
        cntrlr_wdata    = cntrlr_unpack_wdata_w;
      end
    end
  endgenerate

  /*
    * Egress Buffer 0
    * This Fifo holds the sequence of Agent IDs of read xtns that are yet to come from controller
  */
  assign  egr_bffr_0_wren_c     = ingr_bffr_rden_c[agent_id] & ingr_bffr_rdata_w[agent_id][INGR_BFFR_OCC_W-2];

  assign  egr_bffr_0_wdata_w    = { {(EGR_BFFR_0_W-AGENT_ID_W){1'b0}},
                                    agent_id
                                  };

  ff_10x1024_fwft_async   egr_bffr_0_inst
  (
    .aclr                 (~cntrlr_rst_n),
    .data                 (egr_bffr_0_wdata_w),
    .rdclk                (clk),
    .rdreq                (egr_bffr_0_rden_c),
    .wrclk                (cntrlr_clk),
    .wrreq                (egr_bffr_0_wren_c),
    .q                    (egr_bffr_0_rdata_w),
    .rdempty              (egr_bffr_0_rempty_w),
    .rdusedw              (),
    .wrfull               (egr_bffr_0_wfull_w),
    .wrusedw              ()
  );

  assign  egr_bffr_0_rden_c   = ~egr_bffr_0_rempty_w  & ~egr_bffr_1_rempty_w;

  ff_flags #(
    .NUM_INTFS  (1)

  ) egr_bffr_0_flags (

    .clear_clk          (clk),
    .clear_clk_rst_n    (rst_n),

    .wr_clk             (cntrlr_clk),
    .wr_clk_rst_n       (cntrlr_rst_n),

    .rd_clk             (clk),
    .rd_clk_rst_n       (rst_n),

    .clear_flags        (clear_ff_flags_c),

    .ff_wren            (egr_bffr_0_wren_c),
    .ff_full            (egr_bffr_0_wfull_w),

    .ff_rden            (egr_bffr_0_rden_c),
    .ff_empty           (egr_bffr_0_rempty_w),

    .ff_ovrflw          (egr_bffr_0_ovrflow),
    .ff_undrflw         (egr_bffr_0_undrflow)

  );

  /*
    * Egress Buffer 1
    * This buffer is used to carry the read data to the agent clock domain
  */
  assign  egr_bffr_1_wren_c   = cntrlr_rd_valid;

  assign  egr_bffr_1_wdata_w  = { {(EGR_BFFR_1_W-MEM_DATA_W){1'b0}},
                                  cntrlr_rdata
                                };

  ff_40x32_fwft_async   egr_bffr_1_inst
  (
    .aclr               (~cntrlr_rst_n),
    .data               (egr_bffr_1_wdata_w),
    .rdclk              (clk),
    .rdreq              (egr_bffr_1_rden_c),
    .wrclk              (cntrlr_clk),
    .wrreq              (egr_bffr_1_wren_c),
    .q                  (egr_bffr_1_rdata_w),
    .rdempty            (egr_bffr_1_rempty_w),
    .rdusedw            (),
    .wrfull             (egr_bffr_1_wfull_w),
    .wrusedw            ()
  );

  assign  egr_bffr_1_rden_c   = ~egr_bffr_0_rempty_w  & ~egr_bffr_1_rempty_w;

  ff_flags #(
    .NUM_INTFS  (1)

  ) egr_bffr_1_flags (

    .clear_clk          (clk),
    .clear_clk_rst_n    (rst_n),

    .wr_clk             (cntrlr_clk),
    .wr_clk_rst_n       (cntrlr_rst_n),

    .rd_clk             (clk),
    .rd_clk_rst_n       (rst_n),

    .clear_flags        (clear_ff_flags_c),

    .ff_wren            (egr_bffr_1_wren_c),
    .ff_full            (egr_bffr_1_wfull_w),

    .ff_rden            (egr_bffr_1_rden_c),
    .ff_empty           (egr_bffr_1_rempty_w),

    .ff_ovrflw          (egr_bffr_1_ovrflow),
    .ff_undrflw         (egr_bffr_1_undrflow)

  );

  /*  Demux Read Data to Agent  */
  generate
    for(i=0;  i<NUM_AGENTS; i++)
    begin : gen_agent_egr
      assign  agent_rd_valid[i]   = (egr_bffr_0_rdata_w[AGENT_ID_W-1:0] ==  i)  ? egr_bffr_0_rden_c : 1'b0;

      assign  agent_rdata[i]      = egr_bffr_1_rdata_w[MEM_DATA_W-1:0];
    end
  endgenerate

endmodule // sys_mem_arb_least_pend

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>


 --------------------------------------------------------------------------
*/
