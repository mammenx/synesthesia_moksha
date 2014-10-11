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
 -- Module Name       : i2c_master
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module initiates reads & writes on an I2C bus.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module i2c_master #(
  //----------------- Parameter List  ------------------
  parameter MODULE_NAME         = "I2C_MASTER"
  parameter LB_DATA_W           = 32,
  parameter LB_ADDR_W           = 8,
  parameter CLK_DIV_CNT_W       = 8,
  parameter I2C_MAX_DATA_BYTES  = 4,
  parameter ACK_VAL             = 1'b1
) (

  //--------------------- Ports -----------
  input                       clk,
  input                       rst_n,

  input                       lb_wr_en,
  input                       lb_rd_en,
  input   [LB_ADDR_W-1:0]     lb_addr,
  input   [LB_DATA_W-1:0]     lb_wr_data,
  output                      lb_wr_valid,
  output                      lb_rd_valid,
  output  [LB_DATA_W-1:0]     lb_rd_data,

  output                      scl,
  inout                       sda

);

//----------------------- Local parameters Declarations ------------------
  `include  "i2c_master_regmap.sv"

  localparam  NUM_BYTES_IDX   = $clog2(I2C_MAX_DATA_BYTES)    + 1;
  localparam  DATA_CNTR_W     = $clog2(I2C_MAX_DATA_BYTES*8)  + 1;
  localparam  I2C_SEQ_W       = 8 + (I2C_MAX_DATA_BYTES*8);
  localparam  NACK_VAL        = ~ACK_VAL;


//----------------------- Output Register Declaration ---------------------
  reg                         lb_wr_valid;
  reg                         lb_rd_valid;
  reg   [LB_DATA_W-1:0]       lb_rd_data;

  reg                         scl;

//----------------------- Internal Register Declarations ------------------
  reg   [6:0]                 i2c_addr;
  reg   [CLK_DIV_CNT_W-1:0]   i2c_clk_div_cnt;
  reg   [NUM_BYTES_IDX-1:0]   i2c_num_bytes;
  reg                         i2c_rd_n_wr,i2c_start_en,i2c_stop_en,i2c_init;
  reg   [7:0]                 data_cache  [I2C_MAX_DATA_BYTES-1:0];
  reg                         i2c_nack_det;
  reg                         rel_i2c_bus,rel_i2c_bus_next;

  reg   [CLK_DIV_CNT_W-1:0]   tck_cntr;
  reg   [DATA_CNTR_W-1:0]     data_cntr;
  reg                         data_cntr_en;

  reg                         sda_o;

//----------------------- Internal Wire Declarations ----------------------
  wire                        i2c_busy;
  wire  [NUM_BYTES_IDX-1:0]   data_cache_idx;

  wire                        tck_valid,tck_by_2_valid,tck_by_4_valid;
  wire  [(DATA_CNTR_W-3)-1:0] data_cntr_bytes;

  wire  [I2C_SEQ_W-1:0]       i2c_seq_bits;

  wire                        sda_i;


  genvar  i,j;

//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------
enum  logic [2:0] { IDLE_S  = 0,
                    START_S,
                    ACK_S,
                    ADDR_S,
                    DATA_S,
                    STOP_S
                  } fsm_pstate, next_state;



//----------------------- Start of Code -----------------------------------

  assign  data_cache_idx  = lb_addr - I2C_DATA_CACHE_BASE_ADDR;

  assign  i2c_busy        = (fsm_pstate ==  IDLE_S) ? 1'b0  : 1'b1;

  /*  LB Decoding Logic */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      lb_wr_valid             <=  0;
      lb_rd_valid             <=  0;
      lb_rd_data              <=  0;

      i2c_addr                <=  0;
      i2c_clk_div_cnt         <=  0;
      i2c_num_bytes           <=  0;
      i2c_rd_n_wr             <=  0;
      i2c_start_en            <=  0;
      i2c_stop_en             <=  0;
      i2c_init                <=  0;
      data_cache              <=  0;
    end
    else
    begin
      /*  Write Logic */
      if(lb_wr_valid)
      begin
        case(lb_addr)

          I2C_ADDR_REG_ADDR :
          begin
            i2c_addr          <=  lb_data[7:1];
          end

          I2C_CLK_DIV_REG_ADDR  :
          begin
            i2c_clk_div_cnt   <=  lb_data[CLK_DIV_CNT_W-1:0];
          end

          I2C_CONFIG_REG_ADDR :
          begin
            i2c_num_bytes     <=  lb_data[8 :+  NUM_BYTES_IDX];
            i2c_start_en      <=  lb_data[0];
            i2c_stop_en       <=  lb_data[1];
            i2c_init          <=  lb_data[2];
            i2c_rd_n_wr       <=  lb_data[3];
          end

        endcase

        if(lb_addr  >=  I2C_DATA_CACHE_BASE_ADDR)
        begin
          data_cache[data_cache_idx]  <=  lb_data[7:0];
        end
      end
      else
      begin
        i2c_init              <=  0;

        if(i2c_rd_n_wr  & (fsm_pstate ==  DATA_S) & tck_by_2_valid)
        begin
          data_cache[data_cntr_bytes  - 1'b1] = {data_cache[data_cntr_bytes - 1'b1][6:1],sda_i};
        end
      end

      lb_wr_valid             <=  lb_wr_en;


      /*  Read  Logic */
      if(lb_rd_en)
      begin
        case(lb_addr)

          I2C_ADDR_REG_ADDR     : lb_rd_data  <=  {{(LB_DATA_W-8){1'b0}},i2c_addr,1'b0};

          I2C_CLK_DIV_REG_ADDR  : lb_rd_data  <=  {{(LB_DATA_W-CLK_DIV_CNT_W){1'b0}},i2c_clk_div_cnt};

          I2C_CONFIG_REG_ADDR   : lb_rd_data  <=  {{(LB_DATA_W-8-NUM_BYTES_IDX){1'b0}},i2c_num_bytes,4'd0,i2c_rd_n_wr,i2c_init,i2c_stop_en,i2c_start_en};

          I2C_STATUS_REG_ADDR   : lb_rd_data  <=  {{(LB_DATA_W-2){1'b0}},i2c_nack_det,i2c_busy};

          I2C_FSM_REG_ADDR      : lb_rd_data  <=  {{(LB_DATA_W-3){1'b0}},fsm_pstate};

          //I2C_DATA_CACHE_BASE_ADDR
          default :
          begin
            lb_rd_data        <=  {'d0,data_cache[data_cache_idx]};
          end

        endcase
      end

      lb_rd_valid             <=  lb_rd_en;
    end
  end


  /*  Synchronize SDA Line input */
  module dd_sync  #(.P_NO_SYNC_STAGES(2)) sda_sync_inst
  (
      .clk          (clk),
      .rst_n        (rst_n),

      .signal_id    (sda),

      .signal_od    (sda_i)
  );



  /*  FSM Logic */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      fsm_pstate              <=  IDLE_S;
      tck_cntr                <=  0;
      data_cntr               <=  0;
      rel_i2c_bus             <=  0;
    end
    else
    begin
      fsm_pstate              <=  next_state;
      rel_i2c_bus             <=  rel_i2c_bus_next;

      if(tck_by_2_valid | ~i2c_busy)
      begin
        tck_cntr              <=  0;
      end
      else
      begin
        tck_cntr              <=  tck_cntr  + 1'b1;
      end

      if(~i2c_busy)
      begin
        data_cntr             <=  0;
      end
      else if(data_cntr_en)
      begin
        data_cntr             <=  data_cntr + 1'b1;
      end
    end
  end

  assign  tck_valid           =   (tck_cntr ==  i2c_clk_div_cnt)  ? 1'b1  : tck_by_2_valid;
  assign  tck_by_2_valid    =   (tck_cntr ==  {1'b0,i2c_clk_div_cnt[CLK_DIV_CNT_W-1:1]}) ? 1'b1  : tck_valid;
  assign  tck_by_4_valid    =   (tck_cntr ==  {2'b0,i2c_clk_div_cnt[CLK_DIV_CNT_W-1:2]}) ? 1'b1  : tck_by_2_valid;
  assign  data_cntr_bytes     =   data_cntr[DATA_CNTR_W-1:3];

  always@(*)
  begin
    next_state      =   fsm_pstate;
    data_cntr_en    =   1'b0;
    rel_i2c_bus_next=   1'b0;

    case(fsm_pstate)

      IDLE_S  :
      begin
        if(i2c_init)
        begin
          if(i2c_start_en)  //start with START sequence
          begin
            next_state        =   START_S;
          end
          else  //start with ADDR phase
          begin
            next_state        =   ADDR_S;
          end
        end
      end

      START_S :
      begin
        if(tck_valid  & ~scl)
        begin
          next_state          =   ADDR_S;
        end
      end

      ACK_S   :
      begin
        if(i2c_rd_n_wr) //Read
        begin
          rel_i2c_bus_next    =   (data_cntr_bytes  ==  'd1)  ? 1'b1  : 1'b0;
        end
        else  //Write
        begin
          rel_i2c_bus_next    =   1'b1;
        end

        if(tck_valid)
        begin
          if(data_cntr_bytes  > i2c_num_bytes)
          begin
            next_state        =  i2c_stop_en  ? STOP_S  : IDLE_S; 
          end
          else
          begin
            next_state        =   DATA_S;
          end
        end
      end

      ADDR_S  :
      begin
        data_cntr_en          =   tck_valid;

        if((data_cntr[2:0]  ==  3'd7) & tck_valid)
        begin
          next_state          =   ACK_S;
        end
      end

      DATA_S  :
      begin
        rel_i2c_bus_next      =   i2c_rd_n_wr ? 1'b1  : 1'b0;

        data_cntr_en          =   tck_valid;

        if((data_cntr[2:0]  ==  3'd7) & tck_valid)
        begin
          next_state          =   ACK_S;
        end
      end 

      STOP_S  :
      begin
        if(tck_valid  & sda_o)
        begin
          next_state          =   IDLE_S;
        end
      end

    endcase
  end

  //Generate the sequence of bits to be transmitted
  //Transmission starts from i2c_seq_bits[0]
  generate
    for(i=0;  i<7;  i++)
    begin : gen_seq_bits_addr
      assign  i2c_seq_bits[i] = i2c_addr[6-i];
    end

    assign  i2c_seq_bits[7]   = i2c_rd_n_wr;

    for(i=0;  i<I2C_MAX_DATA_BYTES;  i++)
    begin : gen_seq_bits_data_bytes
      for(j=0;  j<8;  j++)
      begin : gen_seq_bits_data_bits
        assign  i2c_seq_bits[(8*(i+1))  + j]  = data_cache[i][7-j];
      end
    end
  endgenerate

  /*  I2C Bus Logic */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      scl                     <=  1'b0;
      sda_o                   <=  1'b0;
    end
    else
    begin
      case(fsm_pstate)

        IDLE_S  :
        begin
          scl                 <=  (i2c_init & i2c_start_en) ? 1'b1  : 1'b0;
          sda_o               <=  (i2c_init & i2c_start_en) ? 1'b1  : 1'b0;
        end

        START_S :
        begin
          sda_o               <=  tck_valid             ? 1'b0  : sda_o;
          scl                 <=  (tck_valid  & ~sda_o) ? 1'b0  : scl;
        end

        ACK_S   :
        begin
          if(next_state ==  STOP_S)
          begin
            sda_o             <=  1'b0;
            scl               <=  1'b0;
          end
          else
          begin
            sda_o             <=  ACK_VAL;
            scl               <=  scl ? ~(tck_by_4_valid  & ~tck_by_2_valid) : (tck_by_4_valid  & ~tck_valid);
          end
        end

        ADDR_S,DATA_S :
        begin
          sda_o               <=  i2c_seq_bits[data_cntr];
          scl                 <=  scl ? ~(tck_by_4_valid  & ~tck_by_2_valid) : (tck_by_4_valid  & ~tck_valid);
        end

        STOP_S  :
        begin
          scl                 <=  tck_valid           ? 1'b1  : scl;
          sda_o               <=  (tck_valid  & scl)  ? 1'b1  : sda_o;
        end

      endcase
    end
  end

  //Tristate logic
  assign  sda                 =   rel_i2c_bus ? 1'bz  : sda_o;

endmodule // i2c_master

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[11-10-2014  05:17:57 PM][mammenx] Modified LB read data formatting

[10-10-2014  08:56:07 AM][mammenx] Synchronized SDA Line input

[07-10-2014  08:44:32 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
