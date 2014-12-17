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
 -- Module Name       : adv7513_video_drvr
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module contains logic for generating video
                        signals & timing.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module adv7513_video_drvr #(
  //----------------- Parameters  -----------------------
  parameter MODULE_NAME     = "ADV7513_VIDEO_DRVR",
  parameter SYNC_ACTIVE_HIGH_N_LOW  = 0,

  //Video Timing Parameters
  parameter HVALID_W        = 1280,
  parameter HFP_W           = 110,
  parameter HSYNC_W         = 40,
  parameter HBP_W           = 220,

  parameter VVALID_W        = 720,
  parameter VFP_W           = 5,
  parameter VSYNC_W         = 5,
  parameter VBP_W           = 20

) (

  //--------------------- Ports -------------------------
  input                       clk,
  input                       rst_n,

  input                       drvr_en,

  input                       ff_empty,
  input     [23:0]            ff_rdata,
  output                      ff_rd_en,

  output reg[23:0]            HDMI_TX_D,
  output reg                  HDMI_TX_DE,
  output reg                  HDMI_TX_HS,
  input                       HDMI_TX_INT,
  output reg                  HDMI_TX_VS

);

//----------------------- Local Parameters Declarations -------------------
  localparam  VGA_HTOTAL_W    = VGA_HVALID_W  + VGA_HFP_W + VGA_HSYNC_W + VGA_HBP_W;
  localparam  VGA_HCNTR_W     = $clog2(VGA_HTOTAL_W);

  localparam  VGA_VTOTAL_W    = VGA_VVALID_W  + VGA_VFP_W + VGA_VSYNC_W + VGA_VBP_W;
  localparam  VGA_VCNTR_W     = $clog2(VGA_VTOTAL_W);

  localparam  SYNC_ACTIVE_VAL = SYNC_ACTIVE_HIGH_N_LOW  ? 1 : 0;
  localparam  SYNC_NACTIVE_VAL= SYNC_ACTIVE_HIGH_N_LOW  ? 0 : 1;

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg   [VGA_HCNTR_W-1:0]     hcntr_f;
  reg   [VGA_VCNTR_W-1:0]     vcntr_f;


//----------------------- Internal Wire Declarations ----------------------
  wire                        hcntr_en_c;
  wire                        hcntr_wrap_c;
  wire                        hfp_ovr_c;
  wire                        hsync_ovr_c;
  wire                        hbp_ovr_c;

  wire                        vcntr_en_c;
  wire                        vcntr_wrap_c;
  wire                        vfp_ovr_c;
  wire                        vsync_ovr_c;
  wire                        vbp_ovr_c;

  wire                        valid_pxl_range_c;

  wire                        pxl_rd_en_c;



//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------
typedef enum  logic [3:0] {IDLE_S=0,  FP_S, SYNC_S, BP_S, VALID_S}  vga_fsm_t;
vga_fsm_t   hfsm_pstate,  hfsm_nstate /* synthesis syn_encoding = "user" */;
vga_fsm_t   vfsm_pstate,  vfsm_nstate /* synthesis syn_encoding = "user" */;


//----------------------- Start of Code -----------------------------------

  /*  FSM Sequential logic  */
  always@(posedge clk, negedge rst_n)
  begin : fsm_seq_logic
    if(~rst_n)
    begin
      hfsm_pstate             <=  IDLE_S;
      vfsm_pstate             <=  IDLE_S;
    end
    else
    begin
      hfsm_pstate             <=  hfsm_nstate;
      vfsm_pstate             <=  vfsm_nstate;
    end
  end


  /*  HFSM combinational logic  */
  always@(*)
  begin
    if(~drvr_en)
    begin
      hfsm_nstate             = IDLE_S;
    end
    else
    begin
      hfsm_nstate             = hfsm_pstate;

      case(hfsm_pstate)

        IDLE_S  :
        begin
          hfsm_nstate         = FP_S;
        end

        FP_S  :
        begin
          if(hfp_ovr_c)
          begin
            hfsm_nstate       = SYNC_S;
          end
        end

        SYNC_S  :
        begin
          if(hsync_ovr_c)
          begin
            hfsm_nstate       = BP_S;
          end
        end

        BP_S  :
        begin
          if(hbp_ovr_c)
          begin
            hfsm_nstate       = VALID_S;
          end
        end

        VALID_S :
        begin
          if(hcntr_wrap_c)
          begin
            hfsm_nstate       = FP_S;
          end
        end

      endcase
    end
  end

  /*  VFSM combinational logic  */
  always@(*)
  begin
    if(~drvr_en)
    begin
      vfsm_nstate             = IDLE_S;
    end
    else
    begin
      vfsm_nstate             = vfsm_pstate;

      case(vfsm_pstate)

        IDLE_S  :
        begin
          vfsm_nstate         = FP_S;
        end

        FP_S  :
        begin
          if(vfp_ovr_c)
          begin
            vfsm_nstate       = SYNC_S;
          end
        end

        SYNC_S  :
        begin
          if(vsync_ovr_c)
          begin
            vfsm_nstate       = BP_S;
          end
        end

        BP_S  :
        begin
          if(vbp_ovr_c)
          begin
            vfsm_nstate       = VALID_S;
          end
        end

        VALID_S :
        begin
          if(vcntr_wrap_c)
          begin
            vfsm_nstate       = FP_S;
          end
        end

      endcase
    end
  end


  //Counter enable logic
  assign  hcntr_en_c          =   (hfsm_pstate  ==  IDLE_S) ? 1'b0  : 1'b1;
  assign  vcntr_en_c          =   (vfsm_pstate  ==  IDLE_S) ? 1'b0  : 1'b1;

  //Check when to wrap counters
  assign  hcntr_wrap_c        =   (hcntr_f  ==  VGA_HTOTAL_W-1) ? 1'b1  : 1'b0;
  assign  vcntr_wrap_c        =   (vcntr_f  ==  VGA_VTOTAL_W-1) ? hcntr_wrap_c  : 1'b0;

  //Check if FP is done
  assign  hfp_ovr_c           =   (hcntr_f  ==  VGA_HFP_W-1)    ? 1'b1  : 1'b0;
  assign  vfp_ovr_c           =   (vcntr_f  ==  VGA_VFP_W-1)    ? hcntr_wrap_c  : 1'b0;

  //Check if SYNC is done
  assign  hsync_ovr_c         =   (hcntr_f  ==  VGA_HFP_W+VGA_HSYNC_W-1)  ? 1'b1  : 1'b0;
  assign  vsync_ovr_c         =   (vcntr_f  ==  VGA_VFP_W+VGA_VSYNC_W-1)  ? hcntr_wrap_c  : 1'b0;

  //Check if BP is done
  assign  hbp_ovr_c           =   (hcntr_f  ==  VGA_HFP_W+VGA_HSYNC_W+VGA_HBP_W-1)  ? 1'b1  : 1'b0;
  assign  vbp_ovr_c           =   (vcntr_f  ==  VGA_VFP_W+VGA_VSYNC_W+VGA_VBP_W-1)  ? hcntr_wrap_c  : 1'b0;

  /*
    * HCNTR, VCNTR Logic
  */
  always@(posedge clk, negedge rst_n)
  begin : vga_tck_cntr_logic
    if(~rst_n)
    begin
      hcntr_f                 <=  0;
      vcntr_f                 <=  0;
    end
    else
    begin

      if(hcntr_wrap_c)
      begin
        hcntr_f               <=  0;
      end
      else if(hcntr_en_c)
      begin
        hcntr_f               <=  hcntr_f + 1'b1;
      end

      if(vcntr_wrap_c)
      begin
        vcntr_f               <=  0;
      end
      else if(vcntr_en_c)
      begin
        vcntr_f               <=  vcntr_f + hcntr_wrap_c;
      end
    end
  end

  //Check if the fsm is in a state of valid range
  assign  valid_pxl_range_c   =   (hfsm_pstate  ==  VALID_S)  & (vfsm_pstate  ==  VALID_S);


  /*  Generate pixel read enable pulse  */
  assign  pxl_rd_en_c = valid_pxl_range_c;

  /*  LBFFR Interface logic */
  assign  ff_rd_en    =   ~ff_empty  & pxl_rd_en_c;


  /*  Internal pipeline logic */
  always@(posedge clk, negedge rst_n)
  begin : vga_pipe_logic
    if(~rst_n)
    begin
      HDMI_TX_D               <=  0;
      HDMI_TX_DE              <=  0;
      HDMI_TX_HS              <=  SYNC_NACTIVE_VAL;
      HDMI_TX_VS              <=  SYNC_NACTIVE_VAL;
    end
    else
    begin
      HDMI_TX_DE              <=  valid_pxl_range_c;

      HDMI_TX_HS              <=  (hfsm_pstate  ==  SYNC_S) ? SYNC_ACTIVE_VAL : SYNC_NACTIVE_VAL;

      HDMI_TX_VS              <=  (vfsm_pstate  ==  SYNC_S) ? SYNC_ACTIVE_VAL : SYNC_NACTIVE_VAL;

      if(valid_pxl_range_c)
      begin
        HDMI_TX_D             <=  ff_rdata;
      end
      begin
        HDMI_TX_D             <=  0;
      end
    end
  end

endmodule // adv7513_video_drvr

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[17-12-2014  01:43:01 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
