// #include <stdio.h>
// #include <math.h>
// #include <complex.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct vector_ {
    void** data;
    int size;
    int count;
} vector;

void vector_init(vector *v)
{
	v->data = NULL;
	v->size = 0;
	v->count = 0;
}

void vector_add(vector *v, int *e)
{
	if (v->size == 0) {
		v->size = 10;
		v->data = malloc(sizeof(void*) * v->size);
		memset(v->data, '\0', sizeof(void) * v->size);
	}
}

// double PI;
// typedef double complex cplx;
 
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

	

	*debugLEDs = 0xFF;
		
	
	vector v;
	vector_init(&v);
	vector_add(&v, 0);
		
//     	PI = atan2(1, 1) * 4;
// 	cplx buf[] = {1, 1, 0, 0};
// 	_fft(buf, buf, 1, 1);
// 	//fft(buf, 4);
    
	*debugLEDs = 0x00;		
	
}
