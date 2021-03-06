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
 -- Header Name       : ssm2603_drvr.h
 -- Author            : mammenx
 -- Function          : 
 --------------------------------------------------------------------------
*/

#ifndef SSM2603_DRVR_H_
#define SSM2603_DRVR_H_

#include <io.h>
#include "system.h"

#define	SSM2603_DRVR_BASE_ADDR	0x01000
#define	NUM_MCLKS				2

//SSM2603 Driver Register addresses
#define	SSM2603_DRVR_CONFIG_REG_ADDR    0x01000
#define	SSM2603_DRVR_STATUS_REG_ADDR    0x01010
#define	SSM2603_DRVR_BCLK_DIV_REG_ADDR  0x01020
#define	SSM2603_DRVR_FS_VAL_REG_ADDR    0x01030

//Field Masks
#define	SSM2603_DRVR_DAC_EN_OFFSET		0
#define	SSM2603_DRVR_DAC_EN_MSK			0x00000001
#define	SSM2603_DRVR_ADC_EN_OFFSET		1
#define	SSM2603_DRVR_ADC_EN_MSK			0x00000002
#define	SSM2603_DRVR_BPS_OFFSET			2
#define	SSM2603_DRVR_BPS_MSK			0x0000000c

//Read SSM2603 Driver Registers
#define	IORD_SSM2603_DRVR_CONFIG				\
		IORD_32DIRECT(CORTEX_BASE, SSM2603_DRVR_CONFIG_REG_ADDR)

#define	IORD_SSM2603_DRVR_STATUS				\
		IORD_32DIRECT(CORTEX_BASE, SSM2603_DRVR_STATUS_REG_ADDR)

#define	IORD_SSM2603_DRVR_BCLK_DIV				\
		IORD_32DIRECT(CORTEX_BASE, SSM2603_DRVR_BCLK_DIV_REG_ADDR)

#define	IORD_SSM2603_DRVR_FS_VAL				\
		IORD_32DIRECT(CORTEX_BASE, SSM2603_DRVR_FS_VAL_REG_ADDR)


//Write SSM2603 Driver registers
#define	IOWR_SSM2603_DRVR_CONFIG(data)		\
		IOWR_32DIRECT(CORTEX_BASE, SSM2603_DRVR_CONFIG_REG_ADDR, data)

#define	IOWR_SSM2603_DRVR_BCLK_DIV(data)		\
		IOWR_32DIRECT(CORTEX_BASE, SSM2603_DRVR_BCLK_DIV_REG_ADDR, data)

#define	IOWR_SSM2603_DRVR_FS_VAL(data)		\
		IOWR_32DIRECT(CORTEX_BASE, SSM2603_DRVR_FS_VAL_REG_ADDR, data)


#endif /* SSM2603_DRVR_H_ */


typedef	enum	{
	FS_8KHZ,
	FS_32KHZ,
	FS_44KHZ,
	FS_48KHZ,
	FS_88KHZ,
	FS_96KHZ
}FS_T;


typedef enum	{	//	==	ACORTEX_FREQ(100MHz) / BCLK_FREQ
	BCLK_DIV_10MHZ	=	10
}BCLK_DIV_T;

typedef	enum	{	//	==	BCLK_FREQ(10MHz)	/	FS
	FS_DIV_8KHZ		=	1250,
	FS_DIV_32KHZ	=	313,
	FS_DIV_44KHZ	=	227,
	FS_DIV_48KHZ	=	208,
	FS_DIV_88KHZ	=	114,
	FS_DIV_96KHZ	=	104
}FS_DIV_T;

static const FS_DIV_T fs2fs_div_lookup[]	=	{
		[FS_8KHZ]	=	FS_DIV_8KHZ,
		[FS_32KHZ]	=	FS_DIV_32KHZ,
		[FS_44KHZ]	=	FS_DIV_44KHZ,
		[FS_48KHZ]	=	FS_DIV_48KHZ,
		[FS_88KHZ]	=	FS_DIV_88KHZ,
		[FS_96KHZ]	=	FS_DIV_96KHZ
};

typedef	enum	{
	BPS_16	=	0,
	BPS_20	=	1,
	BPS_24	=	2,
	BPS_32	=	3
}BPS_T;

void disable_dac_drvr();
void enable_dac_drvr();
void disable_adc_drvr();
void enable_adc_drvr();
void configure_drvr_bps(BPS_T val);
void configure_drvr_fs_div(FS_DIV_T val);
void configure_drvr_bclk_div(BCLK_DIV_T val);
void dump_drvr_regs();
