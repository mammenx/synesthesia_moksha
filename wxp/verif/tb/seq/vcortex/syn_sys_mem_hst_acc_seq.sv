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
 -- Sequence Name     : syn_sys_mem_hst_acc_seq
 -- Author            : mammenx
 -- Function          : This sequence initiates host reads/writes to the
                        system memory.
 --------------------------------------------------------------------------
*/

`ifndef __SYN_SYS_MEM_HST_ACC_SEQ
`define __SYN_SYS_MEM_HST_ACC_SEQ

  import  syn_env_pkg::build_addr;

  class syn_sys_mem_hst_acc_seq  #(
                              parameter type  PKT_TYPE  = syn_lb_seq_item,
                              parameter type  SEQR_TYPE = syn_lb_seqr#(PKT_TYPE)
                            ) extends ovm_sequence  #(PKT_TYPE);



    /*  Adding the parameterized sequence to the registery  */
    typedef syn_sys_mem_hst_acc_seq#(PKT_TYPE,SEQR_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(SEQR_TYPE)

    `include  "cortex_regmap.svh"
    `include  "vcortex_regmap.svh"
    `include  "sys_mem_hst_acc_regmap.svh"


    int mem_addr;
    int mem_data;
    bit read_n_write;

    /*  Constructor */
    function new(string name  = "syn_sys_mem_hst_acc_seq");
      super.new(name);

      mem_addr  = 0;
      mem_data  = 0;
      read_n_write  = 0;
    endfunction

    /*  Body of sequence  */
    task  body();
      PKT_TYPE  pkt,rsp;
      int i;

      p_sequencer.ovm_report_info(get_name(),"Start of syn_sys_mem_hst_acc_seq",OVM_LOW);

      if(read_n_write)  //READ
      begin
        $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Sys Mem Hst Acc Init Seq")));

        start_item(pkt);  //start_item has wait_for_grant()

        pkt.addr  = new[1];
        pkt.data  = new[1];
        pkt.lb_xtn= WRITE;

        $cast(pkt.addr[0],  build_addr(VCORTEX_BLK,VCORTEX_HST_ACCESS_BLK_CODE,SYS_MEM_HST_ACC_ADDR_REG));
        $cast(pkt.data[0],  mem_addr);

        p_sequencer.ovm_report_info(get_name(),$psprintf("Generated pkt - \n%s", pkt.sprint()),OVM_LOW);

        finish_item(pkt);

        #1;

        p_sequencer.ovm_report_info(get_name(),"Start of Polling ...",OVM_LOW);
        i = 0;

        do
        begin
          $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Sys Mem Hst Acc Poll Seq[%1d]",i)));

          start_item(pkt);  //start_item has wait_for_grant()
          
          pkt.addr  = new[1];
          pkt.data  = new[1];
          pkt.lb_xtn= READ;

          $cast(pkt.addr[0],  build_addr(VCORTEX_BLK,VCORTEX_HST_ACCESS_BLK_CODE,SYS_MEM_HST_ACC_STATUS_REG));
          pkt.data[0] = $random;

          p_sequencer.ovm_report_info(get_name(),$psprintf("Generated pkt - \n%s", pkt.sprint()),OVM_LOW);

          finish_item(pkt);

          get_response(rsp);  //wait for response

          p_sequencer.ovm_report_info(get_name(),$psprintf("Got Response pkt - \n%s", rsp.sprint()),OVM_LOW);

          i++;
        end
        while(rsp.data[1] & 'h2); //while read is busy

        pkt.addr  = new[1];
        pkt.data  = new[1];
        pkt.lb_xtn= READ;

        $cast(pkt.addr[0],  build_addr(VCORTEX_BLK,VCORTEX_HST_ACCESS_BLK_CODE,SYS_MEM_HST_ACC_DATA_REG));
        $cast(pkt.data[0],  mem_addr);

        p_sequencer.ovm_report_info(get_name(),$psprintf("Generated pkt - \n%s", pkt.sprint()),OVM_LOW);

        finish_item(pkt);

        get_response(rsp);  //wait for response

        p_sequencer.ovm_report_info(get_name(),$psprintf("Got Response pkt - \n%s", rsp.sprint()),OVM_LOW);

        #1;
      end
      else  //WRITE
      begin
        $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Sys Mem Hst Acc Init Seq")));

        start_item(pkt);  //start_item has wait_for_grant()

        pkt.addr  = new[2];
        pkt.data  = new[2];
        pkt.gap   = new[2];
        pkt.lb_xtn= WRITE;

        $cast(pkt.addr[0],  build_addr(VCORTEX_BLK,VCORTEX_HST_ACCESS_BLK_CODE,SYS_MEM_HST_ACC_ADDR_REG));
        $cast(pkt.data[0],  mem_addr);
        pkt.gap[0]  = 16;

        $cast(pkt.addr[1],  build_addr(VCORTEX_BLK,VCORTEX_HST_ACCESS_BLK_CODE,SYS_MEM_HST_ACC_DATA_REG));
        $cast(pkt.data[1],  mem_addr);
        pkt.gap[1]  = 1;

        p_sequencer.ovm_report_info(get_name(),$psprintf("Generated pkt - \n%s", pkt.sprint()),OVM_LOW);

        finish_item(pkt);

        #1;

        p_sequencer.ovm_report_info(get_name(),"Start of Polling ...",OVM_LOW);
        i = 0;

        do
        begin
          $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Sys Mem Hst Acc Poll Seq[%1d]",i)));

          start_item(pkt);  //start_item has wait_for_grant()
          
          pkt.addr  = new[1];
          pkt.data  = new[1];
          pkt.lb_xtn= READ;

          $cast(pkt.addr[0],  build_addr(VCORTEX_BLK,VCORTEX_HST_ACCESS_BLK_CODE,SYS_MEM_HST_ACC_STATUS_REG));
          pkt.data[0] = $random;

          p_sequencer.ovm_report_info(get_name(),$psprintf("Generated pkt - \n%s", pkt.sprint()),OVM_LOW);

          finish_item(pkt);

          get_response(rsp);  //wait for response

          p_sequencer.ovm_report_info(get_name(),$psprintf("Got Response pkt - \n%s", rsp.sprint()),OVM_LOW);

          i++;
        end
        while(rsp.data[1] & 'h2); //while read is busy
      end

    endtask : body


  endclass  : syn_sys_mem_hst_acc_seq

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[11-01-2015  05:31:10 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/


