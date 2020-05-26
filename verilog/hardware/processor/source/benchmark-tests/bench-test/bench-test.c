#include <stdio.h>
#include <complex.h>

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

	
	while (1) {
		
	*debugLEDs = 0xFF;
	
	int PI = 3;
	cplx buf[] = {1, 1, 0, 0};
	//_fft(buf, buf, 1, 1);
	//fft(buf, 4);
	for (int i = 0; i < 8; i += 2) {
			cplx t = 2**(-I * PI * i / 8) * 11;
			buf[i / 2]     = 11 + t;
			buf[(i + 8)/2] = 11 - t;
		}
    
	*debugLEDs = 0x00;
	
	}
	
}

