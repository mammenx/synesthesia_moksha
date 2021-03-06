/* 
 * "Small Hello World" example. 
 * 
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example 
 * designs. It requires a STDOUT  device in your system's hardware. 
 *
 * The purpose of this example is to demonstrate the smallest possible Hello 
 * World application, using the Nios II HAL library.  The memory footprint
 * of this hosted application is ~332 bytes by default using the standard 
 * reference design.  For a more fully featured Hello World application
 * example, see the example titled "Hello World".
 *
 * The memory footprint of this example has been reduced by making the
 * following changes to the normal "Hello World" example.
 * Check in the Nios II Software Developers Manual for a more complete 
 * description.
 * 
 * In the SW Application project (small_hello_world):
 *
 *  - In the C/C++ Build page
 * 
 *    - Set the Optimization Level to -Os
 * 
 * In System Library project (small_hello_world_syslib):
 *  - In the C/C++ Build page
 * 
 *    - Set the Optimization Level to -Os
 * 
 *    - Define the preprocessor option ALT_NO_INSTRUCTION_EMULATION 
 *      This removes software exception handling, which means that you cannot 
 *      run code compiled for Nios II cpu with a hardware multiplier on a core 
 *      without a the multiply unit. Check the Nios II Software Developers 
 *      Manual for more details.
 *
 *  - In the System Library page:
 *    - Set Periodic system timer and Timestamp timer to none
 *      This prevents the automatic inclusion of the timer driver.
 *
 *    - Set Max file descriptors to 4
 *      This reduces the size of the file handle pool.
 *
 *    - Check Main function does not exit
 *    - Uncheck Clean exit (flush buffers)
 *      This removes the unneeded call to exit when main returns, since it
 *      won't.
 *
 *    - Check Don't use C++
 *      This builds without the C++ support code.
 *
 *    - Check Small C library
 *      This uses a reduced functionality C library, which lacks  
 *      support for buffering, file IO, floating point and getch(), etc. 
 *      Check the Nios II Software Developers Manual for a complete list.
 *
 *    - Check Reduced device drivers
 *      This uses reduced functionality drivers if they're available. For the
 *      standard design this means you get polled UART and JTAG UART drivers,
 *      no support for the LCD driver and you lose the ability to program 
 *      CFI compliant flash devices.
 *
 *    - Check Access device drivers directly
 *      This bypasses the device file system to access device drivers directly.
 *      This eliminates the space required for the device file system services.
 *      It also provides a HAL version of libc services that access the drivers
 *      directly, further reducing space. Only a limited number of libc
 *      functions are available in this configuration.
 *
 *    - Use ALT versions of stdio routines:
 *
 *           Function                  Description
 *        ===============  =====================================
 *        alt_printf       Only supports %s, %x, and %c ( < 1 Kbyte)
 *        alt_putstr       Smaller overhead than puts with direct drivers
 *                         Note this function doesn't add a newline.
 *        alt_putchar      Smaller overhead than putchar with direct drivers
 *        alt_getchar      Smaller overhead than getchar with direct drivers
 *
 */

#include "sys/alt_stdio.h"
#include "ledos/ledos.h"
#include "ch.h"

int test_audio_fft()
{ 
	alt_u32 b32[256];
	alt_u16 b16[256];
	alt_u32 i;
	alt_u32 lbffr[128];
	alt_u32 rbffr[128];

  alt_putstr("Hello from Nios II!\n");

  enable_fgyrus();


  //pcm_cap(FS_32KHZ,BPS_24);

	disable_adc_drvr();
	disable_dac_drvr();
	disable_audio_path();

	update_acache_mode(PCM_BFFR_MODE_NORMAL);

	enable_audio_path(FS_44KHZ,BPS_24);
	enable_adc_drvr();
	enable_dac_drvr();


  /*
	do {

	} while (get_fgyrus_status() == FGYRUS_FFT_DONE);

	alt_printf("FFT Done\n");

	dump_fgyrus_fft_cache(lbffr,rbffr,128);

	 for(i=0;i<128;i++) {
		  printf("FFT L[0x%x] - %d\r\n",i,lbffr[i]);
	  }

	 for(i=0;i<128;i++) {
		  printf("FFT R[0x%x] - %d\r\n",i,rbffr[i]);
	  }
	  */

  dump_drvr_regs();
  aud_codec_dump_regs();

/*
  update_fgyrus_mode(FGYRUS_CONFIG);

  dump_fgyrus_twdl_ram(b32);

  for(i=0;i<FGYRUS_TWDL_RAM_SIZE;i++) {
	  alt_printf("Twdl Ram[0x%x] - 0x%x\r\n",i,b32[i]);
  }


  dump_fgyrus_win_ram(b32);

  for(i=0;i<FGYRUS_WIN_RAM_SIZE;i++) {
	  alt_printf("Win Ram[0x%x] - 0x%x\r\n",i,b32[i]);
  }


  dump_fgyrus_cordic_ram(b16);

  for(i=0;i<FGYRUS_CORDIC_RAM_SIZE;i++) {
	  alt_printf("Cordic Ram[0x%x] - 0x%x\r\n",i,b16[i]);
  }
  */

  /* Event loop never exits. */
  while (1);

  return 0;
}

int main ()
{
	  alt_putstr("Hello from Nios II!\n");

	  init_ledos(BPS_24);

	  //test_audio_fft();

	  return	0;
}
