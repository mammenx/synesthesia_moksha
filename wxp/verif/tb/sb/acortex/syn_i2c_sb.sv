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
 -- Component Name    : syn_i2c_sb
 -- Author            : mammenx
 -- Function          : This scoreboard checks if the I2C transactions
                        received by I2C monitor are the same as that
                        initiated by local bus.
 --------------------------------------------------------------------------
*/

`ifndef __SYN_I2C_SB
`define __SYN_I2C_SB

//Implicit port declarations
`ovm_analysis_imp_decl(_i2c_pkt)

  class syn_i2c_sb  #(parameter I2C_DATA_W= 16,
                      parameter LB_DATA_W = 32,
                      type  SENT_PKT_TYPE = syn_lb_seq_item,
                      type  RCVD_PKT_TYPE = syn_lb_seq_item
                    ) extends ovm_scoreboard;

    `include  "acortex_regmap.svh"
    `include  "i2c_master_regmap.svh"
 

    /*  Register with Factory */
    `ovm_component_param_utils(syn_i2c_sb#(I2C_DATA_W, LB_DATA_W, SENT_PKT_TYPE, RCVD_PKT_TYPE))

    //Queue to hold the sent pkts, till rcvd pkts come
    RCVD_PKT_TYPE sent_que[$];
    RCVD_PKT_TYPE rcvd_que[$];

    //Ports
    ovm_analysis_imp_i2c_pkt #(RCVD_PKT_TYPE,syn_i2c_sb#(I2C_DATA_W,LB_DATA_W,SENT_PKT_TYPE,RCVD_PKT_TYPE))  Mon_i2c_2Sb_port;

    OVM_FILE  f;

    semaphore lb_event;

    syn_reg_map#(LB_DATA_W) reg_map;  //To be connected to acortex_reg_map in acortex_env

    /*  Constructor */
    function new(string name = "syn_i2c_sb", ovm_component parent);
      super.new(name, parent);

      lb_event  = new(0);
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

      Mon_i2c_2Sb_port = new("Mon_i2c_2Sb_port", this);


      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction



    /*
      * Write I2C Pkt
      * This function will be called each time a pkt is written into [ovm_analysis_imp_i2c_pkt]Mon_i2c_2Sb_port
    */
    virtual function void write_i2c_pkt(input RCVD_PKT_TYPE pkt);
      ovm_report_info({get_name(),"[write_i2c_pkt]"},$psprintf("Received pkt\n%s",pkt.sprint()),OVM_LOW);

      //Push packet into rcvd queue
      rcvd_que.push_back(pkt);

      ovm_report_info({get_name(),"[write_i2c_pkt]"},$psprintf("There are %d items in rcvd_que[$]",rcvd_que.size()),OVM_LOW);
    endfunction : write_i2c_pkt


    /*  Run */
    task run();
      RCVD_PKT_TYPE expctd_pkt,actual_pkt,i2c_pkt;
      ovm_report_info({get_name(),"[run]"},"Start of run",OVM_LOW);

      fork
        begin
          forever
          begin
            //Wait for items to arrive in sent & rcvd queues
            ovm_report_info({get_name(),"[run]"},"Waiting on queues ...",OVM_LOW);
            while(!rcvd_que.size())  #1;

            actual_pkt  = rcvd_que.pop_front();

            if(sent_que.size())
            begin
              expctd_pkt  = sent_que.pop_front();
            end
            else
            begin
              ovm_report_error({get_name(),"[run]"},"Unexpected xtn!",OVM_LOW);
              continue;
            end


            if(expctd_pkt.check(actual_pkt))
              ovm_report_info({get_name(),"[run]"},"I2C Transaction is correct",OVM_LOW);
            else
              ovm_report_error({get_name(),"[run]"},"I2C Transaction is incorrect",OVM_LOW);
          end
        end

        begin
          forever
          begin
            ovm_report_info({get_name(),"[run]"},"Waiting for LB xtns",OVM_LOW);
            lb_event.get(1);

            if(reg_map.get_field("i2c_init")  ==  1)
            begin
              reg_map.set_field("i2c_init",0);  //clear this bit because DUT does

              i2c_pkt = new();
              i2c_pkt.addr  = new[1];
              i2c_pkt.data  = new[I2C_DATA_W/8];

              $cast(i2c_pkt.addr[0],  reg_map.get_field("i2c_addr"));

              foreach(i2c_pkt.data[i])
              begin
                $cast(i2c_pkt.data[i],  reg_map.get_field($psprintf("i2c_data_%1d",i)));
              end

              if(reg_map.get_field("i2c_rd_n_wr") ==  1)
              begin
                i2c_pkt.lb_xtn  = READ;
              end
              else
              begin
                i2c_pkt.lb_xtn  = WRITE;
              end

              //Push packet into sent queue
              ovm_report_info({get_name(),"[run]"},$psprintf("Adding pkt to sent_que[$]\n%s",i2c_pkt.sprint()),OVM_LOW);
              sent_que.push_back(i2c_pkt);

              #1;
            end
          end
        end
      join

    endtask : run


    /*  Report  */
    virtual function void report();
      ovm_report_info({get_type_name(),"[report]"},$psprintf("Report -\n%s", this.sprint()), OVM_LOW);
    endfunction : report

  endclass : syn_i2c_sb

`endif


/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[16-10-2014  09:47:25 PM][mammenx] Misc changes to fix issues found during syn_acortex_base_test

[16-10-2014  12:52:42 AM][mammenx] Fixed compilation errors

[15-10-2014  11:44:12 PM][mammenx] Initial Commit

 --------------------------------------------------------------------------
*/
