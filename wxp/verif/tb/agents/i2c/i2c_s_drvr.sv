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
 -- Component Name    : i2c_s_drvr
 -- Author            : mammenx
 -- Function          : This class describes the behaviour of an I2C driver
                        that can act as a slave.
 --------------------------------------------------------------------------
*/

`ifndef __I2C_S_DRVR
`define __I2C_S_DRVR

  class i2c_s_drvr  #(parameter REG_MAP_W = 9,
                      parameter DATA_W    = 16,
                      type  INTF_TYPE     = virtual syn_wm8731_intf.TB_I2C
                    ) extends ovm_driver;

    INTF_TYPE intf;

    OVM_FILE  f;

    bit enable,update_reg_map_en;
    bit [7:0] dev_addr;

    bit[REG_MAP_W-1:0]  regmap_data;
    bit[DATA_W-REG_MAP_W-1:0] regmap_addr;
 
    /*  Register Map to hold registers  */
    syn_reg_map#(REG_MAP_W)   reg_map;  //must be connected from above

    mailbox start_det_sm,stop_det_sm,read_det_sm,write_det_sm;

    mailbox is_ack_phase_sm;

    int t;

    /*  Register with factory */
    `ovm_component_param_utils_begin(i2c_s_drvr#(REG_MAP_W,DATA_W,INTF_TYPE))
      `ovm_field_int(enable,  OVM_ALL_ON);
      `ovm_field_int(update_reg_map_en,  OVM_ALL_ON);
      `ovm_field_int(dev_addr,  OVM_ALL_ON);
    `ovm_component_utils_end


    /*  Constructor */
    function new( string name = "i2c_s_drvr" , ovm_component parent = null) ;
      super.new( name , parent );

      enable    = 1;  //by default enabled; disable from test case
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

      enable  = 1;
      update_reg_map_en  = 1;
      dev_addr  = 'h34;

      start_det_sm  = new(1);
      stop_det_sm   = new(1);
      read_det_sm   = new(1);
      write_det_sm  = new(1);

      is_ack_phase_sm = new(1);

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction : build


    /*  Run */
    task run();

      ovm_report_info({get_name(),"[run]"},"Start of run ",OVM_LOW);

      if(update_reg_map_en)
        ovm_report_info({get_name(),"[run]"},"Update reg_map is enabled",OVM_LOW);
      else
        ovm_report_info({get_name(),"[run]"},"Update reg_map is disabled",OVM_LOW);

      if(enable)
      begin
        intf.sda_o        <= 1;
        intf.release_sda  <= 1;

        @(posedge intf.rst_il);

        #1us;

        fork
          begin
            look_for_start();
          end

          begin
            look_for_stop();
          end

          begin
            get_address();
          end

          begin
            drive_write();
          end

          begin
            drive_read();
          end
        join
      end
      else
      begin
        ovm_report_info({get_name(),"[run]"},"i2c_s_drvr is disabled",OVM_LOW);
        ovm_report_info({get_name(),"[run]"},"Shutting down .....",OVM_LOW);
      end
    endtask : run


    task  look_for_start();

      ovm_report_info({get_name(),"[look_for_start]"},"Start of look_for_start",OVM_LOW);

      forever
      begin
        ovm_report_info({get_name(),"[look_for_start]"},"Looking for START",OVM_LOW);
        @(negedge intf.sda  iff (intf.scl ==  1));
        if(!is_ack_phase_sm.num())
        begin
          ovm_report_info({get_name(),"[look_for_start]"},"Detected START",OVM_LOW);
          start_det_sm.put(1);
        end
      end

    endtask : look_for_start

    task  look_for_stop();

      ovm_report_info({get_name(),"[look_for_stop]"},"Start of look_for_stop",OVM_LOW);

      forever
      begin
        ovm_report_info({get_name(),"[look_for_stop]"},"Looking for STOP",OVM_LOW);
        @(posedge intf.sda  iff (intf.scl ==  1));
        if(!is_ack_phase_sm.num())
        begin
          ovm_report_info({get_name(),"[look_for_stop]"},"Detected STOP",OVM_LOW);
          stop_det_sm.put(1);
        end
      end

    endtask : look_for_stop

    task  get_address();
      bit [7:0] addr;

      ovm_report_info({get_name(),"[get_address]"},"Start of get_address",OVM_LOW);

      forever
      begin
        ovm_report_info({get_name(),"[get_address]"},"Waiting for START",OVM_LOW);
        start_det_sm.get(t);
        ovm_report_info({get_name(),"[get_address]"},"Got START",OVM_LOW);

        addr  = 'd0;

        for(int i=0;i<8;i++)
        begin
          @(posedge intf.scl);
          #1;

          addr  = (addr <<  1)  + intf.sda; //sample address bits
        end

        ovm_report_info({get_name(),"[get_address]"},$psprintf("Got address : 0x%x",addr),OVM_LOW);
        is_ack_phase_sm.put(1);

        @(posedge intf.scl);

        if(addr[7:1]  ==  dev_addr[7:1])
        begin
          ovm_report_info({get_name(),"[get_address]"},$psprintf("Driving ACK"),OVM_LOW);

          intf.sda_o      <=  0;
          intf.release_sda<=  0;

          @(negedge intf.scl);

          intf.sda_o      <=  1;
          intf.release_sda<=  1;

          if(addr[0]) //Read
          begin
            read_det_sm.put(1);
          end
          else  //Write
          begin
            write_det_sm.put(1);
          end
        end
        else
        begin
          ovm_report_error({get_name(),"[get_address]"},$psprintf("Driving NACK"),OVM_LOW);
          intf.sda_o      <=  1;
          intf.release_sda<=  0;

          @(negedge intf.scl);

          intf.sda_o      <=  1;
          intf.release_sda<=  1;

          ovm_report_info({get_name(),"[get_address]"},$psprintf("Waiting for STOP"),OVM_LOW);
          stop_det_sm.get(t);
        end

        #1;
        is_ack_phase_sm.get(t);
      end
    endtask : get_address

    task  drive_write();
      bit[DATA_W-1:0] data;
      bit stop_det_f,start_det_f;
      int num_bytes;

      ovm_report_info({get_name(),"[drive_write]"},$psprintf("Start of drive_write"),OVM_LOW);

      forever
      begin
        ovm_report_info({get_name(),"[drive_write]"},$psprintf("Waiting on write_det_sm"),OVM_LOW);
        write_det_sm.get(t);
        ovm_report_info({get_name(),"[drive_write]"},$psprintf("Receiving write data"),OVM_LOW);

        data  = 'd0;
        stop_det_f  = 0;
        start_det_f = 0;
        num_bytes = 0;

        fork
          begin
            repeat(DATA_W / 8)
            begin
              for(int i=0;i<8;i++)
              begin
                @(posedge intf.scl);
                #1;

                data  = (data <<  1)  + intf.sda;
              end

              ovm_report_info({get_name(),"[drive_write]"},$psprintf("Data : 0x%x",data),OVM_LOW);
              num_bytes++;
              is_ack_phase_sm.put(1);
              @(posedge intf.scl);

              ovm_report_info({get_name(),"[drive_write]"},$psprintf("Driving ACK"),OVM_LOW);

              intf.sda_o      <=  0;
              intf.release_sda<=  0;

              @(negedge intf.scl);

              intf.sda_o      <=  1;
              intf.release_sda<=  1;

              #1;
              ovm_report_info({get_name(),"[drive_write]"},$psprintf("End of ACK"),OVM_LOW);
              is_ack_phase_sm.get(t);
            end

            regmap_addr = data[DATA_W-1:REG_MAP_W];
            regmap_data = data[REG_MAP_W-1:0];
            ovm_report_info({get_name(),"[drive_write]"},$psprintf("Updated regmap_addr to 0x%x",regmap_addr),OVM_LOW);
            ovm_report_info({get_name(),"[drive_write]"},$psprintf("Updated regmap_data to 0x%x",regmap_data),OVM_LOW);
          end

          begin
            do
            begin
              @(intf.scl);

              if(start_det_sm.num())
              begin
                start_det_sm.get(t);
                start_det_f = 1;
              end

              if(stop_det_sm.num())
              begin
                stop_det_sm.get(t);
                stop_det_f  = 1;
              end
            end
            while(!start_det_f  &&  ~stop_det_f);
          end
        join_any

        if(start_det_f)
        begin
          data  = data  >>  1;  //Discard last bit read
          regmap_addr = data  >>  (REG_MAP_W  % 8);
          ovm_report_info({get_name(),"[drive_write]"},$psprintf("Updated regmap_addr to 0x%x",regmap_addr),OVM_LOW);
          continue;
        end
        else if(stop_det_f)
        begin
          continue;
        end
        else if(update_reg_map_en)
        begin
          if(reg_map.chk_addr_exist(regmap_addr) ==  syn_reg_map#(REG_MAP_W)::SUCCESS)
          begin
            reg_map.set_reg(regmap_addr, regmap_data);
            ovm_report_info({get_name(),"[drive_write]"},$psprintf("Configured reg_map addr[0x%x] to 0x%x",regmap_addr,regmap_data),OVM_LOW);
          end
          else
          begin
            ovm_report_error({get_name(),"[drive_write]"},$psprintf("Invalid Regmap address 0x%x",regmap_addr),OVM_LOW);
          end
        end

        ovm_report_info({get_name(),"[drive_write]"},$psprintf("Waiting on stop_det_sm"),OVM_LOW);
        stop_det_sm.get(t);
      end
    endtask : drive_write


    task  drive_read();
      bit [DATA_W-1:0]  data;
      int temp;

      ovm_report_info({get_name(),"[drive_read]"},$psprintf("Start of drive_read"),OVM_LOW);

      forever
      begin
        ovm_report_info({get_name(),"[drive_read]"},$psprintf("Waiting on read_det_sm"),OVM_LOW);
        read_det_sm.get(t);

        data  = 'd0;

        if(reg_map.reg_arry.exists(regmap_addr))
        begin
          data[REG_MAP_W-1:0] = reg_map.reg_arry[regmap_addr];
          ovm_report_info({get_name(),"[drive_read]"},$psprintf("Driving read data 0x%x",data),OVM_LOW);
        end
        else
        begin
          ovm_report_error({get_name(),"[drive_read]"},$psprintf("Address 0x%x does not exist!",regmap_addr),OVM_LOW);
        end

        for(int i=0;i<(DATA_W/16);i++)  //byte swap
        begin
          temp  = data[(i*8)  +:  8];
          data[(i*8)  +:  8]    = data[DATA_W-1 -:  8];
          data[DATA_W-1 -:  8]  = temp;
        end
        ovm_report_info({get_name(),"[drive_read]"},$psprintf("Byte swapped data : 0x%x",data),OVM_LOW);

        repeat(DATA_W/8)
        begin
          for(int i=0;i<8;i++)
          begin
            intf.sda_o      <=  data[DATA_W-1:0];
            intf.release_sda<=  0;

            @(negedge intf.scl);

            data  = data  <<  1;
          end

          is_ack_phase_sm.put(1);
          #1;

          intf.sda_o      <=  1;
          intf.release_sda<=  1;
          @(negedge intf.scl);  //ACK from master

          intf.release_sda<=  0;
          #1;
          is_ack_phase_sm.get(t);
        end

        ovm_report_info({get_name(),"[drive_read]"},$psprintf("Waiting STOP"),OVM_LOW);
        stop_det_sm.get(t);
      end

      #1;
      intf.release_sda  <=  1;

    endtask : drive_read

  endclass  : i2c_s_drvr

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[18-11-2014  06:02:12 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
