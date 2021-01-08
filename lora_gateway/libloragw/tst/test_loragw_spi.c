/*
 / _____)             _              | |
( (____  _____ ____ _| |_ _____  ____| |__
 \____ \| ___ |    (_   _) ___ |/ ___)  _ \
 _____) ) ____| | | || |_| ____( (___| | | |
(______/|_____)_|_|_| \__)_____)\____)_| |_|
  (C)2013 Semtech-Cycleo

Description:
    Minimum test program for the loragw_spi 'library'
    Use logic analyser to check the results.

License: Revised BSD License, see LICENSE.TXT file include in the project
Maintainer: Sylvain Miermont
*/


/* -------------------------------------------------------------------------- */
/* --- DEPENDANCIES --------------------------------------------------------- */

#include <stdint.h>
#include <stdio.h>

#include "loragw_spi.h"

/* -------------------------------------------------------------------------- */
/* --- PRIVATE MACROS ------------------------------------------------------- */

#define ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))

/* -------------------------------------------------------------------------- */
/* --- PRIVATE CONSTANTS ---------------------------------------------------- */

#define BURST_TEST_SIZE 2500 /* >> LGW_BURST_CHUNK */
#define TIMING_REPEAT   1    /* repeat transactions multiple times for timing characterisation */

/* -------------------------------------------------------------------------- */
/* --- MAIN FUNCTION -------------------------------------------------------- */

int main()
{
    int i;
    void *spi_target = NULL;
    uint8_t data = 0;
    uint8_t dataout[BURST_TEST_SIZE];
    uint8_t datain[BURST_TEST_SIZE];
    uint8_t spi_mux_mode = LGW_SPI_MUX_MODE0;

    for (i = 0; i < BURST_TEST_SIZE; ++i) {
        dataout[i] = 0x30 + (i % 10); /* ASCCI code for 0 -> 9 */
        datain[i] = 0x23; /* garbage data, to be overwritten by received data */
    }

    printf("Beginning of test for loragw_spi.c\n");
    lgw_spi_open(&spi_target);
    sleep(1);


    /* performs software reset */
    printf("Performs software reset\n");
    lgw_spi_w(spi_target, spi_mux_mode, LGW_SPI_MUX_TARGET_SX1301, 0x00, 0x80);
    sleep(1);

    /* read chip version */
    for (i = 0; i < TIMING_REPEAT; ++i) {
        lgw_spi_r(spi_target, spi_mux_mode, LGW_SPI_MUX_TARGET_SX1301, 0x01, &data);
        if( data != 103 ) {
            printf("error not reading proper chip version %d != 103", data);
            return 1;
        }
    }
    printf("Chip version is: %d\n",data);
//return 0;


    /* normal R/W test */
/*
//    for (i = 0; i < TIMING_REPEAT; ++i)
//        lgw_spi_w(spi_target, spi_mux_mode, LGW_SPI_MUX_TARGET_SX1301, 0xAA, 0x96);
    for (i = 0; i < TIMING_REPEAT; ++i)
        lgw_spi_r(spi_target, spi_mux_mode, LGW_SPI_MUX_TARGET_SX1301, 0x55, &data);

printf("data received (simple read): 0x%0X\n",data);
//return 0;
*/

    /* 16b unsigned */
    uint16_t rvalue = (uint16_t)(-1);
    uint16_t wvalue = 0x03E5;
    //lgw_reg_w(LGW_PREAMBLE_SYMB1_NB, test_value);
    lgw_spi_wb(spi_target, spi_mux_mode, LGW_SPI_MUX_TARGET_SX1301, 96, &wvalue, 2);
    //lgw_reg_r(LGW_PREAMBLE_SYMB1_NB, &read_value);
    lgw_spi_rb(spi_target, spi_mux_mode, LGW_SPI_MUX_TARGET_SX1301, 96, &rvalue, 2);
    printf("PREAMBLE_SYMB1_NB = 0x%04X (should be 0x%04X)\n", rvalue, wvalue);


    /* burst R/W test, small bursts << LGW_BURST_CHUNK */

//    for (i = 0; i < TIMING_REPEAT; ++i)
//        lgw_spi_wb(spi_target, spi_mux_mode, LGW_SPI_MUX_TARGET_SX1301, 0x55, dataout, 16);
    for (i = 0; i < TIMING_REPEAT; ++i)
        lgw_spi_rb(spi_target, spi_mux_mode, LGW_SPI_MUX_TARGET_SX1301, 0x55, datain, 16);

printf("data received (burst read):");
for( uint8_t i=0; i<16; i++ )
  printf("0x%0X ",datain[i]);
printf("\n");
//return 0;

 return 0;


    /* burst R/W test, large bursts >> LGW_BURST_CHUNK */
    for (i = 0; i < TIMING_REPEAT; ++i)
        lgw_spi_wb(spi_target, spi_mux_mode, LGW_SPI_MUX_TARGET_SX1301, 0x5A, dataout, ARRAY_SIZE(dataout));
    for (i = 0; i < TIMING_REPEAT; ++i)
        lgw_spi_rb(spi_target, spi_mux_mode, LGW_SPI_MUX_TARGET_SX1301, 0x5A, datain, ARRAY_SIZE(datain));
    /* 5A is not relevant for large transferts ?!?!
    printf("\nLarge bursts tests ...\n");
    for( i=0; i<16; i++ ) {
        printf("0x%02X(0x%02X) ", datain[i], dataout[i]);
    }
    for( i=0; i<BURST_TEST_SIZE; i++ ) {
        if( datain[i] != dataout[i] ) {
            printf("\n###ERROR: datain buffer does not match dataout buffer (i=%d) !\n", i);
            break;
        }
    }
    */

    /* last read (blocking), just to be sure no to quit before the FTDI buffer is flushed */
    lgw_spi_r(spi_target, spi_mux_mode, LGW_SPI_MUX_TARGET_SX1301, 0x55, &data);
    printf("data received (simple read): %d\n",data);

    lgw_spi_close(spi_target);
    printf("End of test for loragw_spi.c\n");

    return 0;
}

/* --- EOF ------------------------------------------------------------------ */
