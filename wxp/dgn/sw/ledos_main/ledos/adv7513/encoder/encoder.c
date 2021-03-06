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
 -- File Name         : encoder.c
 -- Author            : mammenx
 -- Function          : 
 --------------------------------------------------------------------------
*/

#include "../adv7513_common.h"
#include "../../cortex/acortex/i2c/i2c.h"
#include "system.h"
#include "encoder.h"

//#define REG_ACCESS_UDELAY  5000

int reg_read(struct hdmi_encoder *ec, int reg, void *data)
{
	alt_u8 * regv = (alt_u8 *)data;

	adv7513_i2c_bffr.byte_arry[0] = reg & 0xff;

	if(i2c_xtn_write(ec->slave_addr,adv7513_i2c_bffr.byte_arry,1,1,0))	{
		return -1;
	}

	if(i2c_xtn_read(ec->slave_addr,adv7513_i2c_bffr.byte_arry,1,1,1))	{
		return -1;
	}

	*regv = adv7513_i2c_bffr.byte_arry[0];

	return 0;
}

int reg_write(struct hdmi_encoder *ec, int reg, int data)
{
	adv7513_i2c_bffr.val = ((data & 0xff) << 8) + (reg & 0xff);

	if(i2c_xtn_write(ec->slave_addr,adv7513_i2c_bffr.byte_arry,2,1,1))	{
		return -1;
	}

	return 0;
}

int reg_update_bits(struct hdmi_encoder *ec, int reg, int mask, int data)
{
	alt_u8 regv = 0;

	if(reg_read(ec,reg,&regv) < 0)
		return -1;

	regv &= ~((alt_u8)mask);

	regv |= ((alt_u8)data & (alt_u8)mask);

	if(reg_write(ec,reg,regv))
		return -1;

	return 0;
}

int reg_or_bits(struct hdmi_encoder *ec, int reg, int data)
{
	alt_u8 regv = 0;

	if(reg_read(ec,reg,&regv) < 0)
		return -1;

	regv |= (alt_u8)data;


	if(reg_write(ec,reg,regv))
		return -1;

	return 0;
}

int reg_clear_bits(struct hdmi_encoder *ec, int reg, int mask)
{
	alt_u8 regv = 0;

	if(reg_read(ec,reg,&regv) < 0)
		return -1;

	regv &= ~((alt_u8)mask);


	if(reg_write(ec,reg,regv))
		return -1;

	return 0;
}


