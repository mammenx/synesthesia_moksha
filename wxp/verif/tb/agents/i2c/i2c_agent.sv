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
 -- Component Name    : i2c_agent
 -- Author            : mammenx
 -- Function          : This agent holds the I2C driver, monitor.
 --------------------------------------------------------------------------
*/

`ifndef __I2C_AGENT
`define __I2C_AGENT

  class i2c_agent #(
                    parameter REG_MAP_W = 9,
                    parameter DATA_W    = 16,
                    type  PKT_TYPE  = syn_lb_seq_item,
                    type  INTF_TYPE     = virtual syn_wm8731_intf.TB_I2C
                  ) extends ovm_component;

    /*  Register with factory */
    `ovm_component_utils(i2c_agent#(REG_MAP_W,DATA_W,PKT_TYPE,INTF_TYPE))


    //Declare Seqr, Drvr, Mon, Sb objects
    i2c_s_drvr#(REG_MAP_W,DATA_W,INTF_TYPE)   s_drvr;
    i2c_mon#(DATA_W,PKT_TYPE,INTF_TYPE)       mon;

    OVM_FILE  f;


    /*  Constructor */
    function new(string name  = "i2c_agent", ovm_component parent = null);
      super.new(name, parent);
    endfunction: new


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

      //Build Seqr, Drvr, Mon, Sb objects using Factory
      s_drvr  = i2c_s_drvr#(REG_MAP_W,DATA_W,INTF_TYPE)::type_id::create("s_drvr",  this);
      mon     = i2c_mon#(DATA_W,PKT_TYPE,INTF_TYPE)::type_id::create("mon", this);

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction


    /*  Connect */
    function void connect();
      super.connect();

      ovm_report_info(get_name(),"START of connect ",OVM_LOW);

        //Make port connections
        //eg. : mon.Mon2Sb_port.connect(sb.Mon2Sb_port);

      ovm_report_info(get_name(),"END of connect ",OVM_LOW);
    endfunction


    /*  Disable Agent */
    function  void  disable_agent();
      s_drvr.enable = 0;
      mon.enable    = 0;

      ovm_report_info(get_name(),"Disabled myself & kids ...",OVM_LOW);
    endfunction : disable_agent



  endclass  : i2c_agent

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[18-11-2014  06:02:12 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
