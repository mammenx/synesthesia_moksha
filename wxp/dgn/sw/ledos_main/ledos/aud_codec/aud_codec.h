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
 -- Header Name       : aud_codec.h
 -- Author            : mammenx
 -- Function          : 
 --------------------------------------------------------------------------
*/

#ifndef AUD_CODEC_H_
#define AUD_CODEC_H_

#include <io.h>
#include "alt_types.h"
#include "../cortex/acortex/acortex.h"

#define	AUD_CODEC_I2C_READ_ADDR		0x35
#define	AUD_CODEC_I2C_WRITE_ADDR	0x34

#define	NUM_AUD_CODEC_REGS			14

#define	AUD_CODEC_DATA_OFFSET		0
#define	AUD_CODEC_DATA_MSK			0x1ff
#define	AUD_CODEC_ADDR_OFFSET		9
#define AUD_CODEC_ADDR_MSK			0x7f

//Register Indexes
#define	AUD_CODEC_LEFT_LINE_IN_REG_IDX			0x00
#define	AUD_CODEC_RIGHT_LINE_IN_REG_IDX			0x01
#define	AUD_CODEC_LEFT_HP_OUT_REG_IDX			0x02
#define	AUD_CODEC_RIGHT_HP_OUT_REG_IDX			0x03
#define	AUD_CODEC_ANALOG_AUD_PATH_REG_IDX		0x04
#define	AUD_CODEC_DIGITAL_AUD_PATH_REG_IDX		0x05
#define	AUD_CODEC_POWER_DOWN_REG_IDX			0x06
#define	AUD_CODEC_DIGITAL_AUD_IF_FMT_REG_IDX	0x07
#define	AUD_CODEC_SAMPLING_CTRL_REG_IDX			0x08
#define	AUD_CODEC_ACTIVE_CTRL_REG_IDX			0x09
#define	AUD_CODEC_RESET_REG_IDX					0x0f
#define AUD_CODEC_ALC_CNTRL_1_REG_IDX			0x10
#define	AUD_CODEC_ALC_CNTRL_2_REG_IDX			0x11
#define	AUD_CODEC_NOISE_GATE_REG_IDX			0x12


//IDX[0] Fields
#define	AUD_CODEC_LINVOL_MSK			0x3f
#define	AUD_CODEC_LINVOL_OFFST			0
#define	AUD_CODEC_LINVOL_IDX			0

#define	AUD_CODEC_LIN_MUTE_MSK			0x1
#define	AUD_CODEC_LIN_MUTE_OFFST		7
#define	AUD_CODEC_LIN_MUTE_IDX			0

#define	AUD_CODEC_LRIN_BOTH_MSK			0x1
#define	AUD_CODEC_LRIN_BOTH_OFFST		8
#define	AUD_CODEC_LRIN_BOTH_IDX			0

//IDX[1] Fields
#define	AUD_CODEC_RINVOL_MSK			0x3f
#define	AUD_CODEC_RINVOL_OFFST			0
#define	AUD_CODEC_RINVOL_IDX			1

#define	AUD_CODEC_RIN_MUTE_MSK			0x1
#define	AUD_CODEC_RIN_MUTE_OFFST		7
#define	AUD_CODEC_RIN_MUTE_IDX			1

#define	AUD_CODEC_RLIN_BOTH_MSK			0x1
#define	AUD_CODEC_RLIN_BOTH_OFFST		8
#define	AUD_CODEC_RLIN_BOTH_IDX			1

//IDX[2] Fields
#define	AUD_CODEC_LHPVOL_MSK			0x7f
#define	AUD_CODEC_LHPVOL_OFFST			0
#define	AUD_CODEC_LHPVOL_IDX			2

#define	AUD_CODEC_LRHP_BOTH_MSK			0x1
#define	AUD_CODEC_LRHP_BOTH_OFFST		8
#define	AUD_CODEC_LRHP_BOTH_IDX			2

//IDX[3] Fields
#define	AUD_CODEC_RHPVOL_MSK			0x7f
#define	AUD_CODEC_RHPVOL_OFFST			0
#define	AUD_CODEC_RHPVOL_IDX			3

#define	AUD_CODEC_RLHP_BOTH_MSK			0x1
#define	AUD_CODEC_RLHP_BOTH_OFFST		8
#define	AUD_CODEC_RLHP_BOTH_IDX			3

//IDX[4] Fields
#define	AUD_CODEC_MIC_BOOST_MSK			0x1
#define	AUD_CODEC_MIC_BOOST_OFFST		0
#define	AUD_CODEC_MIC_BOOST_IDX			4

#define	AUD_CODEC_MUTE_MIC_MSK			0x1
#define	AUD_CODEC_MUTE_MIC_OFFST		1
#define	AUD_CODEC_MUTE_MIC_IDX			4

#define	AUD_CODEC_INSEL_MSK			    0x1
#define	AUD_CODEC_INSEL_OFFST		    2
#define	AUD_CODEC_INSEL_IDX			    4

#define	AUD_CODEC_BYPASS_MSK			0x1
#define	AUD_CODEC_BYPASS_OFFST		  	3
#define	AUD_CODEC_BYPASS_IDX			4

#define	AUD_CODEC_DAC_SEL_MSK			0x1
#define	AUD_CODEC_DAC_SEL_OFFST		  	4
#define	AUD_CODEC_DAC_SEL_IDX			4

#define	AUD_CODEC_SIDE_TONE_MSK			0x1
#define	AUD_CODEC_SIDE_TONE_OFFST		5
#define	AUD_CODEC_SIDE_TONE_IDX			4

#define	AUD_CODEC_SIDE_ATT_MSK			0x3
#define	AUD_CODEC_SIDE_ATT_OFFST		6
#define	AUD_CODEC_SIDE_ATT_IDX			4

//IDX[5] Fields
#define	AUD_CODEC_ADC_HPD_MSK			0x1
#define	AUD_CODEC_ADC_HPD_OFFST		 	0
#define	AUD_CODEC_ADC_HPD_IDX			5

#define	AUD_CODEC_DEEMPH_MSK			0x3
#define	AUD_CODEC_DEEMPH_OFFST		 	1
#define	AUD_CODEC_DEEMPH_IDX			5

#define	AUD_CODEC_DAC_MU_MSK			0x1
#define	AUD_CODEC_DAC_MU_OFFST		 	3
#define	AUD_CODEC_DAC_MU_IDX			5

#define	AUD_CODEC_HPOR_MSK			  	0x1
#define	AUD_CODEC_HPOR_OFFST		  	4
#define	AUD_CODEC_HPOR_IDX			  	5

//IDX[6] Fields
#define	AUD_CODEC_LINEINPD_MSK			0x1
#define	AUD_CODEC_LINEINPD_OFFST		0
#define	AUD_CODEC_LINEINPD_IDX			6

#define	AUD_CODEC_MICPD_MSK		    	0x1
#define	AUD_CODEC_MICPD_OFFST	    	1
#define	AUD_CODEC_MICPD_IDX		    	6

#define	AUD_CODEC_ADCPD_MSK		    	0x1
#define	AUD_CODEC_ADCPD_OFFST	    	2
#define	AUD_CODEC_ADCPD_IDX		    	6

#define	AUD_CODEC_DACPD_MSK		    	0x1
#define	AUD_CODEC_DACPD_OFFST	    	3
#define	AUD_CODEC_DACPD_IDX		    	6

#define	AUD_CODEC_OUTPD_MSK		    	0x1
#define	AUD_CODEC_OUTPD_OFFST	    	4
#define	AUD_CODEC_OUTPD_IDX		    	6

#define	AUD_CODEC_OSCPD_MSK		    	0x1
#define	AUD_CODEC_OSCPD_OFFST	    	5
#define	AUD_CODEC_OSCPD_IDX		    	6

#define	AUD_CODEC_CLKOUTPD_MSK			0x1
#define	AUD_CODEC_CLKOUTPD_OFFST		6
#define	AUD_CODEC_CLKOUTPD_IDX			6

#define	AUD_CODEC_PWROFF_MSK		  	0x1
#define	AUD_CODEC_PWROFF_OFFST	  		7
#define	AUD_CODEC_PWROFF_IDX		  	6

//IDX[7] Fields
#define	AUD_CODEC_FORMAT_MSK		  	0x3
#define	AUD_CODEC_FORMAT_OFFST	  		0
#define	AUD_CODEC_FORMAT_IDX		  	7

#define	AUD_CODEC_IWL_MSK		      	0x3
#define	AUD_CODEC_IWL_OFFST	      		2
#define	AUD_CODEC_IWL_IDX		      	7

#define	AUD_CODEC_LRP_MSK		      	0x1
#define	AUD_CODEC_LRP_OFFST	      		4
#define	AUD_CODEC_LRP_IDX		      	7

#define	AUD_CODEC_LRSWAP_MSK		  	0x1
#define	AUD_CODEC_LRSWAP_OFFST	  		5
#define	AUD_CODEC_LRSWAP_IDX		  	7

#define	AUD_CODEC_MS_MSK		      	0x1
#define	AUD_CODEC_MS_OFFST	      		6
#define	AUD_CODEC_MS_IDX		      	7

#define	AUD_CODEC_BCLK_INV_MSK			0x1
#define	AUD_CODEC_BCLK_INV_OFFST		7
#define	AUD_CODEC_BCLK_INV_IDX			7

//IDX[8] Fields
#define	AUD_CODEC_USB_NORM_MSK			0x1
#define	AUD_CODEC_USB_NORM_OFFST		0
#define	AUD_CODEC_USB_NORM_IDX			8

#define	AUD_CODEC_BOSR_MSK		    	0x1
#define	AUD_CODEC_BOSR_OFFST	    	1
#define	AUD_CODEC_BOSR_IDX		    	8

#define	AUD_CODEC_SR_MSK		      	0xf
#define	AUD_CODEC_SR_OFFST	      		2
#define	AUD_CODEC_SR_IDX		      	8

#define	AUD_CODEC_CLKI_DIV2_MSK			0x1
#define	AUD_CODEC_CLKI_DIV2_OFFST		6
#define	AUD_CODEC_CLKI_DIV2_IDX			8

#define	AUD_CODEC_CLKO_DIV2_MSK			0x1
#define	AUD_CODEC_CLKO_DIV2_OFFST		7
#define	AUD_CODEC_CLKO_DIV2_IDX			8

//IDX[9] Fields
#define	AUD_CODEC_ACTIVE_MSK		  	0x1
#define	AUD_CODEC_ACTIVE_OFFST	  		0
#define	AUD_CODEC_ACTIVE_IDX		  	9

//Reset Address IDX[0x0f]
#define	AUD_CODEC_RESET_IDX				0x0f

//IDX[0x10] Feilds
#define	AUD_CODEC_ALCL_MSK				0xf
#define	AUD_CODEC_ALCL_OFFST			0
#define	AUD_CODEC_ALCL_IDX				0x10

#define	AUD_CODEC_MAXGAIN_MSK			0x7
#define	AUD_CODEC_MAXGAIN_OFFST			4
#define	AUD_CODEC_MAXGAIN_IDX			0x10

#define	AUD_CODEC_ALCSEL_MSK			0x3
#define	AUD_CODEC_ALCSEL_OFFST			7
#define	AUD_CODEC_ALCSEL_IDX			0x10

//IDX[0x11] Fields
#define	AUD_CODEC_ATK_MSK				0xf
#define	AUD_CODEC_ATK_OFFST				0
#define	AUD_CODEC_ATK_IDX				0x11

#define	AUD_CODEC_DCY_MSK				0xf
#define	AUD_CODEC_DCY_OFFST				4
#define	AUD_CODEC_DCY_IDX				0x11

//IDX[0x12] Fields
#define	AUD_CODEC_NGAT_MSK				0x1
#define	AUD_CODEC_NGAT_OFFST			0
#define	AUD_CODEC_NGAT_IDX				0x12

#define	AUD_CODEC_NGG_MSK				0x3
#define	AUD_CODEC_NGG_OFFST				1
#define	AUD_CODEC_NGG_IDX				0x12

#define	AUD_CODEC_NGTH_MSK				0x1f
#define	AUD_CODEC_NGTH_OFFST			3
#define	AUD_CODEC_NGTH_IDX				0x12

typedef enum	{
	FS_8KHZ_SR		=	0x3,
	FS_32KHZ_SR		=	0x6,
	FS_44KHZ_SR		=	0x8,
	FS_48KHZ_SR		=	0x0,
	FS_88KHZ_SR		=	0xf,
	FS_96KHZ_SR		=	0x7
}SR_SEL;

static const SR_SEL fs2sr_lookup[]	=	{
		[FS_8KHZ]	=	FS_8KHZ_SR,
		[FS_32KHZ]	=	FS_32KHZ_SR,
		[FS_44KHZ]	=	FS_44KHZ_SR,
		[FS_48KHZ]	=	FS_48KHZ_SR,
		[FS_88KHZ]	=	FS_88KHZ_SR,
		[FS_96KHZ]	=	FS_96KHZ_SR
};

static const SR_SEL fs2bosr_lookup[]	=	{
		[FS_8KHZ]	=	0,
		[FS_32KHZ]	=	0,
		[FS_44KHZ]	=	1,
		[FS_48KHZ]	=	0,
		[FS_88KHZ]	=	1,
		[FS_96KHZ]	=	0
};

//Buffer for storing I2C read/write data
#define	AUD_CODEC_I2C_BFFR_SIZE			2
//alt_u8	aud_codec_i2c_bffr[AUD_CODEC_I2C_BFFR_SIZE];
union	AUD_CODEC_I2C_BFFR_T	{
	alt_u8	byte_arry[AUD_CODEC_I2C_BFFR_SIZE];
	alt_u16 val;
}aud_codec_i2c_bffr;


//Function to read/write a register in CODEC
I2C_RES	aud_codec_write_reg(alt_u8 addr, alt_u16 val);
I2C_RES	aud_codec_read_reg(alt_u8 addr);
void aud_codec_reset();
void aud_codec_init();
void aud_codec_dump_regs();
void aud_codec_update_field(alt_u16 val, alt_u8 idx, alt_u8 offset, alt_u8 msk);
void aud_codec_update_iwl(BPS_T val);

//MACRO to extract field from CODEC register
#define	AUD_CODEC_EXTRACT_FIELD(offset,msk) \
		(aud_codec_i2c_bffr.val >> offset) & msk

//MACRO to update a field read from codec
#define AUD_CODEC_UPDATE_FIELD(value,offset,msk)	\
		(aud_codec_i2c_bffr.val & ~(msk<<offset)) + ((value & msk)<<offset)

#endif /* AUD_CODEC_H_ */

