module new_instr_mem(
	input [14:0] addr,
	input [31:0] data_in,
	input [7:0] mask_wren,
	input chip_sel,
	input wren,
	input clk,
	input standby,
	input sleep,
	input poweroff,
	output [31:0] data_out
)

  wire data_choice_0;
  wire data_choice_1;
  wire data_out_0;
  wire data_out_1;
  wire select = addr [14];
wire mask_wren_choice_0;
	wire mask_wren_choice_1;
  
  demux1to2 demux1to2_datain(
	  .input0(data_in [31:0]),
	  .select(select), //this is a wire, not a whatever the other one is.
	  .output0(data_choice_0), //also a wire
	  .output1(data_choice_1) //also a wire
  )
	
demux1to2 demux1to2_wren(
		.input0(mask_wren [7:0]),
		.select(select),
		.output0(mask_wren_choice_0),
		.output1(mask_wren_choice_1)
	)
	
mux2to1 mux2to1_dataout(
		.input0(data_out_0),
		.input1(data_out_1),
		.select(select),
		.out(data_out [31:0])
	)
  
  cascaded_mem cascade0(
	  .addr(addr [13:0]),
	  .data_in(data_choice_0 [31:0]),
	  .chip_sel(chip_sel),
	  .mask_wren(mask_wren_choice_0),
	  .wren(wren),
	  .cl(clk),
	  .standby(standby),
	  .sleep(sleep),
	  .poweroff(poweroff),
	  .data_out(data_out_0 [31:0])
  )
  
 cascaded_mem cascade1(
	 .addr(addr [13:0]),
	 .data_in(data_choice_1 [31:0]),
	 .chip_sel(chip_sel),
	 .mask_wren(mask_wren_choice_1),
	 .wren(wren),
	 .cl(clk),
	 .standby(standby),
	 .sleep(sleep),
	 .poweroff(poweroff),
   	 .data_out(data_out_1 [31:0])
  )
