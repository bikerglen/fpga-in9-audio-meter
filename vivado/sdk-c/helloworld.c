#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xil_io.h"
#include <math.h>

#define AUDIO_TEST_0_REG 			(XPAR_AUDIO_WRAPPER_0_BASEADDR + 0x00)
#define AUDIO_TEST_1_REG 			(XPAR_AUDIO_WRAPPER_0_BASEADDR + 0x04)
#define AUDIO_TEST_2_REG 			(XPAR_AUDIO_WRAPPER_0_BASEADDR + 0x08)
#define AUDIO_TEST_3_REG 			(XPAR_AUDIO_WRAPPER_0_BASEADDR + 0x0C)
#define AUDIO_TIMEBASE_VALUE_REG 	(XPAR_AUDIO_WRAPPER_0_BASEADDR + 0x10)
#define AUDIO_TIMEBASE_FLAG_REG 	(XPAR_AUDIO_WRAPPER_0_BASEADDR + 0x14)
#define AUDIO_PEAK_BLOCK_SIZE_REG 	(XPAR_AUDIO_WRAPPER_0_BASEADDR + 0x18)
#define AUDIO_PEAK_FIFO_EMPTY_REG	(XPAR_AUDIO_WRAPPER_0_BASEADDR + 0x1C)
#define AUDIO_PEAK_FIFO_DATA_REG	(XPAR_AUDIO_WRAPPER_0_BASEADDR + 0x20)

#define BARGRAPH_ADDR_REG (XPAR_RGB_LED_BARGRAPH_0_BASEADDR + 0x00)
#define BARGRAPH_DATA_REG (XPAR_RGB_LED_BARGRAPH_0_BASEADDR + 0x04)
#define BARGRAPH_BUFFER_REG (XPAR_RGB_LED_BARGRAPH_0_BASEADDR + 0x08)
#define BARGRAPH_BRIGHTNESS_REG (XPAR_RGB_LED_BARGRAPH_0_BASEADDR + 0x0C)
#define BARGRAPH_TIMER_REG (XPAR_RGB_LED_BARGRAPH_0_BASEADDR + 0x10)
#define BARGRAPH_TIMER_FLAG_REG (XPAR_RGB_LED_BARGRAPH_0_BASEADDR + 0x14)

void SetLevels (void);
void SetDot (uint16_t base, uint8_t n, uint8_t r, uint8_t g, uint8_t b);

const uint8_t gamma8[] = {
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  1,  1,
    1,  1,  1,  1,  1,  1,  1,  1,  1,  2,  2,  2,  2,  2,  2,  2,
    2,  3,  3,  3,  3,  3,  3,  3,  4,  4,  4,  4,  4,  5,  5,  5,
    5,  6,  6,  6,  6,  7,  7,  7,  7,  8,  8,  8,  9,  9,  9, 10,
   10, 10, 11, 11, 11, 12, 12, 13, 13, 13, 14, 14, 15, 15, 16, 16,
   17, 17, 18, 18, 19, 19, 20, 20, 21, 21, 22, 22, 23, 24, 24, 25,
   25, 26, 27, 27, 28, 29, 29, 30, 31, 32, 32, 33, 34, 35, 35, 36,
   37, 38, 39, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 50,
   51, 52, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 66, 67, 68,
   69, 70, 72, 73, 74, 75, 77, 78, 79, 81, 82, 83, 85, 86, 87, 89,
   90, 92, 93, 95, 96, 98, 99,101,102,104,105,107,109,110,112,114,
  115,117,119,120,122,124,126,127,129,131,133,135,137,138,140,142,
  144,146,148,150,152,154,156,158,160,162,164,167,169,171,173,175,
  177,180,182,184,186,189,191,193,196,198,200,203,205,208,210,213,
  215,218,220,223,225,228,231,233,236,239,241,244,247,249,252,255 };

uint8_t buffer = 0;
uint8_t levels[1][48][3];

#define SCALE  16.0F
#define OFFSET  2.0F
#define DECAY   0.0075F

void LevelsToDots (float *state, int16_t level, uint8_t *nLeds, uint8_t *dac);
void spiSend (int n, unsigned char *d);

int main()
{
	int i;
	uint8_t spiData[2];

    init_platform ();

    print("Hello, world!\n\r");

    printf ("%08lx\n\r", Xil_In32 (AUDIO_TEST_0_REG));
    printf ("%08lx\n\r", Xil_In32 (AUDIO_TEST_1_REG));
    printf ("%08lx\n\r", Xil_In32 (AUDIO_TEST_2_REG));
    printf ("%08lx\n\r", Xil_In32 (AUDIO_TEST_3_REG));

    // configure manual slave select, spi mode 2 (CPOL=1, CPHA=0), master mode, enabled
	Xil_Out32 (XPAR_SPI_0_BASEADDR + 0x60, 0x8E);

	for (i = 0; i < 5; i++) {
		// clear timer flag then wait for timer flag to be set
		Xil_Out32 (BARGRAPH_TIMER_FLAG_REG, 0x1);
		while (Xil_In32 (BARGRAPH_TIMER_FLAG_REG) == 0) {
		}
	}

    // initiailze DAC, slow mode, powered up, use 2.048V internal ref voltage
    spiData[0] = 0x90;
    spiData[1] = 0x02;
    spiSend (2, spiData);

    // write DAC B value to buffer
    spiData[0] = 0x10;
    spiData[1] = 0x00;
    spiSend (2, spiData);

    // write DAC A value and move buffer to DAC B simultaneously
    spiData[0] = 0x80;
    spiData[1] = 0x00;
    spiSend (2, spiData);

    // blank both display buffers
    Xil_Out32 (BARGRAPH_ADDR_REG, 0x00000000);
    for (i = 0; i < 512; i++) {
        Xil_Out32 (BARGRAPH_DATA_REG, 0x00000000);
    }

    // select display buffer 0
    Xil_Out32 (BARGRAPH_BUFFER_REG, 0x0);

    // set global brightness to full
    Xil_Out32 (BARGRAPH_BRIGHTNESS_REG, 0x100);

    // set periodic interval timer to 30Hz
    Xil_Out32 (BARGRAPH_TIMER_REG, 1666666);

    float state_left = 0;
    float state_right = 0;

    while (1) {
		uint8_t leds_left, leds_right, dac_left, dac_right;
		uint8_t spiData[2];

		if (!Xil_In32 (AUDIO_PEAK_FIFO_EMPTY_REG)) {
    		uint32_t d = Xil_In32 (AUDIO_PEAK_FIFO_DATA_REG);
    		int16_t l_int = (d >> 16);
    		int16_t r_int = (d & 0xffff);

    		LevelsToDots (&state_left, l_int, &leds_left, &dac_left);
    		LevelsToDots (&state_right, r_int, &leds_right, &dac_right);

			for (i = 0; i < 48; i++) {
				levels[0][i][0] = (i < leds_left) ? 255 : 0;
			}
			SetLevels ();

		    // write DAC B value to buffer
		    spiData[0] = 0x10 | ((dac_right >> 4) & 0x0f);
		    spiData[1] = 0x00 | ((dac_right << 4) & 0xf0);
		    spiSend (2, spiData);

		    // write DAC A value and move buffer to DAC B simultaneously
		    spiData[0] = 0x80 | ((dac_left >> 4) & 0x0f);
		    spiData[1] = 0x00 | ((dac_left << 4) & 0xf0);
		    spiSend (2, spiData);

		    xil_printf (".");
			// printf ("%2d %3d\n\r", leds_left, dac_left);
    	}
    }


    cleanup_platform();

    return 0;
}


void LevelsToDots (float *state, int16_t level, uint8_t *nLeds, uint8_t *dac)
{
	float dB = (float)level / 128.0;

	float percent = (dB + OFFSET + SCALE) / SCALE;			// each segment represents 1.5dB
	if (percent > 1.0) percent = 1.0;
	else if (percent < 0.0) percent = 0.0;

	float decayed = *state - DECAY;
	if (decayed < 0) decayed = 0;
	*state = (percent > decayed) ? percent : decayed;
	*nLeds = ceil (*state * 48);
	*dac = ceil (*state * 255);
}


void SetLevels (void)
{
	int n;
	uint16_t base;

	if (buffer == 0) {
		base = 0x000;
	} else {
		base = 0x100;
	}

	for (n = 0; n < 48; n++) {
		SetDot (base, n, levels[0][n][0], levels[0][n][1], levels[0][n][2]);
	}

	if (buffer == 0) {
		Xil_Out32 (BARGRAPH_BUFFER_REG, 0x0);
		buffer = 1;
	} else {
		Xil_Out32 (BARGRAPH_BUFFER_REG, 0x1);
		buffer = 0;
	}
}


void SetDot (uint16_t base, uint8_t n, uint8_t r, uint8_t g, uint8_t b)
{
	uint8_t row = 16*(n/3);
	uint8_t col = 13 - 3*(n%3);
	uint16_t address = base + row + col;

    Xil_Out32 (BARGRAPH_ADDR_REG, address);
	Xil_Out32 (BARGRAPH_DATA_REG, gamma8[b]);
	Xil_Out32 (BARGRAPH_DATA_REG, gamma8[g]);
	Xil_Out32 (BARGRAPH_DATA_REG, gamma8[r]);
}


void spiSend (int n, uint8_t *data)
{
	uint16_t chip_selects;

	chip_selects = 0xFFFF & ~1;
	Xil_Out32 (XPAR_SPI_0_BASEADDR + 0x70, chip_selects);

	while (n--) {
		Xil_Out32 (XPAR_SPI_0_BASEADDR + 0x68, *data++);
		while (Xil_In32 (XPAR_SPI_0_BASEADDR + 0x64) & 0x8) {
		}
	}

	Xil_Out32 (XPAR_SPI_0_BASEADDR + 0x70, 0xFFFF);
}

