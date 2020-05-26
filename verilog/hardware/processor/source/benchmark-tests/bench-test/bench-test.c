#include <stdio.h>
#include <math.h>
#include <complex.h>
 
double PI;
typedef double complex cplx;
 
// void _fft(cplx buf[], cplx out[], int n, int step)
// {
// 	if (step < n) {
// 		_fft(out, buf, n, step * 2);
// 		_fft(out + step, buf + step, n, step * 2);
 
// 		for (int i = 0; i < n; i += 2 * step) {
// 			cplx t = cexp(-I * PI * i / n) * out[i + step];
// 			buf[i / 2]     = out[i] + t;
// 			buf[(i + n)/2] = out[i] - t;
// 		}
// 	}
// }
 
// void fft(cplx buf[], int n)
// {
// 	cplx out[n];
// 	for (int i = 0; i < n; i++) out[i] = buf[i];
 
// 	_fft(buf, out, n, 1);
// }

int main(void)
{
	/*
	 *	Reading from the special address 0x2000 will cause sail to
	 *	set the value of 8 of the FPGA's pins to the byte written
	 *	to the address. See the PCF file for how those 8 pins are
	 *	mapped.
	 */
	volatile unsigned int *		debugLEDs = (unsigned int *)0x8004000;

	while(1)
	{
		*debugLEDs = 0xFF;
		
    	PI = atan2(1, 1) * 4;
	//cplx buf[] = {1, 1, 0, 0};
	//fft(buf, 4);
    
		*debugLEDs = 0x00;		
	}
}
