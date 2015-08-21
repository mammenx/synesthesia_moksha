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
 -- Module Name       : grapheme_pxl_gw_1280x720
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module converts pixel read/write trasactions
                        to memory reads/writes.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module grapheme_pxl_gw_1280x720 #(
  //----------------- Parameters  -----------------------
    parameter MODULE_NAME = "GRAPHEME_PXL_GW_1280X720"
  , parameter NODE_ID     = 0
  , parameter BFFR_SIZE   = 5
  , parameter MEM_DATA_W  = 32
  , parameter MEM_ADDR_W  = 20  //Must be at least log(1280x720)/log(2)
  , parameter STATUS_W    = 32

)
  import  grapheme_node_prot_pkg::*;
)

  //--------------------- Ports -------------------------
    input                       clk
  , input                       rst_n

  , input                       mem_wait
  , output  reg                 mem_wren
  , output  reg                 mem_rden
  , output  reg [MEM_ADDR_W-1:0]mem_addr
  , output  reg [MEM_DATA_W-1:0]mem_wdata
  , input                       mem_rd_valid
  , input   [MEM_DATA_W-1:0]    mem_rdata

  , input   gnode_prot_cmd_t          ingr_cmd
  , input   [GNODE_PROT_DATA_W-1:0]   ingr_data
  , output                            ingr_ready

  , output  gnode_prot_cmd_t          egr_cmd
  , output  [GNODE_PROT_DATA_W-1:0]   egr_data
  , input                             egr_ready

  , input                             clear_flags
  , output  [STATUS_W-1:0]            status

);

//----------------------- Local Parameters Declarations -------------------
  localparam  X_CORD_W        = $clog2(1280);
  localparam  Y_CORD_W        = $clog2(720);

  localparam  RD_RSP_HDR_FF_W = 40;
  localparam  RD_RSP_HDR_FF_D = 32;
  localparam  RD_RSP_HDR_FF_USED_W  = $clog2(RD_RSP_HDR_FF_D);

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg   [MEM_DATA_W-1:0]          mem_rdata_f;
  reg                             eng2node_job_valid;



//----------------------- Internal Wire Declarations ----------------------
  wire                            node2eng_job_valid;
  wire  [GNODE_PROT_DATA_W-1:0]   node2eng_job_bffr  [BFFR_SIZE-1:0];
  wire                            eng2node_ready;

  wire  [GNODE_PROT_DATA_W-1:0]   eng2node_job_bffr  [BFFR_SIZE-1:0];
  wire                            node2eng_ready;

  gnode_prot_hdr_t                job_hdr_w;

  wire  [X_CORD_W-1:0]            x_cord_w;
  wire  [Y_CORD_W-1:0]            y_cord_w;

  gnode_prot_hdr_t                rd_rsp_hdr_w;

  wire                            rd_rsp_hdr_ff_wren;
  wire  [RD_RSP_HDR_FF_W-1:0]     rd_rsp_hdr_ff_wdata;
  wire                            rd_rsp_hdr_ff_full;
  wire                            rd_rsp_hdr_ff_rden;
  wire  [RD_RSP_HDR_FF_W-1:0]     rd_rsp_hdr_ff_rdata;
  wire                            rd_rsp_hdr_ff_empty;
  wire                            rd_rsp_hdr_ff_ovrflw;
  wire                            rd_rsp_hdr_ff_undrflw;
  wire  [RD_RSP_HDR_FF_USED_W-1:0]rd_rsp_hdr_ff_used;


//----------------------- Start of Code -----------------------------------


  /*
    *          PIXEL GATEWAY JOB FORMAT
    *
    *   +--------------------------------+
    * 0 |      id|   type|    src|    dst|
    *   +--------------------------------+
    * 1 |             PXL DATA           |
    *   +--------------------------------+
    * 2 |           X CORDINATE          |
    *   +--------------------------------+
    * 3 |           Y CORDINATE          |
    *   +--------------------------------+
    * 4 |            RESERVED            |
    *   +--------------------------------+
    * 5 |            RESERVED            |
    *   +--------------------------------+
    *
    *
  */


  /*
    * Memory Interface Logic
  */
  assign  job_hdr_w           = node2eng_job_bffr[0];
  assign  x_cord_w            = node2eng_job_bffr[2][X_CORD_W-1:0];
  assign  y_cord_w            = node2eng_job_bffr[3][Y_CORD_W-1:0];

  always@(posedge  clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      mem_rden                <=  0;
      mem_wren                <=  0;
      mem_addr                <=  0;
      mem_wdata               <=  0;
    end
    else
    begin
      /*  Register job details  */
      if(node2eng_job_valid)
      begin
        mem_wren              <=  (job_hdr_w.job_type ==  WRITE_PXL)  ? 1'b1  : 1'b0;
        mem_rden              <=  (job_hdr_w.job_type ==  READ_PXL)   ? 1'b1  : 1'b0;
        mem_wdata             <=  node2eng_job_bffr[1][MEM_DATA_W-1:0];
        mem_addr              <=  {y_cord_w,10d0} + {y_cord_w,8'd0} + x_cord_w;
      end
      else
      begin
        mem_wren              <=  mem_wren  & mem_wait;
        mem_rden              <=  mem_rden  & mem_wait;
        mem_wdata             <=  mem_wdata;
        mem_addr              <=  mem_addr;
      end
    end
  end

  /*  FIFO to hold read response headers  */
  assign  rd_rsp_hdr_w.job_dst  = job_hdr_w.job_src;
  assign  rd_rsp_hdr_w.job_src  = NODE_ID;
  assign  rd_rsp_hdr_w.job_type = READ_PXL_RSP;
  assign  rd_rsp_hdr_w.job_id   = job_hdr_w.job_id;

  assign  rd_rsp_hdr_ff_wdata   = {   {(RD_RSP_HDR_FF_W-GNODE_PROT_DATA_W){1'b0}}
                                    , rd_rsp_hdr_w
                                  };

  assign  rd_rsp_hdr_ff_wren    = (job_hdr_w.job_type ==  READ_PXL) ? node2eng_ready  : 1'b0;

  ff_40x32_fwft   rd_rsp_hdr_ff_inst
  (
    .aclr     (~rst_n),
    .clock    (clk),
    .data     (rd_rsp_hdr_ff_wdata),
    .rdreq    (rd_rsp_hdr_ff_rden),
    .wrreq    (rd_rsp_hdr_ff_wren),
    .empty    (rd_rsp_hdr_ff_empty),
    .full     (rd_rsp_hdr_ff_full),
    .q        (rd_rsp_hdr_ff_rdata),
    .usedw    (rd_rsp_hdr_ff_used)
  );

  assign  rd_rsp_hdr_ff_rden    = ~rd_rsp_hdr_ff_empty  & eng2node_job_valid  & node2eng_ready;

  /*  Send Read Responses to Node */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      mem_rdata_f             <=  0;
      eng2node_job_valid      <=  0;
    end
    else
    begin
      mem_rdata_f             <=  mem_rd_valid  ? mem_rdata : mem_rdata_f;

      if(eng2node_job_valid)
      begin
        eng2node_job_valid    <=  ~node2eng_ready;
      end
      else
      begin
        eng2node_job_valid    <=  mem_rd_valid;
      end
    end
  end

  assign  eng2node_job_bffr[0]  = rd_rsp_hdr_ff_rdata[GNODE_PROT_DATA_W-1:0];
  assign  eng2node_job_bffr[1]  = mem_rdata_f[GNODE_PROT_DATA_W-1:0];
  assign  eng2node_job_bffr[2]  = {GNODE_PROT_DATA_W{1'b0}};
  assign  eng2node_job_bffr[3]  = {GNODE_PROT_DATA_W{1'b0}};
  assign  eng2node_job_bffr[4]  = {GNODE_PROT_DATA_W{1'b0}};


  assign  eng2node_ready  = mem_wait;

  /*  Instantiate GNODE */
  grapheme_node_prot #(
    ,.NODE_ID             (NODE_ID)
    ,.BFFR_SIZE           (BFFR_SIZE)

  ) gnode_inst  (

     .clk                 (clk         )
    ,.rst_n               (rst_n       )

    ,.ingr_cmd            (ingr_cmd    )
    ,.ingr_data           (ingr_data   )
    ,.ingr_ready          (ingr_ready  )

    ,.egr_cmd             (egr_cmd     )
    ,.egr_data            (egr_data    )
    ,.egr_ready           (egr_ready   )

    ,.node2eng_job_valid  (node2eng_job_valid  )
    ,.node2eng_job_bffr   (node2eng_job_bffr   )
    ,.eng2node_ready      (eng2node_ready      )

    ,.eng2node_job_valid  (eng2node_job_valid  )
    ,.eng2node_job_bffr   (eng2node_job_bffr   )
    ,.node2eng_ready      (node2eng_ready      )

  );


  /*  Check for FIFO Errors */
  ff_flags #(
    .NUM_INTFS  (1)

  ) ff_fpags_inst (

     .clear_clk         (clk)
    ,.clear_clk_rst_n   (rst_n)

    ,.wr_clk            (clk)
    ,.wr_clk_rst_n      (rst_n)

    ,.rd_clk            (clk)
    ,.rd_clk_rst_n      (rst_n)

    ,.clear_flags       (clear_flags)

    ,.ff_wren           (rd_rsp_hdr_ff_wren)
    ,.ff_full           (rd_rsp_hdr_ff_full)

    ,.ff_rden           (rd_rsp_hdr_ff_rden)
    ,.ff_empty          (rd_rsp_hdr_ff_empty)

    ,.ff_ovrflw         (rd_rsp_hdr_ff_ovrflw)
    ,.ff_undrflw        (rd_rsp_hdr_ff_undrflw)

  );


  //Assign status
  assign  status  = {   {(STATUS_W-8-RD_RSP_HDR_FF_USED_W){1'b0}}
                      , rd_rsp_hdr_ff_used
                      , {(8-6){1'b0}}
                      , ingr_ready
                      , egr_ready
                      , eng2node_ready
                      , node2eng_ready
                      , rd_rsp_hdr_ff_ovrflw
                      , rd_rsp_hdr_ff_undrflw
                    };

endmodule // grapheme_pxl_gw_1280x720

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[22-08-2015  01:43:12 AM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
