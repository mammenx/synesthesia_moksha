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
 -- Component Name    : syn_adc_sb
 -- Author            : mammenx
 -- Function          : This class checks that the data read from PCM cache
                        matches with that sent from the codec agent.
 --------------------------------------------------------------------------
*/

`ifndef __SYN_ADC_SB
`define __SYN_ADC_SB

//Implicit port declarations
`ovm_analysis_imp_decl(_adc_sb_sent_pkt)
`ovm_analysis_imp_decl(_adc_sb_rcvd_pkt)

  import  syn_audio_pkg::*;

  class syn_adc_sb #(
                      parameter type  LB_PKT_TYPE   = syn_lb_seq_item,
                      parameter type  PCM_PKT_TYPE  = syn_pcm_seq_item,
                      parameter       LB_DATA_W     = 32
                    ) extends ovm_scoreboard;

    `include  "acortex_regmap.svh"
    `include  "pcm_bffr_regmap.svh"
    `include  "ssm2603_drvr_regmap.svh"

    /*  Register with Factory */
    `ovm_component_param_utils(syn_adc_sb#(LB_PKT_TYPE, PCM_PKT_TYPE, LB_DATA_W))

    //Queue to hold the sent pkts, till rcvd pkts come
    PCM_PKT_TYPE sent_que[$];
    PCM_PKT_TYPE rcvd_que[$];

    //Ports
    ovm_analysis_imp_adc_sb_sent_pkt #(PCM_PKT_TYPE,syn_adc_sb#(LB_PKT_TYPE,PCM_PKT_TYPE,LB_DATA_W))  Mon_sent_2Sb_port;
    ovm_analysis_imp_adc_sb_rcvd_pkt #(PCM_PKT_TYPE,syn_adc_sb#(LB_PKT_TYPE,PCM_PKT_TYPE,LB_DATA_W))  Mon_rcvd_2Sb_port;

    OVM_FILE  f;

    syn_reg_map#(LB_DATA_W)   adc_reg_map;

    /*  Constructor */
    function new(string name = "syn_adc_sb", ovm_component parent);
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

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction

    /*
      * Write Sent Pkt
      * This function will be called each time a pkt is written into [ovm_analysis_imp_adc_sb_sent_pkt]Mon_sent_2Sb_port
    */
    virtual function void write_adc_sb_sent_pkt(input PCM_PKT_TYPE  pkt);
      ovm_report_info({get_name(),"[write_adc_sb_sent_pkt]"},$psprintf("Received pkt\n%s",pkt.sprint()),OVM_LOW);

      //Push packet into sent queue
      if(adc_reg_map.get_field("adc_en")  ==  1)
        sent_que.push_back(pkt);
      else
        ovm_report_info({get_name(),"[write_adc_sb_sent_pkt]"},$psprintf("Skipping sent_que since adc is disabled"),OVM_LOW);

      ovm_report_info({get_name(),"[write_adc_sb_sent_pkt]"},$psprintf("There are %d items in sent_que[$]",sent_que.size()),OVM_LOW);
    endfunction : write_adc_sb_sent_pkt

    /*
      * Write Rcvd Pkt
      * This function will be called each time a pkt is written into [ovm_analysis_imp_adc_sb_rcvd_pkt]Mon_rcvd_2Sb_port
    */
    virtual function void write_adc_sb_rcvd_pkt(input PCM_PKT_TYPE  pkt);
      PCM_PKT_TYPE  pcm_sample_pkt;

      ovm_report_info({get_name(),"[write_adc_sb_rcvd_pkt]"},$psprintf("Received pkt\n%s",pkt.sprint()),OVM_LOW);

      foreach(pkt.pcm_data[i])
      begin
        pcm_sample_pkt          = new();
        pcm_sample_pkt.pcm_data = new[1];
        pcm_sample_pkt.pcm_data[0].lchnnl = pkt.pcm_data[i].lchnnl;
        pcm_sample_pkt.pcm_data[0].rchnnl = pkt.pcm_data[i].rchnnl;

        //Push packet into rcvd queu
        rcvd_que.push_back(pcm_sample_pkt);
      end

      ovm_report_info({get_name(),"[write_adc_sb_rcvd_pkt]"},$psprintf("There are %d items in rcvd_que[$]",rcvd_que.size()),OVM_LOW);
    endfunction : write_adc_sb_rcvd_pkt


    /*  Run */
    task run();
      PCM_PKT_TYPE  sent_pkt,rcvd_pkt;
      string  res;

      ovm_report_info({get_name(),"[run]"},"Start of run",OVM_LOW);

      forever
      begin
        //Wait for items to arrive in sent & rcvd queues
        ovm_report_info({get_name(),"[run]"},"Waiting on rcvd_que ...",OVM_LOW);
        while(!rcvd_que.size())  #1;

        //Extract pkts from front of queues
        rcvd_pkt  = rcvd_que.pop_front();

        if(!sent_que.size())
        begin
          ovm_report_error({get_name(),"[run]"},$psprintf("Unexpected pkt!\n%s",rcvd_pkt.sprint()),OVM_LOW);
          continue;
        end

        sent_pkt  = sent_que.pop_front();

        //Process, compare, check etc.
        if(adc_reg_map.get_field("bps") ==  1)  //16b
        begin
          foreach(rcvd_pkt.pcm_data[i])
          begin
            rcvd_pkt.pcm_data[i].lchnnl = {{16{rcvd_pkt.pcm_data[i].lchnnl[16]}}, rcvd_pkt.pcm_data[i].lchnnl[15:0]};
            rcvd_pkt.pcm_data[i].rchnnl = {{16{rcvd_pkt.pcm_data[i].rchnnl[16]}}, rcvd_pkt.pcm_data[i].rchnnl[15:0]};
          end

          foreach(sent_pkt.pcm_data[i])
          begin
            sent_pkt.pcm_data[i].lchnnl = {{16{sent_pkt.pcm_data[i].lchnnl[16]}}, sent_pkt.pcm_data[i].lchnnl[15:0]};
            sent_pkt.pcm_data[i].rchnnl = {{16{sent_pkt.pcm_data[i].rchnnl[16]}}, sent_pkt.pcm_data[i].rchnnl[15:0]};
          end
        end

        res = sent_pkt.check(rcvd_pkt);

        if(res  ==  "")
        begin
          ovm_report_info({get_name(),"[run]"},$psprintf("PCM Data is correct"),OVM_LOW);
        end
        else
        begin
          ovm_report_error({get_name(),"[run]"},$psprintf("PCM Data is incorrect\n%s",res),OVM_LOW);
        end
      end

    endtask : run


    /*  Report  */
    virtual function void report();
      ovm_report_info({get_type_name(),"[report]"},$psprintf("Report -\n%s", this.sprint()), OVM_LOW);
    endfunction : report

  endclass : syn_adc_sb

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[02-11-2014  07:53:10 PM][mammenx] Misc changes for PCM Test

[16-10-2014  12:52:42 AM][mammenx] Fixed compilation errors

[15-10-2014  11:44:12 PM][mammenx] Initial Commit

 --------------------------------------------------------------------------
*/


