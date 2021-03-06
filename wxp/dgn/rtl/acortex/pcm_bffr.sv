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
 -- Module Name       : pcm_bffr
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module maintains a dual bank memory for storing
                        PCM data.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module pcm_bffr #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME   = "PCM_BFFR",
  parameter LB_DATA_W     = 32,
  parameter LB_ADDR_W     = 8,
  parameter NUM_SAMPLES   = 128,
  parameter MEM_RD_DELAY  = 2,
  parameter MEM_ADDR_W    = $clog2(NUM_SAMPLES) + 1   //Not intened to be overriden

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

  input                       adc_pcm_valid,
  input   [31:0]              adc_lpcm_data,
  input   [31:0]              adc_rpcm_data,

  output  reg                 dac_data_rdy,
  input                       dac_pcm_nxt,
  output  reg [31:0]          dac_lpcm_data,
  output  reg [31:0]          dac_rpcm_data,

  output  reg                 acortex2fgyrus_pcm_rdy,
  input                       fgyrus2acortex_rden,
  input   [MEM_ADDR_W-1:0]    fgyrus2acortex_addr,
  output                      acortex2fgyrus_pcm_data_valid,
  output  [31:0]              acortex2fgyrus_pcm_data

);

//----------------------- Local Parameters Declarations -------------------
  `include  "pcm_bffr_regmap.svh"


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg                         bffr_mode/*synthesis keep*/;
  reg                         cap_done;

  reg                         adc_pcm_valid_1d;
  reg                         dac_data_rdy_1d;
  reg                         dac_pcm_nxt_1d,dac_pcm_nxt_2d;
  reg                         fwft_refresh,fwft_refresh_1d;
  reg     [MEM_ADDR_W-1:0]    pcm_raddr/*synthesis keep*/;
  reg     [MEM_ADDR_W-1:0]    pcm_waddr/*synthesis keep*/;
  reg                         bffr_a_n_b_sel/*synthesis keep*/;
  reg     [MEM_RD_DELAY-1:0]  mem_rd_del_vec[1:0];

//----------------------- Internal Wire Declarations ----------------------
  wire                        adc_pcm_valid_extended;
  wire                        dac_pcm_nxt_extended;
  wire    [31:0]              pcm_mem_wdata/*synthesis keep*/;
  wire                        switch_banks;
  wire    [31:0]              bffr_a_pcm_mem_rdata/*synthesis keep*/;
  wire    [31:0]              bffr_b_pcm_mem_rdata/*synthesis keep*/;
  wire    [31:0]              bffr_pcm_rdata;
  wire                        bffr_a_wr_en/*synthesis keep*/;
  wire                        bffr_b_wr_en/*synthesis keep*/;


//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------



//----------------------- Start of Code -----------------------------------

  /*  LB  Logic */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      lb_wr_valid             <=  0;
      lb_rd_valid             <=  0;
      lb_rd_data              <=  0;

      bffr_mode               <=  0;
      cap_done                <=  0;
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
            cap_done          <=  lb_wr_data[0] ? 1'b0  : cap_done;
          end

        endcase
      end
      else
      begin
        bffr_mode             <=  bffr_mode;

        cap_done              <=  bffr_mode ? cap_done  | switch_banks  : 1'b0;
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
            lb_rd_data        <=  {{(LB_DATA_W-1){1'b0}},cap_done};
          end

          PCM_BFFR_CAP_DATA_REG_ADDR  :
          begin
            lb_rd_data        <=  bffr_a_pcm_mem_rdata;
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
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      dac_data_rdy          <=  0;
      dac_lpcm_data         <=  0;
      dac_rpcm_data         <=  0;

      adc_pcm_valid_1d      <=  0;
      dac_data_rdy_1d       <=  0;
      dac_pcm_nxt_1d        <=  0;
      dac_pcm_nxt_2d        <=  0;
      fwft_refresh          <=  0;
      fwft_refresh_1d       <=  0;
      pcm_waddr             <=  0;
      pcm_raddr             <=  0;
      bffr_a_n_b_sel        <=  1;
      mem_rd_del_vec        <=  '{0,0};
    end
    else
    begin
      adc_pcm_valid_1d      <=  adc_pcm_valid;
      dac_data_rdy_1d       <=  dac_data_rdy;
      dac_pcm_nxt_1d        <=  dac_pcm_nxt;
      dac_pcm_nxt_2d        <=  dac_pcm_nxt_1d;
      fwft_refresh_1d       <=  fwft_refresh;
      mem_rd_del_vec[0]     <=  {mem_rd_del_vec[0][MEM_RD_DELAY-2:0],pcm_raddr[MEM_ADDR_W-1]};
      mem_rd_del_vec[1]     <=  {mem_rd_del_vec[1][MEM_RD_DELAY-2:0],fgyrus2acortex_rden};

      if(~fwft_refresh)
      begin
        fwft_refresh        <=  dac_data_rdy  & ~dac_data_rdy_1d;
      end
      else
      begin
        fwft_refresh        <=  ~fwft_refresh_1d;
      end

      if(lb_wr_en & (lb_addr  ==  PCM_BFFR_CONTROL_REG_ADDR))
      begin
        pcm_waddr           <=  0;
        dac_data_rdy        <=  0;
      end
      else
      begin
        pcm_waddr[MEM_ADDR_W-1]   <=  pcm_waddr[MEM_ADDR_W-1]   ^ adc_pcm_valid_extended;
        pcm_waddr[MEM_ADDR_W-2:0] <=  pcm_waddr[MEM_ADDR_W-2:0] + adc_pcm_valid_1d;

        dac_data_rdy        <=  dac_data_rdy  | switch_banks;
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
        if(lb_wr_en & (lb_addr  ==  PCM_BFFR_CONTROL_REG_ADDR))
        begin
          pcm_raddr           <=  0;
        end
        else
        begin
          pcm_raddr[MEM_ADDR_W-1]   <=  pcm_raddr[MEM_ADDR_W-1]   ^ (dac_pcm_nxt_extended | fwft_refresh);
          //pcm_raddr[MEM_ADDR_W-1]   <=  ~pcm_raddr[MEM_ADDR_W-1];
          pcm_raddr[MEM_ADDR_W-2:0] <=  pcm_raddr[MEM_ADDR_W-2:0] + dac_pcm_nxt_1d;
        end
      end

      if(bffr_mode) //Capture Mode
      begin
        bffr_a_n_b_sel        <=  1'b1;
      end
      else  //Normal mode
      begin
        if(lb_wr_en & (lb_addr  ==  PCM_BFFR_CONTROL_REG_ADDR))
        begin
          bffr_a_n_b_sel      <=  1'b1;
        end
        else
        begin
          bffr_a_n_b_sel      <=  bffr_a_n_b_sel  ^ switch_banks;
        end
      end

      dac_lpcm_data           <=  mem_rd_del_vec[0][MEM_RD_DELAY-1]  ? dac_lpcm_data   : bffr_pcm_rdata;
      dac_rpcm_data           <=  mem_rd_del_vec[0][MEM_RD_DELAY-1]  ? bffr_pcm_rdata  : dac_rpcm_data;
    end
  end

  assign  acortex2fgyrus_pcm_data_valid = mem_rd_del_vec[1][MEM_RD_DELAY-1];

  assign  adc_pcm_valid_extended  = adc_pcm_valid   | adc_pcm_valid_1d;
  assign  dac_pcm_nxt_extended    = dac_pcm_nxt_1d  | dac_pcm_nxt_2d;

  assign  pcm_mem_wdata           = adc_pcm_valid ? adc_lpcm_data : adc_rpcm_data;

  assign  switch_banks            = (pcm_waddr  ==  ((NUM_SAMPLES*2)-1))  ? adc_pcm_valid_extended  : 1'b0;

  assign  bffr_a_wr_en            = bffr_a_n_b_sel  & adc_pcm_valid_extended;
  assign  bffr_b_wr_en            = ~bffr_a_n_b_sel & adc_pcm_valid_extended;

  assign  bffr_pcm_rdata          = bffr_a_n_b_sel  ? bffr_b_pcm_mem_rdata  : bffr_a_pcm_mem_rdata;

  /*  Fgyrus  Interface */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      acortex2fgyrus_pcm_rdy  <=  0;
    end
    else
    begin
      acortex2fgyrus_pcm_rdy  <=  switch_banks;
    end
  end

  /*  Instantiate Memory  */
  generate
    if(NUM_SAMPLES  ==  128)
    begin
      sync_dpram_32W_256D   bffr_a_inst
      (
        .clock              (clk),
        .data               (pcm_mem_wdata),
        .rdaddress          (pcm_raddr),
        .wraddress          (pcm_waddr),
        .wren               (bffr_a_wr_en),
        .q                  (bffr_a_pcm_mem_rdata)
      );

      sync_dpram_32W_256D   bffr_b_inst
      (
        .clock              (clk),
        .data               (pcm_mem_wdata),
        .rdaddress          (pcm_raddr),
        .wraddress          (pcm_waddr),
        .wren               (bffr_b_wr_en),
        .q                  (bffr_b_pcm_mem_rdata)
      );

      sync_dpram_32W_256D   acortex2fgyrus_bffr_inst
      (
        .clock              (clk),
        .data               (pcm_mem_wdata),
        .rdaddress          (fgyrus2acortex_addr),
        .wraddress          (pcm_waddr),
        .wren               (adc_pcm_valid_extended),
        .q                  (acortex2fgyrus_pcm_data)
      );

    end
    else  //Undefined memory
    begin
      undef_mem undef_mem_inst();
    end
  endgenerate


endmodule // pcm_bffr

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[11-11-2014  07:52:04 PM][mammenx] Moving to single clock domain

[03-11-2014  06:26:27 PM][mammenx] Added cap_done status

[02-11-2014  07:52:04 PM][mammenx] Fixed issues found in PCM Test

[14-10-2014  12:47:57 AM][mammenx] Fixed compilation errors & warnings

[12-10-2014  09:40:44 PM][mammenx] Modified module name to match filename

[12-10-2014  08:44:07 PM][mammenx] Renamed regmap to .svh

[12-10-2014  02:12:20 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
