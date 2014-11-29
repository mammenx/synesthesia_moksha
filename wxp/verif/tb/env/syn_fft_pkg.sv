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
 -- Package Name      : syn_fft_pkg
 -- Author            : mammenx
 -- Description       : This package contains all the datatypes needed for
                        FFT.
 --------------------------------------------------------------------------
*/

package syn_fft_pkg;

  `define COMPLEX_STRUCT_T_DEF(WIDTH, NAME) \
    typedef struct  packed  { \
      logic [WIDTH-1:0] re; \
      logic [WIDTH-1:0] im; \
    } ``NAME``;


  parameter P_FFT_SAMPLE_W    = 32;
  parameter P_FFT_TWDL_W      = 10;

  `COMPLEX_STRUCT_T_DEF(P_FFT_SAMPLE_W, fft_sample_t)

  `COMPLEX_STRUCT_T_DEF(P_FFT_TWDL_W, fft_twdl_t)

  typedef enum  logic {NORMAL=1'b0,CONFIG=1'b1} fgyrus_mode_t;

endpackage  //  syn_fft_pkg

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[29-11-2014  10:36:46 PM][mammenx] Misc changes to stabilize Acorte scoreboards for PCM test

 --------------------------------------------------------------------------
*/


