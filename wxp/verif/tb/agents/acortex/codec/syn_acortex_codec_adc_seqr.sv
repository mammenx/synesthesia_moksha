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
 -- Component Name    : syn_acortex_codec_adc_seqr
 -- Author            : mammenx 
 -- Function          : ADC Sequencer class.
 --------------------------------------------------------------------------
*/

`ifndef __SYN_ACORTEX_CODEC_ADC_SEQR
`define __SYN_ACORTEX_CODEC_ADC_SEQR

class syn_acortex_codec_adc_seqr  #(type  PKT_TYPE  = syn_pcm_seq_item
                                  ) extends ovm_sequencer #(PKT_TYPE);

    /*  Register with factory */
    `ovm_component_param_utils(syn_acortex_codec_adc_seqr#(PKT_TYPE))
  
    OVM_FILE  f;

    function new (string name = "syn_acortex_codec_adc_seqr", ovm_component parent);
        super.new(name, parent);
    endfunction : new

    function  void  build();
      super.build();

      f = $fopen({"./logs/",get_full_name(),".log"},  "w");

      set_report_default_file(f);
      set_report_severity_action(OVM_INFO,  OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_WARNING, OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_ERROR,  OVM_COUNT | OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_FATAL,  OVM_EXIT | OVM_DISPLAY | OVM_LOG);

      ovm_report_info(get_name(),"Start of build ",OVM_LOW);


      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction : build

 
endclass : syn_acortex_codec_adc_seqr

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[15-10-2014  11:44:12 PM][mammenx] Initial Commit

 --------------------------------------------------------------------------
*/


