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
 -- Project Code      : synesthesia_moksha
 -- Module Name       : fgyrus_fsm
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This block is where FFT transform is implemented.
 --------------------------------------------------------------------------
*/


`timescale 1ns / 10ps

`include  "fft_utils.svh"

module fgyrus_fsm #(
  parameter MODULE_NAME         = "FGYRUS_FSM",
  parameter LB_DATA_W           = 32,
  parameter LB_ADDR_W           = 12,
  parameter NUM_SAMPLES         = 128,
  parameter SAMPLE_W            = 32,
  parameter TWDL_W              = 10,
  parameter PCM_MEM_DATA_W      = 32,
  parameter PCM_MEM_ADDR_W      = 8,
  parameter WIN_RAM_DATA_W      = 32,
  parameter WIN_RAM_ADDR_W      = 7,
  parameter TWDL_RAM_DATA_W     = 32,
  parameter TWDL_RAM_ADDR_W     = 7,
  parameter CORDIC_RAM_DATA_W   = 16,
  parameter CORDIC_RAM_ADDR_W   = 8,
  parameter FFT_CACHE_DATA_W    = 32,
  parameter FFT_CACHE_ADDR_W    = 8,
  parameter DIV_W               = 32,
  parameter PST_VEC_W           = 8,
  parameter MEM_RD_DEL          = 2,
  parameter BUT_DEL             = 4

) (

  //--------------------- Misc Ports (Logic)  -----------
  input                       clk,
  input                       rst_n,

  //Local Bus
  input                       lb_wr_en,
  input                       lb_rd_en,
  input   [LB_ADDR_W-1:0]     lb_addr,
  input   [LB_DATA_W-1:0]     lb_wr_data,
  output  reg                     lb_wr_valid,
  output  reg                     lb_rd_valid,
  output  reg [LB_DATA_W-1:0]     lb_rd_data,

  //Butterfly Wing
  output  reg [SAMPLE_W-1:0]      sample_a_re,
  output  reg [SAMPLE_W-1:0]      sample_a_im,
  output  reg [SAMPLE_W-1:0]      sample_b_re,
  output  reg [SAMPLE_W-1:0]      sample_b_im,
  output  reg [TWDL_W-1:0]        twdl_re,
  output  reg [TWDL_W-1:0]        twdl_im,
  output  reg                     sample_rdy,

  input   [SAMPLE_W-1:0]      res_re,
  input   [SAMPLE_W-1:0]      res_im,
  input                       res_rdy,

  input                       bffr_ovrflw,
  input                       bffr_underflw,

  //PCM Buffer
  input                         pcm_rdy /* synthesis keep */,

  output  [PCM_MEM_ADDR_W-1:0]  pcm_addr /* synthesis keep */,
  output  [PCM_MEM_DATA_W-1:0]  pcm_wdata /* synthesis keep */,
  output                        pcm_wren /* synthesis keep */,
  output                        pcm_rden /* synthesis keep */,
  input   [PCM_MEM_DATA_W-1:0]  pcm_rdata /* synthesis keep */,
  input                         pcm_rd_valid /* synthesis keep */,

  //Window RAM
  output  [WIN_RAM_ADDR_W-1:0]  win_ram_addr,
  output  [WIN_RAM_DATA_W-1:0]  win_ram_wdata,
  output                        win_ram_wren,
  output                        win_ram_rden,
  input   [WIN_RAM_DATA_W-1:0]  win_ram_rdata,
  input                         win_ram_rd_valid,

  //Twiddle RAM
  output  [TWDL_RAM_ADDR_W-1:0]   twdl_ram_addr,
  output  [TWDL_RAM_DATA_W-1:0]   twdl_ram_wdata,
  output                          twdl_ram_wren,
  output                          twdl_ram_rden,
  input   [TWDL_RAM_DATA_W-1:0]   twdl_ram_rdata,
  input                           twdl_ram_rd_valid,

  //CORDIC RAM
  output  [CORDIC_RAM_ADDR_W-1:0] cordic_ram_addr,
  output  [CORDIC_RAM_DATA_W-1:0] cordic_ram_wdata,
  output                          cordic_ram_wren,
  output  reg                     cordic_ram_rden,
  input   [CORDIC_RAM_DATA_W-1:0] cordic_ram_rdata,
  input                           cordic_ram_rd_valid,

  //FFT Cache
  output  reg [SAMPLE_W-1:0]      cache_intf_wr_sample_re /* synthesis keep */,
  output  reg [SAMPLE_W-1:0]      cache_intf_wr_sample_im /* synthesis keep */,
  output  reg                     cache_intf_wr_en /* synthesis keep */,
  output  [FFT_CACHE_ADDR_W-1:0]  cache_intf_waddr /* synthesis keep */,
  output  [FFT_CACHE_ADDR_W-1:0]  cache_intf_raddr /* synthesis keep */,
  output  reg                     cache_intf_rd_en /* synthesis keep */,
  input                           cache_intf_rd_valid /* synthesis keep */,
  input   [SAMPLE_W-1:0]          cache_intf_rd_sample_re /* synthesis keep */,
  input   [SAMPLE_W-1:0]          cache_intf_rd_sample_im /* synthesis keep */,
  output                          cache_intf_fft_done /* synthesis keep */,

  output  [FFT_CACHE_DATA_W-1:0]  cache_intf_hst_wdata,
  output                          cache_intf_hst_wren,
  output  [FFT_CACHE_ADDR_W-1:0]  cache_intf_hst_addr,
  output                          cache_intf_hst_rden,
  input   [FFT_CACHE_DATA_W-1:0]  cache_intf_hst_rdata,
  input                           cache_intf_hst_rd_valid

  );

//----------------------- Global parameters Declarations ------------------
  localparam  SAMPLE_CNTR_W   = $clog2(NUM_SAMPLES*2);
  localparam  DEC_WIN_PIPE_L  = MEM_RD_DEL+1+BUT_DEL+1;
  localparam  NUM_FFT_STAGES  = $clog2(NUM_SAMPLES);  //should be 7
  localparam  LB_DEL          = MEM_RD_DEL;
  localparam  LB_ADDR_DEL_W   = LB_DEL*LB_ADDR_W;

  `include  "fgyrus_reg_map.svh"


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  logic [(2*LB_DEL)-1:0]    lb_del_vec_f /*synthesis keep*/;
  logic [LB_ADDR_DEL_W-1:0] lb_addr_del_vec_f /*synthesis keep*/;
  logic                       fgyrus_en_f /*synthesis keep*/;
  logic                       fgyrus_mode_f /*synthesis keep*/;  //0->Normal,  1->Config
  logic [3:0]                 fgyrus_post_norm_f /*synthesis keep*/;
  logic                       but_bffr_ovrflow_f /*synthesis keep*/;
  logic                       but_bffr_underflw_f /*synthesis keep*/;
  logic                       fft_done_f /*synthesis keep*/; //Clear on read

  logic [PST_VEC_W-1:0]     pst_vec_f /*synthesis keep*/;
  logic                       wait_for_end_f /*synthesis keep*/;
  logic [SAMPLE_CNTR_W-1:0] sample_rcntr_f /*synthesis keep*/;
  logic [SAMPLE_CNTR_W-1:0] sample_wcntr_f /*synthesis keep*/;

  logic [NUM_FFT_STAGES-1:0]  fft_stage_rd_f /*synthesis keep*/;
  logic [SAMPLE_CNTR_W-1:0] fft_stage_rd_bound_f /*synthesis keep*/;
  logic [NUM_FFT_STAGES-1:0]  fft_stage_wr_f /*synthesis keep*/;
  logic [SAMPLE_CNTR_W-1:0] fft_stage_wr_bound_f /*synthesis keep*/;

  logic                       div_load_f /*synthesis keep*/;
  logic [DIV_W-1:0]         div_n_f /*synthesis keep*/;
  logic [DIV_W-1:0]         div_d_f /*synthesis keep*/;
  logic                       div_norm_f /*synthesis keep*/;
  logic                       div_d_is_null_f /*synthesis keep*/;

  logic [6:0]                 twdl_addr_f /*synthesis keep*/;
  logic [7:0]                 cordic_addr_f /*synthesis keep*/;

  genvar  i;

//----------------------- Internal Wire Declarations ----------------------
  logic [LB_ADDR_W-1:0]     lb_del_addr_w /*synthesis keep*/;
  logic                       fgyrus_busy_c /*synthesis keep*/;

  logic                       rchnnl_n_lchnnl_w /*synthesis keep*/;
  logic [SAMPLE_CNTR_W-2:0] sample_rcntr_rev_w /*synthesis keep*/;
  logic                       decimate_ovr_c /*synthesis keep*/;

  logic                       wrap_inc_fft_rcntr_c /*synthesis keep*/;
  logic                       fft_stage_rd_ovr_c /*synthesis keep*/;
  logic                       fft_rd_ovr_c /*synthesis keep*/;

  logic                       wrap_inc_fft_wcntr_c /*synthesis keep*/;
  logic                       fft_stage_wr_ovr_c /*synthesis keep*/;
  logic                       fft_wr_ovr_c /*synthesis keep*/;

  logic                       cordic_ovr_c /*synthesis keep*/;
  logic                       abs_ovr_c /*synthesis keep*/;

  logic [DIV_W-1:0]         div_res_q_w /*synthesis keep*/;
  logic [DIV_W-1:0]         div_res_r_w /*synthesis keep*/;
  logic                       div_res_rdy_w /*synthesis keep*/;
  logic                       div_res_almost_done_w /*synthesis keep*/;
  logic [DIV_W-1:0]         div_res_q_norm_c /*synthesis keep*/;


//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------
enum  logic [2:0] { IDLE_S  = 3'd0,
                    DECIMATE_WINDOW_S,
                    FFT_S,
                    CORDIC_S,
                    ABS_S
                  } fsm_pstate/* synthesis keep */, next_state;


//----------------------- Start of Code -----------------------------------

  assign  lb_del_addr_w = lb_addr_del_vec_f[LB_ADDR_DEL_W-1 -:  LB_ADDR_W];

  /*  Local Bus Logic */
  always_ff@(posedge clk, negedge rst_n)
  begin : lb_logic
    if(~rst_n)
    begin
      lb_wr_valid        <=  0;
      lb_rd_valid        <=  0;
      lb_rd_data         <=  0;

      fgyrus_en_f             <=  0;
      fgyrus_mode_f           <=  0;  //normal
      fgyrus_post_norm_f      <=  0;  //No normalization
      but_bffr_ovrflow_f      <=  0;
      but_bffr_underflw_f     <=  0;
      fft_done_f              <=  0;

      lb_del_vec_f            <=  0;
      lb_addr_del_vec_f       <=  0;
    end
    else
    begin
      lb_del_vec_f            <=  {lb_del_vec_f[(2*LB_DEL)-3:0],  lb_wr_en,  lb_rd_en};
      lb_addr_del_vec_f       <=  {lb_addr_del_vec_f[LB_ADDR_DEL_W-LB_ADDR_W-1:0],  lb_addr};

      if(lb_wr_en)
      begin
        fgyrus_en_f           <=  (lb_addr ==  {FGYRUS_REG_CODE,FGYRUS_CONTROL_REG_ADDR})  ? lb_wr_data[0]  : fgyrus_en_f;

        fgyrus_mode_f         <=  (lb_addr ==  {FGYRUS_REG_CODE,FGYRUS_CONTROL_REG_ADDR})  ? lb_wr_data[1]  : fgyrus_mode_f;

        fgyrus_post_norm_f    <=  (lb_addr ==  {FGYRUS_REG_CODE,FGYRUS_POST_NORM_REG_ADDR})? lb_wr_data[3:0]: fgyrus_post_norm_f;
      end

      lb_wr_valid        <=  lb_del_vec_f[(2*LB_DEL)-1];

      but_bffr_ovrflow_f      <=  but_bffr_ovrflow_f  | bffr_ovrflw;
      but_bffr_underflw_f     <=  but_bffr_underflw_f | bffr_underflw;

      case(lb_del_addr_w[LB_ADDR_W-1  -:  4])

        FGYRUS_REG_CODE :
        begin
          case(lb_del_addr_w[7:0])

            FGYRUS_CONTROL_REG_ADDR   : lb_rd_data <=  {{LB_DATA_W-2{1'b0}}, fgyrus_mode_f,fgyrus_en_f};
            FGYRUS_STATUS_REG_ADDR    : lb_rd_data <=  {{LB_DATA_W-4{1'b0}}, fft_done_f,but_bffr_ovrflow_f,but_bffr_underflw_f,fgyrus_busy_c};
            FGYRUS_POST_NORM_REG_ADDR : lb_rd_data <=  {{LB_DATA_W-4{1'b0}}, fgyrus_post_norm_f};
            default                   : lb_rd_data <=  'hdeadbabe;

          endcase
        end

        FGYRUS_FFT_CACHE_RAM_CODE :
          lb_rd_data     <=  cache_intf_hst_rdata;

        FGYRUS_TWDLE_RAM_CODE :
          lb_rd_data     <=  twdl_ram_rdata;

        FGYRUS_CORDIC_RAM_CODE  :
          lb_rd_data     <=  {{(LB_DATA_W-CORDIC_RAM_DATA_W){1'b0}}, cordic_ram_rdata};

        FGYRUS_WIN_RAM_CODE :
          lb_rd_data     <=  win_ram_rdata;

        default  : lb_rd_data    <=  'hdeadbabe;
      endcase

      lb_rd_valid        <=  lb_del_vec_f[(2*LB_DEL)-2];

      //Clear on read logic
      if(fft_done_f)
      begin
        fft_done_f       <= ~lb_rd_valid;
      end
      else
      begin
        fft_done_f       <= cache_intf_fft_done;
      end
    end
  end

  //Check if FSM is busy or not
  assign  fgyrus_busy_c = (fsm_pstate ==  IDLE_S) ?1'b0  : 1'b1;


  /*  FSM Sequential Logic  */
  always_ff@(posedge clk, negedge rst_n)
  begin : fsm_seq_logic
    if(~rst_n)
    begin
      fsm_pstate              <=  IDLE_S;
    end
    else
    begin
      fsm_pstate              <=  next_state;
    end
  end

  /*  FSm Combinational Logic */
  always_comb
  begin : fsm_comb_logic
    next_state  = fsm_pstate;

    case(fsm_pstate)

      IDLE_S  :
      begin
        if(fgyrus_en_f  & pcm_rdy  & ~fgyrus_mode_f)
        begin
          next_state  = DECIMATE_WINDOW_S;
        end
      end

      DECIMATE_WINDOW_S :
      begin
        if(decimate_ovr_c)
        begin
          next_state  = FFT_S;
        end
      end

      FFT_S :
      begin
        if(fft_wr_ovr_c)
        begin
          next_state  = CORDIC_S;
        end
      end

      CORDIC_S  :
      begin
        if(cordic_ovr_c)
        begin
          next_state  = ABS_S;
        end
      end

      ABS_S :
      begin
        if(abs_ovr_c)
        begin
          next_state  = IDLE_S;
        end
      end

    endcase
  end


  /*  PST Vector Logic  */
  always_ff@(posedge clk, negedge rst_n)
  begin : pst_vec_logic
    if(~rst_n)
    begin
      pst_vec_f               <=  0;
    end
    else
    begin
      case(fsm_pstate)

        IDLE_S  :
        begin
          pst_vec_f           <=  0;
        end

        DECIMATE_WINDOW_S :
        begin
          pst_vec_f[0]        <=  decimate_ovr_c  ? 1'b0  : ~pst_vec_f[0];
        end

        FFT_S :
        begin
          pst_vec_f[0]        <=  fft_wr_ovr_c  ? 1'b0    : ~pst_vec_f[0];
        end

        CORDIC_S  :
        begin
          pst_vec_f[2:0]      <=  {pst_vec_f[1:0],cache_intf_rd_valid};

          pst_vec_f[3]        <=  div_res_rdy_w;
        end

        ABS_S :
        begin
          pst_vec_f[2:0]      <=  {pst_vec_f[1:0],cache_intf_rd_valid};

          pst_vec_f[3]        <=  div_res_rdy_w;
        end

      endcase
    end
  end


  /*  Sample counter logic  */
  always_ff@(posedge clk, negedge rst_n)
  begin : sample_cntr_logic
    if(~rst_n)
    begin
      wait_for_end_f          <=  0;
      sample_rcntr_f          <=  0;
      sample_wcntr_f          <=  0;
    end
    else
    begin
      case(fsm_pstate)

        IDLE_S  :
        begin
          sample_rcntr_f      <=  0;
          sample_wcntr_f      <=  0;
          wait_for_end_f      <=  0;
        end

        DECIMATE_WINDOW_S :
        begin
          sample_rcntr_f      <=  wait_for_end_f  ? 'd0 : sample_rcntr_f + pst_vec_f[0];

          if(wait_for_end_f)  //wait for decimate over signal
          begin
            wait_for_end_f    <=  ~decimate_ovr_c;
          end
          else  //wait for last sample read
          begin
            wait_for_end_f    <=  (&sample_rcntr_f) ? pst_vec_f[0]  : 1'b0;
          end

          sample_wcntr_f      <=  sample_wcntr_f  + cache_intf_wr_en;
        end

        FFT_S :
        begin
          if(wait_for_end_f)  //wait for decimate over signal
          begin
            wait_for_end_f    <=  ~fft_wr_ovr_c;
          end
          else  //wait for last sample read
          begin
            wait_for_end_f    <=  fft_rd_ovr_c;
          end

          sample_rcntr_f[SAMPLE_CNTR_W-2:0] <=  (fft_stage_rd_ovr_c | wait_for_end_f) ? 0
                                                                      : sample_rcntr_f[SAMPLE_CNTR_W-2:0] +
                                                                        fft_stage_rd_f +
                                                                        wrap_inc_fft_rcntr_c;

          sample_rcntr_f[SAMPLE_CNTR_W-1]   <=  ~fft_rd_ovr_c &
                                                      (sample_rcntr_f[SAMPLE_CNTR_W-1]  |
                                                        (fft_stage_rd_f[NUM_FFT_STAGES-1]  & fft_stage_rd_ovr_c));


          if(cache_intf_wr_en)
          begin
            sample_wcntr_f[SAMPLE_CNTR_W-2:0] <=  fft_stage_wr_ovr_c  ? 0
                                                                        : sample_wcntr_f[SAMPLE_CNTR_W-2:0] +
                                                                          fft_stage_wr_f +
                                                                          wrap_inc_fft_wcntr_c;

            sample_wcntr_f[SAMPLE_CNTR_W-1]   <=  ~fft_wr_ovr_c &
                                                        (sample_wcntr_f[SAMPLE_CNTR_W-1]  |
                                                          (fft_stage_wr_f[NUM_FFT_STAGES-1]  & fft_stage_wr_ovr_c));
          end
        end

        CORDIC_S  : 
        begin
          if(wait_for_end_f)  //wait for over signal
          begin
            wait_for_end_f    <=  ~cordic_ovr_c;
          end
          else  //wait for last sample read
          begin
            wait_for_end_f    <=  &cache_intf_raddr;
          end

          sample_rcntr_f      <=  sample_rcntr_f  + pst_vec_f[3];
          sample_wcntr_f      <=  sample_wcntr_f  + cache_intf_wr_en;
        end

        ABS_S : 
        begin
          if(wait_for_end_f)  //wait for decimate over signal
          begin
            wait_for_end_f    <=  ~abs_ovr_c;
          end
          else  //wait for last sample read
          begin
            wait_for_end_f    <=  &cache_intf_raddr;
          end

          sample_rcntr_f      <=  sample_rcntr_f  + (div_res_almost_done_w  & ~wait_for_end_f);
          sample_wcntr_f      <=  sample_wcntr_f  + cache_intf_wr_en;
        end

      endcase
    end
  end

  //Check for end of decimation
  assign  decimate_ovr_c  = (&sample_wcntr_f) ? cache_intf_wr_en  : 1'b0;

  //Bit reversed version of sample counter
  generate
    for (i=0; i < SAMPLE_CNTR_W-1; i=i+1)
    begin : BIT_REV
      assign  sample_rcntr_rev_w[i]  = sample_rcntr_f[SAMPLE_CNTR_W-2-i];
    end
  endgenerate

  /*  PCM Mem Interface Logic */
  assign  rchnnl_n_lchnnl_w = sample_rcntr_f[SAMPLE_CNTR_W-1];
  assign  pcm_addr    = (fsm_pstate ==  DECIMATE_WINDOW_S)  ? {rchnnl_n_lchnnl_w,sample_rcntr_rev_w}  : 0;
  assign  pcm_wdata   = 0;
  assign  pcm_wren    = 0;
  assign  pcm_rden    = (fsm_pstate ==  DECIMATE_WINDOW_S)  ? ~pst_vec_f[0] & ~wait_for_end_f : 1'b0;

  /*  Window Mem Interface Logic  */
  assign  win_ram_addr       = fgyrus_mode_f  ? lb_addr[6:0] :
                                 ((fsm_pstate  ==  DECIMATE_WINDOW_S)  ? sample_rcntr_rev_w  : 0);
  assign  win_ram_wdata      = lb_wr_data;
  assign  win_ram_wren       = (lb_addr[LB_ADDR_W-1 -: 4] ==  FGYRUS_WIN_RAM_CODE)  ? lb_wr_en : 1'b0;
  assign  win_ram_rden       = (fsm_pstate ==  DECIMATE_WINDOW_S)  ? ~pst_vec_f[0] : 1'b0;

  /*  FFT Stage Counter Logic */
  always_ff@(posedge clk, negedge rst_n)
  begin : fft_stage_logic
    if(~rst_n)
    begin
      fft_stage_rd_f          <=  1;  //One hot
      fft_stage_rd_bound_f    <=  (NUM_SAMPLES-1);
      fft_stage_wr_f          <=  1;  //One hot
      fft_stage_wr_bound_f    <=  (NUM_SAMPLES-1);
    end
    else
    begin
      if(fsm_pstate ==  FFT_S)
      begin
        if(fft_stage_rd_ovr_c)
        begin
          if(fft_stage_rd_f[NUM_FFT_STAGES-1])
          begin
            fft_stage_rd_f        <=  1;
            fft_stage_rd_bound_f  <=  (NUM_SAMPLES-1);
          end
          else
          begin
            fft_stage_rd_f        <=  {fft_stage_rd_f[NUM_FFT_STAGES-2:0],1'b0};
            fft_stage_rd_bound_f  <=  fft_stage_rd_bound_f  - fft_stage_rd_f;
          end
        end

        if(fft_stage_wr_ovr_c)
        begin
          if(fft_stage_wr_f[NUM_FFT_STAGES-1])
          begin
            fft_stage_wr_f        <=  1;
            fft_stage_wr_bound_f  <=  (NUM_SAMPLES-1);
          end
          else
          begin
            fft_stage_wr_f        <=  {fft_stage_wr_f[NUM_FFT_STAGES-2:0],1'b0};
            fft_stage_wr_bound_f  <=  fft_stage_wr_bound_f  - fft_stage_wr_f;
          end
        end
      end
      else
      begin
        fft_stage_rd_f        <=  1;
        fft_stage_rd_bound_f  <=  (NUM_SAMPLES-1);
        fft_stage_wr_f        <=  1;
        fft_stage_wr_bound_f  <=  (NUM_SAMPLES-1);
      end
    end
  end

  //Check when to wrap the FFT sample counter
  assign  wrap_inc_fft_rcntr_c  = (sample_rcntr_f[SAMPLE_CNTR_W-2:0]  >=  fft_stage_rd_bound_f)  ? 1'b1  : 1'b0;
  assign  wrap_inc_fft_wcntr_c  = (sample_wcntr_f[SAMPLE_CNTR_W-2:0]  >=  fft_stage_wr_bound_f)  ? cache_intf_wr_en  : 1'b0;

  //Check for end of FFT stage
  assign  fft_stage_rd_ovr_c    = &sample_rcntr_f[SAMPLE_CNTR_W-2:0];
  assign  fft_stage_wr_ovr_c    = &sample_wcntr_f[SAMPLE_CNTR_W-2:0]  & cache_intf_wr_en;

  //Check if all samples have been FFT'd
  assign  fft_rd_ovr_c          = fft_stage_rd_ovr_c  & sample_rcntr_f[SAMPLE_CNTR_W-1] & fft_stage_rd_f[NUM_FFT_STAGES-1];
  assign  fft_wr_ovr_c          = fft_stage_wr_ovr_c  & sample_wcntr_f[SAMPLE_CNTR_W-1] & fft_stage_wr_f[NUM_FFT_STAGES-1];


  /*  Butterfly Interface Logic */
  always_ff@(posedge clk, negedge rst_n)
  begin : but_intf_logic
    if(~rst_n)
    begin
      sample_a_re    <=  0;
      sample_a_im    <=  0;
      sample_b_re    <=  0;
      sample_b_im    <=  0;
      twdl_re        <=  0;
      twdl_im        <=  0;
      sample_rdy     <=  0;
    end
    else
    begin
      case(fsm_pstate)

        IDLE_S  :
        begin
          sample_rdy   <=  0;
        end

        DECIMATE_WINDOW_S :
        begin
          sample_a_re  <=  0;
          sample_a_im  <=  0;

          sample_b_re  <=  pcm_rdata;
          sample_b_im  <=  0;

          twdl_re      <=  win_ram_rdata[TWDL_W-1:0];
          twdl_im      <=  0;

          sample_rdy   <=  win_ram_rd_valid & pcm_rd_valid;
        end

        FFT_S :
        begin
          sample_a_re  <=  sample_b_re;
          sample_a_im  <=  sample_b_im;

          sample_b_re  <=  cache_intf_rd_sample_re;
          sample_b_im  <=  cache_intf_rd_sample_im;

          twdl_re      <=  twdl_ram_rdata[16  +:  TWDL_W];
          twdl_im      <=  twdl_ram_rdata[TWDL_W-1:0];

          sample_rdy   <=  twdl_ram_rd_valid  & cache_intf_rd_valid & pst_vec_f[0];
        end

      endcase
    end
  end

  /*  FFT Cache Interface Logic */
  always_ff@(posedge clk, negedge rst_n)
  begin : fft_cache_intf_logic
    if(~rst_n)
    begin
      cache_intf_wr_en            <=  0;
      cache_intf_rd_en            <=  0;
      cache_intf_wr_sample_re     <=  0;
      cache_intf_wr_sample_im     <=  0;
    end
    else
    begin
      case(fsm_pstate)

        IDLE_S  :
        begin
          cache_intf_wr_en        <=  0;
          cache_intf_rd_en        <=  0;
        end

        DECIMATE_WINDOW_S :
        begin
          cache_intf_wr_en        <=  res_rdy  & ~pst_vec_f[0];
          cache_intf_wr_sample_re <=  res_re;
          cache_intf_wr_sample_im <=  res_im;

          cache_intf_rd_en        <=  decimate_ovr_c;
        end

        FFT_S :
        begin
          cache_intf_rd_en        <=  fft_wr_ovr_c  ? 1'b1  : ~wait_for_end_f;

          cache_intf_wr_en        <=  res_rdy;
          cache_intf_wr_sample_re <=  res_re;
          cache_intf_wr_sample_im <=  res_im;
        end

        CORDIC_S  :
        begin
          cache_intf_rd_en        <=  cordic_ovr_c  | (pst_vec_f[3] & ~wait_for_end_f);

          cache_intf_wr_en        <=  cordic_ram_rd_valid;
          cache_intf_wr_sample_re <=  cache_intf_rd_sample_re;
          cache_intf_wr_sample_im <=  {{(SAMPLE_W-CORDIC_RAM_DATA_W){1'b0}}, cordic_ram_rdata};
        end

        ABS_S :
        begin
          cache_intf_rd_en        <=  div_res_almost_done_w & ~wait_for_end_f;

          cache_intf_wr_en        <=  div_res_rdy_w;
          cache_intf_wr_sample_re <=  div_res_q_norm_c;
          cache_intf_wr_sample_im <=  0;
        end
      endcase
    end
  end

  assign  cache_intf_waddr      = sample_wcntr_f;
  assign  cache_intf_raddr      = sample_rcntr_f;

  assign  cache_intf_hst_addr   = lb_addr[7:0];
  assign  cache_intf_hst_wdata  = lb_wr_data;
  assign  cache_intf_hst_wren   = (lb_addr[LB_ADDR_W-1 -:  4]  ==  FGYRUS_FFT_CACHE_RAM_CODE)  ? lb_wr_en : 1'b0;
  assign  cache_intf_hst_rden   = 0;
  assign  cache_intf_fft_done   = (fsm_pstate ==  ABS_S)  ? abs_ovr_c : 1'b0;


  /*  Twiddle RAM Address Logic */
  always_ff@(posedge clk, negedge rst_n)
  begin : twdl_ram_addr_logic
    if(~rst_n)
    begin
      twdl_addr_f             <= 1;
    end
    else
    begin
      case(fsm_pstate)

        FFT_S :
        begin
          twdl_addr_f         <=  (fft_stage_rd_ovr_c & fft_stage_rd_f[NUM_FFT_STAGES-1]) ? 1
                                    : twdl_addr_f  + wrap_inc_fft_rcntr_c;
        end

        default :
        begin
          twdl_addr_f         <=  1;
        end

      endcase
    end
  end

  assign  twdl_ram_addr  = fgyrus_mode_f ? lb_addr[6:0] : twdl_addr_f;
  assign  twdl_ram_rden  = (fsm_pstate ==  FFT_S)  ? ~wait_for_end_f : 1'b0;
  assign  twdl_ram_wren  = (lb_addr[LB_ADDR_W-1 -:  4]  ==  FGYRUS_TWDLE_RAM_CODE)  ? lb_wr_en : 1'b0;
  assign  twdl_ram_wdata = lb_wr_data;


  /*  Divider Feeder Pipe */
  always_ff@(posedge clk, negedge rst_n)
  begin : div_feeder_logic
    if(~rst_n)
    begin
      div_load_f              <=  0;
      div_n_f                 <=  0;
      div_d_f                 <=  0;
      div_norm_f              <=  0;
      div_d_is_null_f         <=  0;
    end
    else
    begin
      if(fsm_pstate ==  IDLE_S)
      begin
        div_load_f            <=  0;
        div_norm_f            <=  0;
        div_d_is_null_f       <=  0;
      end
      else
      begin
        div_load_f            <=  pst_vec_f[2];

        if(div_d_is_null_f)
        begin
          div_d_is_null_f     <=  ~div_res_rdy_w;
        end
        else if(pst_vec_f[1])
        begin
          div_d_is_null_f     <=  ~(|div_d_f);
        end

        if(div_norm_f)
        begin
          div_norm_f          <=  ~div_res_rdy_w;
        end
        else if(pst_vec_f[1])
        begin
          div_norm_f          <=  ~(|div_n_f[DIV_W-1:16]);
        end
      end

      if((fsm_pstate  ==  CORDIC_S) | (fsm_pstate ==  ABS_S))
      begin
        case(1'b1)  //synthesis full_case parallel_case

          cache_intf_rd_valid : //register the numerator & denominator
          begin
            div_n_f           <=  (fsm_pstate ==  CORDIC_S) ? cache_intf_rd_sample_im : cache_intf_rd_sample_re;
            div_d_f           <=  (fsm_pstate ==  CORDIC_S) ? cache_intf_rd_sample_re : cache_intf_rd_sample_im;
          end

          pst_vec_f[0]  : //convert to positive integer
          begin
            div_n_f           <=  div_n_f[DIV_W-1]  ? ~div_n_f  + 1'b1  : div_n_f;
            div_d_f           <=  div_d_f[DIV_W-1]  ? ~div_d_f  + 1'b1  : div_d_f;
          end

          pst_vec_f[2]  : //normalise numerator
          begin
            div_n_f           <=  div_norm_f  ? {div_n_f[15:0],{16{1'b0}}}  : div_n_f;
          end

          default :
          begin
            div_n_f           <=  div_n_f;
            div_d_f           <=  div_d_f;
          end

        endcase
      end
    end
  end

  //Normalise the div result
  always_comb
  begin : div_res_norm_logic
    if(fsm_pstate ==  ABS_S)  //Here, the final result has to be multiplied by 16b
    begin                     //If its already normalized during loading, leave as is
      div_res_q_norm_c  = div_norm_f  ? div_res_q_w : {div_res_q_w[15:0],  {16{1'b0}}};
    end
    else
    begin
      div_res_q_norm_c  = div_norm_f  ? {{16{1'b0}}, div_res_q_w[DIV_W-1:16]} : div_res_q_w;
    end
  end

  /*  Cordic RAM Address logic  */
  always_ff@(posedge clk, negedge rst_n)
  begin : cordic_ram_addr_logic
    if(~rst_n)
    begin
      cordic_addr_f           <=  0;
      cordic_ram_rden         <=  0;
    end
    else
    begin
      if((fsm_pstate ==  CORDIC_S) & div_res_rdy_w)
      begin
        cordic_addr_f         <=  (div_d_is_null_f  | (|div_res_q_norm_c[DIV_W-1:8]))  ? 8'hff //infinity case
                                                                                    : div_res_q_norm_c[7:0];
      end

      cordic_ram_rden         <=  (fsm_pstate ==  CORDIC_S) ? div_res_rdy_w : 1'b0;
    end
  end

  assign  cordic_ram_addr  = fgyrus_mode_f ? lb_addr[7:0] : cordic_addr_f;
  assign  cordic_ram_wren  = (lb_addr[LB_ADDR_W-1 -:  4]  ==  FGYRUS_CORDIC_RAM_CODE) ? lb_wr_en : 1'b0;
  assign  cordic_ram_wdata = lb_wr_data[CORDIC_RAM_DATA_W-1:0];

  //Check for end of CORDIC & ABS stages
  assign  cordic_ovr_c  = (&cache_intf_waddr)  & cache_intf_wr_en;
  assign  abs_ovr_c     = cordic_ovr_c;


  /* Instantiate divider module */
  divider_rad4    div_rad4_inst
  (
    .clk          (clk),
    .rst          (~rst_n),
    .load         (div_load_f),
    .n            (div_n_f),
    .d            (div_d_f),
    .q            (div_res_q_w),
    .r            (div_res_r_w),
    .ready        (div_res_rdy_w),
    .almost_done  (div_res_almost_done_w)
  );

  defparam  div_rad4_inst.WIDTH_N = DIV_W;
  defparam  div_rad4_inst.WIDTH_D = DIV_W;

endmodule // fgyrus_fsm


/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[06-12-2014  05:46:36 PM][mammenx] Added fft_done_f

[29-11-2014  10:32:10 PM][mammenx] Fixed pcm read address issue

 --------------------------------------------------------------------------
*/

