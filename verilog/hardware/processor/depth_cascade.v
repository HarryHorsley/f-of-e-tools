module new_instr_mem(
  input [15:0] addr,
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
  wire select_addr_dataout = addr [14];
  wire wren_select = addr [15];
  
  demux1to2()
  
  cascaded_mem cascade0(
    .addr(addr [13:0])
    .data_in(data_choice_0 [31:0])
    .chip_sel(chip_sel)
    .wren(wren)
    .cl(clk)
    .standby(standby)
    .sleep(sleep)
    .poweroff(poweroff)
    .data_out(data_out_0 [31:0])
  )
  
 cascaded_mem cascade1(
    .addr(addr [13:0])
   .data_in(data_choice_1 [31:0])
    .chip_sel(chip_sel)
    .wren(wren)
    .cl(clk)
    .standby(standby)
    .sleep(sleep)
    .poweroff(poweroff)
   .data_out(data_out_1 [31:0])
  )
