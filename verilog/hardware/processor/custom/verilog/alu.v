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



`include "../include/rv32i-defines.v"
`include "../include/sail-core-defines.v"



/*
 *	Description:
 *
 *		This module implements the ALU for the RV32I.
 */



/*
 *	Not all instructions are fed to the ALU. As a result, the ALUctl
 *	field is only unique across the instructions that are actually
 *	fed to the ALU.
 */
module alu(ALUctl, A, B, ALUOut, Branch_Enable);
	input [6:0]		ALUctl;
	input [31:0]		A;
	input [31:0]		B;
	output reg [31:0]	ALUOut;
	output reg          Branch_Enable;

    reg[31:0] A_fwd;
    reg[31:0] B_fwd;
    reg sub;

    always @(ALUctl, A, B) begin
        case (ALUctl[3:0])
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR:
            begin
                A_fwd = ~A;
                B_fwd = ~B;
            end
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW:
            begin
                A_fwd = A;
                B_fwd = 32'hFFFFFFFF; // Result = A = A & 1
            end
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS:
            begin
                A_fwd = ~A;
                B_fwd = ~B;
            end
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRC:
            begin
                A_fwd = ~A;
                B_fwd = B;
            end
            default:
            begin
                A_fwd = A;
                B_fwd = B;
            end
        endcase
        case (ALUctl[3:0])
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB: sub=1'b1;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT: sub=1'b1;
            default: sub=1'b0;
        endcase
    end

    wire[31:0] add_out;
    wire[31:0] and_out;
    reg[31:0] shift_out;
    wire[31:0] xor_out;

    // assign add_out = A_fwd + B_fwd + c_in
    // Replace the above with an instantiation of the iCE40 DSP with
    // appropriate settings for 32x32 Adder / Subtractor

    SB_MAC16 sb_mac16_adder(
        .CLK(1'b0), // Clock and clock enable
        .CE(1'b0),  // Is it fine to disable the clock if using the adder?
        .A(A_fwd[15:0]),
        .B(B_fwd[15:0]),
        .C(A_fwd[31:16]),
        .D(B_fwd[31:16]),
        .ADDSUBTOP(sub),
        .ADDSUBBOT(sub),
        .O(add_out)
    );

    assign and_out = A_fwd & B_fwd;
    assign xor_out = A^B;

    always @(A_fwd, B_fwd) begin
        case (ALUctl[4:1])
            001: shift_out = A_fwd >> B_fwd[4:0];
            010: shift_out = A_fwd >>> B_fwd[4:0];
            100: shift_out = A_fwd << B_fwd[4:0];
            default: shift_out = A_fwd >> B_fwd[4:0];
        endcase
    end

    reg[31:0] op_out;

	always @(ALUctl, add_out, and_out, shift_out, xor_out) begin
		case (ALUctl[3:0])
			/*
			 *	AND (the fields also match ANDI and LUI)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_AND: op_out = and_out;

			/*
			 *	OR (the fields also match ORI)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR: op_out = and_out;

			/*
			 *	ADD (the fields also match AUIPC, all loads, all stores, and ADDI)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ADD: op_out = add_out;

			/*
			 *	SUBTRACT (the fields also matches all branches)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB: op_out = add_out;

			/*
			 *	SLT (the fields also matches all the other SLT variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT: op_out = add_out;

			/*
			 *	SRL (the fields also matches the other SRL variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRL: op_out = shift_out;

			/*
			 *	SRA (the fields also matches the other SRA variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRA: op_out = shift_out;

			/*
			 *	SLL (the fields also match the other SLL variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLL: op_out = shift_out;

			/*
			 *	XOR (the fields also match other XOR variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_XOR: op_out = xor_out;

			/*
			 *	CSRRW  only
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW:	op_out = and_out;

			/*
			 *	CSRRS only
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS:	op_out = and_out;

			/*
			 *	CSRRC only
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRC:	op_out = and_out;

			/*
			 *	Should never happen.
			 */
			default: op_out = 0;
		endcase
	end

    always @(ALUctl, op_out) begin
        case (ALUctl[3:0])
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR: ALUOut = ~op_out;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB: ALUOut = op_out;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT: ALUOut = op_out[31];
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW: ALUOut = op_out;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS: ALUOut = ~op_out;
            default: ALUOut = op_out;
        endcase
    end

    wire Branch_Result;
    wire Branch_Result_Inv;
    wire Branch_Zero_Check;

    assign Branch_Zero_Check = (ALUOut==0);

    // Otherwise, ALUOut = A - B.
    // Branch_Result = 1 if A < B, so need ALUOut < 0, so ALUOut[31] == 1
    mux2to1 branch_result_mux(
        .input0(Branch_Zero_Check),
        .input1(ALUOut[31]),
        .select(ALUctl[6]),
        .out(Branch_Result)
    );

    assign Branch_Result_Inv = (~Branch_Result);

    mux2to1 branch_inv_mux(
        .input0(Branch_Result),
        .input1(Branch_Result_Inv),
        .select(ALUctl[4]),
        .out(Branch_Enable)
    );


endmodule
