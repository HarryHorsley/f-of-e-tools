// write_file_ex.v
// note that, we need to create Modelsim project to run this file,
// or provide full path to the input-file i.e. adder_data.txt  

`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module write_file_ex;
    
    reg a, b, sum_expected, carry_expected;
    // [3:0] = 4 bit data
    // [0:5] = 6 rows  in the file adder_data.txt
    reg[3:0] read_data [0:5];

    integer write_data;
    integer i;

    initial
    begin 

        // readmemb = read the binary values from the file
        // other option is 'readmemh' for reading hex values
        // create Modelsim project to use relative path with respect to project directory
        $readmemb("input_output_files/adder_data.txt", read_data);
        // or provide the compelete path as below
        // $readmemb("D:/Testbences/input_output_files/adder_data.txt", read_data);

        // write data : provide full path or create project as above
        write_data = $fopen("input_output_files/write_file_ex.txt");
        
        for (i=0; i<6; i=i+1)
        begin
            {a, b, sum_expected, carry_expected} = read_data[i];
            #20;

            // write data to file using 'fdisplay'
            $fdisplay(write_data, "%b_%b_%b_%b", a, b, sum_expected, carry_expected);
        end

        $fclose(write_data);  // close the file
    end


endmodule
