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
	aud_codec_i2c_bffr.val			=	((addr & AUD_CODEC_ADDR_MSK) << AUD_CODEC_ADDR_OFFSET) + \
										((val & AUD_CODEC_DATA_MSK)  << AUD_CODEC_DATA_OFFSET);

	byte_rev_i2c_arry(aud_codec_i2c_bffr.byte_arry,2);

	//alt_printf("[aud_codec_write_reg] addr : 0x%x, val : 0x%x\n",addr,val);
	//alt_printf("[aud_codec_write_reg] byte_arry[0] : 0x%x\n",aud_codec_i2c_bffr.byte_arry[0]);
	//alt_printf("[aud_codec_write_reg] byte_arry[1] : 0x%x\n",aud_codec_i2c_bffr.byte_arry[1]);

	return i2c_xtn_write(AUD_CODEC_I2C_WRITE_ADDR,aud_codec_i2c_bffr.byte_arry,2,1,1);

}

I2C_RES	aud_codec_read_reg(alt_u8 addr)	{
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


void aud_codec_reset()	{
	if(aud_codec_write_reg(AUD_CODEC_RESET_IDX,0))	{
		alt_printf("[aud_codec_reset] Error in I2C\n");
	}
}

void aud_codec_init(BPS_T bps)	{
	aud_codec_reset();

	aud_codec_update_field(0,AUD_CODEC_PWROFF_IDX,AUD_CODEC_PWROFF_OFFST,AUD_CODEC_PWROFF_MSK);
	aud_codec_update_field(0,AUD_CODEC_LINEINPD_IDX,AUD_CODEC_LINEINPD_OFFST,AUD_CODEC_LINEINPD_MSK);

	/* Configure misc settings */
	aud_codec_update_iwl(bps);
	aud_codec_update_field(1,AUD_CODEC_LRP_IDX,AUD_CODEC_LRP_OFFST,AUD_CODEC_LRP_MSK);
	aud_codec_update_field(3,AUD_CODEC_FORMAT_IDX,AUD_CODEC_FORMAT_OFFST,AUD_CODEC_FORMAT_MSK);
	aud_codec_update_field(1,AUD_CODEC_USB_NORM_IDX,AUD_CODEC_USB_NORM_OFFST,AUD_CODEC_USB_NORM_MSK);

	aud_codec_update_field(1,AUD_CODEC_DAC_SEL_IDX,AUD_CODEC_DAC_SEL_OFFST,AUD_CODEC_DAC_SEL_MSK);
	aud_codec_update_field(0,AUD_CODEC_BYPASS_IDX,AUD_CODEC_BYPASS_OFFST,AUD_CODEC_BYPASS_MSK);

	aud_codec_update_field(0,AUD_CODEC_DAC_MU_IDX,AUD_CODEC_DAC_MU_OFFST,AUD_CODEC_DAC_MU_MSK);

	/* Activate */
	aud_codec_update_field(1,AUD_CODEC_ACTIVE_IDX,AUD_CODEC_ACTIVE_OFFST,AUD_CODEC_ACTIVE_MSK);

	aud_codec_update_field(0,AUD_CODEC_OUTPD_IDX,AUD_CODEC_OUTPD_OFFST,AUD_CODEC_OUTPD_MSK);

}

void aud_codec_dump_regs(){
	alt_u8 i;

	alt_printf("CODEC Regs - \r\n");

	for(i=0; i<10; i++){
		switch(i) {
			case AUD_CODEC_LEFT_LINE_IN_REG_IDX: {
				if(aud_codec_read_reg(i))	{
					alt_printf("[aud_codec_dump_regs] ERROR in reading codec register 0x%x\r\n",i);
					return;
				}
				alt_printf("[0x%x] LEFT_LINE_IN REG - 0x%x\r\n",i,aud_codec_i2c_bffr.val);
				alt_printf("\tLRIN BOTH : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_LRIN_BOTH_OFFST,AUD_CODEC_LRIN_BOTH_MSK));
				alt_printf("\tLIN MUTE  : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_LIN_MUTE_OFFST,AUD_CODEC_LIN_MUTE_MSK));
				alt_printf("\tLIN VOL   : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_LINVOL_OFFST,AUD_CODEC_LINVOL_MSK));
				continue;
			}

			case AUD_CODEC_RIGHT_LINE_IN_REG_IDX: {
				if(aud_codec_read_reg(i))	{
					alt_printf("[aud_codec_dump_regs] ERROR in reading codec register 0x%x\r\n",i);
					return;
				}
				alt_printf("[0x%x] RIGHT_LINE_IN REG - 0x%x\r\n",i,aud_codec_i2c_bffr.val);
				alt_printf("\tRLIN BOTH : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_RLIN_BOTH_OFFST,AUD_CODEC_RLIN_BOTH_MSK));
				alt_printf("\tRIN MUTE  : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_RIN_MUTE_OFFST,AUD_CODEC_RIN_MUTE_MSK));
				alt_printf("\tRIN VOL   : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_RINVOL_OFFST,AUD_CODEC_RINVOL_MSK));
				continue;
			}

			case AUD_CODEC_LEFT_HP_OUT_REG_IDX: {
				if(aud_codec_read_reg(i))	{
					alt_printf("[aud_codec_dump_regs] ERROR in reading codec register 0x%x\r\n",i);
					return;
				}
				alt_printf("[0x%x] LEFT_HP_OUT REG - 0x%x\r\n",i,aud_codec_i2c_bffr.val);
				alt_printf("\tLRHP BOTH : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_LRHP_BOTH_OFFST,AUD_CODEC_LRHP_BOTH_MSK));
				alt_printf("\tLHPVOL    : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_LHPVOL_OFFST,AUD_CODEC_LHPVOL_MSK));
				continue;
			}

			case AUD_CODEC_RIGHT_HP_OUT_REG_IDX: {
				if(aud_codec_read_reg(i))	{
					alt_printf("[aud_codec_dump_regs] ERROR in reading codec register 0x%x\r\n",i);
					return;
				}
				alt_printf("[0x%x] RIGHT_HP_OUT REG - 0x%x\r\n",i,aud_codec_i2c_bffr.val);
				alt_printf("\tRLHP BOTH : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_RLHP_BOTH_OFFST,AUD_CODEC_RLHP_BOTH_MSK));
				alt_printf("\tRHPVOL    : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_RHPVOL_OFFST,AUD_CODEC_RHPVOL_MSK));
				continue;
			}

			case AUD_CODEC_ANALOG_AUD_PATH_REG_IDX: {
				if(aud_codec_read_reg(i))	{
					alt_printf("[aud_codec_dump_regs] ERROR in reading codec register 0x%x\r\n",i);
					return;
				}
				alt_printf("[0x%x] ANALOG_AUDIO_PATH REG - 0x%x\r\n",i,aud_codec_i2c_bffr.val);
				alt_printf("\tSIDE ATT  : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_SIDE_ATT_OFFST,AUD_CODEC_SIDE_ATT_MSK));
				alt_printf("\tSIDE TONE : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_SIDE_TONE_OFFST,AUD_CODEC_SIDE_TONE_MSK));
				alt_printf("\tDAC SEL   : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_DAC_SEL_OFFST,AUD_CODEC_DAC_SEL_MSK));
				alt_printf("\tBYPASS    : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_BYPASS_OFFST,AUD_CODEC_BYPASS_MSK));
				alt_printf("\tINSEL     : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_INSEL_OFFST,AUD_CODEC_INSEL_MSK));
				alt_printf("\tMUTE MIC  : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_MUTE_MIC_OFFST,AUD_CODEC_MUTE_MIC_MSK));
				alt_printf("\tMIC BOOST  : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_MIC_BOOST_OFFST,AUD_CODEC_MIC_BOOST_MSK));
				continue;
			}

			case AUD_CODEC_DIGITAL_AUD_PATH_REG_IDX: {
				if(aud_codec_read_reg(i))	{
					alt_printf("[aud_codec_dump_regs] ERROR in reading codec register 0x%x\r\n",i);
					return;
				}
				alt_printf("[0x%x] DIGITAL_AUDIO_PATH REG - 0x%x\r\n",i,aud_codec_i2c_bffr.val);
				alt_printf("\tHPOR      : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_HPOR_OFFST,AUD_CODEC_HPOR_MSK));
				alt_printf("\tDAC MUTE  : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_DAC_MU_OFFST,AUD_CODEC_DAC_MU_MSK));
				alt_printf("\tDE-EMPH   : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_DEEMPH_OFFST,AUD_CODEC_DEEMPH_MSK));
				alt_printf("\tADC HPD   : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_ADC_HPD_OFFST,AUD_CODEC_ADC_HPD_MSK));
				continue;
			}

			case AUD_CODEC_POWER_DOWN_REG_IDX: {
				if(aud_codec_read_reg(i))	{
					alt_printf("[aud_codec_dump_regs] ERROR in reading codec register 0x%x\r\n",i);
					return;
				}
				alt_printf("[0x%x] POWER_DOWN REG - 0x%x\r\n",i,aud_codec_i2c_bffr.val);
				alt_printf("\tPWR OFF   : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_PWROFF_OFFST,AUD_CODEC_PWROFF_MSK));
				alt_printf("\tCLK OUTPD : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_CLKOUTPD_OFFST,AUD_CODEC_CLKOUTPD_MSK));
				alt_printf("\tOSCPD     : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_OSCPD_OFFST,AUD_CODEC_OSCPD_MSK));
				alt_printf("\tOUTPD     : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_OUTPD_OFFST,AUD_CODEC_OUTPD_MSK));
				alt_printf("\tDACPD     : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_DACPD_OFFST,AUD_CODEC_DACPD_MSK));
				alt_printf("\tADCPD     : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_ADCPD_OFFST,AUD_CODEC_ADCPD_MSK));
				alt_printf("\tMICPD     : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_MICPD_OFFST,AUD_CODEC_MICPD_MSK));
				alt_printf("\tLINEINPD  : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_LINEINPD_OFFST,AUD_CODEC_LINEINPD_MSK));
				continue;
			}

			case AUD_CODEC_DIGITAL_AUD_IF_FMT_REG_IDX: {
				if(aud_codec_read_reg(i))	{
					alt_printf("[aud_codec_dump_regs] ERROR in reading codec register 0x%x\r\n",i);
					return;
				}
				alt_printf("[0x%x] DIGITAL_AUD_INTF_FMT REG - 0x%x\r\n",i,aud_codec_i2c_bffr.val);
				alt_printf("\tBCLK INV  : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_BCLK_INV_OFFST,AUD_CODEC_BCLK_INV_MSK));
				alt_printf("\tMS        : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_MS_OFFST,AUD_CODEC_MS_MSK));
				alt_printf("\tLRSWAP    : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_LRSWAP_OFFST,AUD_CODEC_LRSWAP_MSK));
				alt_printf("\tLRP       : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_LRP_OFFST,AUD_CODEC_LRP_MSK));
				alt_printf("\tIWL       : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_IWL_OFFST,AUD_CODEC_IWL_MSK));
				alt_printf("\tFORMAT    : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_FORMAT_OFFST,AUD_CODEC_FORMAT_MSK));
				continue;
			}

			case AUD_CODEC_SAMPLING_CTRL_REG_IDX: {
				if(aud_codec_read_reg(i))	{
					alt_printf("[aud_codec_dump_regs] ERROR in reading codec register 0x%x\r\n",i);
					return;
				}
				alt_printf("[0x%x] SAMPLING_CNTRL REG - 0x%x\r\n",i,aud_codec_i2c_bffr.val);
				alt_printf("\tCLKO DIV2 : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_CLKO_DIV2_OFFST,AUD_CODEC_CLKO_DIV2_MSK));
				alt_printf("\tCLKI DIV2 : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_CLKI_DIV2_OFFST,AUD_CODEC_CLKI_DIV2_MSK));
				alt_printf("\tSR        : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_SR_OFFST,AUD_CODEC_SR_MSK));
				alt_printf("\tBOSR      : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_BOSR_OFFST,AUD_CODEC_BOSR_MSK));
				alt_printf("\tUSB/NORM  : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_USB_NORM_OFFST,AUD_CODEC_USB_NORM_MSK));
				continue;
			}

			case AUD_CODEC_ACTIVE_CTRL_REG_IDX: {
				if(aud_codec_read_reg(i))	{
					alt_printf("[aud_codec_dump_regs] ERROR in reading codec register 0x%x\r\n",i);
					return;
				}
				alt_printf("[0x%x] SAMPLING_CNTRL REG - 0x%x\r\n",i,aud_codec_i2c_bffr.val);
				alt_printf("\tACTIVE    : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_ACTIVE_OFFST,AUD_CODEC_ACTIVE_MSK));
				continue;
			}

			default: {
				continue;
			}
		}
	}

	for(i=0xf; i<0x13; i++){
			switch(i) {
				case AUD_CODEC_RESET_REG_IDX: {
					if(aud_codec_read_reg(i))	{
						alt_printf("[aud_codec_dump_regs] ERROR in reading codec register 0x%x\r\n",i);
						return;
					}
					alt_printf("[0x%x] AUD_CODEC_RESET REG - 0x%x\r\n",i,aud_codec_i2c_bffr.val);
					continue;
				}

				case AUD_CODEC_ALC_CNTRL_1_REG_IDX: {
					if(aud_codec_read_reg(i))	{
						alt_printf("[aud_codec_dump_regs] ERROR in reading codec register 0x%x\r\n",i);
						return;
					}
					alt_printf("[0x%x] AUD_CODEC_ALC_CNTRL_1 REG - 0x%x\r\n",i,aud_codec_i2c_bffr.val);
					alt_printf("\tALCL : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_ALCL_OFFST,AUD_CODEC_ALCL_MSK));
					alt_printf("\tMAXGAIN : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_MAXGAIN_OFFST,AUD_CODEC_MAXGAIN_MSK));
					alt_printf("\tALCSEL : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_ALCSEL_OFFST,AUD_CODEC_ALCSEL_MSK));
					continue;
				}

				case AUD_CODEC_ALC_CNTRL_2_REG_IDX: {
					if(aud_codec_read_reg(i))	{
						alt_printf("[aud_codec_dump_regs] ERROR in reading codec register 0x%x\r\n",i);
						return;
					}
					alt_printf("[0x%x] AUD_CODEC_ALC_CNTRL_2 REG - 0x%x\r\n",i,aud_codec_i2c_bffr.val);
					alt_printf("\tATK : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_ATK_OFFST,AUD_CODEC_ATK_MSK));
					alt_printf("\tDCY : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_DCY_OFFST,AUD_CODEC_DCY_MSK));
					continue;
				}

				case AUD_CODEC_NOISE_GATE_REG_IDX: {
					if(aud_codec_read_reg(i))	{
						alt_printf("[aud_codec_dump_regs] ERROR in reading codec register 0x%x\r\n",i);
						return;
					}
					alt_printf("[0x%x] AUD_CODEC_NOISE_GATE REG - 0x%x\r\n",i,aud_codec_i2c_bffr.val);
					alt_printf("\tNGAT : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_NGAT_OFFST,AUD_CODEC_NGAT_MSK));
					alt_printf("\tNGG : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_NGG_OFFST,AUD_CODEC_NGAT_MSK));
					alt_printf("\tNGTH : 0x%x\r\n",AUD_CODEC_EXTRACT_FIELD(AUD_CODEC_NGTH_OFFST,AUD_CODEC_NGTH_MSK));
					continue;
				}

			default: {
				continue;
			}
		}
	}

	return;
}

void aud_codec_update_field(alt_u16 val, alt_u8 idx, alt_u8 offset, alt_u8 msk)	{
	if(aud_codec_read_reg(idx))	{
		alt_printf("[aud_codec_update_field] ERROR in reading codec register 0x%x\r\n",idx);
		return;
	}

	aud_codec_i2c_bffr.val = AUD_CODEC_UPDATE_FIELD(val,offset,msk);

	if(aud_codec_write_reg(idx,aud_codec_i2c_bffr.val))	{
		alt_printf("[aud_codec_update_field] ERROR in writing to codec register 0x%x\r\n",idx);
		return;
	}

	return;
}

void aud_codec_update_iwl(BPS_T val)	{
	aud_codec_update_field(val,AUD_CODEC_IWL_IDX,AUD_CODEC_IWL_OFFST,AUD_CODEC_IWL_MSK);
	return;
}
