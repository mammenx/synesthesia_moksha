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
 -- Project Code      : synesthesia_moksha
 -- Interface Name    : syn_wm8731_intf
 -- Author            : mammenx
 -- Function          : This interface contains all the signals required to
                        interface with the WM8731 Audio Codec.
 --------------------------------------------------------------------------
*/

interface syn_wm8731_intf  (input logic rst_il);

  //Logic signals
  logic   mclk;

  logic   bclk;
  logic   adc_dat;
  logic   adc_lrc;
  logic   dac_dat;
  logic   dac_lrc;

  logic   scl;
  tri1    sda;
  logic   sda_o;
  logic   release_sda;

  //Modports

    modport TB_I2C  (
                      input   rst_il,
                      input   scl,
                      output  sda_o,
                      output  release_sda,
                      inout   sda
                    );

    assign  sda = release_sda ? 1'bz  : sda_o;

    modport TB_DAC  (
                      input   rst_il,
                      input   bclk,
                      input   dac_dat,
                      input   dac_lrc
                    );

    modport TB_ADC  (
                      input   rst_il,
                      input   bclk,
                      output  adc_dat,
                      input   adc_lrc
                    );


endinterface  //  syn_wm8731_intf

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[18-11-2014  06:03:18 PM][mammenx] Removed MCLK feature testing and updated I2C agents

[15-10-2014  11:44:12 PM][mammenx] Initial Commit

 --------------------------------------------------------------------------
*/


