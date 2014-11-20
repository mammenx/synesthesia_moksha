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
 -- File Name         : i2c.c
 -- Author            : mammenx
 -- Function          : 
 --------------------------------------------------------------------------
*/

#include "i2c.h"
#include "alt_types.h"
#include "sys/alt_stdio.h"
#include "ch.h"


I2C_RES	get_i2c_status()	{
	alt_u32 status;

	status = IORD_I2C_STATUS;

	if(status & I2C_NACK_DET_MSK)
		return I2C_NACK_DETECTED;
	else if(status & I2C_BUSY_MSK)
		return I2C_BUSY;
	else
		return I2C_IDLE;
}

void 	configure_i2c_clk(alt_u8 clk_val)	{
	IOWR_I2C_CLK_DIV(clk_val & I2C_CLK_DIV_MSK);
}

alt_u8 	get_i2c_clk()	{
	return IORD_I2C_CLK_DIV & I2C_CLK_DIV_MSK;
}

void 	configure_i2c_addr(alt_u8 addr_val)	{
	IOWR_I2C_ADDR(addr_val & I2C_ADDR_MSK);
}

alt_u8 	get_i2c_addr()	{
	return	IORD_I2C_ADDR & I2C_ADDR_MSK;
}

I2C_RES	i2c_xtn_write(alt_u8 addr, alt_u8 *data, alt_u8 num_bytes, alt_u8 start, alt_u8 stop)	{
	alt_u32 i,fsm;

	if(num_bytes > I2C_MAX_XTN_LEN)	{
		alt_printf("[i2c_xtn_write] ERROR num_bytes(0x%x) > I2C_MAX_XTN_LEN(0x%x)\r\n",num_bytes,I2C_MAX_XTN_LEN);
		return I2C_ERROR;
	}

	configure_i2c_addr(addr);

	for(i=0; i<num_bytes;i++)	{
		IOWR_I2C_DATA_CACHE(i,data[i]);
	}

	//alt_printf("[i2c_xtn_write] Bffr[0] : 0x%x\n",IORD_I2C_DATA_CACHE(0));
	//alt_printf("[i2c_xtn_write] Bffr[1] : 0x%x\n",IORD_I2C_DATA_CACHE(1));
	//alt_printf("[i2c_xtn_write] Bffr[2] : 0x%x\n",IORD_I2C_DATA_CACHE(2));
	//alt_printf("[i2c_xtn_write] Bffr[3] : 0x%x\n",IORD_I2C_DATA_CACHE(3));

	IOWR_I2C_CONFIG((num_bytes << I2C_NUM_BYTES_OFFSET) + I2C_INIT_MSK + ((stop & 0x1) << 1) + (start & 0x1));

	fsm = 0xfffff;

	while(IORD_I2C_STATUS & I2C_BUSY_MSK){
		chThdSleepMilliseconds(1);	//wait for I2C driver to be free
		//if(fsm != IORD_I2C_FSM) {
		//	fsm = IORD_I2C_FSM;
		//	alt_printf("[i2c_xtn_write] FSM : 0x%x\n",fsm);
		//	alt_printf("[i2c_xtn_write] STATUS : 0x%x\n",IORD_I2C_STATUS);
		//}
	}

	if(IORD_I2C_STATUS	&	I2C_NACK_DET_MSK){
		alt_printf("[i2c_xtn_write] NACK Detected : 0x%x\r\n",IORD_I2C_STATUS);
		return I2C_NACK_DETECTED;
	}

	return I2C_OK;
}


I2C_RES	i2c_xtn_read(alt_u8 addr, alt_u8 *bffr, alt_u8 num_bytes, alt_u8 start, alt_u8 stop)	{
	alt_u32 i;

	if(num_bytes > I2C_MAX_XTN_LEN)	{
		alt_printf("[i2c_xtn_write] ERROR num_bytes(0x%x) > I2C_MAX_XTN_LEN(0x%x)\r\n",num_bytes,I2C_MAX_XTN_LEN);
		return I2C_ERROR;
	}

	configure_i2c_addr(addr);

	IOWR_I2C_CONFIG((num_bytes << I2C_NUM_BYTES_OFFSET) + I2C_RD_N_WR_MSK + I2C_INIT_MSK + ((stop & 0x1) << 1) + (start & 0x1));

	while(IORD_I2C_STATUS & I2C_BUSY_MSK){
		chThdSleepMilliseconds(1);	//wait for I2C driver to be free
	}

	if(IORD_I2C_STATUS	&	I2C_NACK_DET_MSK){
		alt_printf("[i2c_xtn_read] NACK Detected : 0x%x\r\n",IORD_I2C_STATUS);
		return I2C_NACK_DETECTED;
	}

	for(i=0; i<num_bytes;i++)	{
		//alt_printf("[i2c_xtn_read] Cache[0x%x] : 0x%x\n",i,IORD_I2C_DATA_CACHE(i));
		bffr[i]	=	IORD_I2C_DATA_CACHE(i)	&	0xff;
	}

	return I2C_OK;
}

void	byte_rev_i2c_arry(alt_u8 *bffr,alt_u32 size)	{
	alt_u8	temp;
	alt_u16 i;

	for(i=0;i<(size>>1);i++)	{
		temp = bffr[i];
		bffr[i] = bffr[size-i-1];
		bffr[size-i-1] = temp;
	}
}
