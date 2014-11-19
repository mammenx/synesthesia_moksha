/*
 --------------------------------------------------------------------------
   Synesthesia-Zen - Copyright (C) 2012 Gregory Matthew James.

   This file is part of Synesthesia-Zen.

   Synesthesia-Zen is free; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   Synesthesia-Zen is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program. If not, see <http://www.gnu.org/licenses/>.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------
 -- Project Code      : synesthesia_zen
 -- Sequence Name     : syn_ssm2603_codec_config_seq
 -- Author            : mammenx
 -- Function          : This sequence can be used to configure ssm2603 codec.
 --------------------------------------------------------------------------
*/

`ifndef __SYN_SSM2603_CODEC_CONFIG_SEQ
`define __SYN_SSM2603_CODEC_CONFIG_SEQ

  import  syn_audio_pkg::*;
  import  syn_env_pkg::build_addr;

  class syn_ssm2603_codec_config_seq  #(
                                      parameter type  PKT_TYPE  = syn_lb_seq_item,
                                      parameter type  SEQR_TYPE = syn_lb_seqr#(PKT_TYPE),
                                      parameter I2C_DATA_W      = 16,
                                      parameter CODEC_DATA_W    = 9
                                    ) extends ovm_sequence  #(PKT_TYPE);

    localparam  CODEC_ADDR_W  = I2C_DATA_W  - CODEC_DATA_W;

    /*  Adding the parameterized sequence to the registery  */
    typedef syn_ssm2603_codec_config_seq#(PKT_TYPE,SEQR_TYPE,I2C_DATA_W,CODEC_DATA_W) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(SEQR_TYPE)

    syn_i2c_config_seq#(I2C_DATA_W,PKT_TYPE,SEQR_TYPE)  i2c_config_seq;

    bit [CODEC_ADDR_W-1:0]  addr;
    bit [CODEC_DATA_W-1:0]  data;
    bit                     read_n_write;
    bit                     poll_en;

    /*  Constructor */
    function new(string name  = "syn_ssm2603_codec_config_seq");
      super.new(name);

      addr  = 0;
      data  = 0;
      read_n_write  = 0;
      poll_en = 1;
    endfunction

    /*  Body of sequence  */
    virtual task  body();
      if(read_n_write)  //READ
      begin
        m_sequencer.ovm_report_info(get_name(),$psprintf("Start of READ with addr[0x%x]",addr),OVM_LOW);

        i2c_config_seq  = syn_i2c_config_seq#(I2C_DATA_W,PKT_TYPE,SEQR_TYPE)::type_id::create("codec_i2c_write_addr_seq");
        i2c_config_seq.num_bytes= $ceil(real'(CODEC_ADDR_W) / real'(8));
        m_sequencer.ovm_report_info(get_name(),$psprintf("num_bytes = [0x%x]",i2c_config_seq.num_bytes),OVM_LOW);
        //i2c_config_seq.i2c_data = {addr,  {(8-(CODEC_ADDR_W%8)){1'b0}}};
        i2c_config_seq.i2c_data = {addr, data};
        i2c_config_seq.poll_en  = poll_en;
        i2c_config_seq.rd_n_wr  = 0;
        i2c_config_seq.start_en = 1;
        i2c_config_seq.stop_en  = 0;

        i2c_config_seq.start(m_sequencer,this);

        i2c_config_seq  = syn_i2c_config_seq#(I2C_DATA_W,PKT_TYPE,SEQR_TYPE)::type_id::create("codec_i2c_read_data_seq");
        i2c_config_seq.num_bytes= I2C_DATA_W  / 8;
        i2c_config_seq.poll_en  = poll_en;
        i2c_config_seq.rd_n_wr  = 1;
        i2c_config_seq.start_en = 1;
        i2c_config_seq.stop_en  = 1;

        i2c_config_seq.start(m_sequencer,this);
      end
      else  //  WRITE
      begin
        m_sequencer.ovm_report_info(get_name(),$psprintf("Start of WRITE with addr[0x%x] data[0x%x]",addr,data),OVM_LOW);

        i2c_config_seq  = syn_i2c_config_seq#(I2C_DATA_W,PKT_TYPE,SEQR_TYPE)::type_id::create("codec_i2c_write_addr_data_seq");
        i2c_config_seq.i2c_data = {addr,data};
        i2c_config_seq.poll_en  = poll_en;
        i2c_config_seq.rd_n_wr  = 0;
        i2c_config_seq.start_en = 1;
        i2c_config_seq.stop_en  = 1;
        i2c_config_seq.num_bytes= I2C_DATA_W  / 8;

        i2c_config_seq.start(m_sequencer,this);
      end

    endtask : body


  endclass  : syn_ssm2603_codec_config_seq

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[19-11-2014  10:46:30 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/


