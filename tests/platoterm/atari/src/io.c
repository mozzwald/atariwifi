/**
 * PLATOTERM for Atari Cartridges
 *
 * Author: Thomas Cherryhomes <thom.cherryhomes at gmail dot com>
 *
 * I/O Functions
 */

#include <serial.h>
#include <stdbool.h>
#include <atari.h>
#include "io.h"
#include "protocol.h"
#include "sio.h"

extern bool running;

static uint8_t io_res;
static uint8_t recv_buffer[256];
static uint16_t recv_buffer_size=0;
static uint8_t outb;
static uint8_t status[4];

extern padPt TTYLoc;

static unsigned char hostname[256]="irata.online:8005";

uint8_t xoff_enabled=false;


/**
 * io_init() - Set-up the I/O
 */
void io_init(void)
{
  OS.soundr=0;
  
  // Establish connection
  OS.dcb.ddevic=0x70;
  OS.dcb.dunit=1;
  OS.dcb.dcomnd='c';
  OS.dcb.dstats=0x80;
  OS.dcb.dbuf=&hostname;
  OS.dcb.dtimlo=0x0f;
  OS.dcb.dbyt=256;
  OS.dcb.daux=0;
  siov();
}

/**
 * io_send_byte(b) - Send specified byte out
 */
void io_send_byte(uint8_t b)
{
  outb=b;
  OS.dcb.ddevic=0x70;
  OS.dcb.dunit=1;
  OS.dcb.dcomnd='w';
  OS.dcb.dstats=0x80;
  OS.dcb.dbuf=&outb;
  OS.dcb.dtimlo=0x0f;
  OS.dcb.dbyt=1;
  OS.dcb.daux=1;
  siov();
}

/**
 * io_main() - The IO main loop
 */
void io_main(void)
{
  if (PIA.pbctl==0xBC)
    {
      // Get # of bytes waiting
      OS.dcb.ddevic=0x70;
      OS.dcb.dunit=1;
      OS.dcb.dcomnd='s';
      OS.dcb.dstats=0x40;
      OS.dcb.dbuf=&status;
      OS.dcb.dtimlo=0x0f;
      OS.dcb.dbyt=4;
      OS.dcb.daux=0;
      siov();
      
      if (status[0])
  	{
  	  // Do a read into into recv buffer and ShowPLATO
  	  OS.dcb.ddevic=0x70;
  	  OS.dcb.dunit=1;
  	  OS.dcb.dcomnd='r';
  	  OS.dcb.dstats=0x40;
  	  OS.dcb.dbuf=&recv_buffer;
  	  OS.dcb.dbyt=status[0];
  	  OS.dcb.daux1=status[0];
  	  OS.dcb.daux2=0;
  	  siov();
  	  ShowPLATO((padByte *)recv_buffer, status[0]);
  	}
      
      PIA.pbctl|=0x01; // enable interrupt
    }
}

/**
 * io_done() - Called to close I/O
 */
void io_done(void)
{
}