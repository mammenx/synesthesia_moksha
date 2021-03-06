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
 -- File Name         : acortex.c
 -- Author            : mammenx
 -- Function          : 
 --------------------------------------------------------------------------
*/

#include "acortex.h"
#include "../../aud_codec/aud_codec.h"
#include "ch.h"
#include "sys/alt_stdio.h"


void init_acortex(BPS_T bps)	{
	configure_i2c_clk(255);

	configure_drvr_bclk_div(BCLK_DIV_10MHZ);
	configure_drvr_bps(bps);
}

void enable_audio_path(FS_T fs, BPS_T bps)	{
	/* De-Activate Codec */
	aud_codec_update_field(0,AUD_CODEC_ACTIVE_IDX,AUD_CODEC_ACTIVE_OFFST,AUD_CODEC_ACTIVE_MSK);
	aud_codec_update_field(1,AUD_CODEC_OUTPD_IDX,AUD_CODEC_OUTPD_OFFST,AUD_CODEC_OUTPD_MSK);

	/* Make configurations */
	aud_codec_update_field(0,AUD_CODEC_LIN_MUTE_IDX,AUD_CODEC_LIN_MUTE_OFFST,AUD_CODEC_LIN_MUTE_MSK);
	aud_codec_update_field(0,AUD_CODEC_RIN_MUTE_IDX,AUD_CODEC_RIN_MUTE_OFFST,AUD_CODEC_RIN_MUTE_MSK);

	aud_codec_update_field(bps,AUD_CODEC_IWL_IDX,AUD_CODEC_IWL_OFFST,AUD_CODEC_IWL_MSK);
	configure_drvr_bps(bps);

	aud_codec_update_field(fs2bosr_lookup[fs],AUD_CODEC_BOSR_IDX,AUD_CODEC_BOSR_OFFST,AUD_CODEC_BOSR_MSK);
	aud_codec_update_field(fs2sr_lookup[fs],AUD_CODEC_SR_IDX,AUD_CODEC_SR_OFFST,AUD_CODEC_SR_MSK);

	configure_drvr_fs_div(fs2fs_div_lookup[fs]);

	aud_codec_update_field(0,AUD_CODEC_ADCPD_IDX,AUD_CODEC_ADCPD_OFFST,AUD_CODEC_ADCPD_MSK);
	aud_codec_update_field(0,AUD_CODEC_DACPD_IDX,AUD_CODEC_DACPD_OFFST,AUD_CODEC_DACPD_MSK);

	/* Activate Codec */
	aud_codec_update_field(1,AUD_CODEC_ACTIVE_IDX,AUD_CODEC_ACTIVE_OFFST,AUD_CODEC_ACTIVE_MSK);
	aud_codec_update_field(0,AUD_CODEC_OUTPD_IDX,AUD_CODEC_OUTPD_OFFST,AUD_CODEC_OUTPD_MSK);

}

void disable_audio_path()	{
	/* De-Activate Codec */
	aud_codec_update_field(0,AUD_CODEC_ACTIVE_IDX,AUD_CODEC_ACTIVE_OFFST,AUD_CODEC_ACTIVE_MSK);
	aud_codec_update_field(1,AUD_CODEC_OUTPD_IDX,AUD_CODEC_OUTPD_OFFST,AUD_CODEC_OUTPD_MSK);

	/* Make configurations */
	aud_codec_update_field(1,AUD_CODEC_LIN_MUTE_IDX,AUD_CODEC_LIN_MUTE_OFFST,AUD_CODEC_LIN_MUTE_MSK);
	aud_codec_update_field(1,AUD_CODEC_RIN_MUTE_IDX,AUD_CODEC_RIN_MUTE_OFFST,AUD_CODEC_RIN_MUTE_MSK);

	aud_codec_update_field(1,AUD_CODEC_ADCPD_IDX,AUD_CODEC_ADCPD_OFFST,AUD_CODEC_ADCPD_MSK);
	aud_codec_update_field(1,AUD_CODEC_DACPD_IDX,AUD_CODEC_DACPD_OFFST,AUD_CODEC_DACPD_MSK);

	/* Activate Codec */
	aud_codec_update_field(1,AUD_CODEC_ACTIVE_IDX,AUD_CODEC_ACTIVE_OFFST,AUD_CODEC_ACTIVE_MSK);
	aud_codec_update_field(0,AUD_CODEC_OUTPD_IDX,AUD_CODEC_OUTPD_OFFST,AUD_CODEC_OUTPD_MSK);

}

void pcm_cap(FS_T fs, BPS_T bps)	{
	alt_u32 lbffr[PCM_BFFR_NUM_SAMPLES];
	alt_u32 rbffr[PCM_BFFR_NUM_SAMPLES];
	alt_u32 i;


	disable_adc_drvr();
	disable_audio_path();

	update_acache_mode(PCM_BFFR_MODE_CAPTURE);

	enable_audio_path(fs,bps);
	enable_adc_drvr();

	do {
		chThdSleepMilliseconds(1);
	}while(((IORD_PCM_BFFR_STATUS>>PCM_BFFR_CAP_DONE_OFFSET) & PCM_BFFR_CAP_DONE_MSK) == 0);

	dump_acache_cap_data(lbffr, rbffr);

	for(i=0;i<PCM_BFFR_NUM_SAMPLES;i++)	{
		printf("[pcm_cap] LBFFR[0x%x] - 0x%x\r\n",i,lbffr[i]);
	}

	alt_printf("\r\n");

	for(i=0;i<PCM_BFFR_NUM_SAMPLES;i++)	{
		printf("[pcm_cap] RBFFR[0x%x] - 0x%x\r\n",i,rbffr[i]);
	}

	alt_printf("\r\n");

	disable_adc_drvr();
	disable_audio_path();

}

