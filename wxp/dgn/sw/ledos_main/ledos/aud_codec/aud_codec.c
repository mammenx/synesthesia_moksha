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
 -- File Name         : aud_codec.c
 -- Author            : mammenx
 -- Function          : 
 --------------------------------------------------------------------------
*/


#include "aud_codec.h"
#include "../cortex/acortex/acortex.h"
#include "alt_types.h"
#include "sys/alt_stdio.h"
#include "ch.h"


I2C_RES	aud_codec_write_reg(alt_u8 addr, alt_u16 val)	{
	aud_codec_i2c_bffr.byte_arry[0]	=	val & 0xff;
	aud_codec_i2c_bffr.byte_arry[1]	=	((addr & AUD_CODEC_ADDR_MSK) << AUD_CODEC_ADDR_OFFSET) + ((val & 0x100) >> 8);

	return i2c_xtn_write(AUD_CODEC_I2C_WRITE_ADDR,aud_codec_i2c_bffr.byte_arry,2,1,1);
}

I2C_RES	aud_codec_read_reg(alt_u8 addr, alt_u16 *val)	{
	aud_codec_i2c_bffr.byte_arry[0]	=	(addr & AUD_CODEC_ADDR_MSK) << 1;

	if(i2c_xtn_write(AUD_CODEC_I2C_WRITE_ADDR,aud_codec_i2c_bffr.byte_arry,1,1,0))	{
		return I2C_ERROR;
	}

	if(i2c_xtn_read(AUD_CODEC_I2C_READ_ADDR,aud_codec_i2c_bffr.byte_arry,2,1,1))	{
		return I2C_ERROR;
	}

	aud_codec_i2c_bffr.val	=	aud_codec_i2c_bffr.val	&	AUD_CODEC_DATA_MSK;

	return I2C_OK;
}


