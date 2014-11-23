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
 -- Sequence Name     : syn_rst_config_seq
 -- Author            : mammenx
 -- Function          : This sequence configures the reset config register
 --------------------------------------------------------------------------
*/

`ifndef __SYN_RST_CONFIG_SEQ
`define __SYN_RST_CONFIG_SEQ

  import  syn_env_pkg::build_addr;

  class syn_rst_config_seq  #(
                              parameter type  PKT_TYPE  = syn_lb_seq_item,
                              parameter type  SEQR_TYPE = syn_lb_seqr#(PKT_TYPE)
                            ) extends ovm_sequence  #(PKT_TYPE);



    /*  Adding the parameterized sequence to the registery  */
    typedef syn_rst_config_seq#(PKT_TYPE,SEQR_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(SEQR_TYPE)

    `include  "cortex_regmap.svh"
    `include  "rst_cntrl_regmap.svh"


    bit acortex_rst_n;
    bit fgyrus_rst_n;

    /*  Constructor */
    function new(string name  = "syn_rst_config_seq");
      super.new(name);

      acortex_rst_n = 0;
      fgyrus_rst_n  = 0;
    endfunction

    /*  Body of sequence  */
    task  body();
      PKT_TYPE  pkt,rsp;

      p_sequencer.ovm_report_info(get_name(),"Start of syn_rst_config_seq",OVM_LOW);

      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Reset Config Seq")));

      start_item(pkt);  //start_item has wait_for_grant()
      
      pkt.addr  = new[1];
      pkt.data  = new[1];
      pkt.lb_xtn= WRITE;

      $cast(pkt.addr[0],  build_addr(RST_SYNC_BLK,0,RST_CNTRL_REG_ADDR));
      pkt.data[0][ACORTEX_BLK]  = acortex_rst_n;
      pkt.data[0][FGYRUS_BLK]   = fgyrus_rst_n;

      p_sequencer.ovm_report_info(get_name(),$psprintf("Generated pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      #1;

    endtask : body


  endclass  : syn_rst_config_seq

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[19-11-2014  10:47:50 PM][mammenx] Added i2c read support

[02-11-2014  01:47:10 PM][mammenx] Modified for syn_env_pkg

[16-10-2014  12:52:42 AM][mammenx] Fixed compilation errors

[15-10-2014  11:44:12 PM][mammenx] Initial Commit

 --------------------------------------------------------------------------
*/


