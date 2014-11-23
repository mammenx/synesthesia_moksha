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
 -- Test Name         : syn_cortex_pcm_test
 -- Author            : mammenx
 -- Function          : This test checks the ADC->PCM-Buffer->DAC path.
 --------------------------------------------------------------------------
*/

class syn_cortex_pcm_test extends syn_cortex_base_test;

    `ovm_component_utils(syn_cortex_pcm_test)

    //Sequences
    syn_codec_adc_load_seq#(super.PCM_SEQ_ITEM_T,super.ADC_SEQR_T)    codec_adc_config_seq;
    syn_ssm2603_drvr_config_seq#(super.LB_SEQ_ITEM_T,super.LB_SEQR_T) drvr_config_seq;


    OVM_FILE  f;

    /*  Constructor */
    function new (string name="syn_cortex_pcm_test", ovm_component parent=null);
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

      codec_adc_config_seq= syn_codec_adc_load_seq#(super.PCM_SEQ_ITEM_T,super.ADC_SEQR_T)::type_id::create("codec_adc_config_seq");
      drvr_config_seq     = syn_ssm2603_drvr_config_seq#(super.LB_SEQ_ITEM_T,super.LB_SEQR_T)::type_id::create("drvr_config_seq");

      ovm_report_info(get_full_name(),"End of build",OVM_LOW);
    endfunction : build


    /*  Connect */
    function  void  connect();
      super.connect();

      ovm_report_info(get_full_name(),"Start of connect",OVM_LOW);

        super.env.codec_agent.i2c.s_drvr.update_reg_map_en = 1;

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

      super.setup_codec(32);

      #500;

      codec_adc_config_seq.pcm_pkt.fill_inc(128,0,1);

      drvr_config_seq.bclk_div_val  = 10;
      drvr_config_seq.fs_div_val    = 75;
      drvr_config_seq.dac_en        = 1;
      drvr_config_seq.adc_en        = 1;
      drvr_config_seq.bps           = 2'b11;

      fork
        begin
          codec_adc_config_seq.start(super.env.codec_agent.adc_seqr);
          codec_adc_config_seq.start(super.env.codec_agent.adc_seqr);
          codec_adc_config_seq.start(super.env.codec_agent.adc_seqr);
        end

        begin
          drvr_config_seq.start(super.env.lb_agent.seqr);
        end
      join

      do  
      begin
        #100ns;
      end 
      while(super.env.codec_agent.dac_mon.num_samples < 256);

      #10;

      ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
      global_stop_request();

      ovm_report_info(get_full_name(),"End of run",OVM_LOW);
    endtask : run


endclass : syn_cortex_pcm_test

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[18-11-2014  06:03:18 PM][mammenx] Removed MCLK feature testing and updated I2C agents

[02-11-2014  07:53:10 PM][mammenx] Misc changes for PCM Test

[02-11-2014  01:48:33 PM][mammenx] Fixed misc issues from simulation

[02-11-2014  12:16:37 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/


