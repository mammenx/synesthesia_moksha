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
 -- Sequence Name     : syn_fgyrus_fft_poll_seq
 -- Author            : mammenx
 -- Function          : This sequence polls the fgyrus status register until
                        the FSM is idle and then issues a burst read to
                        the fft_cache. A copy of the FFT cache data read is
                        sent to the FFT scoreboard via LB SEQR.
 --------------------------------------------------------------------------
*/

`ifndef __SYN_FGYRUS_FFT_POLL_SEQ
`define __SYN_FGYRUS_FFT_POLL_SEQ

  import  syn_env_pkg::build_addr;

  class syn_fgyrus_fft_poll_seq #(
                                   type  PKT_TYPE  = syn_lb_seq_item,
                                   type  SEQR_TYPE = syn_lb_seqr#(PKT_TYPE),
                                   type  FFT_PKT_TYPE = syn_pcm_seq_item
                                ) extends ovm_sequence  #(PKT_TYPE);

    /*  Adding the parameterized sequence to the registery  */
    typedef syn_fgyrus_fft_poll_seq#(PKT_TYPE,SEQR_TYPE,FFT_PKT_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(SEQR_TYPE)

    `include  "cortex_regmap.svh"
    `include  "fgyrus_reg_map.svh"

    int poll_time_us;

    /*  Constructor */
    function new(string name  = "syn_fgyrus_fft_poll_seq");
      super.new(name);

      poll_time_us  = 10;
    endfunction

    /*  Body of sequence  */
    task  body();
      int i=0;
      PKT_TYPE  pkt;
      FFT_PKT_TYPE  fft_pkt;

      p_sequencer.ovm_report_info(get_name(),"Start of syn_fgyrus_fft_poll_seq",OVM_LOW);

      do
      begin
        repeat(poll_time_us)  #1us;

        $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("FGYRUS Status Poll Seq[%1d]",i)));

        start_item(pkt);  //start_item has wait_for_grant()
        
        pkt.addr  = new[1];
        pkt.data  = new[1];
        pkt.lb_xtn= READ;

        $cast(pkt.addr[0],  build_addr(FGYRUS_BLK,FGYRUS_REG_CODE,FGYRUS_STATUS_REG_ADDR));
        pkt.data[0] = $random;

        p_sequencer.ovm_report_info(get_name(),$psprintf("Generated pkt - \n%s", pkt.sprint()),OVM_LOW);

        finish_item(pkt);

        get_response(rsp);  //wait for response

        p_sequencer.ovm_report_info(get_name(),$psprintf("Got Response pkt - \n%s", rsp.sprint()),OVM_LOW);

        i++;
      end
      while(rsp.data[0][3]  ==  0); //Wait for fft_done


      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("FFT Cache Read Seq[%1d]",i)));

      start_item(pkt);  //start_item has wait_for_grant()
      
      pkt.addr  = new[256];
      pkt.data  = new[256];
      pkt.lb_xtn= BURST_READ;

      for(i=0; i<pkt.addr.size; i++)
      begin
        $cast(pkt.addr[i],  build_addr(FGYRUS_BLK,FGYRUS_FFT_CACHE_RAM_CODE,8'd0));
        pkt.addr[i] = pkt.addr[i] + i;
        pkt.data[i] = $random;
      end

      p_sequencer.ovm_report_info(get_name(),$psprintf("Generated pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      get_response(rsp);  //wait for response

      p_sequencer.ovm_report_info(get_name(),$psprintf("Got Response pkt - \n%s", rsp.sprint()),OVM_LOW);

      fft_pkt = new("fft_pkt");
      fft_pkt.pcm_data  = new[128];

      for(int i=0; i<128; i++)
      begin
        $cast(fft_pkt.pcm_data[i].lchnnl, rsp.data[i]);
        $cast(fft_pkt.pcm_data[i].rchnnl, rsp.data[i+128]);
      end

      p_sequencer.ovm_report_info(get_name(),$psprintf("Built FFT pkt - \n%s", fft_pkt.sprint()),OVM_LOW);
      p_sequencer.LB2FFT_Sb_port.write(fft_pkt);

    endtask : body


  endclass  : syn_fgyrus_fft_poll_seq

`endif


/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[06-12-2014  05:46:09 PM][mammenx] Initial Commit

 --------------------------------------------------------------------------
*/


