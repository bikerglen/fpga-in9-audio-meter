//=============================================================================================
// FIXED-POINT CORDIC LOG10
// Copyright 2018 by Glen Akins.
// All rights reserved.
// 
// Set editor width to 96 and tab stop to 4.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//=============================================================================================

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <math.h>

#define NORM_STEPS       5
#define ROUNDS           8
#define ALPHA_FRAC_BITS 12

double   normf[NORM_STEPS];
uint32_t normi[NORM_STEPS];
double   alphaf[ROUNDS];
uint32_t alphai[ROUNDS];

void BuildTables (void);

void clog10_24b (uint32_t x);

int main (int argc, char *argv[])
{
	BuildTables ();

	clog10_24b (0x000000);
	clog10_24b (0x000001);
	clog10_24b (0x600000);
	clog10_24b (0x808891);
	clog10_24b (0xdebeef);
	clog10_24b (0xFFFFFF);

	clog10_24b (0x800000);
	clog10_24b (0x400000);
	clog10_24b (0x200000);
	clog10_24b (0x100000);
	clog10_24b (0x080000);
	clog10_24b (0x040000);
	clog10_24b (0x020000);
	clog10_24b (0x010000);
	clog10_24b (0x008000);
	clog10_24b (0x004000);
	clog10_24b (0x002000);
	clog10_24b (0x001000);
	clog10_24b (0x000800);
	clog10_24b (0x000400);
	clog10_24b (0x000200);
	clog10_24b (0x000100);
	clog10_24b (0x000080);
	clog10_24b (0x000040);
	clog10_24b (0x000020);
	clog10_24b (0x000010);
	clog10_24b (0x000008);
	clog10_24b (0x000004);
	clog10_24b (0x000002);
	clog10_24b (0x000001);

	return 0;
}


//---------------------------------------------------------------------------------------------
// Build Alpha Table
//
// Calculates log10 (65536), log10 (256), log10 (16), log10 (4) ...
// Calculates log10 (3/2), log10 (5/4), log10 (9/8), log10 (17/16) ...
//

void BuildTables (void)
{
	printf ("Building normalization table.\n");
	for (int step = 0; step < NORM_STEPS; step++) {
		double power = pow (2, (1 << (4-step)));
		normf[step] = log10 (power);
		normi[step] = normf[step] * pow (2, ALPHA_FRAC_BITS);
		printf ("%2d %12.6f %12.6f %12d\n", step, power, normf[step], normi[step]);
	}

	printf ("Building alpha table.\n");
	for (int round = 0; round < ROUNDS; round++) {
		double fraction = (1 + pow (2, -(1 + round)));
		alphaf[round] = log10 (fraction);
		alphai[round] = alphaf[round] * pow (2, ALPHA_FRAC_BITS);
		printf ("%2d %12.6f %12.6f %12d\n", round, fraction, alphaf[round], alphai[round]);
	}
	
	printf ("\n");
}


//---------------------------------------------------------------------------------------------
// Calculate log10 (x)
//

void clog10_24b (uint32_t x)
{
	// calculate using built in functions and print result
	double f = (double)x/(double)16777216;
	double l = log10 (f);
	printf ("using built-in fp functions: x: %12.6f, y: %12.6f\n", f, l);

	// initialize result variable
	double y = 0;
	int32_t yi = 0;

	// normalize input
	if ((x & 0xFFFF00) == 0) { x <<= 16; y -= normf[0]; yi -= normi[0]; }
	if ((x & 0xFF0000) == 0) { x <<=  8; y -= normf[1]; yi -= normi[1]; }
	if ((x & 0xF00000) == 0) { x <<=  4; y -= normf[2]; yi -= normi[2]; }
	if ((x & 0xC00000) == 0) { x <<=  2; y -= normf[3]; yi -= normi[3]; }
	if ((x & 0x800000) == 0) { x <<=  1; y -= normf[4]; yi -= normi[4]; }

	// run rounds
	for (int round = 0; round < ROUNDS; round++) {
		uint32_t tmp = x + (x >> (1+round)); 
		if ((tmp & 0xff000000) == 0) { x = tmp; y -= alphaf[round]; yi -= alphai[round]; }
	}

	// print result
	printf ("float cordic results:                            %12.6f\n", y);
	printf ("int cordic result:                               %12.6f %d\n", 
			(double)yi/(double)pow (2, ALPHA_FRAC_BITS), yi);
	printf ("\n");
}
