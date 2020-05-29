`include "../include/rv32i-defines.v"
`include "../include/sail-core-defines.v"

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
            // AND, 0000, out = A & B
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_AND: op_out = and_out;

            // OR, 0001, out = A | B
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR: op_out = and_out;

            // ADD, 0010, out = A + B
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ADD: op_out = add_out;

            // SUB, 0110, out = A - B
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB: op_out = add_out;

            // SLT, 0111, out = (A < B ? 1 : 0)
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT: op_out = add_out;

            // SRL, 0011, out = A>>B[4:0]
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRL: op_out = shift_out;

            // SRA, 0100, out = A>>>B[4:0]
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRA: op_out = shift_out;

            // SLL, 0101, out = A<<B[4:0]
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLL: op_out = shift_out;

            // XOR, 1000, out = A ^ B
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_XOR: op_out = xor_out;

            // CSRRW, 1001, out = A
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW:	op_out = and_out;

            // CSRRS, 1010, out = A | B
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS:	op_out = and_out;

            // CSRRC, 1011, out = ~A & B
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRC:	op_out = and_out;

            // Shouldn't happen
			default: op_out = 0;
		endcase
	end

    always @(ALUctl, op_out) begin
        case (ALUctl[3:0])
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR: ALUOut = ~op_out;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB: ALUOut = op_out;
            // For SLT, set to 32'b1 if op_out is negative, so just take the
            // sign bit of op_out and pad with zeros at the start.
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT: ALUOut = {31'b0, op_out[31]};
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW: ALUOut = op_out;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS: ALUOut = ~op_out;
            default: ALUOut = op_out;
        endcase
    end

    wire ALUOut_Zero_Check;
    assign ALUOut_Zero_Check = (ALUOut==0 ? 1'b1 : 1'b0);

    wire Branch_Result;
    wire Branch_Result_Inv;

    // All branches use the SUB operation.
    // For BEQ, BNE, Branch_Result = ALUOut_Zero_Check
    // For BLT, BGE, BLTU, BGEU, Branch_Result = ALUOut[31], which assuming
    // ALUOut is signed, will be 1 if it is negative.
    mux2to1 branch_result_mux(
        .input0(ALUOut_Zero_Check[0]),
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
