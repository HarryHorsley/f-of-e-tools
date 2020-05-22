int
main(void)
{
	/*
	 *	Reading from the special address 0x2000 will cause sail to
	 *	set the value of 8 of the FPGA's pins to the byte written
	 *	to the address. See the PCF file for how those 8 pins are
	 *	mapped.
	 */
	volatile unsigned int *		debugLEDs = (unsigned int *)0x8004000;

  unsigned int i = 3;
  unsigned int j = 6;
  unsigned int z;
  
	enum
	{
		kSpinDelay = 400000,
	};

	while(1)
	{
		*debugLEDs = 0xFF;
    z = i + j; // Addition
    z = j - i; // Subtraction
    z = j / i; // Division
		/*
		 *	Spin
		 */
		for (int j = 0; j < kSpinDelay; j++);
    
		*debugLEDs = 0x00;
    z = 3 + 6;
    z = 6 - 3;
    z = 6 / 3; // Integer division
		/*
		 *	Spin
		 */
		for (int j = 0; j < kSpinDelay; j++);		
	}
}
