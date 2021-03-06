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
 -- File Name         : pcm_bffr.c
 -- Author            : mammenx
 -- Function          : 
 --------------------------------------------------------------------------
*/

#include "pcm_bffr.h"
#include "alt_types.h"
#include "sys/alt_stdio.h"


void update_acache_mode(PCM_BFFR_MODE_T mode)	{
	IOWR_PCM_BFFR_CONTROL(mode & PCM_BFFR_MODE_MSK);
}

void dump_acache_cap_data(alt_u32 *lbffr, alt_u32 *rbffr)	{
	alt_u32	i;

	for(i=0; i<PCM_BFFR_NUM_SAMPLES; i++)	{
		IOWR_PCM_BFFR_CAP_ADDR(i);
		lbffr[i]	=	IORD_PCM_BFFR_CAP_DATA;

		IOWR_PCM_BFFR_CAP_ADDR(i+PCM_BFFR_NUM_SAMPLES);
		rbffr[i]	=	IORD_PCM_BFFR_CAP_DATA;
	}
}
