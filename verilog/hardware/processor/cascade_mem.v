module data_cascaded_mem(
	input [13:0] addr,
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

SB_SPRAM256KA cascade0(
 .DATAIN(data_in [31:16]),
	.ADDRESS(addr [13:0]),
	.MASKWREN(mask_wren [7:0]),
 .WREN(wren),
 .CHIPSELECT(chip_sel),
 .CLOCK(clk),
 .STANDBY(standby),
 .SLEEP(sleep),
 .POWEROFF(poweroff),
 .DATAOUT(data_out [31:16])
) 

SB_SPRAM256KA cascade1(
 .DATAIN(data_in [15:0]),
 .ADDRESS(addr),
 .MASKWREN(mask_wren [7:0]),
 .WREN(wren),
 .CHIPSELECT(chip_sel),
 .CLOCK(clk),
 .STANDBY(standby),
 .SLEEP(sleep),
 .POWEROFF(poweroff),
 .DATAOUT(data_out [15:0])
) 
