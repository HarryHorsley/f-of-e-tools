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

    always @* begin
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

    reg[31:0] add_out;
    reg[31:0] and_out;
    reg[31:0] shift_out;
    reg[31:0] xor_out;

    // Implement addition/subtraction with an SB_MAC16 instance
    // Input 1 (A_fwd) = {A[15:0], B[15:0]}
    // Input 2 (B_fwd) = {C[15:0], D[15:0]}
    //
    /*
    SB_MAC16 sb_mac16_adder(
        .A(A_fwd[31:16]),
        .B(A_fwd[15:0]),
        .C(B_fwd[31:16]),
        .D(B_fwd[15:0]),
        .ADDSUBTOP(sub), // Controls add/sub
        .ADDSUBBOT(sub),
        .CI(sub),
        .OLOADBOT(1'b0), // Controls output from bottom adder
        .OLOADTOP(1'b0), // Controls output from top adder
        .O(add_out)
    );
    defparam sb_mac16_adder.C_REG = 1'b0; // Not registered, meaning
    defparam sb_mac16_adder.A_REG = 1'b0; // not loaded into a register.
    defparam sb_mac16_adder.B_REG = 1'b0;
    defparam sb_mac16_adder.D_REG = 1'b0;

    defparam sb_mac16_adder.TOPOUTPUT_SELECT = 2'b00; // Top output add/sub, not registered
    defparam sb_mac16_adder.BOTOUTPUT_SELECT = 2'b00; // Bot output add/sub, not registered

    defparam sb_mac16_adder.TOPADDSUB_LOWERINPUT = 2'b00; // Pass input A to top adder
    defparam sb_mac16_adder.TOPADDSUB_UPPERINPUT = 1'b1; // Pass input C to top adder
    defparam sb_mac16_adder.BOTADDSUB_LOWERINPUT = 2'b00; // Pass input B to bot adder
    defparam sb_mac16_adder.BOTADDSUB_UPPERINPUT = 1'b1; // Pass input D to bot adder

    defparam sb_mac16_adder.TOPADDSUB_CARRYSELECT = 2'b11; // Pass CO from lower to CI of upper
    defparam sb_mac16_adder.BOTADDSUB_CARRYSELECT = 2'b11; // Pass CI(sub) to lower CI
    */

    always @* begin
        if (sub)
            add_out = A_fwd + ~B_fwd + 32'b1;
        else
            add_out = A_fwd + B_fwd;
        and_out = A_fwd & B_fwd;
        xor_out = A^B;
        case (ALUctl[2:0])
            3'b011: shift_out = A_fwd >> B_fwd[4:0]; // SRL
            3'b100: shift_out = A_fwd >>> B_fwd[4:0]; // SRA
            3'b101: shift_out = A_fwd << B_fwd[4:0]; // SLL
            default: shift_out = 0;
        endcase
    end

    reg[31:0] op_out;

    always @* begin
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


    always @* begin
        case (ALUctl[3:0])
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR: ALUOut = ~op_out;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB: ALUOut = op_out;
            // For SLT, set to 32'b1 if op_out is negative, so just take the
            // sign bit of op_out and pad with zeros at the start.
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT:
                ALUOut = $signed(A_fwd) < $signed(B_fwd) ? 32'b1 : 32'b0; //{31'b0, op_out[31]};
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW: ALUOut = op_out;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS: ALUOut = ~op_out;
            default: ALUOut = op_out;
        endcase
    end

    reg ALUOut_Zero_Check;
    always @* begin
        if (op_out===0)
            ALUOut_Zero_Check = 1;
        else
            ALUOut_Zero_Check = 0;
    end

    reg Branch_Result;

    // All branches use the SUB operation.
    // For BEQ, BNE, Branch_Result = ALUOut_Zero_Check
    // For BLT, BGE, BLTU, BGEU, Branch_Result = ALUOut[31], which assuming
    // ALUOut is signed, will be 1 if it is negative.

    always @* begin
        if (ALUctl[6]) begin
            if (ALUctl[5]) // unsigned
                Branch_Result = $unsigned(A_fwd) < $unsigned(B_fwd) ? 32'b1 : 32'b0;
            else // signed
                Branch_Result = $signed(A_fwd) < $signed(B_fwd) ? 32'b1 : 32'b0;
            end
        else
            Branch_Result = ALUOut_Zero_Check;
    end
    /* mux2to1 is 32-bit, so just use the above instead
    mux2to1 branch_result_mux(
        .input0(ALUOut_Zero_Check),
        .input1(ALUOut[31]),
        .select(ALUctl[6]),
        .out(Branch_Result)
    );
    */

    always @* begin
        // ALUctl[6:4] = 010 when branching is unused
        if (~ALUctl[6] & ALUctl[5] & ~ALUctl[4]) begin
            Branch_Enable = 1'b0;
        end
        else begin
            if (ALUctl[4])
                Branch_Enable = ~Branch_Result;
            else
                Branch_Enable = Branch_Result;
        end
    end

endmodule
