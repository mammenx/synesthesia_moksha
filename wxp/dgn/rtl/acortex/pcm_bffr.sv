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
 -- Module Name       : pcm_buffer
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module maintains a dual bank memory for storing
                        PCM data.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module pcm_buffer #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME   = "PCM_BUFFER",
  parameter LB_DATA_W     = 32,
  parameter LB_ADDR_W     = 8,
  parameter NUM_SAMPLES   = 128,
  parameter MEM_RD_DELAY  = 2,
  parameter MEM_ADDR_W    = $clog2(NUM_SAMPLES) + 1   //Not intened to be overriden

) (

  //--------------------- Ports -------------------------
  input                       acortex_clk,
  input                       acortex_rst_n,

  input                       fgyrus_clk,
  input                       fgyrus_rst_n,

  input                       lb_wr_en,
  input                       lb_rd_en,
  input   [LB_ADDR_W-1:0]     lb_addr,
  input   [LB_DATA_W-1:0]     lb_wr_data,
  output                      lb_wr_valid,
  output                      lb_rd_valid,
  output  [LB_DATA_W-1:0]     lb_rd_data,

  input                       adc_pcm_valid,
  input   [31:0]              adc_lpcm_data,
  input   [31:0]              adc_rpcm_data,

  input                       dac_pcm_nxt,
  output  [31:0]              dac_lpcm_data,
  output  [31:0]              dac_rpcm_data,

  output                      acortex2fgyrus_pcm_rdy,
  input   [MEM_ADDR_W-1:0]    fgyrus2acortex_addr,
  output  [31:0]              acortex2fgyrus_pcm_data

);

//----------------------- Local Parameters Declarations -------------------
  `include  "pcm_bffr_regmap.svh"


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------
  reg                         lb_wr_valid;
  reg                         lb_rd_valid;
  reg     [LB_DATA_W-1:0]     lb_rd_data;

//----------------------- Internal Register Declarations ------------------
  reg                         bffr_mode;

  reg                         adc_pcm_valid_1d;
  reg                         dac_pcm_nxt_1d;
  reg     [MEM_ADDR_W-1:0]    pcm_raddr,pcm_waddr;
  reg                         bffr_a_n_b_sel;
  reg     [MEM_RD_DELAY-1:0]  mem_rd_del_vec;

//----------------------- Internal Wire Declarations ----------------------
  wire                        adc_pcm_valid_extended;
  wire                        dac_pcm_nxt_extended;
  wire    [31:0]              pcm_mem_wdata;
  wire                        switch_banks;
  wire    [31:0]              bffr_a_pcm_mem_rdata,bffr_b_pcm_mem_rdata,bffr_pcm_rdata;
  wire                        bffr_a_wr_en,bffr_b_wr_en;


//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------



//----------------------- Start of Code -----------------------------------

  /*  LB  Logic */
  always@(posedge acortex_clk,  negedge acortex_rst_n)
  begin
    if(~acortex_rst_n)
    begin
      lb_wr_valid             <=  0;
      lb_rd_valid             <=  0;
      lb_rd_data              <=  0;

      bffr_mode               <=  0;
    end
    else
    begin
      /*  Write Logic */
      if(lb_wr_en)
      begin
        case(lb_addr)

          PCM_BFFR_CONTROL_REG_ADDR :
          begin
            bffr_mode         <=  lb_wr_data[0];
          end

        endcase
      end

      lb_wr_valid             <=  lb_wr_en;


      /*  Read Logic  */
      if(lb_rd_en)
      begin
        case(lb_addr)

          PCM_BFFR_CONTROL_REG_ADDR :
          begin
            lb_rd_data        <=  {{(LB_DATA_W-1){1'b0}},bffr_mode};
          end

          PCM_BFFR_STATUS_REG_ADDR  :
          begin

          end

          default :
          begin
            lb_rd_data        <=  'hdeadbabe;
          end

        endcase
      end

      lb_rd_valid             <=  lb_rd_en;
    end
  end


  /*  Address Logic */
  always@(posedge acortex_clk,  negedge acortex_rst_n)
  begin
    if(~acortex_rst_n)
    begin
      dac_lpcm_data         <=  0;
      dac_rpcm_data         <=  0;

      adc_pcm_valid_1d      <=  0;
      dac_pcm_nxt_1d        <=  0;
      pcm_waddr             <=  0;
      pcm_raddr             <=  0;
      bffr_a_n_b_sel        <=  1;
      mem_rd_del_vec        <=  0;
    end
    else
    begin
      adc_pcm_valid_1d      <=  adc_pcm_valid;
      dac_pcm_nxt_1d        <=  dac_pcm_nxt;
      mem_rd_del_vec        <=  {mem_rd_del_vec[MEM_RD_DELAY-2:0],pcm_raddr[MEM_ADDR_W-1]};

      if(lb_wr_en & (lb_addr  ==  PCM_BFFR_CONTROL_REG_ADDR))
      begin
        pcm_waddr           <=  0;
      end
      else
      begin
        pcm_waddr[MEM_ADDR_W-1]   <=  pcm_waddr[MEM_ADDR_W-1]   ^ adc_pcm_valid_extended;
        pcm_waddr[MEM_ADDR_W-2:0] <=  pcm_waddr[MEM_ADDR_W-2:0] + adc_pcm_valid_1d;
      end

      if(bffr_mode) //Capture Mode
      begin
        if(lb_wr_en & (lb_addr  ==  PCM_BFFR_CAP_ADDR_REG_ADDR))
        begin
          pcm_raddr           <=  lb_wr_data[MEM_ADDR_W-1:0];
        end
      end
      else  //Normal mode
      begin
        pcm_raddr[MEM_ADDR_W-1]   <=  pcm_raddr[MEM_ADDR_W-1]   ^ adc_pcm_nxt_extended;
        pcm_raddr[MEM_ADDR_W-2:0] <=  pcm_raddr[MEM_ADDR_W-2:0] + adc_pcm_nxt_1d;
      end

      if(bffr_mode) //Capture Mode
      begin
        bffr_a_n_b_sel        <=  1'b1;
      end
      else  //Normal mode
      begin
        bffr_a_n_b_sel        <=  bffr_a_n_b_sel  ^ switch_banks;
      end

      dac_lpcm_data           <=  mem_rd_del_vec[MEM_RD_DELAY-1]  ? dac_lpcm_data   : bffr_pcm_rdata;
      dac_rpcm_data           <=  mem_rd_del_vec[MEM_RD_DELAY-1]  ? bffr_pcm_rdata  : dac_rpcm_data;
    end
  end

  assign  adc_pcm_valid_extended  = adc_pcm_valid | adc_pcm_valid_1d;
  assign  dac_pcm_nxt_extended    = dac_pcm_nxt   | dac_pcm_nxt_1d;

  assign  pcm_mem_wdata           = adc_pcm_valid ? adc_lpcm_data : adc_rpcm_data;

  assign  switch_banks            = (pcm_waddr  ==  (NUM_SAMPLES*2))  ? adc_pcm_valid_extended  : 1'b0;

  assign  bffr_a_wr_en            = bffr_a_n_b_sel  & adc_pcm_valid_extended;
  assign  bffr_b_wr_en            = ~bffr_a_n_b_sel & adc_pcm_valid_extended;

  assign  bffr_pcm_rdata          = bffr_a_n_b_sel  ? bffr_b_pcm_mem_rdata  : bffr_a_pcm_mem_rdata;

  /*  Instantiate Memory  */
  generate
    if(NUM_SAMPLES  ==  128)
    begin
      sync_dpram_32W_256D   bffr_a_inst
      (
        .clock              (acortex_clk),
        .data               (pcm_mem_wdata),
        .rdaddress          (pcm_raddr),
        .wraddress          (pcm_waddr),
        .wren               (bffr_a_wr_en),
        .q                  (bffr_a_pcm_mem_rdata)
      );

      sync_dpram_32W_256D   bffr_b_inst
      (
        .clock              (acortex_clk),
        .data               (pcm_mem_wdata),
        .rdaddress          (pcm_raddr),
        .wraddress          (pcm_waddr),
        .wren               (bffr_b_wr_en),
        .q                  (bffr_b_pcm_mem_rdata)
      );

      async_dpram_32W_256D  acortex2fgyrus_bffr_inst
      (
        .wrclock            (acortex_clk),
        .wren               (adc_pcm_valid_extended),
        .wraddress          (pcm_waddr),
        .data               (pcm_mem_wdata),
        .rdclock            (fgyrus_clk),
        .rdaddress          (fgyrus2acortex_addr),
        .q                  (acortex2fgyrus_pcm_data)
      );
    end
    else  //Undefined memory
    begin
      undef_mem undef_mem_inst();
    end
  endgenerate


  /*  Instantiate Pulse Sync  */
  pulse_toggle_sync #(.REGISTER_OUTPUT(1))  pulse_sync_inst
  (
    .in_clk         (acortex_clk),
    .in_rst_n       (acortex_rst_n),

    .out_clk        (fgyrus_clk),
    .out_rst_n      (fgyrus_rst_n),

    .pulse_in       (switch_banks),

    .pulse_out      (acortex2fgyrus_pcm_rdy)
  );



endmodule // pcm_buffer

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[12-10-2014  08:44:07 PM][mammenx] Renamed regmap to .svh

[12-10-2014  02:12:20 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
