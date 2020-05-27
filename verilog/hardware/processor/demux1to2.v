module demuxe1to2(
  input [31:0] input0,
  input select,
  output [31:0] output0,
  output [31:0] output1
)
  if (select)
    assign output1 = input0;
    assign output0 = 0; //just set to 0 here?
  else
    assign output0 = input0;
    assign output1 = 0;
  
      
