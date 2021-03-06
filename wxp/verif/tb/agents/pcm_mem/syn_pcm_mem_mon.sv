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
 -- Component Name    : syn_pcm_mem_mon
 -- Author            : mammenx
 -- Function          : This class monitors the PCM cache interface from
                        Acortex to Fgyrus & sends packets to scoreboard.
 --------------------------------------------------------------------------
*/

`ifndef __SYN_PCM_MEM_MON
`define __SYN_PCM_MEM_MON

  class syn_pcm_mem_mon #(parameter NUM_SAMPLES = 128,
                          parameter type  PKT_TYPE  = syn_pcm_seq_item,
                          parameter type  INTF_TYPE = virtual syn_pcm_mem_intf
                        ) extends ovm_component;

    INTF_TYPE intf;

    ovm_analysis_port #(PKT_TYPE) Mon2Sb_port;

    OVM_FILE  f;

    PKT_TYPE  pkt;

    shortint  enable;

    /*  Register with factory */
    `ovm_component_param_utils(syn_pcm_mem_mon#(NUM_SAMPLES,PKT_TYPE, INTF_TYPE))


    /*  Constructor */
    function new( string name = "syn_pcm_mem_mon" , ovm_component parent = null) ;
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

      Mon2Sb_port = new("Mon2Sb_port", this);

      pkt = new();

      enable  = 1;  //Enabled by default; disable from test case

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction : build


    /*  Run */
    task run();
      int num_samples_read;

      ovm_report_info({get_name(),"[run]"},"Start of run ",OVM_LOW);

      //wait for reset

      if(enable)
      begin
        fork
          begin
            forever
            begin
              //Monitor logic
              ovm_report_info({get_name(),"[run]"},"Waiting for pcm_data_rdy pulse",OVM_LOW);
              @(posedge intf.cb_mon.pcm_data_rdy);
              ovm_report_info({get_name(),"[run]"},"Detected pcm_data_rdy pulse",OVM_LOW);
              @(posedge intf.clk_ir);

              pkt = new();

              pkt.pcm_data  = new[NUM_SAMPLES];
              num_samples_read  = 0;

              do
              begin
                @(posedge intf.clk_ir);

                if(intf.cb_mon.pcm_rd_valid)
                begin
                  //ovm_report_info({get_name(),"[run]"},$psprintf("intf.cb_mon.pcm_raddr[0x%x], num_samples_read[%1d]",intf.cb_mon.pcm_raddr,num_samples_read),OVM_LOW);
                  num_samples_read++;

                  if(intf.cb_mon.pcm_raddr  > (NUM_SAMPLES-1))
                  begin
                    pkt.pcm_data[intf.cb_mon.pcm_raddr-NUM_SAMPLES].rchnnl = intf.cb_mon.pcm_rdata;
                    ovm_report_info({get_name(),"[run]"},$psprintf("pkt.pcm_data[%1d].rchnnl = 0x%x",(intf.cb_mon.pcm_raddr-NUM_SAMPLES),pkt.pcm_data[intf.cb_mon.pcm_raddr-NUM_SAMPLES].lchnnl),OVM_LOW);
                  end
                  else
                  begin
                    pkt.pcm_data[intf.cb_mon.pcm_raddr].lchnnl = intf.cb_mon.pcm_rdata;
                    ovm_report_info({get_name(),"[run]"},$psprintf("pkt.pcm_data[%1d].lchnnl = 0x%x",intf.cb_mon.pcm_raddr,pkt.pcm_data[intf.cb_mon.pcm_raddr].lchnnl),OVM_LOW);
                  end
                end
              end
              while(num_samples_read  < (NUM_SAMPLES*2));

              @(posedge intf.clk_ir);

              //Send captured pkt to SB
              ovm_report_info({get_name(),"[run]"},$psprintf("Sending pkt to SB -\n%s", pkt.sprint()),OVM_LOW);
              Mon2Sb_port.write(pkt);
            end
          end
        join
      end
      else
      begin
        ovm_report_info({get_name(),"[run]"},"syn_pcm_mem_mon  is disabled",OVM_LOW);
        ovm_report_info({get_name(),"[run]"},"Shutting down .....",OVM_LOW);
      end
    endtask : run


  endclass  : syn_pcm_mem_mon

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[29-11-2014  10:36:46 PM][mammenx] Misc changes to stabilize Acorte scoreboards for PCM test

[02-11-2014  07:53:10 PM][mammenx] Misc changes for PCM Test

[16-10-2014  09:47:25 PM][mammenx] Misc changes to fix issues found during syn_acortex_base_test

[15-10-2014  11:44:12 PM][mammenx] Initial Commit

 --------------------------------------------------------------------------
*/


