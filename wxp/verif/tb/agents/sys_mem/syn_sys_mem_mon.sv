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
 -- Component Name    : syn_sys_mem_mon
 -- Author            : mammenx
 -- Function          : This class defines monitoring logic for capturing
                        xtns along the sys_mem_intf.
 --------------------------------------------------------------------------
*/

`ifndef __SYN_SYS_MEM_MON
`define __SYN_SYS_MEM_MON

  class syn_sys_mem_mon #(parameter DATA_W      = 32,
                      parameter ADDR_W      = 27,
                      parameter NUM_AGENTS  = 1,
                      type  PKT_TYPE        = syn_sys_mem_seq_item,
                      type  INTF_TYPE       = virtual syn_sys_mem_intf
                    ) extends ovm_component;

    INTF_TYPE  intf;

    ovm_analysis_port #(PKT_TYPE) Mon2Sb_ingr_port;
    ovm_analysis_port #(PKT_TYPE) Mon2Sb_egr_port;

    OVM_FILE  f;

    PKT_TYPE  ingr_pkt[NUM_AGENTS];
    PKT_TYPE  egr_pkt[NUM_AGENTS];

    process   egr_mon_proc[NUM_AGENTS];
    process   ingr_mon_proc[NUM_AGENTS];

    shortint  enable;

    /*  Register with factory */
    `ovm_component_param_utils(syn_sys_mem_mon#(DATA_W, ADDR_W, NUM_AGENTS, PKT_TYPE, INTF_TYPE))


    /*  Constructor */
    function new( string name = "syn_sys_mem_mon" , ovm_component parent = null) ;
      super.new( name , parent );
    endfunction : new


    /*  Build */
    function  void  build();
      super.build();

      f = $fopen({"./logs/",get_full_name(),".log"},  "w");

      set_report_default_file(f);
      set_report_severity_action(OVM_INFO,  OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_WARNING, OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_ERROR,  OVM_COUNT | OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_FATAL,  OVM_EXIT | OVM_DISPLAY | OVM_LOG);

      ovm_report_info(get_name(),"Start of build ",OVM_LOW);

      Mon2Sb_ingr_port  = new("Mon2Sb_ingr_port", this);
      Mon2Sb_egr_port   = new("Mon2Sb_egr_port", this);

      for(int i=0;  i<NUM_AGENTS; i++)
      begin
        ingr_pkt[i] = new();
        egr_pkt[i]  = new();
      end

      enable  = 1;  //Enabled by default; disable from test case

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction : build


    /*  Run */
    task run();

      ovm_report_info({get_name(),"[run]"},"Start of run ",OVM_LOW);

      //wait for reset
      @(posedge intf.rst_il);

      if(enable)
      begin
        for(int i=0;  i<NUM_AGENTS; i++)
        begin
          automatic int agent_id  = i;

          fork  //Spawn Ingress monitor thread per agent
            begin
              ingr_mon_proc[agent_id] = process::self();

              ovm_report_info($psprintf("%s[run[ingr_mon_%1d]]",get_name(),agent_id),$psprintf("Start of ingr_mon proc"),OVM_LOW);

              forever
              begin
                //Monitor logic
                @(posedge intf.clk_ir);

                if(~intf.cb_mon.mem_wait[agent_id])
                begin
                  if(intf.cb_mon.mem_rden[agent_id])
                  begin
                    ingr_pkt[agent_id] = new();
                    ingr_pkt[agent_id].addr  = new[1];
                    ingr_pkt[agent_id].data  = new[1];
                    ingr_pkt[agent_id].read_n_write  = 1;

                    ingr_pkt[agent_id].addr[0]   = intf.cb_mon.mem_addr[agent_id];
                    ingr_pkt[agent_id].data[0]   = intf.cb_mon.mem_wdata[agent_id];
                    ingr_pkt[agent_id].agent_id  = agent_id;

                    //Send captured pkt to SB
                    ovm_report_info($psprintf("%s[run[ingr_mon_%1d]]",get_name(),agent_id),$psprintf("Sending ingr_pkt to SB -\n%s", ingr_pkt[agent_id].sprint()),OVM_LOW);
                    Mon2Sb_ingr_port.write(ingr_pkt[agent_id]);
                  end

                  if(intf.cb_mon.mem_wren[agent_id])
                  begin
                    ingr_pkt[agent_id] = new();
                    ingr_pkt[agent_id].addr  = new[1];
                    ingr_pkt[agent_id].data  = new[1];
                    ingr_pkt[agent_id].read_n_write  = 0;

                    ingr_pkt[agent_id].addr[0]   = intf.cb_mon.mem_addr[agent_id];
                    ingr_pkt[agent_id].data[0]   = intf.cb_mon.mem_wdata[agent_id];
                    ingr_pkt[agent_id].agent_id  = agent_id;

                    //Send captured pkt to SB
                    ovm_report_info($psprintf("%s[run[ingr_mon_%1d]]",get_name(),agent_id),$psprintf("Sending ingr_pkt to SB -\n%s", ingr_pkt[agent_id].sprint()),OVM_LOW);
                    Mon2Sb_ingr_port.write(ingr_pkt[agent_id]);
                  end
                end
              end
            end
          join_none

          fork  //Spawn Egress monitor thread per agent
            begin
              egr_mon_proc[agent_id] = process::self();

              ovm_report_info($psprintf("%s[run[egr_mon_%1d]]",get_name(),agent_id),$psprintf("Start of egr_mon proc"),OVM_LOW);

              forever
              begin
                //Monitor logic
                @(posedge intf.clk_ir);

                if(intf.cb_mon.mem_rd_valid[agent_id])
                begin
                  egr_pkt[agent_id]  = new();
                  egr_pkt[agent_id].addr  = new[1];
                  egr_pkt[agent_id].data  = new[1];
                  egr_pkt[agent_id].read_n_write  = 1;

                  egr_pkt[agent_id].data[0]   = intf.cb_mon.mem_rdata;
                  egr_pkt[agent_id].agent_id  = agent_id;

                  //Send captured pkt to SB
                  ovm_report_info($psprintf("%s[run[egr_mon_%1d]]",get_name(),agent_id),$psprintf("Sending egr_pkt to SB -\n%s", egr_pkt[agent_id].sprint()),OVM_LOW);
                  Mon2Sb_egr_port.write(egr_pkt[agent_id]);
                end
              end
            end
          join_none
        end //for loop
      end
      else
      begin
        ovm_report_info({get_name(),"[run]"},"syn_sys_mem_mon  is disabled",OVM_LOW);
        ovm_report_info({get_name(),"[run]"},"Shutting down .....",OVM_LOW);
      end
    endtask : run


  endclass  : syn_sys_mem_mon

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>


 --------------------------------------------------------------------------
*/
