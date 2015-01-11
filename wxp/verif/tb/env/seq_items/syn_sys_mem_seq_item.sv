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
 -- Component Name    : syn_sys_mem_seq_item
 -- Author            : mammenx
 -- Function          : This class describes a typical system memory transaction
                        item.
 --------------------------------------------------------------------------
*/

`ifndef __SYN_SYS_MEM_SEQ_ITEM
`define __SYN_SYS_MEM_SEQ_ITEM


  class syn_sys_mem_seq_item  #(parameter DATA_W  = 32,
                                parameter ADDR_W  = 27
                              ) extends ovm_sequence_item;

    //fields
    rand  bit [ADDR_W-1:0]  addr[];
    rand  bit [DATA_W-1:0]  data[];
    rand  bit               read_n_write;

    //registering with factory
    `ovm_object_param_utils_begin(syn_sys_mem_seq_item#(DATA_W,ADDR_W))
      `ovm_field_array_int(addr,  OVM_ALL_ON | OVM_HEX);
      `ovm_field_array_int(data,  OVM_ALL_ON | OVM_HEX);
      `ovm_field_int(read_n_write,  OVM_ALL_ON | OVM_HEX);
    `ovm_object_utils_end

    /*  Constructor */
    function new(string name = "syn_sys_mem_seq_item");
      super.new(name);
    endfunction : new


    /*  Constraint  Block */

    /*  Function to check a pkt of same type */
    function  bit check (input  syn_sys_mem_seq_item#(DATA_W,ADDR_W) item);

      if(this.addr.size !=  item.addr.size) return  0;

      if(this.data.size !=  item.data.size) return  0;

      foreach(this.addr[i])
      begin
        if(this.addr[i] !=  item.addr[i])   return  0;
      end

      foreach(this.data[i])
      begin
        if(this.data[i] !=  item.data[i])   return  0;
      end

      return  1;

    endfunction : check

    function  string  checkString (input  syn_sys_mem_seq_item#(DATA_W,ADDR_W) item);
      string  res = "";

      if(this.addr.size !=  item.addr.size)
      begin
        $psprintf("%s\nExpected addr.size[%1d], Actual addr.size[%1d]",res,this.addr.size,item.addr.size);
      end
      else
      begin
        for(int i=0;  i<this.addr.size; i++)
        begin
          if(this.addr[i] !=  item.addr[i]) res = $psprintf("%s\nExpected addr[%1d]:0x%x, Actual addr[%1d]:0x%x",res,i,this.addr[i],i,item.addr[i]);
        end
      end

      if(this.data.size !=  item.data.size)
      begin
        $psprintf("%s\nExpected data.size[%1d], Actual data.size[%1d]",res,this.data.size,item.data.size);
      end
      else
      begin
        for(int k=0;  k<this.data.size; k++)
        begin
          if(this.data[k] !=  item.data[k]) res = $psprintf("%s\nExpected data[%1d]:0x%x, Actual data[%1d]:0x%x",res,k,this.data[k],k,item.data[k]);
        end
      end

      return  res;

    endfunction : checkString


  endclass  : syn_sys_mem_seq_item

`endif


/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[11-01-2015  01:23:03 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/


