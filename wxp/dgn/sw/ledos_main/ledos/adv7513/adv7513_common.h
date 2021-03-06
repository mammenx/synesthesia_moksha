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
 -- Header Name       : adv7513_common.h
 -- Author            : mammenx
 -- Function          : 
 --------------------------------------------------------------------------
*/

#ifndef ADV7513_COMMON_H_
#define ADV7513_COMMON_H_

#include <stdio.h>
#include <stdlib.h> // malloc, free
#include <string.h>
#include <stddef.h>
#include <unistd.h>  // usleep (unix standard?)
#include "sys/alt_flash.h"
#include "sys/alt_flash_types.h"
#include "io.h"
#include "alt_types.h"  // alt_u32
#include "sys/alt_irq.h"  // interrupt
#include "altera_avalon_pio_regs.h" //IOWR_ALTERA_AVALON_PIO_DATA
#include "sys/alt_alarm.h" // time tick function (alt_nticks(), alt_ticks_per_second())
#include "sys/alt_timestamp.h"
#include "sys/alt_stdio.h"
#include "system.h"
#include <fcntl.h>
//#include "debug.h"

#define DEBUG_DUMP  /*printf */


typedef int bool;
#define TRUE    1
#define FALSE   0

#define ADV7513_SALVE_ADDR7		0x39										// 0x39)PD-low 0x3D)PD-high
#define ADV7513_SALVE_ADDR8		((alt_u8)(ADV7513_SALVE_ADDR7) << 1)		// 0x72)PD-low 0x7A)PD-high
#define ADV7513_EDID_ADDR8		0x7e

//Buffer for storing I2C read/write data
#define	ADV7513_I2C_BFFR_SIZE			2
//alt_u8	aud_codec_i2c_bffr[AUD_CODEC_I2C_BFFR_SIZE];
union	ADV7513_I2C_BFFR_T	{
	alt_u8	byte_arry[ADV7513_I2C_BFFR_SIZE];
	alt_u16 val;
}adv7513_i2c_bffr;


#endif /* ADV7513_COMMON_H_ */

