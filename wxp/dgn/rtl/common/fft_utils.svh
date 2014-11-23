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
 -- Project Code      : synesthesia
 -- Package Name      : fft_utils
 -- Author            : mammenx
 -- Description       : This package contains all the datatypes needed for
                        FFT.
 --------------------------------------------------------------------------
*/


`ifndef __FFT_UTILS
`define __FFT_UTILS 

  `define drop_complex_set(TYPE,WIDTH,prefix,postfix)  \
      TYPE  [WIDTH-1:0] prefix``re``postfix;  \
      TYPE  [WIDTH-1:0] prefix``im``postfix;  \


  `define drop_complex_ports(p_prefix,p_postfix,w_prefix,w_postfix) \
      .p_prefix``re``p_postfix    (w_prefix``re``w_postfix),  \
      .p_prefix``im``p_postfix    (w_prefix``im``w_postfix)   \


  `define drop_fft_cache_data_intf_set(TYPE,SAMPLE_W,MEM_DATA_W,MEM_ADDR_W,prefix,postfix) \
      `drop_complex_set(TYPE,SAMPLE_W,prefix``wr_sample_,postfix);  \
      TYPE                    prefix``wr_en``postfix; \
      TYPE  [MEM_ADDR_W-1:0]  prefix``waddr``postfix; \
      TYPE  [MEM_ADDR_W-1:0]  prefix``raddr``postfix; \
      TYPE                    prefix``rd_en``postfix; \
      TYPE                    prefix``rd_valid``postfix; \
      `drop_complex_set(TYPE,SAMPLE_W,prefix``rd_sample_,postfix);  \
      TYPE                    prefix``fft_done``postfix; \


  `define drop_fft_cache_data_intf_ports(p_prefix,p_postfix,w_prefix,w_postfix) \
      `drop_complex_ports(p_prefix``wr_sample_,p_postfix,w_prefix``wr_sample_,w_postfix), \
      .p_prefix``wr_en``p_postfix       (w_prefix``wr_en``w_postfix), \
      .p_prefix``waddr``p_postfix       (w_prefix``waddr``w_postfix), \
      .p_prefix``raddr``p_postfix       (w_prefix``raddr``w_postfix), \
      .p_prefix``rd_en``p_postfix       (w_prefix``rd_en``w_postfix), \
      .p_prefix``rd_valid``p_postfix    (w_prefix``rd_valid``w_postfix),  \
      `drop_complex_ports(p_prefix``rd_sample_,p_postfix,w_prefix``rd_sample_,w_postfix), \
      .p_prefix``fft_done``p_postfix    (w_prefix``fft_done``w_postfix) \


`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

 --------------------------------------------------------------------------
*/

