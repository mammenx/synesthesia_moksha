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
 -- Component Name    : syn_sys_mem_drvr
 -- Author            : mammenx
 -- Function          : This clas contains logic for modelling the system
                        memory.
 --------------------------------------------------------------------------
*/

`ifndef __SYN_SYS_MEM_DRVR
`define __SYN_SYS_MEM_DRVR

  class syn_sys_mem_drvr  #(parameter DATA_W  = 32,
                        parameter ADDR_W  = 27,
                        type  PKT_TYPE    = syn_sys_mem_seq_item,
                        type  INTF_TYPE   = virtual syn_sys_mem_intf
                      ) extends ovm_driver  #(PKT_TYPE,PKT_TYPE); //request, response

    INTF_TYPE intf;

    OVM_FILE  f;

    shortint  enable;

    bit [DATA_W-1:0]  sys_mem[int];  //Holds the memory contents

    int stall_freq_max; //Assert wait once in x clks [max]
    int stall_time_max; //Assert wait for x clks [max]

    mailbox rd_mb;
    int rd_delay_max;   //Max number of cycles to delay reads

    /*  Register with factory */
    `ovm_component_param_utils_begin(syn_sys_mem_drvr#(DATA_W, ADDR_W, PKT_TYPE, INTF_TYPE))
      `ovm_field_int(enable,  OVM_ALL_ON);
      `ovm_field_int(stall_freq_max,  OVM_ALL_ON);
      `ovm_field_int(stall_time_max,  OVM_ALL_ON);
      `ovm_field_int(rd_delay_max,  OVM_ALL_ON);
    `ovm_component_utils_end


    /*  Constructor */
    function new( string name = "syn_sys_mem_drvr" , ovm_component parent = null) ;
      super.new( name , parent );

      enable    = 1;  //by default enabled; disable from test case

      stall_freq_max  = 20;
      stall_time_max  = 4;

      rd_mb = new();  //un bounded
      rd_delay_max    = 0;
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


      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction : build


    /*  Run */
    task run();
      PKT_TYPE  pkt = new();
      PKT_TYPE  pkt_rsp;

      ovm_report_info({get_name(),"[run]"},"Start of run ",OVM_LOW);

      //Wait for reset  ...
      intf.cb_drvr.mem_wait     <=  0;
      intf.cb_drvr.mem_rd_valid <=  0;
      intf.cb_drvr.mem_rdata    <=  0;

      @(posedge intf.rst_il);

      if(enable)
      begin
        fork
          begin
            process_seq_item();
          end

          begin
            talk_to_dut();
          end
        join  //join_all
      end
      else
      begin
        ovm_report_info({get_name(),"[run]"},"syn_sys_mem_drvr is disabled",OVM_LOW);
        ovm_report_info({get_name(),"[run]"},"Shutting down .....",OVM_LOW);
      end
    endtask : run

    /*  Taks to accept sequence items & update memory */
    task  process_seq_item();
      PKT_TYPE  pkt = new();
      PKT_TYPE  pkt_rsp;
      int       mem_addr;

      forever
      begin
        ovm_report_info({get_name(),"[process_seq_item]"},"Waiting for seq_item",OVM_LOW);
        seq_item_port.get_next_item(pkt);

        ovm_report_info({get_name(),"[process_seq_item]"},$psprintf("Got seq_item - \n%s",pkt.sprint()),OVM_LOW);

        ovm_report_info({get_name(),"[process_seq_item]"},$psprintf("pkt.addr.size = %1d, pkt.data.size = %1d",pkt.addr.size,pkt.data.size),OVM_LOW);


        if(pkt.read_n_write ==  0)  //WRITE
        begin
          for(int i=0; i<pkt.addr.size; i++)
          begin
            $cast(mem_addr,pkt.addr[i]);
            sys_mem[mem_addr] = pkt.data[i];
            ovm_report_info({get_name(),"[process_seq_item]"},$psprintf("Updated sys_mem[%1d] to 0x%x",mem_addr,sys_mem[mem_addr]),OVM_LOW);
          end

          ovm_report_info({get_name(),"[process_seq_item]"},$psprintf("Updated sys_mem"),OVM_LOW);
        end
        else  //READ
        begin
          pkt_rsp = new();
          pkt_rsp.addr  = new[pkt.addr.size];
          pkt_rsp.data  = new[pkt.addr.size];

          foreach(pkt.addr[i])
          begin
            $cast(mem_addr,pkt.addr[i]);
            pkt_rsp.addr[i] = pkt.addr[i];
            pkt_rsp.data[i] = sys_mem[mem_addr];
          end

          //Send back response
          pkt_rsp.set_id_info(pkt);
          #1;
          seq_item_port.put_response(pkt_rsp);
        end

        seq_item_port.item_done();
      end
    endtask : process_seq_item

    /*  Task to interact with DUT */
    task  talk_to_dut();
      int mem_waddr;
      int mem_raddr;

      fork
        begin
          forever
          begin
            @(posedge intf.clk_ir);

            if(intf.cb_drvr.mem_wren  && ~intf.cb_drvr.mem_wait)
            begin
              $cast(mem_waddr,intf.cb_drvr.mem_addr);
              sys_mem[mem_waddr] = intf.cb_drvr.mem_wdata;
              //ovm_report_info({get_name(),"[talk_to_dut]"},$psprintf("Updated sys_mem[0x%x] to 0x%x",mem_waddr,sys_mem[mem_waddr]),OVM_LOW);
            end
            else if(intf.cb_drvr.mem_rden && ~intf.cb_drvr.mem_wait)
            begin
              $cast(mem_waddr,intf.cb_drvr.mem_addr); //Dont freak, I just want to re-use this variable
              rd_mb.put(mem_waddr);
            end
          end
        end

        begin
          forever
          begin
            intf.cb_drvr.mem_wait <=  0;

            repeat  ($urandom_range(stall_freq_max,0))  @(posedge intf.clk_ir);

            repeat  ($urandom_range(stall_time_max,0))
            begin
              intf.cb_drvr.mem_wait <=  1;
              @(posedge intf.clk_ir);
            end
          end
        end

        begin
          forever
          begin
            repeat  ($urandom_range(rd_delay_max,0))  @(posedge intf.clk_ir);

            rd_mb.get(mem_raddr);

            intf.cb_drvr.mem_rd_valid <=  1;

            //ovm_report_info({get_name(),"[talk_to_dut]"},$psprintf("Got mem_raddr : 0x%x",mem_raddr),OVM_LOW);

            if(sys_mem.exists(mem_raddr))
              intf.cb_drvr.mem_rdata  <=  sys_mem[mem_raddr];
            else
              intf.cb_drvr.mem_rdata  <=  'd0;

            @(posedge intf.clk_ir);

            intf.cb_drvr.mem_rd_valid <=  0;
          end
        end
      join

    endtask : talk_to_dut
 

  endclass  : syn_sys_mem_drvr

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[11-01-2015  05:33:26 PM][mammenx] Misc changes for debug

[11-01-2015  01:23:03 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
