/*
 --------------------------------------------------------------------------
   Synesthesia-Zen - Copyright (C) 2012 Gregory Matthew James.

   This file is part of Synesthesia-Zen.

   Synesthesia-Zen is free; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   Synesthesia-Zen is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program. If not, see <http://www.gnu.org/licenses/>.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------
 -- Project Code      : synesthesia_zen
 -- Sequence Name     : syn_ssm2603_drvr_config_seq
 -- Author            : mammenx
 -- Function          : This sequence configures the ssm2603 Driver.
 --------------------------------------------------------------------------
*/

`ifndef __SYN_SSM2603_DRVR_CONFIG_SEQ
`define __SYN_SSM2603_DRVR_CONFIG_SEQ

  import  syn_audio_pkg::*;
  import  syn_env_pkg::build_addr;

  class syn_ssm2603_drvr_config_seq  #(
                                      parameter type  PKT_TYPE  = syn_lb_seq_item,
                                      parameter type  SEQR_TYPE = syn_lb_seqr#(PKT_TYPE)
                                    ) extends ovm_sequence  #(PKT_TYPE);



    /*  Adding the parameterized sequence to the registery  */
    typedef syn_ssm2603_drvr_config_seq#(PKT_TYPE,SEQR_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(SEQR_TYPE)

    `include  "cortex_regmap.svh"
    `include  "acortex_regmap.svh"
    `include  "ssm2603_drvr_regmap.svh"

    int   bclk_div_val;
    int   fs_div_val;
    bit   dac_en,adc_en;
    bit [1:0] bps;
    int   mclk_sel;

    /*  Constructor */
    function new(string name  = "syn_ssm2603_drvr_config_seq");
      super.new(name);

      bclk_div_val  = 10;
      fs_div_val    = 75;
      dac_en        = 0;
      adc_en        = 0;
      bps           = 0;
      mclk_sel      = 0;
    endfunction

    /*  Body of sequence  */
    task  body();
      PKT_TYPE  pkt;

      p_sequencer.ovm_report_info(get_name(),"Start of syn_ssm2603_drvr_config_seq",OVM_LOW);

      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("ssm2603 Driver Config Seq")));

      start_item(pkt);  //start_item has wait_for_grant()
      
      pkt.addr  = new[4];
      pkt.data  = new[4];
      pkt.lb_xtn= BURST_WRITE;

      $cast(pkt.addr[0],  build_addr(ACORTEX_BLK,ACORTEX_DRVR_BLK_CODE,SSM2603_DRVR_BCLK_DIV_REG_ADDR));
      pkt.data[0] = bclk_div_val;

      $cast(pkt.addr[1],  build_addr(ACORTEX_BLK,ACORTEX_DRVR_BLK_CODE,SSM2603_DRVR_FS_VAL_REG_ADDR));
      pkt.data[1] = fs_div_val;

      $cast(pkt.addr[2],  build_addr(ACORTEX_BLK,ACORTEX_DRVR_BLK_CODE,SSM2603_DRVR_MCLK_SEL_REG_ADDR));
      pkt.data[2] = mclk_sel;

      $cast(pkt.addr[3],  build_addr(ACORTEX_BLK,ACORTEX_DRVR_BLK_CODE,SSM2603_DRVR_CONFIG_REG_ADDR));
      pkt.data[3][0]    = dac_en;
      pkt.data[3][1]    = adc_en;
      pkt.data[3][3:2]  = bps;

      p_sequencer.ovm_report_info(get_name(),$psprintf("Generated pkt - \n%s", pkt.sprint()),OVM_LOW);


      finish_item(pkt);

      #1;

    endtask : body


  endclass  : syn_ssm2603_drvr_config_seq

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[02-11-2014  01:48:33 PM][mammenx] Fixed misc issues from simulation

[02-11-2014  12:16:37 PM][mammenx] Initial Commit

 --------------------------------------------------------------------------
*/


