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
 -- Package Name      : syn_env_pkg
 -- Author            : mammenx
 -- Description       : This package contains common environment tasks.
 --------------------------------------------------------------------------
*/

package syn_env_pkg;

  //Local Bus parameters
  parameter LB_DATA_W   = 32;
  parameter LB_BASE_W   = 8;
  parameter LB_BLK_0_W  = 4;
  parameter LB_BLK_1_W  = 4;
  parameter LB_ADDR_W   = LB_BLK_1_W  + LB_BLK_0_W  + LB_BASE_W;

  //Function to build address from components
  function  bit[LB_ADDR_W-1:0]  build_addr(input  int blk1,blk0,base);
    bit [LB_ADDR_W-1:0] res;

    res[LB_BASE_W-1:0]                    = base;
    res[LB_BLK_0_W+LB_BASE_W-1:LB_BASE_W] = blk0;
    res[LB_ADDR_W-1:LB_BLK_0_W+LB_BASE_W] = blk1;

    return  res;
  endfunction : build_addr

endpackage  //  syn_env_pkg


/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[02-11-2014  01:24:12 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/


