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
 -- Sequence Name     : syn_fgyrus_fsm_config_seq
 -- Author            : mammenx
 -- Function          : This sequence configures the Fgyrus FSM module
 --------------------------------------------------------------------------
*/

`ifndef __SYN_FGYRUS_FSM_CONFIG_SEQ
`define __SYN_FGYRUS_FSM_CONFIG_SEQ

  import  syn_env_pkg::build_addr;
  import  syn_fft_pkg::fgyrus_mode_t;

  class syn_fgyrus_fsm_config_seq  #(
                              parameter type  PKT_TYPE  = syn_lb_seq_item,
                              parameter type  SEQR_TYPE = syn_lb_seqr#(PKT_TYPE)
                            ) extends ovm_sequence  #(PKT_TYPE);



    /*  Adding the parameterized sequence to the registery  */
    typedef syn_fgyrus_fsm_config_seq#(PKT_TYPE,SEQR_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(SEQR_TYPE)

    `include  "cortex_regmap.svh"
    `include  "fgyrus_reg_map.svh"


    bit fgyrus_en;
    fgyrus_mode_t fgyrus_mode;
    bit fgyrus_post_norm;

    /*  Constructor */
    function new(string name  = "syn_fgyrus_fsm_config_seq");
      super.new(name);

      fgyrus_en = 0;
      fgyrus_mode = syn_fft_pkg::NORMAL;
      fgyrus_post_norm  = 0;
    endfunction

    /*  Body of sequence  */
    task  body();
      PKT_TYPE  pkt,rsp;

      p_sequencer.ovm_report_info(get_name(),"Start of syn_fgyrus_fsm_config_seq",OVM_LOW);

      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Reset Config Seq")));

      start_item(pkt);  //start_item has wait_for_grant()
      
      pkt.addr  = new[2];
      pkt.data  = new[2];
      pkt.lb_xtn= BURST_WRITE;

      $cast(pkt.addr[0],  build_addr(FGYRUS_BLK,FGYRUS_REG_CODE,FGYRUS_CONTROL_REG_ADDR));
      pkt.data[0][0]  = fgyrus_en;
      $cast(pkt.data[0][1],fgyrus_mode);

      $cast(pkt.addr[1],  build_addr(FGYRUS_BLK,FGYRUS_REG_CODE,FGYRUS_POST_NORM_REG_ADDR));
      pkt.data[1][3:0]  = fgyrus_post_norm;

      p_sequencer.ovm_report_info(get_name(),$psprintf("Generated pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      #1;

    endtask : body


  endclass  : syn_fgyrus_fsm_config_seq

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[06-12-2014  05:46:09 PM][mammenx] Initial Commit

[29-11-2014  10:37:15 PM][mammenx] Initial Commit

 --------------------------------------------------------------------------
*/


