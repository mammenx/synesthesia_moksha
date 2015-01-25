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
 -- Sequence Name     : syn_sys_mem_part_mngr_config_seq
 -- Author            : mammenx
 -- Function          : This sequence configures adv7513_cntrlr.
 --------------------------------------------------------------------------
*/

`ifndef __SYN_SYS_MEM_PART_MNGR_CONFIG_SEQ
`define __SYN_SYS_MEM_PART_MNGR_CONFIG_SEQ

  import  syn_env_pkg::build_addr;

  class syn_sys_mem_part_mngr_config_seq  #(
                              parameter type  PKT_TYPE  = syn_lb_seq_item,
                              parameter type  SEQR_TYPE = syn_lb_seqr#(PKT_TYPE)
                            ) extends ovm_sequence  #(PKT_TYPE);



    /*  Adding the parameterized sequence to the registery  */
    typedef syn_sys_mem_part_mngr_config_seq#(PKT_TYPE,SEQR_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(SEQR_TYPE)

    `include  "cortex_regmap.svh"
    `include  "sys_mem_intf_regmap.svh"
    `include  "sys_mem_part_mngr_regmap.svh"


    int part_num;
    int start_addr;
    int end_addr;

    /*  Constructor */
    function new(string name  = "syn_sys_mem_part_mngr_config_seq");
      super.new(name);

      part_num    = 0;
      start_addr  = 0;
      end_addr    = 0;
    endfunction

    /*  Body of sequence  */
    task  body();
      PKT_TYPE  pkt,rsp;

      p_sequencer.ovm_report_info(get_name(),"Start of syn_sys_mem_part_mngr_config_seq",OVM_LOW);

      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Sys Mem Part Mngr Config Seq")));

      start_item(pkt);  //start_item has wait_for_grant()
      
      pkt.addr  = new[2];
      pkt.data  = new[2];
      pkt.gap   = new[2];
      pkt.lb_xtn= WRITE;

      $cast(pkt.addr[0],  build_addr(SYS_MEM_MNGR_BLK,SYS_MEM_INTF_PART_BLK_CODE,part_num));
      pkt.data[0]     = start_addr;
      pkt.gap[0]      = 5;

      $cast(pkt.addr[1],  build_addr(SYS_MEM_MNGR_BLK,SYS_MEM_INTF_PART_BLK_CODE,32+part_num));
      pkt.data[1]     = end_addr;
      pkt.gap[1]      = 5;

      p_sequencer.ovm_report_info(get_name(),$psprintf("Generated pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      #1;

    endtask : body


  endclass  : syn_sys_mem_part_mngr_config_seq

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[10-01-2015  07:20:09 PM][mammenx] Initial Commit

 --------------------------------------------------------------------------
*/


