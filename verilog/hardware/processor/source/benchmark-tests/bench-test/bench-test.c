#include <stdlib.h>
#include <stdio.h>

#define MIN(X, Y) (((X) < (Y)) ? (X) : (Y))
#define MAX(X, Y) (((X) < (Y)) ? (Y) : (X))

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
	
	int h[] = { 1.0, 4.0, 1.0, 1.0, 24.0,4,9,6,78};
  	int x[] = { 1.0, 1.0, 1.0, 3.0, 1.0,3,87,1,6};
	int lenH = 9;
  	int nconv = lenH+lenH-1;
  	int i,j,h_start,x_start,x_end,y,m;
	for (m=0; m<10000; m++){	//This is to make enough iterations for a period of time between LED flashes
  	for (i=0; i<nconv; i++)
  	{
    	x_start = MAX(0,i-lenH+1);
    	x_end   = MIN(i+1,lenH);
    	h_start = MIN(i,lenH-1);
    	for(j=x_start; j<x_end; j++)
    	{
      		y += h[h_start--]*x[j];
   	 }
	}
		y = 0;
	}
    
	*debugLEDs = 0x00;
	
	}
	
}

