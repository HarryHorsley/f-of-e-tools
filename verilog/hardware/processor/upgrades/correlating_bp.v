/*
	Authored 2018-2019, Ryan Voo.

	All rights reserved.
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions
	are met:

	*	Redistributions of source code must retain the above
		copyright notice, this list of conditions and the following
		disclaimer.

	*	Redistributions in binary form must reproduce the above
		copyright notice, this list of conditions and the following
		disclaimer in the documentation and/or other materials
		provided with the distribution.

	*	Neither the name of the author nor the names of its
		contributors may be used to endorse or promote products
		derived from this software without specific prior written
		permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
	FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
	COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
	INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
	LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
	ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.
*/



/*
 *		Branch Predictor FSM
 */

module branch_predictor(
		clk,
		actual_branch_decision,
		branch_decode_sig,
		branch_mem_sig,
		in_addr,
		offset,
		branch_addr,
		prediction
	);

	/*
	 *	inputs
	 */
	input		clk;
	input		actual_branch_decision;
	input		branch_decode_sig;
	input		branch_mem_sig;
	input [31:0]	in_addr;
	input [31:0]	offset;

	/*
	 *	outputs
	 */
	output [31:0]	branch_addr;
	output		prediction;

	/*
	 *	internal state
	 */
	reg [3:0] 	branch_history_reg;
 	reg [2:0] 	global_history_reg [15:0];
	reg		branch_mem_sig_reg;
	
	initial begin
		branch_history_reg = 4'b0000;
		global_history_reg[15:0] = 2'b00;
		branch_mem_sig_reg = 1'b0;
	end

	always @(negedge clk) begin
		branch_mem_sig_reg <= branch_mem_sig;
	end
	
	always @(posedge clk) begin
		if (branch_mem_sig_reg) begin
			branch_history_reg <= branch_history_reg << 1;
			branch_history_reg[0] <= actual_branch_decision;
			global_history_reg[branch_history_reg][1] <= (global_history_reg[branch_history_reg][1]&global_history_reg[branch_history_reg][0]) | (global_history_reg[branch_history_reg][0]&actual_branch_decision) | (global_history_reg[branch_history_reg][1]&actual_branch_decision);
			global_history_reg[branch_history_reg][0] <= actual_branch_decision;
		end
	end

	assign branch_addr = in_addr + offset;
	assign prediction = global_history_reg[branch_history_reg][1] & branch_decode_sig;
endmodule

