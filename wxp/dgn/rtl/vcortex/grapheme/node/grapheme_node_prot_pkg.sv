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
 -- Package Name      : grapheme_node_prot_pkg
 -- Author            : mammenx
 -- Description       : This package defines the parameters & structures
                        used by the protocol followed by grapheme nodes.
 --------------------------------------------------------------------------
*/

package grapheme_node_prot_pkg;

  parameter GNODE_PROT_DATA_W     = 32;
  parameter GNODE_PROT_CMD_W      = 2;
  parameter GNODE_PROT_JOB_TYPE_W = 8;


  typedef enum  logic [GNODE_PROT_CMD_W-1:0] {
      IDLE      = 0
    , SOP       = 1
    , VALID     = 2
    , EOP       = 3
  } gnode_prot_cmd_t;

  typedef enum  logic [GNODE_PROT_JOB_TYPE_W-1:0] {
      READ_PXL      = 0
    , WRITE_PXL     = 1
    , READ_PXL_RSP  = 2
    , DRAW_LINE     = 3
  } gnode_prot_job_type_t;

  typedef struct  packed  {
      logic [7:0] job_id
    , gnode_prot_job_type_t job_type
    , logic [7:0] job_src
    , logic [7:0] job_dst
  } gnode_prot_hdr_t; //Total size should equal GNODE_PROT_DATA_W

endpackage  //  grapheme_node_prot_pkg

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[22-08-2015  01:42:44 AM][mammenx] Added READ_PXL_RSP code to job_type

 --------------------------------------------------------------------------
*/
