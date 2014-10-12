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
 -- Package Name      : lb_utils
 -- Author            : mammenx
 -- Description       : This defines a set of macros that can be used for
                        integration of Local Bus interfaces.
 --------------------------------------------------------------------------
*/

`infdef __LB_UTILS
`define __LB_UTILS 

  `define drop_lb_wires(LB_DATA_W,LB_ADDR_W,prefix,postfix) \
      wire                        prefix``_wr_en_``postfix;           \
      wire                        prefix``_rd_en_``postfix;           \
      wire    [LB_ADDR_W-1:0]     prefix``_addr_``postfix;            \
      wire    [LB_DATA_W-1:0]     prefix``_wr_data_``postfix;         \
      wire                        prefix``_wr_valid_``postfix;        \
      wire                        prefix``_rd_valid_``postfix;        \
      wire    [LB_DATA_W-1:0]     prefix``_rd_data_``postfix;         \


  `define drop_lb_ports(p_prefix,p_postfix,w_prefix,w_postfix)  \
      .p_prefix``_wr_en_``p_postfix       (w_prefix``_wr_en_``w_postfix   ),  \
      .p_prefix``_rd_en_``p_postfix       (w_prefix``_rd_en_``w_postfix   ),  \
      .p_prefix``_addr_``p_postfix        (w_prefix``_addr_``w_postfix    ),  \
      .p_prefix``_wr_data_``p_postfix     (w_prefix``_wr_data_``w_postfix ),  \
      .p_prefix``_wr_valid_``p_postfix    (w_prefix``_wr_valid_``w_postfix),  \
      .p_prefix``_rd_valid_``p_postfix    (w_prefix``_rd_valid_``w_postfix),  \
      .p_prefix``_rd_data_``p_postfix     (w_prefix``_rd_data_``w_postfix )   \

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[12-10-2014  10:02:19 PM][mammenx] Initial Commit

 --------------------------------------------------------------------------
*/
