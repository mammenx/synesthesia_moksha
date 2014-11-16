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
 -- Header Name       : pcm_bffr.h
 -- Author            : mammenx
 -- Function          : 
 --------------------------------------------------------------------------
*/

#ifndef PCM_BFFR_H_
#define PCM_BFFR_H_

#include <io.h>
#include "system.h"
#include "alt_types.h"


#define	PCM_BFFR_BASE_ADDRESS	0x02000
#define	PCM_BFFR_NUM_SAMPLES	128

//PCM Buffer Register Addresses
#define	PCM_BFFR_CONTROL_REG_ADDR   0x02000
#define PCM_BFFR_STATUS_REG_ADDR    0x02010
#define PCM_BFFR_CAP_ADDR_REG_ADDR  0x02020
#define PCM_BFFR_CAP_DATA_REG_ADDR  0x02030

//Field Masks
#define	PCM_BFFR_MODE_OFFSET		0
#define	PCM_BFFR_MODE_MSK			0x1
#define	PCM_BFFR_CAP_DONE_OFFSET	0
#define	PCM_BFFR_CAP_DONE_MSK		0x1

//Read PCM Buffer Registers
#define	IORD_PCM_BFFR_CONTROL				\
		IORD_32DIRECT(CORTEX_BASE, PCM_BFFR_CONTROL_REG_ADDR)

#define	IORD_PCM_BFFR_STATUS				\
		IORD_32DIRECT(CORTEX_BASE, PCM_BFFR_STATUS_REG_ADDR)

#define	IORD_PCM_BFFR_CAP_ADDR				\
		IORD_32DIRECT(CORTEX_BASE, PCM_BFFR_CAP_ADDR_REG_ADDR)

#define	IORD_PCM_BFFR_CAP_DATA				\
		IORD_32DIRECT(CORTEX_BASE, PCM_BFFR_CAP_DATA_REG_ADDR)

//Write PCM Buffer Registers
#define	IOWR_PCM_BFFR_CONTROL(data)		\
		IOWR_32DIRECT(CORTEX_BASE, PCM_BFFR_CONTROL_REG_ADDR, data)

#define	IOWR_PCM_BFFR_CAP_ADDR(data)		\
		IOWR_32DIRECT(CORTEX_BASE, PCM_BFFR_CAP_ADDR_REG_ADDR, data)


typedef enum{
	PCM_BFFR_MODE_NORMAL  = 0,
	PCM_BFFR_MODE_CAPTURE = 1
}PCM_BFFR_MODE_T;

void update_acache_mode(PCM_BFFR_MODE_T mode);
void dump_acache_cap_data(alt_u32 *lbffr, alt_u32 *rbffr);


#endif /* PCM_BFFR_H_ */

