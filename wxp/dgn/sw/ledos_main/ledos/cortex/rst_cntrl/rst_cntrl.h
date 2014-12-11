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
 -- Header Name       : rst_cntrl.h
 -- Author            : mammenx
 -- Function          : 
 --------------------------------------------------------------------------
*/

#ifndef RST_CNTRL_H_
#define RST_CNTRL_H_

#include <io.h>
#include "system.h"
#include "alt_types.h"

#define	RESET_CNTRL_REG_ADDR	0x20000
#define	RESET_CNTRL_MSK			0x00000007

#define	IORD_RESET_CNTRL			\
		IORD_32DIRECT(CORTEX_BASE, RESET_CNTRL_REG_ADDR)

#define	IOWR_RESET_CNTRL(data)		\
		IOWR_32DIRECT(CORTEX_BASE, RESET_CNTRL_REG_ADDR, data)



#endif /* RST_CNTRL_H_ */

