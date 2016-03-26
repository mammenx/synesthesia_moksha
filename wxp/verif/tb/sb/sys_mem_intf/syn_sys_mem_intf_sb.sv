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
 -- Component Name    : syn_sys_mem_intf_sb
 -- Author            : mammenx
 -- Function          : This scoreboard checks that the xtns going in and
                        out of the sys_mem_intf is correct.
 --------------------------------------------------------------------------
*/

`ifndef __SYN_SYS_MEM_INTF_SB
`define __SYN_SYS_MEM_INTF_SB

  import  syn_env_pkg::*;

//Implicit port declarations
`ovm_analysis_imp_decl(_rcvd_pkt)
`ovm_analysis_imp_decl(_sent_pkt)
`ovm_analysis_imp_decl(_agent_rcvd_pkt)
`ovm_analysis_imp_decl(_agent_sent_pkt)

  class syn_sys_mem_intf_sb #(  parameter DATA_W      = 32,
                                parameter ADDR_W      = 27,
                                parameter NUM_AGENTS  = 2,
                                parameter LB_DATA_W   = 32,
                                type  SENT_PKT_TYPE   = syn_sys_mem_seq_item,
                                type  RCVD_PKT_TYPE   = syn_sys_mem_seq_item
                            ) extends ovm_scoreboard;

    /*  Register with Factory */
    `ovm_component_param_utils(syn_sys_mem_intf_sb#(DATA_W,ADDR_W,NUM_AGENTS,LB_DATA_W,SENT_PKT_TYPE, RCVD_PKT_TYPE))

    //Queue to hold the sent pkts, till rcvd pkts come
    SENT_PKT_TYPE sent_que[$];
    RCVD_PKT_TYPE rcvd_que[$];

    typedef SENT_PKT_TYPE agent_sent_que_t[$];
    typedef RCVD_PKT_TYPE agent_rcvd_que_t[$];

    agent_sent_que_t  agent_sent_que[];
    agent_rcvd_que_t  agent_rcvd_que[];

    int rd_order_que[$];

    syn_reg_map#(LB_DATA_W)   sys_mem_intf_reg_map; //need to connect this to original regmap in env

    //Ports
    ovm_analysis_imp_sent_pkt #(SENT_PKT_TYPE,syn_sys_mem_intf_sb#(DATA_W,ADDR_W,NUM_AGENTS,LB_DATA_W,SENT_PKT_TYPE, RCVD_PKT_TYPE))  Mon_sent_2Sb_port;
    ovm_analysis_imp_rcvd_pkt #(RCVD_PKT_TYPE,syn_sys_mem_intf_sb#(DATA_W,ADDR_W,NUM_AGENTS,LB_DATA_W,SENT_PKT_TYPE, RCVD_PKT_TYPE))  Mon_rcvd_2Sb_port;

    ovm_analysis_imp_agent_sent_pkt #(SENT_PKT_TYPE,syn_sys_mem_intf_sb#(DATA_W,ADDR_W,NUM_AGENTS,LB_DATA_W,SENT_PKT_TYPE, RCVD_PKT_TYPE))  Mon_agent_sent_2Sb_port;
    ovm_analysis_imp_agent_rcvd_pkt #(RCVD_PKT_TYPE,syn_sys_mem_intf_sb#(DATA_W,ADDR_W,NUM_AGENTS,LB_DATA_W,SENT_PKT_TYPE, RCVD_PKT_TYPE))  Mon_agent_rcvd_2Sb_port;

    OVM_FILE  f;


    /*  Constructor */
    function new(string name = "syn_sys_mem_intf_sb", ovm_component parent);
      super.new(name, parent);
    endfunction : new


    /*  Build */
    function void build();
      super.build();

      f = $fopen({"./logs/",get_full_name(),".log"},  "w");

      set_report_default_file(f);
      set_report_severity_action(OVM_INFO,  OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_WARNING, OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_ERROR,  OVM_COUNT | OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_FATAL,  OVM_EXIT | OVM_DISPLAY | OVM_LOG);

      ovm_report_info(get_name(),"Start of build ",OVM_LOW);

      Mon_sent_2Sb_port = new("Mon_sent_2Sb_port", this);
      Mon_rcvd_2Sb_port = new("Mon_rcvd_2Sb_port", this);

      Mon_agent_sent_2Sb_port = new("Mon_agent_sent_2Sb_port", this);
      Mon_agent_rcvd_2Sb_port = new("Mon_agent_rcvd_2Sb_port", this);

      agent_sent_que    = new[NUM_AGENTS];
      agent_rcvd_que    = new[NUM_AGENTS];

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction


    /*
      * Write Sent Pkt
      * This function will be called each time a pkt is written into [ovm_analysis_imp_sent_pkt]Mon_sent_2Sb_port
    */
    virtual function void write_sent_pkt(input SENT_PKT_TYPE  pkt);
      ovm_report_info({get_name(),"[write_sent_pkt]"},$psprintf("Received pkt\n%s",pkt.sprint()),OVM_LOW);

      //Push packet into sent queue
      sent_que.push_back(pkt);

      ovm_report_info({get_name(),"[write_sent_pkt]"},$psprintf("There are %d items in sent_que[$]",sent_que.size()),OVM_LOW);
    endfunction : write_sent_pkt


    /*
      * Write Rcvd Pkt
      * This function will be called each time a pkt is written into [ovm_analysis_imp_rcvd_pkt]Mon_rcvd_2Sb_port
    */
    virtual function void write_rcvd_pkt(input RCVD_PKT_TYPE pkt);
      ovm_report_info({get_name(),"[write_rcvd_pkt]"},$psprintf("Received pkt\n%s",pkt.sprint()),OVM_LOW);

      //Push packet into rcvd queue
      rcvd_que.push_back(pkt);

      ovm_report_info({get_name(),"[write_rcvd_pkt]"},$psprintf("There are %d items in rcvd_que[$]",rcvd_que.size()),OVM_LOW);
    endfunction : write_rcvd_pkt


    /*
      * Write Agent Sent Pkt
      * This function will be called each time a pkt is written into [ovm_analysis_imp_agent_sent_pkt]Mon_agent_sent_2Sb_port
    */
    virtual function void write_agent_sent_pkt(input SENT_PKT_TYPE  pkt);
      ovm_report_info({get_name(),"[write_agent_sent_pkt]"},$psprintf("Received pkt\n%s",pkt.sprint()),OVM_LOW);

      //Push packet into agent_sent queue
      agent_sent_que[pkt.agent_id].push_back(pkt);

      ovm_report_info({get_name(),"[write_agent_sent_pkt]"},$psprintf("There are %d items in agent_sent_que[%1d][$]",agent_sent_que[pkt.agent_id].size(),pkt.agent_id),OVM_LOW);
    endfunction : write_agent_sent_pkt

    /*
      * Write Agent Rcvd Pkt
      * This function will be called each time a pkt is written into [ovm_analysis_imp_agent_rcvd_pkt]Mon_agent_rcvd_2Sb_port
    */
    virtual function void write_agent_rcvd_pkt(input RCVD_PKT_TYPE pkt);
      RCVD_PKT_TYPE exp_pkt;

      ovm_report_info({get_name(),"[write_agent_rcvd_pkt]"},$psprintf("Received pkt\n%s",pkt.sprint()),OVM_LOW);

      //Get the next expected packet per agent
      if(agent_rcvd_que[pkt.agent_id].size)
      begin
        exp_pkt = agent_rcvd_que[pkt.agent_id][0];

        exp_pkt.addr[0] = pkt.addr[0];  //Not relevant

        if(exp_pkt.check(pkt))
        begin
          exp_pkt = agent_rcvd_que[pkt.agent_id].pop_front();
          ovm_report_info({get_name(),"[write_agent_rcvd_pkt]"},$psprintf("Pkt matches with agent_rcvd_que[%1d][0]",pkt.agent_id),OVM_LOW);
        end
        else
        begin
          ovm_report_error({get_name(),"[write_agent_rcvd_pkt]"},$psprintf("Pkt does not match with agent_rcvd_que[%1d][0]",pkt.agent_id),OVM_LOW);
        end
      end
      else
      begin
        ovm_report_error({get_name(),"[write_agent_rcvd_pkt]"},$psprintf("Unexpected pkt; agent_rcvd_que[%1d] is empty!",pkt.agent_id),OVM_LOW);
      end
    endfunction : write_agent_rcvd_pkt


    /*  Run */
    task run();
      ovm_report_info({get_name(),"[run]"},"Start of run",OVM_LOW);

      fork
        begin
          proc_ingr_path();
        end

        begin
          proc_egr_path();
        end
      join

    endtask : run


    virtual task  proc_ingr_path();
      SENT_PKT_TYPE sent_pkt,sent_pkt_expctd;
      bit   match_found;

      ovm_report_info({get_name(),"[proc_ingr_path]"},"Start of proc_ingr_path",OVM_LOW);

      forever
      begin
        ovm_report_info({get_name(),"[proc_ingr_path]"},"Waiting on sent_que[$] ...",OVM_LOW);
        while(!sent_que.size())  #1;

        sent_pkt  = sent_que.pop_front();
        match_found = 0;

        ovm_report_info({get_name(),"[proc_ingr_path]"},$psprintf("Got pkt\n%s",sent_pkt.sprint()),OVM_LOW);

        //Compare against the front items in each agent sent queue to match
        for(int i=0; i<NUM_AGENTS; i++)
        begin
          if(!agent_sent_que[i].size) continue; //skip if empty

          sent_pkt_expctd = agent_sent_que[i][0];

          ovm_report_info({get_name(),"[proc_ingr_path]"},$psprintf("Head packet for agent[%1d] :\n%s",i,sent_pkt_expctd.sprint()),OVM_LOW);

          sent_pkt_expctd.addr[0] = update_agent_addr(sent_pkt_expctd.addr[0],  sent_pkt_expctd.agent_id);
          sent_pkt.agent_id = sent_pkt_expctd.agent_id; //This is so that the check passes;

          if(sent_pkt_expctd.check(sent_pkt))
          begin
            sent_pkt_expctd = agent_sent_que[i].pop_front();
            ovm_report_info({get_type_name(),"[proc_ingr_path]"},$psprintf("Pkt matches with agent_sent_que[%1d][0]\n%s", i,sent_pkt_expctd.sprint()), OVM_LOW);

            if(sent_pkt_expctd.read_n_write)
            begin
              rd_order_que.push_back(sent_pkt_expctd.agent_id);
              ovm_report_info({get_type_name(),"[proc_ingr_path]"},$psprintf("Updated rd_order_que with : %1d", sent_pkt_expctd.agent_id), OVM_LOW);
            end

            match_found = 1;
            break;
          end
        end

        if(!match_found)
        begin
          ovm_report_error({get_type_name(),"[proc_ingr_path]"},$psprintf("Could not match pkt with any pending items in agent_sent_que"), OVM_LOW);
        end
      end
    endtask : proc_ingr_path

    virtual task  proc_egr_path();
      RCVD_PKT_TYPE rcvd_pkt;

      ovm_report_info({get_name(),"[proc_egr_path]"},"Start of proc_egr_path",OVM_LOW);

      forever
      begin
        ovm_report_info({get_name(),"[proc_egr_path]"},"Waiting on rcvd_que[$] ...",OVM_LOW);
        while(!rcvd_que.size())  #1;

        rcvd_pkt  = rcvd_que.pop_front();

        ovm_report_info({get_name(),"[proc_egr_path]"},$psprintf("Got pkt\n%s",rcvd_pkt.sprint()),OVM_LOW);

        if(!rd_order_que.size)
        begin
          ovm_report_error({get_name(),"[proc_egr_path]"},$psprintf("Unexpected xtn!; rd_order_que is empty!"),OVM_LOW);
          continue;
        end

        rcvd_pkt.agent_id = rd_order_que.pop_front();
        ovm_report_info({get_name(),"[proc_egr_path]"},$psprintf("Updated rcvd_pkt.agent_id to %1d",rcvd_pkt.agent_id),OVM_LOW);

        agent_rcvd_que[rcvd_pkt.agent_id].push_back(rcvd_pkt);

        ovm_report_info({get_name(),"[proc_egr_path]"},$psprintf("There are %d items in agent_rcvd_que[%1d][$]",agent_rcvd_que[rcvd_pkt.agent_id].size(),rcvd_pkt.agent_id),OVM_LOW);
      end
    endtask : proc_egr_path

    function  bit [ADDR_W-1:0]  update_agent_addr(input bit [ADDR_W-1:0] addr, int agent_id);
      int start_addr;
      int res;

      ovm_report_info({get_type_name(),"[update_agent_addr]"},$psprintf("ADDR_W = %d", ADDR_W), OVM_LOW);

      start_addr  = sys_mem_intf_reg_map.get_space_reg("sys_mem_part_start_ram",  agent_id);
      ovm_report_info({get_type_name(),"[update_agent_addr]"},$psprintf("Start addr for agent_id[%1d] : 0x%x", agent_id, start_addr), OVM_LOW);

      res = addr  + start_addr;

      ovm_report_info({get_type_name(),"[update_agent_addr]"},$psprintf("Updated addr:0x%x to 0x%x", addr, res), OVM_LOW);

      return  res;

    endfunction : update_agent_addr

    /*  Report  */
    virtual function void report();
      ovm_report_info({get_type_name(),"[report]"},$psprintf("Report -\n%s", this.sprint()), OVM_LOW);
    endfunction : report

  endclass : syn_sys_mem_intf_sb

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>


 --------------------------------------------------------------------------
*/
