// // #include <stdio.h>
// // #include <math.h>
// // #include <complex.h>

// // double PI;
// // typedef double complex cplx;
 
// // void _fft(cplx buf[], cplx out[], int n, int step)
// // {
// // 	if (step < n) {
// // 		_fft(out, buf, n, step * 2);
// // 		_fft(out + step, buf + step, n, step * 2);
 
// // 		for (int i = 0; i < n; i += 2 * step) {
// // 			cplx t = cexp(-I * PI * i / n) * out[i + step];
// // 			buf[i / 2]     = out[i] + t;
// // 			buf[(i + n)/2] = out[i] - t;
// // 		}
// // 	}
// // }
 
// // void fft(cplx buf[], int n)
// // {
// // 	cplx out[n];
// // 	for (int i = 0; i < n; i++) out[i] = buf[i];
 
// // 	_fft(buf, out, n, 1);
// // }

// int main(void)
// {
// 	/*
// 	 *	Reading from the special address 0x2000 will cause sail to
// 	 *	set the value of 8 of the FPGA's pins to the byte written
// 	 *	to the address. See the PCF file for how those 8 pins are
// 	 *	mapped.
// 	 */
// 	volatile unsigned int *		debugLEDs = (unsigned int *)0x8004000;

	
// 	while (1) {
		
// 	*debugLEDs = 0xFF;
		
	
		
// //     	PI = atan2(1, 1) * 4;
// // 	cplx buf[] = {1, 1, 0, 0};
// // 	_fft(buf, buf, 1, 1);
// // 	//fft(buf, 4);
    
// 	*debugLEDs = 0x00;
	
// 	}
	
// }
#include <complex>
#define MAX 200

#define M_PI 3.1415926535897932384

int log2(int N)    /*function to calculate the log2(.) of int numbers*/
{
  int k = N, i = 0;
  while(k) {
    k >>= 1;
    i++;
  }
  return i - 1;
}

int reverse(int N, int n)    //calculating revers number
{
  int j, p = 0;
  for(j = 1; j <= log2(N); j++) {
    if(n & (1 << (log2(N) - j)))
      p |= 1 << (j - 1);
  }
  return p;
}

void ordina(complex<double>* f1, int N) //using the reverse order in the array
{
  complex<double> f2[MAX];
  for(int i = 0; i < N; i++)
    f2[i] = f1[reverse(N, i)];
  for(int j = 0; j < N; j++)
    f1[j] = f2[j];
}

void transform(complex<double>* f, int N) //
{
  ordina(f, N);    //first: reverse order
  complex<double> *W;
  W = (complex<double> *)malloc(N / 2 * sizeof(complex<double>));
  W[1] = polar(1., -2. * M_PI / N);
  W[0] = 1;
  for(int i = 2; i < N / 2; i++)
    W[i] = pow(W[1], i);
  int n = 1;
  int a = N / 2;
  for(int j = 0; j < log2(N); j++) {
    for(int i = 0; i < N; i++) {
      if(!(i & n)) {
        complex<double> temp = f[i];
        complex<double> Temp = W[(i * a) % (n * a)] * f[i + n];
        f[i] = temp + Temp;
        f[i + n] = temp - Temp;
      }
    }
    n *= 2;
    a = a / 2;
  }
  free(W);
}

void FFT(complex<double>* f, int N, double d)
{
  transform(f, N);
  for(int i = 0; i < N; i++)
    f[i] *= d; //multiplying by step
}

int main()
{
complex<double> vec[MAX];

vec[0] = 1;
vec[1] = 0;
FFT(vec, int 2, double 1);
  return 0;
}
