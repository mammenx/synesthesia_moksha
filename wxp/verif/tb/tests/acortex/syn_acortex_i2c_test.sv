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
 -- Test Name         : syn_acortex_i2c_test
 -- Author            : mammenx
 -- Function          : This test checks if I2C xtns are working.
 --------------------------------------------------------------------------
*/

class syn_acortex_i2c_test extends syn_acortex_base_test;

    `ovm_component_utils(syn_acortex_i2c_test)

    //Sequences
    syn_i2c_config_seq#(super.I2C_DATA_W,super.LB_SEQ_ITEM_T,super.LB_SEQR_T)   i2c_config_seq;
    syn_ssm2603_codec_config_seq#(super.LB_SEQ_ITEM_T,super.LB_SEQR_T,super.I2C_DATA_W,super.CODEC_REG_MAP_W) codec_config_seq;


    OVM_FILE  f;

    /*  Constructor */
    function new (string name="syn_acortex_i2c_test", ovm_component parent=null);
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

      i2c_config_seq  = syn_i2c_config_seq#(super.I2C_DATA_W,super.LB_SEQ_ITEM_T,super.LB_SEQR_T)::type_id::create("i2c_config_seq");
      codec_config_seq= syn_ssm2603_codec_config_seq#(super.LB_SEQ_ITEM_T,super.LB_SEQR_T,super.I2C_DATA_W,super.CODEC_REG_MAP_W)::type_id::create("codec_config_seq");

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

      //  for(int i=0;  i<1; i++)
      //  begin
      //    i2c_config_seq.poll_en    = 1;
      //    i2c_config_seq.rd_n_wr    = 0;
      //    i2c_config_seq.num_bytes  = 2;
      //    i2c_config_seq.i2c_data   = $random & 'h0fff;
      //    i2c_config_seq.start(super.env.lb_agent.seqr);

      //    #100ns;
      //  end

      //  i2c_config_seq.poll_en    = 1;
      //  i2c_config_seq.rd_n_wr    = 0;
      //  i2c_config_seq.start_en   = 1;
      //  i2c_config_seq.stop_en    = 0;
      //  i2c_config_seq.num_bytes  = 1;
      //  i2c_config_seq.i2c_data   = $random & 'hffff;
      //  i2c_config_seq.start(super.env.lb_agent.seqr);

      //  #100ns;
 
      //  i2c_config_seq.poll_en    = 1;
      //  i2c_config_seq.rd_n_wr    = 1;
      //  i2c_config_seq.start_en   = 1;
      //  i2c_config_seq.stop_en    = 1;
      //  i2c_config_seq.num_bytes  = 2;
      //  i2c_config_seq.i2c_data   = $random & 'hffff;
      //  i2c_config_seq.start(super.env.lb_agent.seqr);

      //  #100ns;

      codec_config_seq.addr = 'd1;
      codec_config_seq.data = $random;
      codec_config_seq.read_n_write = 0;
      codec_config_seq.poll_en  = 1;

      codec_config_seq.start(super.env.lb_agent.seqr);

      codec_config_seq.addr = 'd1;
      codec_config_seq.data = $random;
      codec_config_seq.read_n_write = 1;
      codec_config_seq.poll_en  = 1;

      codec_config_seq.start(super.env.lb_agent.seqr);


      ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
      global_stop_request();

      ovm_report_info(get_full_name(),"End of run",OVM_LOW);
    endtask : run


endclass : syn_acortex_i2c_test

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[19-11-2014  10:47:50 PM][mammenx] Added i2c read support

[18-11-2014  06:03:18 PM][mammenx] Removed MCLK feature testing and updated I2C agents

[15-10-2014  11:44:12 PM][mammenx] Initial Commit

 --------------------------------------------------------------------------
*/


