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

`ifndef __LB_UTILS
`define __LB_UTILS 

  `define drop_lb_wires(LB_DATA_W,LB_ADDR_W,prefix,postfix) \
      wire                        prefix``wr_en``postfix;           \
      wire                        prefix``rd_en``postfix;           \
      wire    [LB_ADDR_W-1:0]     prefix``addr``postfix;            \
      wire    [LB_DATA_W-1:0]     prefix``wr_data``postfix;         \
      wire                        prefix``wr_valid``postfix;        \
      wire                        prefix``rd_valid``postfix;        \
      wire    [LB_DATA_W-1:0]     prefix``rd_data``postfix;         \


  `define drop_lb_ports(p_prefix,p_postfix,w_prefix,w_postfix)  \
      .p_prefix``wr_en``p_postfix       (w_prefix``wr_en``w_postfix   ),  \
      .p_prefix``rd_en``p_postfix       (w_prefix``rd_en``w_postfix   ),  \
      .p_prefix``addr``p_postfix        (w_prefix``addr``w_postfix    ),  \
      .p_prefix``wr_data``p_postfix     (w_prefix``wr_data``w_postfix ),  \
      .p_prefix``wr_valid``p_postfix    (w_prefix``wr_valid``w_postfix),  \
      .p_prefix``rd_valid``p_postfix    (w_prefix``rd_valid``w_postfix),  \
      .p_prefix``rd_data``p_postfix     (w_prefix``rd_data``w_postfix )   \


  `define drop_lb_splitter_wires(LB_DATA_W,LB_ADDR_W,NUM_CHILDREN,prefix,postfix) \
      wire    [NUM_CHILDREN-1:0]  prefix``wr_en``postfix;           \
      wire    [NUM_CHILDREN-1:0]  prefix``rd_en``postfix;           \
      wire    [LB_ADDR_W-1:0]     prefix``addr``postfix [NUM_CHILDREN-1:0]; \
      wire    [LB_DATA_W-1:0]     prefix``wr_data``postfix [NUM_CHILDREN-1:0]; \
      wire    [NUM_CHILDREN-1:0]  prefix``wr_valid``postfix;        \
      wire    [NUM_CHILDREN-1:0]  prefix``rd_valid``postfix;        \
      wire    [LB_DATA_W-1:0]     prefix``rd_data``postfix [NUM_CHILDREN-1:0]; \


  `define drop_lb_ports_split(CHILD_ID,p_prefix,p_postfix,w_prefix,w_postfix)  \
      .p_prefix``wr_en``p_postfix       (w_prefix``wr_en``w_postfix[CHILD_ID]   ),  \
      .p_prefix``rd_en``p_postfix       (w_prefix``rd_en``w_postfix[CHILD_ID]   ),  \
      .p_prefix``addr``p_postfix        (w_prefix``addr``w_postfix[CHILD_ID]    ),  \
      .p_prefix``wr_data``p_postfix     (w_prefix``wr_data``w_postfix[CHILD_ID] ),  \
      .p_prefix``wr_valid``p_postfix    (w_prefix``wr_valid``w_postfix[CHILD_ID]),  \
      .p_prefix``rd_valid``p_postfix    (w_prefix``rd_valid``w_postfix[CHILD_ID]),  \
      .p_prefix``rd_data``p_postfix     (w_prefix``rd_data``w_postfix[CHILD_ID] )   \


`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[14-10-2014  12:47:57 AM][mammenx] Fixed compilation errors & warnings

[13-10-2014  10:31:24 PM][mammenx] Added lb_splitter related macros

[12-10-2014  10:02:19 PM][mammenx] Initial Commit

 --------------------------------------------------------------------------
*/
