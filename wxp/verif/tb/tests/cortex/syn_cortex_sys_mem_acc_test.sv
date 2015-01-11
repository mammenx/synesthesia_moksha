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
 -- Test Name         : syn_cortex_sys_mem_acc_test
 -- Author            : mammenx
 -- Function          : This test checks the arbitration logic for system
                        memory by issues host accesses & enabling video
                        refresh.
 --------------------------------------------------------------------------
*/

class syn_cortex_sys_mem_acc_test extends syn_cortex_base_test;

    `ovm_component_utils(syn_cortex_sys_mem_acc_test)

    //Sequences
    syn_rst_config_seq#(super.LB_SEQ_ITEM_T,super.LB_SEQR_T)    rst_config_seq;
    syn_adv7513_cntrlr_config_seq#(super.LB_SEQ_ITEM_T,super.LB_SEQR_T)    adv7513_cntrlr_config_seq;
    syn_sys_mem_hst_acc_seq#(super.LB_SEQ_ITEM_T,super.LB_SEQR_T)   sys_mem_hst_acc_seq;


    OVM_FILE  f;

    /*  Constructor */
    function new (string name="syn_cortex_sys_mem_acc_test", ovm_component parent=null);
        super.new (name, parent);
    endfunction : new 


    /*  Build */
    function  void  build();
      super.build();

      f = $fopen({"./logs/",get_full_name(),".log"});

      set_report_default_file(f);
      set_report_severity_action(OVM_INFO,  OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_WARNING, OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_ERROR,  OVM_COUNT | OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_FATAL,  OVM_EXIT | OVM_DISPLAY | OVM_LOG);


      ovm_report_info(get_full_name(),"Start of build",OVM_LOW);

      rst_config_seq  = syn_rst_config_seq#(super.LB_SEQ_ITEM_T,super.LB_SEQR_T)::type_id::create("rst_config_seq");
      adv7513_cntrlr_config_seq = syn_adv7513_cntrlr_config_seq#(super.LB_SEQ_ITEM_T,super.LB_SEQR_T)::type_id::create("adv7513_cntrlr_config_seq");
      sys_mem_hst_acc_seq = syn_sys_mem_hst_acc_seq#(super.LB_SEQ_ITEM_T,super.LB_SEQR_T)::type_id::create("sys_mem_hst_acc_seq");

      ovm_report_info(get_full_name(),"End of build",OVM_LOW);
    endfunction : build


    /*  Connect */
    function  void  connect();
      super.connect();

      ovm_report_info(get_full_name(),"Start of connect",OVM_LOW);

        super.env.codec_agent.i2c.s_drvr.update_reg_map_en = 1;
        //super.env.codec_agent.disable_agent();

      ovm_report_info(get_full_name(),"End of connect",OVM_LOW);
    endfunction : connect


    /*  End of Elaboration  */
    function void end_of_elaboration();
      super.end_of_elaboration();
    endfunction


    /*  Run */
    virtual task run ();
      ovm_report_info(get_full_name(),"Start of run",OVM_LOW);

      super.env.sprint();

      #500;
      rst_config_seq.sys_mem_mngr_rst_n = 1;
      rst_config_seq.vcortex_rst_n      = 1;
      rst_config_seq.start(super.env.lb_agent.seqr);

      #100ns;

      super.configure_sys_mem_part(0,0,((2**super.SYS_MEM_ADDR_W)-1));
      super.configure_sys_mem_part(1,'h4000000,((2**super.SYS_MEM_ADDR_W)-1));

      adv7513_cntrlr_config_seq.line_bffr_en  = 1;
      adv7513_cntrlr_config_seq.drvr_en       = 1;
      adv7513_cntrlr_config_seq.start(super.env.lb_agent.seqr);

      for(int i=0;  i<16; i++)
      begin
        sys_mem_hst_acc_seq.mem_addr      = 'h4000100  + i;
        sys_mem_hst_acc_seq.mem_data      = i;
        sys_mem_hst_acc_seq.read_n_write  = 0;
        sys_mem_hst_acc_seq.start(super.env.lb_agent.seqr);
        #1;
      end

      #1us;

      ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
      global_stop_request();

      ovm_report_info(get_full_name(),"End of run",OVM_LOW);
    endtask : run


endclass : syn_cortex_sys_mem_acc_test

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[11-01-2015  06:19:45 PM][mammenx] Added cntrlr_clk

[11-01-2015  05:33:50 PM][mammenx] Added sys_mem_hst_acc_seq

[11-01-2015  01:23:03 PM][mammenx] Initial Commit

 --------------------------------------------------------------------------
*/


