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
 -- Header Name       : i2c.h
 -- Author            : mammenx
 -- Function          : 
 --------------------------------------------------------------------------
*/

#ifndef I2C_H_
#define I2C_H_

#include <io.h>
#include "system.h"
#include "alt_types.h"


#define	I2C_DRIVER_BASE_ADDR	0x00000
#define	I2C_MAX_XTN_LEN			4

//I2C Driver Register Addresses
#define	I2C_ADDR_REG_ADDR         0x00000
#define I2C_CLK_DIV_REG_ADDR      0x00010
#define I2C_CONFIG_REG_ADDR       0x00020
#define I2C_STATUS_REG_ADDR       0x00030
#define I2C_FSM_REG_ADDR          0x00040
#define I2C_DATA_CACHE_BASE_ADDR  0x00050

//Field Masks
#define I2C_ADDR_MSK				0x000000ff
#define I2C_CLK_DIV_MSK				0x0000ffff
#define	I2C_START_EN_MSK			0x00000001
#define	I2C_STOP_EN_MSK				0x00000002
#define	I2C_INIT_MSK				0x00000004
#define	I2C_RD_N_WR_MSK				0x00000008
#define	I2C_NUM_BYTES_OFFSET		8
#define	I2C_BUSY_MSK				0x00000001
#define	I2C_NACK_DET_MSK			0x00000002

//Read I2C Registers
#define	IORD_I2C_ADDR			\
		IORD_32DIRECT(CORTEX_BASE, I2C_ADDR_REG_ADDR)

#define	IORD_I2C_CLK_DIV			\
		IORD_32DIRECT(CORTEX_BASE, I2C_CLK_DIV_REG_ADDR)

#define	IORD_I2C_CONFIG			\
		IORD_32DIRECT(CORTEX_BASE, I2C_CONFIG_REG_ADDR)

#define	IORD_I2C_STATUS			\
		IORD_32DIRECT(CORTEX_BASE, I2C_STATUS_REG_ADDR)

#define	IORD_I2C_FSM			\
		IORD_32DIRECT(CORTEX_BASE, I2C_FSM_REG_ADDR)

#define	IORD_I2C_DATA_CACHE(OFFSET)			\
		IORD_32DIRECT(CORTEX_BASE, I2C_DATA_CACHE_BASE_ADDR+(OFFSET<<4))


//Write I2C Registers
#define	IOWR_I2C_ADDR(data)		\
		IOWR_32DIRECT(CORTEX_BASE, I2C_ADDR_REG_ADDR, data)

#define	IOWR_I2C_CLK_DIV(data)		\
		IOWR_32DIRECT(CORTEX_BASE, I2C_CLK_DIV_REG_ADDR, data)

#define	IOWR_I2C_CONFIG(data)		\
		IOWR_32DIRECT(CORTEX_BASE, I2C_CONFIG_REG_ADDR, data)

#define	IOWR_I2C_DATA_CACHE(OFFSET,data)		\
		IOWR_32DIRECT(CORTEX_BASE, I2C_DATA_CACHE_BASE_ADDR+(OFFSET<<4), data)

#endif /* I2C_H_ */


typedef enum {
	I2C_OK	=	0,		/*	(0)	RD/WR Transaction success	*/
	I2C_NACK_DETECTED,	/*	(1)	Invalid I2C transaction		*/
	I2C_BUSY,			/*	(2)	I2C is busy in a transaction*/
	I2C_IDLE,			/*	(3) I2C is ready for new transaction	*/
	I2C_ERROR			/*	(4) Error in I2C parameters	*/
} I2C_RES;

I2C_RES	get_i2c_status();
void 	configure_i2c_clk(alt_u8 clk_val);
alt_u8 	get_i2c_clk();
void 	configure_i2c_addr(alt_u8 addr_val);
alt_u8 	get_i2c_addr();
I2C_RES	i2c_xtn_write(alt_u8 addr, alt_u8 *data, alt_u8 num_bytes, alt_u8 start, alt_u8 stop);
I2C_RES	i2c_xtn_read(alt_u8 addr, alt_u8 *bffr, alt_u8 num_bytes, alt_u8 start, alt_u8 stop);
void	byte_rev_i2c_arry(alt_u8 *bffr,alt_u32 size);
