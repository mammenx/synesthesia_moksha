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
 -- Component Name    : syn_cortex_env
 -- Author            : mammenx
 -- Function          : This is the complete verif environment for Cortex
                        block.
 --------------------------------------------------------------------------
*/


`ifndef __SYN_CORTEX_ENV
`define __SYN_CORTEX_ENV

  import  syn_env_pkg::*;

  class syn_cortex_env extends ovm_env;

    `include  "cortex_regmap.svh"
    `include  "acortex_regmap.svh"
    `include  "i2c_master_regmap.svh"
    `include  "pcm_bffr_regmap.svh"
    `include  "ssm2603_drvr_regmap.svh"
    `include  "fgyrus_reg_map.svh"
    `include  "vcortex_regmap.svh"
    `include  "sys_mem_hst_acc_regmap.svh"
    `include  "adv7513_cntrlr_regmap.svh"
    `include  "sys_mem_intf_regmap.svh"
    `include  "sys_mem_part_mngr_regmap.svh"
    `include  "sys_mem_arb_regmap.svh"

    //Parameters
    parameter       LB_DATA_W   = syn_env_pkg::LB_DATA_W;
    parameter       LB_ADDR_W   = syn_env_pkg::LB_BLK_1_W + syn_env_pkg::LB_BLK_0_W + syn_env_pkg::LB_BASE_W;
    parameter type  LB_PKT_T    = syn_lb_seq_item#(LB_DATA_W,LB_ADDR_W);
    parameter type  LB_DRVR_INTF_T  = virtual syn_lb_tb_intf#(LB_DATA_W,LB_ADDR_W);
    parameter type  LB_MON_INTF_T   = virtual syn_lb_tb_intf#(LB_DATA_W,LB_ADDR_W);

    parameter       REG_MAP_W     = 9;

    parameter       I2C_DATA_W    = 16;
    parameter type  I2C_INTF_TYPE = virtual syn_wm8731_intf.TB_I2C;
    parameter type  I2C_PKT_TYPE  = syn_lb_seq_item#(8, 7); //8b data & 7b address

    parameter type  PCM_PKT_TYPE  = syn_pcm_seq_item;

    parameter type  DAC_INTF_TYPE = virtual syn_wm8731_intf.TB_DAC;
    parameter type  ADC_INTF_TYPE = virtual syn_wm8731_intf.TB_ADC;

    parameter       NUM_PCM_SAMPLES   = 128;
    //parameter type  PCM_MEM_INTF_DRVR_TYPE = virtual syn_pcm_mem_intf#(32,8,2).TB_MASTER;
    //parameter type  PCM_MEM_INTF_MON_TYPE  = virtual syn_pcm_mem_intf#(32,8,2).TB_MON;
    parameter type  PCM_MEM_INTF_DRVR_TYPE  = virtual syn_pcm_mem_intf_mon.TB_DRVR;
    parameter type  PCM_MEM_INTF_MON_TYPE   = virtual syn_pcm_mem_intf_mon.TB_MON;

    parameter type  BUT_PKT_TYPE  = syn_but_seq_item;
    parameter type  BUT_INTF_TYPE = virtual syn_but_intf;

    parameter type  FFT_CACHE_PKT_TYPE  = syn_fft_cache_seq_item;
    parameter type  FFT_CACHE_INTF_TYPE = virtual syn_fft_cache_intf#(32,8);

    parameter SYS_MEM_DATA_W  = 32;
    parameter SYS_MEM_ADDR_W  = 27;
    parameter SYS_MEM_NUM_AGENTS  = 2;
    parameter type  SYS_MEM_PKT_TYPE  = syn_sys_mem_seq_item#(SYS_MEM_DATA_W,SYS_MEM_ADDR_W);
    parameter type  SYS_MEM_INTF_TYPE = virtual syn_sys_mem_intf#(SYS_MEM_DATA_W,SYS_MEM_ADDR_W,1);
    parameter type  SYS_MEM_AGENT_INTF_TYPE = virtual syn_sys_mem_intf#(SYS_MEM_DATA_W,SYS_MEM_ADDR_W,SYS_MEM_NUM_AGENTS);


    /*  Register with factory */
    `ovm_component_utils(syn_cortex_env)

    //Declare agents, scoreboards
    syn_lb_agent#(LB_DATA_W,LB_ADDR_W,LB_PKT_T,LB_DRVR_INTF_T,LB_MON_INTF_T)  lb_agent;
    syn_acortex_codec_agent#( REG_MAP_W,
                              I2C_DATA_W,
                              I2C_INTF_TYPE,
                              I2C_PKT_TYPE,
                              PCM_PKT_TYPE,
                              DAC_INTF_TYPE,
                              ADC_INTF_TYPE
                            )  codec_agent;
    syn_pcm_mem_agent#(NUM_PCM_SAMPLES,PCM_PKT_TYPE,PCM_MEM_INTF_DRVR_TYPE,PCM_MEM_INTF_MON_TYPE)  pcm_mem_agent;
    syn_i2c_sb#(I2C_DATA_W,LB_DATA_W,LB_PKT_T,I2C_PKT_TYPE)   i2c_sb;
    syn_adc_sb#(LB_PKT_T,PCM_PKT_TYPE,LB_DATA_W)              adc_sb;
    syn_dac_sb#(LB_PKT_T,PCM_PKT_TYPE,LB_DATA_W)              dac_sb;

    syn_reg_map#(REG_MAP_W)   wm8731_reg_map;  //each register is 9b

    syn_reg_map#(LB_DATA_W)   acortex_reg_map;

    syn_reg_map#(LB_DATA_W)   fgyrus_reg_map;

    syn_reg_map#(LB_DATA_W)   vcortex_reg_map;

    syn_reg_map#(LB_DATA_W)   sys_mem_intf_reg_map;

    syn_but_sniffer#(BUT_PKT_TYPE,BUT_INTF_TYPE)              but_sniffer;
    syn_but_sb#(BUT_PKT_TYPE,BUT_PKT_TYPE)                    but_sb;

    syn_fft_cache_sniffer#(FFT_CACHE_PKT_TYPE,FFT_CACHE_INTF_TYPE)            fft_cache_sniffer;
    syn_fft_cache_sb#(PCM_PKT_TYPE,FFT_CACHE_PKT_TYPE)                        fft_cache_sb;

    syn_fft_sb#(PCM_PKT_TYPE,PCM_PKT_TYPE)                                    fft_sb;

    syn_sys_mem_agent#(SYS_MEM_DATA_W,SYS_MEM_ADDR_W,SYS_MEM_NUM_AGENTS,SYS_MEM_PKT_TYPE,SYS_MEM_INTF_TYPE,SYS_MEM_AGENT_INTF_TYPE)  sys_mem_agent;

    syn_sys_mem_intf_sb#(SYS_MEM_DATA_W,SYS_MEM_ADDR_W,SYS_MEM_NUM_AGENTS,LB_DATA_W,SYS_MEM_PKT_TYPE,SYS_MEM_PKT_TYPE)  sys_mem_intf_sb;

    OVM_FILE  f;


    //For routing LB packets
    tlm_analysis_fifo#(LB_PKT_T)  LB2Env_ff;


    /*  Constructor */
    function new(string name  = "syn_cortex_env", ovm_component parent = null);
      super.new(name, parent);
    endfunction: new


    /*  Build */
    function void build();
      super.build();

      f = $fopen({"./logs/",get_full_name(),".log"});

      set_report_default_file(f);
      set_report_severity_action(OVM_INFO,  OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_WARNING, OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_ERROR,  OVM_COUNT | OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_FATAL,  OVM_EXIT | OVM_DISPLAY | OVM_LOG);

      ovm_report_info(get_name(),"Start of build ",OVM_LOW);

      lb_agent      = syn_lb_agent#(LB_DATA_W,LB_ADDR_W,LB_PKT_T,LB_DRVR_INTF_T,LB_MON_INTF_T)::type_id::create("lb_agent",  this);
      codec_agent   = syn_acortex_codec_agent#(REG_MAP_W,I2C_DATA_W,I2C_INTF_TYPE,I2C_PKT_TYPE,PCM_PKT_TYPE,DAC_INTF_TYPE,ADC_INTF_TYPE)::type_id::create("codec_agent",  this);
      pcm_mem_agent = syn_pcm_mem_agent#(NUM_PCM_SAMPLES,PCM_PKT_TYPE,PCM_MEM_INTF_DRVR_TYPE,PCM_MEM_INTF_MON_TYPE)::type_id::create("pcm_mem_agent",  this);
      i2c_sb        = syn_i2c_sb#(I2C_DATA_W,LB_DATA_W,LB_PKT_T,I2C_PKT_TYPE)::type_id::create("i2c_sb",  this);
      adc_sb        = syn_adc_sb#(LB_PKT_T,PCM_PKT_TYPE,LB_DATA_W)::type_id::create("adc_sb",  this);
      dac_sb        = syn_dac_sb#(LB_PKT_T,PCM_PKT_TYPE,LB_DATA_W)::type_id::create("dac_sb",  this);

      but_sniffer   = syn_but_sniffer#(BUT_PKT_TYPE,BUT_INTF_TYPE)::type_id::create("but_sniffer",  this);
      but_sb        = syn_but_sb#(BUT_PKT_TYPE,BUT_PKT_TYPE)::type_id::create("but_sb",  this);

      fft_cache_sniffer = syn_fft_cache_sniffer#(FFT_CACHE_PKT_TYPE,FFT_CACHE_INTF_TYPE)::type_id::create("fft_cache_sniffer",  this);
      fft_cache_sb  = syn_fft_cache_sb#(PCM_PKT_TYPE,FFT_CACHE_PKT_TYPE)::type_id::create("fft_cache_sb",  this);
      fft_sb        = syn_fft_sb#(PCM_PKT_TYPE,PCM_PKT_TYPE)::type_id::create("fft_sb",  this);

      sys_mem_agent = syn_sys_mem_agent#(SYS_MEM_DATA_W,SYS_MEM_ADDR_W,SYS_MEM_NUM_AGENTS,SYS_MEM_PKT_TYPE,SYS_MEM_INTF_TYPE,SYS_MEM_AGENT_INTF_TYPE)::type_id::create("sys_mem_agent", this);

      sys_mem_intf_sb = syn_sys_mem_intf_sb#(SYS_MEM_DATA_W,SYS_MEM_ADDR_W,SYS_MEM_NUM_AGENTS,LB_DATA_W,SYS_MEM_PKT_TYPE,SYS_MEM_PKT_TYPE)::type_id::create("sys_mem_intf_sb", this);

      LB2Env_ff       = new("LB2Env_ff",this);

      wm8731_reg_map     = syn_reg_map#(REG_MAP_W)::type_id::create("wm8731_reg_map",this);
      build_wm8731_reg_map();
      ovm_report_info(get_name(),$psprintf("WM8731 Reg Map Table%s",wm8731_reg_map.sprintTable()),OVM_LOW);

      acortex_reg_map    = syn_reg_map#(LB_DATA_W)::type_id::create("acortex_reg_map",this);
      build_acortex_reg_map();
      ovm_report_info(get_name(),$psprintf("Acortex Reg Map Table%s",acortex_reg_map.sprintTable()),OVM_LOW);

      fgyrus_reg_map    = syn_reg_map#(LB_DATA_W)::type_id::create("fgyrus_reg_map",this);
      build_fgyrus_reg_map();
      ovm_report_info(get_name(),$psprintf("Fgyrus Reg Map Table%s",fgyrus_reg_map.sprintTable()),OVM_LOW);

      vcortex_reg_map   = syn_reg_map#(LB_DATA_W)::type_id::create("vcortex_reg_map",this);
      build_vcortex_reg_map();
      ovm_report_info(get_name(),$psprintf("Vcortex Reg Map Table%s",vcortex_reg_map.sprintTable()),OVM_LOW);

      sys_mem_intf_reg_map    = syn_reg_map#(LB_DATA_W)::type_id::create("sys_mem_intf_reg_map",this);
      build_sys_mem_intf_reg_map();
      ovm_report_info(get_name(),$psprintf("Sys Mem Intf Reg Map Table%s",sys_mem_intf_reg_map.sprintTable()),OVM_LOW);

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction


    /*  Connect */
    function void connect();
      super.connect();

      ovm_report_info(get_name(),"START of connect ",OVM_LOW);

        this.pcm_mem_agent.drvr.mode_master_n_slave  = 0;  //configure as slave

        //Ports
        lb_agent.mon.Mon2Sb_port.connect(this.LB2Env_ff.analysis_export);
        //codec_agent.i2c_mon.Mon2Sb_port.connect(i2c_sb.Mon_i2c_2Sb_port);
        codec_agent.i2c.mon.Mon2Sb_port.connect(i2c_sb.Mon_i2c_2Sb_port);
        pcm_mem_agent.mon.Mon2Sb_port.connect(adc_sb.Mon_rcvd_2Sb_port);
        codec_agent.adc_mon.Mon2Sb_port.connect(adc_sb.Mon_sent_2Sb_port);
        codec_agent.adc_mon.Mon2Sb_port.connect(dac_sb.Mon_sent_2Sb_port);
        codec_agent.dac_mon.Mon2Sb_port.connect(dac_sb.Mon_rcvd_2Sb_port);

        //Reg Map
        codec_agent.adc_drvr.reg_map  = this.wm8731_reg_map;
        codec_agent.adc_mon.reg_map   = this.wm8731_reg_map;
        codec_agent.dac_mon.reg_map   = this.wm8731_reg_map;
        //codec_agent.i2c_slave.reg_map = this.wm8731_reg_map;
        codec_agent.i2c.s_drvr.reg_map = this.wm8731_reg_map;

        i2c_sb.reg_map        = this.acortex_reg_map;
        adc_sb.adc_reg_map    = this.acortex_reg_map;
        dac_sb.dac_reg_map    = this.acortex_reg_map;

        but_sniffer.SnifferIngr2Sb_port.connect(but_sb.Mon_sent_2Sb_port);
        but_sniffer.SnifferEgr2Sb_port.connect(but_sb.Mon_rcvd_2Sb_port);

        this.pcm_mem_agent.mon.Mon2Sb_port.connect(fft_cache_sb.Mon_sent_2Sb_port);
        this.fft_cache_sniffer.Sniffer2Sb_port.connect(fft_cache_sb.Mon_rcvd_2Sb_port);

        this.pcm_mem_agent.mon.Mon2Sb_port.connect(fft_sb.Mon_sent_2Sb_port);
        this.lb_agent.seqr.LB2FFT_Sb_port.connect(fft_sb.Mon_rcvd_2Sb_port);

        this.sys_mem_agent.agent_mon.Mon2Sb_ingr_port.connect(sys_mem_intf_sb.Mon_agent_sent_2Sb_port);
        this.sys_mem_agent.agent_mon.Mon2Sb_egr_port.connect(sys_mem_intf_sb.Mon_agent_rcvd_2Sb_port);

        this.sys_mem_agent.mon.Mon2Sb_ingr_port.connect(sys_mem_intf_sb.Mon_sent_2Sb_port);
        this.sys_mem_agent.mon.Mon2Sb_egr_port.connect(sys_mem_intf_sb.Mon_rcvd_2Sb_port);

        sys_mem_intf_sb.sys_mem_intf_reg_map  = this.sys_mem_intf_reg_map;

      ovm_report_info(get_name(),"END of connect ",OVM_LOW);
    endfunction

    /*  Run */
    task  run();
      LB_PKT_T  lb_pkt;

      ovm_report_info({get_name(),"[run]"},"START of run ...",OVM_LOW);

      forever
      begin
        ovm_report_info({get_name(),"[run]"},$psprintf("Waiting for LB packets"),OVM_LOW);

        LB2Env_ff.get(lb_pkt);

        ovm_report_info({get_name(),"[run]"},$psprintf("Received LB pkt->\n%s",lb_pkt.sprint()),OVM_LOW);

        if((lb_pkt.lb_xtn  ==  WRITE) ||  (lb_pkt.lb_xtn  ==  BURST_WRITE))
        begin
          for(int i=0;  i<lb_pkt.addr.size; i++)
          begin
            if(lb_pkt.addr[i][LB_ADDR_W-1  -:  LB_BLK_1_W] ==  ACORTEX_BLK)
            begin
              if(!acortex_reg_map.set_reg(lb_pkt.addr[i],lb_pkt.data[i]))
              begin
                ovm_report_info({get_name(),"[run]"},"Updated acortex_regmap",OVM_LOW);
              end
              else
              begin
                ovm_report_warning({get_name(),"[run]"},"Could not update acortex_regmap!",OVM_LOW);
              end
            end
            else if(lb_pkt.addr[i][LB_ADDR_W-1  -:  LB_BLK_1_W] ==  FGYRUS_BLK)
            begin
              if(!fgyrus_reg_map.set_reg(lb_pkt.addr[i],lb_pkt.data[i]))
              begin
                ovm_report_info({get_name(),"[run]"},"Updated fgyrus_regmap",OVM_LOW);
              end
              else
              begin
                ovm_report_warning({get_name(),"[run]"},"Could not update fgyrus_regmap!",OVM_LOW);
              end
            end
            else if(lb_pkt.addr[i][LB_ADDR_W-1  -:  LB_BLK_1_W] ==  SYS_MEM_MNGR_BLK)
            begin
              if(!sys_mem_intf_reg_map.set_reg(lb_pkt.addr[i],lb_pkt.data[i]))
              begin
                ovm_report_info({get_name(),"[run]"},"Updated sys_mem_intf_reg_map",OVM_LOW);
              end
              else
              begin
                ovm_report_warning({get_name(),"[run]"},"Could not update sys_mem_intf_reg_map!",OVM_LOW);
              end
            end
            else
            begin
              ovm_report_warning({get_name(),"[run]"},"Unknown LB_BLK_1 code!",OVM_LOW);
            end
          end

          #1;

          //Intimate people
          i2c_sb.lb_event.put(1);
        end
      end
    endtask : run

    /*
      * This function builds the WM8731 register map as per the spec
    */
    function  void  build_wm8731_reg_map();

      wm8731_reg_map.create_field("linvol",    0,  0,  4);
      wm8731_reg_map.create_field("linmute",   0,  7,  7);
      wm8731_reg_map.create_field("lrinboth",  0,  8,  8);
      wm8731_reg_map.create_field("rinvol",    1,  0,  4);
      wm8731_reg_map.create_field("rinmute",   1,  7,  7);
      wm8731_reg_map.create_field("rlinboth",  1,  8,  8);
      wm8731_reg_map.create_field("lhpvol",    2,  0,  6);
      wm8731_reg_map.create_field("lzcen",     2,  7,  7);
      wm8731_reg_map.create_field("lrhpboth",  2,  8,  8);
      wm8731_reg_map.create_field("rhpvol",    3,  0,  6);
      wm8731_reg_map.create_field("rzcen",     3,  7,  7);
      wm8731_reg_map.create_field("rlhpboth",  3,  8,  8);
      wm8731_reg_map.create_field("micboost",  4,  0,  0);
      wm8731_reg_map.create_field("mutemic",   4,  1,  1);
      wm8731_reg_map.create_field("insel",     4,  2,  2);
      wm8731_reg_map.create_field("bypass",    4,  3,  3);
      wm8731_reg_map.create_field("dacsel",    4,  4,  4);
      wm8731_reg_map.create_field("sdetone",   4,  5,  5);
      wm8731_reg_map.create_field("sideatt",   4,  6,  7);
      wm8731_reg_map.create_field("adchpd",    5,  0,  0);
      wm8731_reg_map.create_field("deemph",    5,  1,  2);
      wm8731_reg_map.create_field("dacmu",     5,  3,  3);
      wm8731_reg_map.create_field("hpor",      5,  4,  4);
      wm8731_reg_map.create_field("lineinpd",  6,  0,  0);
      wm8731_reg_map.create_field("micpd",     6,  1,  1);
      wm8731_reg_map.create_field("adcpd",     6,  2,  2);
      wm8731_reg_map.create_field("dacpd",     6,  3,  3);
      wm8731_reg_map.create_field("outpd",     6,  4,  4);
      wm8731_reg_map.create_field("oscpd",     6,  5,  5);
      wm8731_reg_map.create_field("clkoutpd",  6,  6,  6);
      wm8731_reg_map.create_field("pwroff",    6,  7,  7);
      wm8731_reg_map.create_field("format",    7,  0,  1);
      wm8731_reg_map.create_field("iwl",       7,  2,  3);
      wm8731_reg_map.create_field("lrp",       7,  4,  4);
      wm8731_reg_map.create_field("lrswap",    7,  5,  5);
      wm8731_reg_map.create_field("ms",        7,  6,  6);
      wm8731_reg_map.create_field("bclkinv",   7,  7,  7);
      wm8731_reg_map.create_field("usb/norm",  8,  0,  0);
      wm8731_reg_map.create_field("bosr",      8,  1,  1);
      wm8731_reg_map.create_field("sr",        8,  2,  5);
      wm8731_reg_map.create_field("clk1div2",  8,  6,  6);
      wm8731_reg_map.create_field("clk0div2",  8,  7,  7);
      wm8731_reg_map.create_field("active",    9,  0,  0);

    endfunction : build_wm8731_reg_map

    function  void  build_acortex_reg_map();
      acortex_reg_map.create_field("i2c_addr",      build_addr(ACORTEX_BLK,ACORTEX_I2C_BLK_CODE,I2C_ADDR_REG_ADDR),    1,    7);
      acortex_reg_map.create_field("clk_div",       build_addr(ACORTEX_BLK,ACORTEX_I2C_BLK_CODE,I2C_CLK_DIV_REG_ADDR), 0,    LB_DATA_W-1);
      acortex_reg_map.create_field("i2c_start_en",  build_addr(ACORTEX_BLK,ACORTEX_I2C_BLK_CODE,I2C_CONFIG_REG_ADDR),  0,    0);
      acortex_reg_map.create_field("i2c_stop_en",   build_addr(ACORTEX_BLK,ACORTEX_I2C_BLK_CODE,I2C_CONFIG_REG_ADDR),  1,    1);
      acortex_reg_map.create_field("i2c_init",      build_addr(ACORTEX_BLK,ACORTEX_I2C_BLK_CODE,I2C_CONFIG_REG_ADDR),  2,    2);
      acortex_reg_map.create_field("i2c_rd_n_wr",   build_addr(ACORTEX_BLK,ACORTEX_I2C_BLK_CODE,I2C_CONFIG_REG_ADDR),  3,    3);
      acortex_reg_map.create_field("i2c_num_bytes", build_addr(ACORTEX_BLK,ACORTEX_I2C_BLK_CODE,I2C_CONFIG_REG_ADDR),  8,    LB_DATA_W-1);
      acortex_reg_map.create_field("i2c_data_0",    build_addr(ACORTEX_BLK,ACORTEX_I2C_BLK_CODE,I2C_DATA_CACHE_BASE_ADDR+0),  0,  7);
      acortex_reg_map.create_field("i2c_data_1",    build_addr(ACORTEX_BLK,ACORTEX_I2C_BLK_CODE,I2C_DATA_CACHE_BASE_ADDR+1),  0,  7);
      acortex_reg_map.create_field("i2c_data_2",    build_addr(ACORTEX_BLK,ACORTEX_I2C_BLK_CODE,I2C_DATA_CACHE_BASE_ADDR+2),  0,  7);
      acortex_reg_map.create_field("i2c_data_3",    build_addr(ACORTEX_BLK,ACORTEX_I2C_BLK_CODE,I2C_DATA_CACHE_BASE_ADDR+3),  0,  7);

      acortex_reg_map.create_field("dac_en",        build_addr(ACORTEX_BLK,ACORTEX_DRVR_BLK_CODE,SSM2603_DRVR_CONFIG_REG_ADDR),   0,  0);
      acortex_reg_map.create_field("adc_en",        build_addr(ACORTEX_BLK,ACORTEX_DRVR_BLK_CODE,SSM2603_DRVR_CONFIG_REG_ADDR),   1,  1);
      acortex_reg_map.create_field("bps_val",       build_addr(ACORTEX_BLK,ACORTEX_DRVR_BLK_CODE,SSM2603_DRVR_CONFIG_REG_ADDR),   2,  3);
      acortex_reg_map.create_field("bclk_div_val",  build_addr(ACORTEX_BLK,ACORTEX_DRVR_BLK_CODE,SSM2603_DRVR_BCLK_DIV_REG_ADDR), 0,  LB_DATA_W-1);
      acortex_reg_map.create_field("fs_val",        build_addr(ACORTEX_BLK,ACORTEX_DRVR_BLK_CODE,SSM2603_DRVR_FS_VAL_REG_ADDR),   0,  LB_DATA_W-1);
      acortex_reg_map.create_field("bffr_mode",     build_addr(ACORTEX_BLK,ACORTEX_PCM_BFFR_CLK_CODE,PCM_BFFR_CONTROL_REG_ADDR),  0,  0);
    endfunction : build_acortex_reg_map


    function  void  build_fgyrus_reg_map();
      fgyrus_reg_map.create_field("fgyrus_en",    build_addr(FGYRUS_BLK,FGYRUS_REG_CODE,FGYRUS_CONTROL_REG_ADDR),  0,  0);
      fgyrus_reg_map.create_field("fgyrus_mode",  build_addr(FGYRUS_BLK,FGYRUS_REG_CODE,FGYRUS_CONTROL_REG_ADDR),  1,  1);

      fgyrus_reg_map.create_field("fgyrus_busy",        build_addr(FGYRUS_BLK,FGYRUS_REG_CODE,FGYRUS_STATUS_REG_ADDR),  0,  0);
      fgyrus_reg_map.create_field("but_bffr_underflow", build_addr(FGYRUS_BLK,FGYRUS_REG_CODE,FGYRUS_STATUS_REG_ADDR),  1,  1);
      fgyrus_reg_map.create_field("but_bffr_ovrflow",   build_addr(FGYRUS_BLK,FGYRUS_REG_CODE,FGYRUS_STATUS_REG_ADDR),  2,  2);

      fgyrus_reg_map.create_field("fgyrus_post_norm", build_addr(FGYRUS_BLK,FGYRUS_REG_CODE,FGYRUS_POST_NORM_REG_ADDR),  3,  0);

      fgyrus_reg_map.create_space("fgyrus_fft_cache_ram", build_addr(FGYRUS_BLK,FGYRUS_FFT_CACHE_RAM_CODE,0), 256);
      fgyrus_reg_map.create_space("fgyrus_twdl_ram",      build_addr(FGYRUS_BLK,FGYRUS_TWDLE_RAM_CODE,0),     128);
      fgyrus_reg_map.create_space("fgyrus_cordic_ram",    build_addr(FGYRUS_BLK,FGYRUS_CORDIC_RAM_CODE,0),    256);
      fgyrus_reg_map.create_space("fgyrus_win_ram",       build_addr(FGYRUS_BLK,FGYRUS_WIN_RAM_CODE,0),       128);
    endfunction : build_fgyrus_reg_map

    function  void  build_vcortex_reg_map();
      vcortex_reg_map.create_field("line_bffr_en",  build_addr(VCORTEX_BLK,VCORTEX_ADV7513_CNTRLR_BLK_CODE,ADV7513_CNTRLR_CONFIG_REG),  0,  0);
      vcortex_reg_map.create_field("drvr_en",       build_addr(VCORTEX_BLK,VCORTEX_ADV7513_CNTRLR_BLK_CODE,ADV7513_CNTRLR_CONFIG_REG),  1,  1);

      vcortex_reg_map.create_field("avd7513_lbffr_ovrflw",  build_addr(VCORTEX_BLK,VCORTEX_ADV7513_CNTRLR_BLK_CODE,ADV7513_CNTRLR_STATUS_REG),  0,  0);
      vcortex_reg_map.create_field("avd7513_lbffr_undrflw", build_addr(VCORTEX_BLK,VCORTEX_ADV7513_CNTRLR_BLK_CODE,ADV7513_CNTRLR_STATUS_REG),  1,  1);

      vcortex_reg_map.create_field("mem_addr",      build_addr(VCORTEX_BLK,VCORTEX_HST_ACCESS_BLK_CODE,SYS_MEM_HST_ACC_ADDR_REG),  SYS_MEM_ADDR_W-1,  0);
      vcortex_reg_map.create_field("mem_data",      build_addr(VCORTEX_BLK,VCORTEX_HST_ACCESS_BLK_CODE,SYS_MEM_HST_ACC_DATA_REG),  SYS_MEM_DATA_W-1,  0);

      vcortex_reg_map.create_field("sys_mem_hst_acc_wren", build_addr(VCORTEX_BLK,VCORTEX_HST_ACCESS_BLK_CODE,SYS_MEM_HST_ACC_STATUS_REG),  0,  0);
      vcortex_reg_map.create_field("sys_mem_hst_acc_rden", build_addr(VCORTEX_BLK,VCORTEX_HST_ACCESS_BLK_CODE,SYS_MEM_HST_ACC_STATUS_REG),  1,  1);

    endfunction : build_vcortex_reg_map

    function  void  build_sys_mem_intf_reg_map();
      sys_mem_intf_reg_map.create_space("sys_mem_part_start_ram",  build_addr(SYS_MEM_MNGR_BLK,SYS_MEM_INTF_PART_BLK_CODE,0),  SYS_MEM_NUM_AGENTS);
      sys_mem_intf_reg_map.create_space("sys_mem_part_end_ram",    build_addr(SYS_MEM_MNGR_BLK,SYS_MEM_INTF_PART_BLK_CODE,32), SYS_MEM_NUM_AGENTS);

    endfunction : build_sys_mem_intf_reg_map

  endclass  : syn_cortex_env

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[11-01-2015  01:20:27 PM][mammenx] .

[11-01-2015  01:15:50 PM][mammenx] .

[11-01-2015  01:13:54 PM][mammenx] Added sys_mem_agent & fixed misc simulation issues

[06-12-2014  05:48:30 PM][mammenx] Added fft_sb to environment

[30-11-2014  05:57:00 PM][mammenx] Added syn_fft_cache_sb components

[30-11-2014  11:39:05 AM][mammenx] Added syn_but_sb

[18-11-2014  06:03:18 PM][mammenx] Removed MCLK feature testing and updated I2C agents

[02-11-2014  07:53:10 PM][mammenx] Misc changes for PCM Test

[02-11-2014  01:47:10 PM][mammenx] Modified for syn_env_pkg

[16-10-2014  09:47:25 PM][mammenx] Misc changes to fix issues found during syn_acortex_base_test

[16-10-2014  12:52:42 AM][mammenx] Fixed compilation errors

[15-10-2014  11:44:12 PM][mammenx] Initial Commit

 --------------------------------------------------------------------------
*/


