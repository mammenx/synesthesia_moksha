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
 -- Header Name       : encoder.h
 -- Author            : mammenx
 -- Function          : 
 --------------------------------------------------------------------------
*/

#ifndef ENCODER_H_
#define ENCODER_H_

struct vendor_infoframe {
	int struct_3d;
	int ext_data_3d;
};

struct avi_infoframe {
	int scan_info;			// s1s0 scan information
	int bar_info;			// b1b0 bar info
	int active_fmt;			// a0 active format information
	int rgb_ycbcr;			// y1y0 rgb or ycbcr
	//int f7;				// future use
	int active_fmt_ar;		// r3r0 active format aspect ratio
	int pict_ar;			// m1m0 picture aspect ratio
	int colorimetry;		// c1c0 colorimetry
	int scaling;			// sc1sc0 non-uniform picture scaling
	int quant;				// q1q0 rgb quantization range
	int colorimetry_ext;	// ec2ec0 extended colorimetry
	int itc;				// it content
	int vic;				// vic6vic0 video identification code
	int pr;					// pr3pr0 pixel repetition factor
	int yq1yq0;				// ??

	struct bar {
		int top_e;		// line number of end of top bar
		int bottom_s;	// line number of start of bottom bar
		int left_e;		// pixel number of end of left bar
		int right_s;	// pixel number of start of right bar
	} bar;
};

#if 0
struct audio_infoframe {
	int channel_count;	// cc2cc0 channel count
	int coding_type;	// ct3ct0 coding type
	int sample_size;	// ss1ss0 sample size
	int sample_freq;	// sf2sf0 sample frequency
	int spk_alloc;		// ca7ca0 channel/speaker allocation
	int level_shift;	// lsv3lsv0 level shift value
	int downmix;		// dm_inh downmix inhibit
};
#endif

struct hdmi_encoder {
	int slave_addr;		// i2c address of encoder slave device
	int edid_addr;		// i2c address of EDID slave address

	int hpd_prev;		// previous hpd status
	int hpd_latest;		// latest hpd status
	int hpd_event;		// hpd state change indicator
	int hpd;			// hpd indicator (stable)

	unsigned int int_mask;		// interrupt enable mask
	//unsigned int int_status;	// current interrupt status

	unsigned char chip_id[4];
	unsigned char chip_rev[4];

	struct avi_infoframe avi_if;		// auxiliary video infoframe
	//struct audio_infoframe audio_if;	// audio infoframe

	struct vendor_infoframe vendor_if;	// vendor specific infoframe
};

extern int reg_read(struct hdmi_encoder *ec, int reg, void *data);

extern int reg_write(struct hdmi_encoder *ec, int reg, int data);

extern int reg_update_bits(struct hdmi_encoder *ec, int reg, int mask, int data);

extern int reg_or_bits(struct hdmi_encoder *ec, int reg, int data);

extern int reg_clear_bits(struct hdmi_encoder *ec, int reg, int mask);


#endif /* ENCODER_H_ */

