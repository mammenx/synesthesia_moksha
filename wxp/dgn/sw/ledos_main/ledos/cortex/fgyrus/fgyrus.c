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
 -- Header Name       : fgyrus.c
 -- Author            : mammenx
 -- Function          : 
 --------------------------------------------------------------------------
*/

#include "fgyrus.h"
#include "alt_types.h"
#include "sys/alt_stdio.h"
#include "system.h"

void disable_fgyrus(){
	IOWR_FGYRUS_CTRL(IORD_FGYRUS_CTRL & ~FGYRUS_EN_MSK);
}

void enable_fgyrus(){
	IOWR_FGYRUS_CTRL((IORD_FGYRUS_CTRL & ~FGYRUS_EN_MSK) + FGYRUS_EN_MSK);
}

void update_fgyrus_mode(FGYRUS_MODE_T mode){
	IOWR_FGYRUS_CTRL((IORD_FGYRUS_CTRL & ~FGYRUS_MODE_MSK) + mode);
}

FGYRUS_MODE_T get_fgyrus_mode(){
	return IORD_FGYRUS_CTRL & FGYRUS_MODE_MSK;
}

FGYRUS_STATUS_T get_fgyrus_status(){
	alt_u32 reg	=	IORD_FGYRUS_STATUS;

	if(reg & FGYRUS_BUT_OFLW_MSK)	return FGYRUS_BUT_OFLW;
	if(reg & FGYRUS_BUT_UFLW_MSK)	return FGYRUS_BUT_UFLW;
	if(reg & FGYRUS_BUSY_MSK)		return FGYRUS_BUSY;
	if(reg & FGYRUS_FFT_DONE_MSK)	return FGYRUS_FFT_DONE;
	return FGYRUS_IDLE;
}

void dump_fgyrus_win_ram(alt_u32* bffr){
	alt_u16 i;

	for(i=0; i<FGYRUS_WIN_RAM_SIZE; i++)
		bffr[i] = IORD_32DIRECT(CORTEX_BASE, (FGYRUS_WIN_RAM_BASE+(i<<4)));
}

void dump_fgyrus_twdl_ram(alt_u32* bffr){
	alt_u16 i;

	for(i=0; i<FGYRUS_TWDL_RAM_SIZE; i++)
		bffr[i] = IORD_32DIRECT(CORTEX_BASE, (FGYRUS_TWDL_RAM_BASE+(i<<4)));

}

void dump_fgyrus_cordic_ram(alt_u16* bffr){
	alt_u16 i;

	for(i=0; i<FGYRUS_CORDIC_RAM_SIZE; i++)
		bffr[i] = IORD_32DIRECT(CORTEX_BASE, (FGYRUS_CORDIC_RAM_BASE+(i<<4)));

}

/*
 * This function reads the FFT data from FFT cache into the given buffers
 * num should be less than FGYRUS_FFT_LEN
 */
void dump_fgyrus_fft_cache(alt_u32* lbffr, alt_u32*rbffr, alt_u8 num){
	alt_u16 i;
	alt_u16 offset;

	for(i=0, offset=0x000; i<num; i++, offset=offset+0x10)	//read LChannel FFT data
		lbffr[i] = IORD_32DIRECT(CORTEX_BASE, (FGYRUS_FFT_CACHE_BASE+ offset));

	for(i=0, offset=0x800; i<num; i++, offset=offset+0x10)	//read RChannel FFT data
		rbffr[i] = IORD_32DIRECT(CORTEX_BASE, (FGYRUS_FFT_CACHE_BASE+ offset));

}
