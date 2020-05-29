module demuxe1to2(
  input [31:0] input0,
  input select,
  output [31:0] output0,
  output [31:0] output1
);
  
 assign output1 = (select) ? 0 : input0;
 assign output0 = (select) ? input0 : 0;
