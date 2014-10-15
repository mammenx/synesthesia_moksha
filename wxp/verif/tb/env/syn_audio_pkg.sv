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
 -- Package Name      : syn_audio_pkg
 -- Author            : mammenx
 -- Description       : This package contains definitions of all Audio
                        related structures & types.
 --------------------------------------------------------------------------
*/

package syn_audio_pkg;

  parameter PCM_DATA_W  = 32;

  //PCM Data structure
  typedef struct  packed  {
    logic [PCM_DATA_W-1:0]  lchnnl;
    logic [PCM_DATA_W-1:0]  rchnnl;
  } pcm_data_t;

  //Bits Per Sample data type
  typedef enum  logic {
                        BPS_16=1'b0,
                        BPS_32
                      } bps_t;

  typedef enum  logic {
                        NORMAL=1'b0,
                        CAPTURE
                      } acache_mode_t;

endpackage  //  syn_audio_pkg


/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[15-10-2014  11:44:12 PM][mammenx] Initial Commit

 --------------------------------------------------------------------------
*/


