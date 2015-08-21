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
 -- Module Name       : grapheme_hst_acc
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module converts local bus transactions from
                        host into the grapheme node protocol.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module grapheme_hst_acc #(
  //----------------- Parameters  -----------------------
    parameter MODULE_NAME         = "GRAPHEME_HST_ACC"
  , parameter LB_DATA_W           = 32
  , parameter LB_ADDR_W           = 8
  , parameter NODE_ID             = 0
  , parameter BFFR_SIZE           = 5

) 
  import  grapheme_node_prot_pkg::*;
(

  //--------------------- Ports -------------------------
    input                       clk
  , input                       rst_n

  , input                       lb_wr_en
  , input                       lb_rd_en
  , input   [LB_ADDR_W-1:0]     lb_addr
  , input   [LB_DATA_W-1:0]     lb_wr_data
  , output  reg                 lb_wr_valid
  , output  reg                 lb_rd_valid
  , output  reg [LB_DATA_W-1:0] lb_rd_data

  , input   gnode_prot_cmd_t          ingr_cmd
  , input   [GNODE_PROT_DATA_W-1:0]   ingr_data
  , output                            ingr_ready

  , output  gnode_prot_cmd_t          egr_cmd
  , output  [GNODE_PROT_DATA_W-1:0]   egr_data
  , input                             egr_ready


);

//----------------------- Local Parameters Declarations -------------------
  `include  "grapheme_hst_acc_regmap.svh"

  localparam  BFFR_IDX_W      = $clog2(BFFR_SIZE);


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  integer   n;

  reg                             eng2node_job_valid;
  reg   [GNODE_PROT_DATA_W-1:0]   eng2node_job_bffr  [BFFR_SIZE-1:0];

  reg                             job_rdy;

//----------------------- Internal Wire Declarations ----------------------
  wire                            bffr_hst_wr_en;
  wire  [BFFR_IDX_W-1:0]          bffr_idx;

  wire                            node2eng_job_valid;
  wire  [GNODE_PROT_DATA_W-1:0]   node2eng_job_bffr  [BFFR_SIZE-1:0];
  wire                            eng2node_ready;

  wire                            node2eng_ready;


//----------------------- Internal Interface Declarations -----------------

  /*  Local Bus logic */
  assign  bffr_hst_wr_en      = (lb_addr  > GRAPHEME_HST_ACC_BFFR_OFFSET) ? 1'b1  : 1'b0;
  assign  bffr_idx            = lb_addr[BFFR_IDX_W:0] - GRAPHEME_HST_ACC_BFFR_OFFSET;

  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      lb_wr_valid             <=  0;
      lb_rd_valid             <=  0;
      lb_rd_data              <=  0;

      eng2node_job_valid      <=  0;

      for(n=0;n<BFFR_SIZE;n++)
      begin
        eng2node_job_bffr[n]  <=  0;
      end

      job_rdy                 <=  0;
    end
    else
    begin
      if(eng2node_job_valid)
      begin
        eng2node_job_valid    <=  node2eng_ready  ? 1'b0  : 1'b1;
      end
      else
      begin
        eng2node_job_valid    <=  (lb_addr  ==  GRAPHEME_HST_ACC_CNTRL_REG) ? : lb_wr_en  : 1'b0;
      end

      lb_wr_valid             <=  lb_wr_en;


      if(bffr_hst_wr_en)
      begin
        eng2node_job_bffr[bffr_idx]   <=  lb_wr_data[GNODE_PROT_DATA_W-1:0];
      end
      else if(node2eng_job_valid)
      begin
        for(n=0;n<BFFR_SIZE;n++)
        begin
          eng2node_job_bffr[n]        <=  node2eng_job_bffr[n];
        end
      end

      if((lb_addr  ==  GRAPHEME_HST_ACC_STATUS_REG) & lb_rd_en)
      begin
        job_rdy               <=  0;

        lb_rd_data            <=  {{(LB_DATA_W-5){1'b0}}, job_rdy,ingr_ready,egr_ready,eng2node_ready,node2eng_ready};
      end
      else
      begin
        job_rdy               <=  job_rdy | node2eng_ready;

        lb_rd_data            <=  'hdeadbabe;
      end
    end
  end

  assign  eng2node_ready      =   1'b1;

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




//----------------------- Start of Code -----------------------------------

endmodule // grapheme_hst_acc

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[21-08-2015  07:47:04 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
