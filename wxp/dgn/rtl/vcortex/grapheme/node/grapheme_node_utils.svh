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
 -- Package Name      : grapheme_node_utils
 -- Author            : mammenx
 -- Description       : This defines a set of macros that can be used for
                        integration of grapheme nodes.
 --------------------------------------------------------------------------
*/

`ifndef __GRAPHEME_NODE_UTILS
`define __GRAPHEME_NODE_UTILS 

  `define drop_gnode_wires(NUM_NODES,CMD_TYPE,DATA_W,prefix,postfix) \
    CMD_TYPE              prefix``cmd``postfix  [NUM_NODES-1:0];  \
    wire  [DATA_W-1:0]    prefix``data``postfix [NUM_NODES-1:0];  \
    wire  [NUM_NODES-1:0] prefix``ready``postfix; \


  `define drop_gnode_ports(p_prefix,p_postfix,w_prefix,w_postfix) \
     .p_prefix``cmd``p_postfix      (w_prefix``cmd``w_postfix)    \
    ,.p_prefix``data``p_postfix     (w_prefix``data``w_postfix)   \
    ,.p_prefix``ready``p_postfix    (w_prefix``ready``w_postfix)  \


`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[22-08-2015  02:58:53 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
