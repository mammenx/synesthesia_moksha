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
 -- File Name         : sys_mem_intf.c
 -- Author            : mammenx
 -- Function          : 
 --------------------------------------------------------------------------
*/

#include "alt_types.h"
#include "sys/alt_stdio.h"
#include "system.h"
#include "sys_mem_intf.h"

void check_sys_mem_intf_errors()	{
	alt_u32	reg;

	reg = IORD_SYS_MEM_ARB_STATUS_REG;

	if(reg & SYS_MEM_ARB_EGR_BFFR_0_UNDERFLOW_MSK)	{
		alt_printf("[check_sys_mem_intf_errors] EGR_BFFR_0_UNDERFLOW Detected!\r\n");
	}

	if(reg & SYS_MEM_ARB_EGR_BFFR_0_OVERFLOW_MSK)	{
			alt_printf("[check_sys_mem_intf_errors] EGR_BFFR_0_OVERFLOW Detected!\r\n");
	}

	if(reg & SYS_MEM_ARB_EGR_BFFR_1_UNDERFLOW_MSK)	{
		alt_printf("[check_sys_mem_intf_errors] EGR_BFFR_1_UNDERFLOW Detected!\r\n");
	}

	if(reg & SYS_MEM_ARB_EGR_BFFR_0_OVERFLOW_MSK)	{
			alt_printf("[check_sys_mem_intf_errors] EGR_BFFR_1_OVERFLOW Detected!\r\n");
	}

	if(reg & SYS_MEM_ARB_INGR_BFFR_0_UNDERFLOW_MSK)	{
		alt_printf("[check_sys_mem_intf_errors] INGR_BFFR_0_UNDERFLOW Detected!\r\n");
	}

	if(reg & SYS_MEM_ARB_INGR_BFFR_0_OVERFLOW_MSK)	{
			alt_printf("[check_sys_mem_intf_errors] INGR_BFFR_0_OVERFLOW Detected!\r\n");
	}

	if(reg & SYS_MEM_ARB_INGR_BFFR_1_UNDERFLOW_MSK)	{
		alt_printf("[check_sys_mem_intf_errors] INGR_BFFR_1_UNDERFLOW Detected!\r\n");
	}

	if(reg & SYS_MEM_ARB_INGR_BFFR_0_OVERFLOW_MSK)	{
			alt_printf("[check_sys_mem_intf_errors] INGR_BFFR_1_OVERFLOW Detected!\r\n");
	}

	return;
}


void configure_sys_mem_intf_part(alt_u8 part_num, alt_u32 start_addr, alt_u32 end_addr)	{
	if(part_num >= SYS_MEM_INTF_PART_MNGR_SIZE)	{
		alt_printf("[configure_sys_mem_intf_part] ERROR part_num 0x%x exceeds table size 0x%x",part_num,SYS_MEM_INTF_PART_MNGR_SIZE);
		return;
	}

	if(start_addr > SYS_MEM_INTF_PART_MAX_ADDR)	{
		alt_printf("[configure_sys_mem_intf_part] ERROR start_addr 0x%x exceeds max addr 0x%x",start_addr,SYS_MEM_INTF_PART_MAX_ADDR);
		return;
	}

	if(end_addr > SYS_MEM_INTF_PART_MAX_ADDR)	{
		alt_printf("[configure_sys_mem_intf_part] ERROR end_addr 0x%x exceeds max addr 0x%x",end_addr,SYS_MEM_INTF_PART_MAX_ADDR);
		return;
	}

	IOWR_32DIRECT(CORTEX_BASE, (SYS_MEM_INTF_PART_MNGR_START_BASE+(part_num<<4)), start_addr);
	IOWR_32DIRECT(CORTEX_BASE, (SYS_MEM_INTF_PART_MNGR_END_BASE+(part_num<<4)), end_addr);

	return;
}
