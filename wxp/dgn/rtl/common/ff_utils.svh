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
 -- Package Name      : ff_utils
 -- Author            : mammenx
 -- Description       : This defines a set of macros that can be used for
                        integration of fifo interfaces.
 --------------------------------------------------------------------------
*/

`ifndef __FF_UTILS
`define __FF_UTILS 

  `define drop_ff_rd_wires(DATA_W,prefix,postfix) \
      wire                prefix``rd_en``postfix; \
      wire  [DATA_W-1:0]  prefix``rdata``postfix; \
      wire                prefix``empty``postfix; \


  `define drop_ff_wr_wires(DATA_W,prefix,postfix) \
      wire                prefix``wr_en``postfix; \
      wire  [DATA_W-1:0]  prefix``wdata``postfix; \
      wire                prefix``empty``postfix; \


  `define drop_ff_rd_ports(p_prefix,p_postfix,w_prefix,w_postfix)  \
      .p_prefix``rd_en``p_postfix        (w_prefix``rd_en``w_postfix   ),  \
      .p_prefix``rdata``p_postfix        (w_prefix``rdata``w_postfix   ),  \
      .p_prefix``empty``p_postfix        (w_prefix``empty``w_postfix   )   \


  `define drop_ff_wr_ports(p_prefix,p_postfix,w_prefix,w_postfix)  \
      .p_prefix``wr_en``p_postfix        (w_prefix``wr_en``w_postfix   ),  \
      .p_prefix``wdata``p_postfix        (w_prefix``wdata``w_postfix   ),  \
      .p_prefix``full``p_postfix         (w_prefix``full``w_postfix    )   \


`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[08-01-2015  05:35:13 PM][mammenx] Fixed compilation issues

[17-12-2014  01:21:20 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
