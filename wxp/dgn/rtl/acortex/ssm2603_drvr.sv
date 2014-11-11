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
 -- Module Name       : ssm2603_drvr
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module interfaces with the SSM2603 Audio Codec
                        and drives ADC/DAC data.

                        Limitations/Assumptions:
                          - Only DSP Mode [LRP=1] is supported.
                          - Audio Codec works in Slave Mode
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module ssm2603_drvr #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME         = "SSM2603_DRVR",
  parameter LB_DATA_W           = 32,
  parameter LB_ADDR_W           = 8,
  parameter NUM_MCLKS           = 2,
  parameter BCLK_CNTR_W         = 8,
  parameter FS_CNTR_W           = 16

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

  input   [NUM_MCLKS-1:0]     mclk_vec,

  output  reg                 adc_pcm_valid,
  output  reg [31:0]          adc_lpcm_data,
  output  reg [31:0]          adc_rpcm_data,

  input                       dac_data_rdy,
  output  reg                 dac_pcm_nxt,
  input   [31:0]              dac_lpcm_data,
  input   [31:0]              dac_rpcm_data,

  input                       AUD_ADCDAT,
  output  reg                 AUD_ADCLRCK,
  output  reg                 AUD_BCLK,
  output  reg                 AUD_DACDAT,
  output  reg                 AUD_DACLRCK,
  output  reg                 AUD_XCK

);

//----------------------- Local Parameters Declarations -------------------
  `include  "ssm2603_drvr_regmap.svh"

  localparam  MCLK_SEL_W      = $clog2(NUM_MCLKS);

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg   [BCLK_CNTR_W-1:0]     bclk_div_val;
  reg   [FS_CNTR_W-1:0]       fs_val;
  reg                         dac_en,adc_en;
  reg   [1:0]                 bps_val;
  reg   [MCLK_SEL_W-1:0]      mclk_sel;
  reg   [NUM_MCLKS-1:0]       mclk_sel_vec;

  reg   [BCLK_CNTR_W-1:0]     bclk_cntr;
  reg   [FS_CNTR_W-1:0]       fs_cntr;

  reg   [FS_CNTR_W-1:0]       lpcm_msb_offset,lpcm_lsb_offset;
  reg   [FS_CNTR_W-1:0]       rpcm_msb_offset,rpcm_lsb_offset;

  reg   [31:0]                dac_lpcm_data_fmt,dac_rpcm_data_fmt;

  reg                         prep_adc_data;

//----------------------- Internal Wire Declarations ----------------------
  wire                        bclk_tck;
  wire                        bclk_tck_by_2;
  wire                        fs_tck;

  wire  [31:0]                dac_lpcm_data_rev,dac_rpcm_data_rev;
  wire  [FS_CNTR_W-1:0]       lpcm_idx,rpcm_idx;

//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------
  enum  logic [2:0] { IDLE_S= 3'd0,
                      LRCK_S,
                      LCHANNEL_S,
                      RCHANNEL_S,
                      WAIT_FOR_FS_S  
                    }  fsm_pstate, next_state;


  genvar  i;

//----------------------- Start of Code -----------------------------------


  /*  LB Logic  */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      lb_wr_valid             <=  0;
      lb_rd_valid             <=  0;
      lb_rd_data              <=  0;

      bclk_div_val            <=  0;
      fs_val                  <=  0;
      dac_en                  <=  0;
      adc_en                  <=  0;
      bps_val                 <=  0;
      mclk_sel                <=  0;
    end
    else
    begin
      /*  Write Logic */
      if(lb_wr_en)
      begin
        case(lb_addr)

          SSM2603_DRVR_CONFIG_REG_ADDR  :
          begin
            dac_en            <=  lb_wr_data[0];
            adc_en            <=  lb_wr_data[1];
            bps_val           <=  lb_wr_data[3:2];
          end

          SSM2603_DRVR_BCLK_DIV_REG_ADDR  :
          begin
            bclk_div_val      <=  lb_wr_data[BCLK_CNTR_W-1:0];
          end

          SSM2603_DRVR_FS_VAL_REG_ADDR  :
          begin
            fs_val            <=  lb_wr_data[FS_CNTR_W-1:0];
          end

          SSM2603_DRVR_MCLK_SEL_REG_ADDR  :
          begin
            mclk_sel          <=  lb_wr_data[MCLK_SEL_W-1:0];
          end

        endcase
      end

      lb_wr_valid             <=  lb_wr_en;


      /*  Read Logic*/
      if(lb_rd_en)
      begin
        case(lb_addr)

          SSM2603_DRVR_CONFIG_REG_ADDR  :
          begin
            lb_rd_data        <=  {{(LB_DATA_W-4){1'b0}},bps_val,adc_en,dac_en};
          end

          SSM2603_DRVR_STATUS_REG_ADDR  :
          begin
            lb_rd_data        <=  {{(LB_DATA_W-3){1'b0}},fsm_pstate};
          end

          SSM2603_DRVR_BCLK_DIV_REG_ADDR  :
          begin
            lb_rd_data        <=  {{(LB_DATA_W-BCLK_CNTR_W){1'b0}},bclk_div_val};
          end

          SSM2603_DRVR_FS_VAL_REG_ADDR  :
          begin
            lb_rd_data        <=  {{(LB_DATA_W-FS_CNTR_W){1'b0}},fs_val};
          end

          SSM2603_DRVR_MCLK_SEL_REG_ADDR  :
          begin
            lb_rd_data        <=  {{(LB_DATA_W-MCLK_SEL_W){1'b0}},mclk_sel};
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


  /*  FSM Logic */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      fsm_pstate              <=  IDLE_S;

      fs_cntr                 <=  0;
    end
    else
    begin
      fsm_pstate              <=  next_state;

      if(fs_tck | (fsm_pstate ==  IDLE_S))
      begin
        fs_cntr               <=  0;
      end
      else
      begin
        fs_cntr               <=  fs_cntr + bclk_tck;
      end
    end
  end

  assign  fs_tck              =   (fs_cntr  ==  fs_val) ? bclk_tck  : 1'b0;

  always@(*)
  begin
    next_state                =   fsm_pstate;

    case(fsm_pstate)

      IDLE_S  :
      begin
        if((dac_en  & dac_data_rdy) | adc_en)
        begin
          next_state          =   LRCK_S;
        end
      end

      LRCK_S  :
      begin
        if(bclk_tck)
        begin
          next_state          =   LCHANNEL_S;
        end
      end

      LCHANNEL_S  :
      begin
        if(bclk_tck & (fs_cntr  ==  lpcm_lsb_offset))
        begin
          next_state          =   RCHANNEL_S;
        end
      end

      RCHANNEL_S  :
      begin
        if(bclk_tck & (fs_cntr  ==  rpcm_lsb_offset))
        begin
          if(fs_tck)  //skip WAIT_FOR_FS_S
          begin
            if(adc_en | (dac_en & dac_data_rdy))
            begin
              next_state      =   LRCK_S;
            end
            else
            begin
              next_state      =   IDLE_S;
            end
          end
          else
          begin
            next_state        =   WAIT_FOR_FS_S;
          end
        end
      end

      WAIT_FOR_FS_S :
      begin
        if(fs_tck)
        begin
          if(adc_en | (dac_en & dac_data_rdy))
          begin
            next_state        =   LRCK_S;
          end
          else
          begin
            next_state        =   IDLE_S;
          end
        end
      end

    endcase
  end


  /*  BCLK  Logic */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      bclk_cntr               <=  0;

      AUD_BCLK                <=  0;
    end
    else
    begin
      if(bclk_tck | (fsm_pstate ==  IDLE_S))
      begin
        bclk_cntr             <=  0;
      end
      else
      begin
        bclk_cntr             <=  bclk_cntr + 1'b1;
      end

      if(fsm_pstate ==  IDLE_S)
      begin
        AUD_BCLK              <=  0;
      end
      else
      begin
        AUD_BCLK              <=  AUD_BCLK  ^ bclk_tck_by_2;
      end
    end
  end

  assign  bclk_tck            =   (bclk_cntr  ==  bclk_div_val) ? 1'b1  : 1'b0;
  assign  bclk_tck_by_2       =   (bclk_cntr  ==  {1'b0,bclk_div_val[BCLK_CNTR_W-1:1]}) ? 1'b1  : bclk_tck;


  //Bit reverse DAC data for transmission
  generate
    for(i=0;  i<32; i++)
    begin : gen_bitrev_dac
      assign  dac_lpcm_data_rev[i]  = dac_lpcm_data[31-i];
      assign  dac_rpcm_data_rev[i]  = dac_rpcm_data[31-i];
    end
  endgenerate


  //Decode offsets, format data based on word length
  always@(*)
  begin
    case(bps_val)

      2'b00 : //16b
      begin
        lpcm_msb_offset       =   'd1;
        lpcm_lsb_offset       =   'd16;
        rpcm_msb_offset       =   'd17;
        rpcm_lsb_offset       =   'd32;

        dac_lpcm_data_fmt     =   {16'd0,dac_lpcm_data_rev[31:16]};
        dac_rpcm_data_fmt     =   {16'd0,dac_rpcm_data_rev[31:16]};
      end

      2'b01 : //20b
      begin
        lpcm_msb_offset       =   'd1;
        lpcm_lsb_offset       =   'd20;
        rpcm_msb_offset       =   'd21;
        rpcm_lsb_offset       =   'd40;

        dac_lpcm_data_fmt     =   {12'd0,dac_lpcm_data_rev[31:12]};
        dac_rpcm_data_fmt     =   {12'd0,dac_rpcm_data_rev[31:12]};
      end

      2'b11 : //32b
      begin
        lpcm_msb_offset       =   'd1;
        lpcm_lsb_offset       =   'd32;
        rpcm_msb_offset       =   'd33;
        rpcm_lsb_offset       =   'd64;

        dac_lpcm_data_fmt     =   dac_lpcm_data_rev[31:0];
        dac_rpcm_data_fmt     =   dac_rpcm_data_rev[31:0];
      end

      default : //2'b10, 24b
      begin
        lpcm_msb_offset       =   'd1;
        lpcm_lsb_offset       =   'd24;
        rpcm_msb_offset       =   'd25;
        rpcm_lsb_offset       =   'd48;

        dac_lpcm_data_fmt     =   {8'd0,dac_lpcm_data_rev[31:8]};
        dac_rpcm_data_fmt     =   {8'd0,dac_rpcm_data_rev[31:8]};
      end

    endcase
  end

  assign  lpcm_idx            =   fs_cntr - lpcm_msb_offset;
  assign  rpcm_idx            =   fs_cntr - rpcm_msb_offset;


  /*  DAC Logic */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      dac_pcm_nxt             <=  0;

      AUD_DACDAT              <=  0;
      AUD_DACLRCK             <=  0;
    end
    else
    begin
      dac_pcm_nxt             <=  (fs_cntr  ==  rpcm_lsb_offset)  ? dac_en  & dac_data_rdy  & bclk_tck  : 1'b0;

      AUD_DACLRCK             <=  (fsm_pstate ==  LRCK_S) ? dac_en  & dac_data_rdy  : 1'b0;

      if(fsm_pstate ==  LCHANNEL_S)
      begin
        AUD_DACDAT            <=  dac_lpcm_data_fmt[lpcm_idx];
      end
      else if(fsm_pstate  ==  RCHANNEL_S)
      begin
        AUD_DACDAT            <=  dac_rpcm_data_fmt[rpcm_idx];
      end
      else
      begin
        AUD_DACDAT            <=  0;
      end
    end
  end


  /*  ADC Logic */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      adc_pcm_valid           <=  0;
      adc_lpcm_data           <=  0;
      adc_rpcm_data           <=  0;

      AUD_ADCLRCK             <=  0;

      prep_adc_data           <=  0;
    end
    else
    begin
      AUD_ADCLRCK             <=  (fsm_pstate ==  LRCK_S) ? adc_en  : 1'b0;

      prep_adc_data           <=  (fs_cntr  ==  rpcm_lsb_offset)  ? adc_en  & bclk_tck  : 1'b0;

      if(bclk_tck_by_2  & ~AUD_BCLK)
      begin
        if(fsm_pstate ==  LCHANNEL_S)
        begin
          adc_lpcm_data       <=  {adc_lpcm_data[30:0],AUD_ADCDAT};
        end
        else if(fsm_pstate  ==  RCHANNEL_S)
        begin
          adc_rpcm_data       <=  {adc_rpcm_data[30:0],AUD_ADCDAT};
        end
      end
      else if(prep_adc_data)
      begin
        case(bps_val)
          2'b00 : //16b
          begin
            adc_lpcm_data     <=  {{16{adc_lpcm_data[15]}},adc_lpcm_data[15:0]};
            adc_rpcm_data     <=  {{16{adc_rpcm_data[15]}},adc_rpcm_data[15:0]};
          end

          2'b01 : //20b
          begin
            adc_lpcm_data     <=  {{10{adc_lpcm_data[19]}},adc_lpcm_data[19:0]};
            adc_rpcm_data     <=  {{10{adc_rpcm_data[19]}},adc_rpcm_data[19:0]};
          end

          2'b11 : //32b
          begin
            adc_lpcm_data     <=  adc_lpcm_data;
            adc_rpcm_data     <=  adc_rpcm_data;
          end

          default : //2'b10, 24b
          begin
            adc_lpcm_data     <=  {{8{adc_lpcm_data[23]}},adc_lpcm_data[23:0]};
            adc_rpcm_data     <=  {{8{adc_rpcm_data[23]}},adc_rpcm_data[23:0]};
          end

        endcase
      end

      adc_pcm_valid           <=  prep_adc_data;
    end
  end


  /*  Instantiate MCLK Mux  */
  clk_mux  #(.P_NO_CLOCKS(NUM_MCLKS))  mclk_mux_inst
  (
      .clk_vec      (mclk_vec),
      .rst_n        (rst_n),

      .clk_en_vec   (mclk_sel_vec),

      .clk_o        (AUD_XCK)
  );

  always@(*)  //One hot encode the MCLK select vector
  begin
    mclk_sel_vec              =   0;

    mclk_sel_vec[mclk_sel]    =   1'b1;
  end


endmodule // ssm2603_drvr

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[02-11-2014  07:53:04 PM][mammenx] Fixed synthesis errors

[02-11-2014  07:52:04 PM][mammenx] Fixed issues found in PCM Test

[14-10-2014  12:47:57 AM][mammenx] Fixed compilation errors & warnings

[11-10-2014  05:29:40 PM][mammenx] Renamed regmap files as .svh

[11-10-2014  05:18:26 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
