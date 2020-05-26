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

#include <math.h>
#include <chrono>
using namespace std;
using namespace std::chrono;

// timer cribbed from
// https://gist.github.com/gongzhitaao/7062087
class Timer
{
public:
    Timer() : beg_(clock_::now()) {}
    void reset() { beg_ = clock_::now(); }
    double elapsed() const {
        return duration_cast<second_>
            (clock_::now() - beg_).count();
    }

private:
    typedef high_resolution_clock clock_;
    typedef duration<double, ratio<1>> second_;
    time_point<clock_> beg_;
};

int main(char* argv)
{
    double total;
    Timer tmr;

#define randf() ((double) rand()) / ((double) (RAND_MAX))
#define OP_TEST(name, expr)               \
    total = 0.0;                          \
    srand(42);                            \
    tmr.reset();                          \
    for (int i = 0; i < 100000000; i++) { \
        double r1 = randf();              \
        double r2 = randf();              \
        total += expr;                    \
    }                                     \
    double name = tmr.elapsed();          \
    printf(#name);                        \
    printf(" %.7f\n", name - baseline);

    // time the baseline code:
    //   for loop with no extra math op
    OP_TEST(baseline, 1.0)

    // time various floating point operations.
    //   subtracts off the baseline time to give
    //   a better approximation of the cost
    //   for just the specified operation
    OP_TEST(plus, r1 + r2)
    OP_TEST(minus, r1 - r2)
    OP_TEST(mult, r1 * r2)
    OP_TEST(div, r1 / r2)
    OP_TEST(sqrt, sqrt(r1))
    OP_TEST(sin, sin(r1))
    OP_TEST(cos, cos(r1))
    OP_TEST(tan, tan(r1))
    OP_TEST(atan, atan(r1))
    OP_TEST(exp, exp(r1))
}
