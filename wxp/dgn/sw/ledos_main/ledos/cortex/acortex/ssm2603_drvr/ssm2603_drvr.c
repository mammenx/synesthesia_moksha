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
 -- File Name         : ssm2603_drvr.c
 -- Author            : mammenx
 -- Function          : 
 --------------------------------------------------------------------------
*/

#include "ssm2603_drvr.h"
#include "alt_types.h"
#include "sys/alt_stdio.h"


void disable_dac_drvr()	{
	IOWR_SSM2603_DRVR_CONFIG(IORD_SSM2603_DRVR_CONFIG	&	~SSM2603_DRVR_DAC_EN_MSK);
}

void enable_dac_drvr()	{
	IOWR_SSM2603_DRVR_CONFIG(IORD_SSM2603_DRVR_CONFIG	|	SSM2603_DRVR_DAC_EN_MSK);
}

void disable_adc_drvr()	{
	IOWR_SSM2603_DRVR_CONFIG(IORD_SSM2603_DRVR_CONFIG	&	~SSM2603_DRVR_ADC_EN_MSK);
}

void enable_adc_drvr()	{
	IOWR_SSM2603_DRVR_CONFIG(IORD_SSM2603_DRVR_CONFIG	|	SSM2603_DRVR_ADC_EN_MSK);
}

void configure_drvr_bps(BPS_T val)	{
	IOWR_SSM2603_DRVR_CONFIG((IORD_SSM2603_DRVR_CONFIG & ~SSM2603_DRVR_BPS_MSK) | (val << SSM2603_DRVR_BPS_OFFSET));
}

void configure_drvr_fs_div(FS_DIV_T val)	{
	IOWR_SSM2603_DRVR_FS_VAL(val);
}

void configure_drvr_bclk_div(BCLK_DIV_T val)	{
	IOWR_SSM2603_DRVR_BCLK_DIV(val);
}

void dump_drvr_regs()	{
	alt_printf("[dump_drvr_regs] SSM2603_DRVR_CONFIG_REG   : 0x%x\r\n",IORD_SSM2603_DRVR_CONFIG);
	alt_printf("[dump_drvr_regs] SSM2603_DRVR_STATUS_REG   : 0x%x\r\n",IORD_SSM2603_DRVR_STATUS);
	alt_printf("[dump_drvr_regs] SSM2603_DRVR_BCLK_DIV_REG : 0x%x\r\n",IORD_SSM2603_DRVR_BCLK_DIV);
	alt_printf("[dump_drvr_regs] SSM2603_DRVR_FS_VAL_REG   : 0x%x\r\n",IORD_SSM2603_DRVR_FS_VAL);
}
