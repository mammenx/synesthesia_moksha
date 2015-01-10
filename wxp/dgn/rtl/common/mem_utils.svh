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
 -- Package Name      : mem_utils
 -- Author            : mammenx
 -- Description       : This defines a set of macros that can be used for
                        integration of memory interfaces.
 --------------------------------------------------------------------------
*/

`ifndef __MEM_UTILS
`define __MEM_UTILS 

  `define drop_mem_wires(DATA_W,ADDR_W,prefix,postfix) \
      wire                        prefix``wren``postfix;           \
      wire                        prefix``rden``postfix;           \
      wire    [ADDR_W-1:0]        prefix``addr``postfix;            \
      wire    [DATA_W-1:0]        prefix``wdata``postfix;         \
      wire                        prefix``rd_valid``postfix;        \
      wire    [DATA_W-1:0]        prefix``rdata``postfix;         \


  `define drop_mem_ports(p_prefix,p_postfix,w_prefix,w_postfix)  \
      .p_prefix``wren``p_postfix        (w_prefix``wren``w_postfix   ),  \
      .p_prefix``rden``p_postfix        (w_prefix``rden``w_postfix   ),  \
      .p_prefix``addr``p_postfix        (w_prefix``addr``w_postfix    ),  \
      .p_prefix``wdata``p_postfix       (w_prefix``wdata``w_postfix ),  \
      .p_prefix``rd_valid``p_postfix    (w_prefix``rd_valid``w_postfix),  \
      .p_prefix``rdata``p_postfix       (w_prefix``rdata``w_postfix )   \


  `define drop_mem_wires_multi(DATA_W,ADDR_W,DIM_W,prefix,postfix) \
      wire    [DIM_W-1:0]         prefix``wren``postfix;           \
      wire    [DIM_W-1:0]         prefix``rden``postfix;           \
      wire    [ADDR_W-1:0]        prefix``addr``postfix [DIM_W-1:0];  \
      wire    [DATA_W-1:0]        prefix``wdata``postfix [DIM_W-1:0]; \
      wire    [DIM_W-1:0]         prefix``rd_valid``postfix;        \
      wire    [DATA_W-1:0]        prefix``rdata``postfix [DIM_W-1:0]; \


`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[10-01-2015  07:16:28 PM][mammenx] Added new macro for dropping multidimensional wires


 --------------------------------------------------------------------------
*/
