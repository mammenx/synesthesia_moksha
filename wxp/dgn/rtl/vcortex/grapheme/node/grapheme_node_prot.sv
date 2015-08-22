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
 -- Module Name       : grapheme_node_prot
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module decodes incoming packets and acts as a
                        node in the job chain.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module grapheme_node_prot #(
  //----------------- Parameters  -----------------------
    parameter MODULE_NAME = "GRAPHEME_NODE_PROT"
  , parameter NODE_ID     = 0
  , parameter BFFR_SIZE   = 5

) 
  import  grapheme_node_prot_pkg::*;
(

  //--------------------- Ports -------------------------
    input                     clk
  , input                     rst_n

  , input                     node_en

  , input   gnode_prot_cmd_t          ingr_cmd
  , input   [GNODE_PROT_DATA_W-1:0]   ingr_data
  , output                            ingr_ready

  , output  gnode_prot_cmd_t          egr_cmd
  , output  [GNODE_PROT_DATA_W-1:0]   egr_data
  , input                             egr_ready

  , output  reg               node2eng_job_valid
  , output  reg [DATA_W-1:0]  node2eng_job_bffr  [BFFR_SIZE-1:0]
  , input                     eng2node_ready

  , input                     eng2node_job_valid
  , input       [DATA_W-1:0]  eng2node_job_bffr  [BFFR_SIZE-1:0]
  , output                    node2eng_ready

);

//----------------------- Local Parameters Declarations -------------------
  localparam  EGR_FF_DATA_W   = 40;
  localparam  BFFR_CNTR_W     = $clog2(BFFR_SIZE);


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  integer n;

  reg   [BFFR_CNTR_W-1:0]     bffr_cntr;
  reg                         egr_ff_eng_n_port_sel;
  reg                         ingr_dst_id_match;


//----------------------- Internal Wire Declarations ----------------------
  gnode_prot_hdr_t            ingr_hdr_w;
  wire                        ingr_data_valid_c;
  wire                        ingr_dst_id_match_c;

  gnode_prot_cmd_t            eng2node_cmd_c;
  wire  [DATA_W-1:0]          eng2node_data_c;

  wire                        bffr_cntr_en_c;
  wire                        bffr_cntr_rst_c;

  gnode_prot_cmd_t            ingr_sel_cmd_c;
  wire  [DATA_W-1:0]          ingr_sel_data_c;

  wire                        egr_ff_wren_c;
  wire  [EGR_FF_DATA_W-1:0]   egr_ff_wdata_w;
  wire                        egr_ff_full_w;
  wire                        egr_ff_rden_c;
  wire  [EGR_FF_DATA_W-1:0]   egr_ff_rdata_w;
  wire                        egr_ff_empty_w;

//----------------------- Start of Code -----------------------------------

  //Decode Ingress Header
  assign  ingr_hdr_w          = ingr_data;

  //Check if ingress data is valid
  assign  ingr_data_valid_c   = (ingr_cmd !=  IDLE) ? ingr_ready  : 1'b0;

  //Check if the destination id of packet matches this node
  assign  ingr_dst_id_match_c = (ingr_hdr_w.job_dst ==  NODE_ID)  & (ingr_cmd ==  SOP) ? node_en  : 1'b0;

  //Back-pressure ingress port
  assign  ingr_ready          = egr_ff_eng_n_port_sel ? 1'b0  :
                                (ingr_dst_id_match_c  | ingr_dst_id_match)  ? eng2node_ready  : ~egr_ff_full_w;

  //Back-pressure engine  - pulse ready when the job bffr has been shifted into egr_ff
  assign  node2eng_ready      = egr_ff_eng_n_port_sel & bffr_cntr_rst_c; 

  //Decode CMD & DATA for eng2node
  always@(*)
  begin
    if(eng2node_job_valid)
    begin
      if(bffr_cntr  ==  0)
      begin
        eng2node_cmd_c        =   SOP
      end
      else if(bffr_cntr_rst_c)
      begin
        eng2node_cmd_c        =   EOP
      end
      else
      begin
        eng2node_cmd_c        =   VALID
      end
    end
    else
    begin
      eng2node_cmd_c          =   IDLE;
    end

    eng2node_data_c           =   eng2node_job_bffr[bffr_cntr];
  end

  //Increment bffr_cntr when valid jobs arrive on either ingr or eng2node ports
  assign  bffr_cntr_en_c      = egr_ff_eng_n_port_sel | ingr_data_valid_c;

  //Reset bffr cntr at the end of buffer
  assign  bffr_cntr_rst_c     = (bffr_cntr  ==  (BFFR_SIZE-1))  ? 1'b1  : 1'b0;

  /*
    * Flop Logic
  */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      bffr_cntr               <=  0;
      egr_ff_eng_n_port_sel   <=  0;
    end
    else
    begin
      //Buffer Counter Logic
      if(bffr_cntr_rst_c)
      begin
        bffr_cntr             <=  0;
      end
      else if(bffr_cntr_en_c)
      begin
        bffr_cntr             <=  bffr_cntr + 1'b1;
      end

      if(~node_en)
      begin
        egr_ff_eng_n_port_sel <=  0;
      end
      else if(egr_ff_eng_n_port_sel) //Wait for end of buffer
      begin
        egr_ff_eng_n_port_sel <=  bffr_cntr_rst_c ? 1'b0  : eng2node_job_bffr;
      end
      else  //Give priority for main ingress bus
      begin
        egr_ff_eng_n_port_sel <=  (ingr_cmd ==  IDLE) & (eng2node_cmd_c !=  IDLE);
      end

    end
  end

  /*
    * Node2Engine Buffer
  */
  always@(posedge  clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      ingr_dst_id_match       <=  0;

      node2eng_job_valid      <=  0;
      node2eng_job_bffr       <=  0;
    end
    else
    begin
      if(ingr_dst_id_match)
      begin
        ingr_dst_id_match     <=  bffr_cntr_rst_c ? 1'b0  : ingr_dst_id_match;
      end
      else
      begin
        ingr_dst_id_match     <=  ingr_ready  & ingr_dst_id_match_c;
      end

      if(ingr_dst_id_match_c  | ingr_dst_id_match)
      begin
        node2eng_job_bffr[bffr_cntr]  <=  ingr_data;
      end

      node2eng_job_valid      <=  ingr_dst_id_match & bffr_cntr_rst_c;

    end
  end

  //Mux CMD & DATA between eng & ingr ports
  assign  ingr_sel_cmd_c  = egr_ff_eng_n_port_sel ? eng2node_cmd_c  : ingr_cmd;
  assign  ingr_sel_data_c = egr_ff_eng_n_port_sel ? eng2node_data_c : ingr_data;

  /*  Instantiate Egress Fifo  */
  assign  egr_ff_wdata_w  = {  {(EGR_FF_DATA_W-GNODE_PROT_DATA_W-GNODE_PROT_CMD_W){1'b0}}
                              ,ingr_sel_data_c
                              ,ingr_sel_cmd_c
                            };

  assign  egr_ff_wren_c   = egr_ff_eng_n_port_sel | (ingr_data_valid_c  & ~ingr_dst_id_match  & ~ingr_dst_id_match_c);

  ff_40x32_fwft   egr_ff
  (
    .aclr         (~rst_n),
    .clock        (clk),
    .data         (egr_ff_wdata_w),
    .rdreq        (egr_ff_rden_c),
    .wrreq        (egr_ff_wren_c),
    .empty        (egr_ff_empty_w),
    .full         (egr_ff_full_w),
    .q            (egr_ff_rdata_w),
    .usedw        ()
  );

  assign  egr_ff_rden_c = egr_ready;

  assign  egr_cmd       = egr_ff_empty_w  ? IDLE  : egr_ff_rdata_w[GNODE_PROT_CMD_W-1:0];
  assign  egr_data      = egr_ff_rdata_w[GNODE_PROT_CMD_W +:  GNODE_PROT_DATA_W];

endmodule // grapheme_node_prot

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[22-08-2015  02:58:05 PM][mammenx] Added node_en


 --------------------------------------------------------------------------
*/
