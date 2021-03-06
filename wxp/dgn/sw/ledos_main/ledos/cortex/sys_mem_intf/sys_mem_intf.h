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
 -- Header Name       : sys_mem_intf.h
 -- Author            : mammenx
 -- Function          : 
 --------------------------------------------------------------------------
*/

#ifndef SYS_MEM_INTF_H_
#define SYS_MEM_INTF_H_

#include <io.h>
#include "system.h"
#include "alt_types.h"

#define	SYS_MEM_INTF_ARB_BASE				0x20000
#define	SYS_MEM_INTF_PART_MNGR_BASE			0x21000
#define	SYS_MEM_INTF_PART_MNGR_START_BASE	0x21000
#define	SYS_MEM_INTF_PART_MNGR_END_BASE		0x21200

//Size of Partition Manager Table
#define	SYS_MEM_INTF_PART_MNGR_SIZE		32
#define	SYS_MEM_INTF_PART_MAX_ADDR		268435455

//System Memory Interface Arbiter Register Addresses
#define	SYS_MEM_ARB_STATUS_REG_ADDR	0x20000

//System Memory Interface Arbiter Field Masks
#define	SYS_MEM_ARB_EGR_BFFR_0_UNDERFLOW_MSK		0x1
#define	SYS_MEM_ARB_EGR_BFFR_0_OVERFLOW_MSK			0x2
#define	SYS_MEM_ARB_EGR_BFFR_1_UNDERFLOW_MSK		0x4
#define	SYS_MEM_ARB_EGR_BFFR_1_OVERFLOW_MSK			0x8
#define	SYS_MEM_ARB_INGR_BFFR_0_UNDERFLOW_MSK		0x10
#define	SYS_MEM_ARB_INGR_BFFR_0_OVERFLOW_MSK		0x20
#define	SYS_MEM_ARB_INGR_BFFR_1_UNDERFLOW_MSK		0x40
#define	SYS_MEM_ARB_INGR_BFFR_1_OVERFLOW_MSK		0x80

//Read System Memory Interface Arbiter Registers
#define	IORD_SYS_MEM_ARB_STATUS_REG			\
		IORD_32DIRECT(CORTEX_BASE, SYS_MEM_ARB_STATUS_REG_ADDR)


void check_sys_mem_intf_errors();
void configure_sys_mem_intf_part(alt_u8 part_num, alt_u32 start_addr, alt_u32 end_addr);

#endif /* SYS_MEM_INTF_H_ */

