`include "../include/rv32i-defines.v"
`include "../include/sail-core-defines.v"

module arg_forward(ALUctl, A, B, A_fwd, B_fwd);
	input [6:0]		ALUctl;
	input [31:0]		A;
	input [31:0]		B;
	output reg [31:0]		A_fwd;
	output reg [31:0]		B_fwd;

    always @* begin
        case (ALUctl[3:0])
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR:
            begin
                A_fwd = ~A;
                B_fwd = ~B;
            end
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW:
            begin
                A_fwd = A; // Output A = A & A
                B_fwd = A;
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
    end

endmodule

module sub_forward(ALUctl, sub);
    input [6:0] ALUctl;
    output reg sub;

    always @* begin
        case (ALUctl[3:0])
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB: sub=1'b1;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT: sub=1'b1;
            default: sub=1'b0;
        endcase
    end
endmodule

module op_select(ALUctl3to0, and_out, add_out, slt_out, srl_out,
                 sra_out, sll_out, xor_out, op_out);
    input [3:0] ALUctl3to0;
    input [31:0] and_out, add_out, slt_out, srl_out, sra_out, sll_out, xor_out;
    output reg [31:0] op_out;

    always @* begin
		case (ALUctl3to0)
            // AND, 0000, out = A & B
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_AND: op_out = and_out;

            // OR, 0001, out = A | B
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR: op_out = and_out;

            // ADD, 0010, out = A + B
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ADD: op_out = add_out;

            // SUB, 0110, out = A - B
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB: op_out = add_out;

            // SLT, 0111, out = (A < B ? 1 : 0)
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT: op_out = slt_out;

            // SRL, 0011, out = A>>B[4:0]
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRL: op_out = srl_out;

            // SRA, 0100, out = A>>>B[4:0]
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRA: op_out = sra_out;

            // SLL, 0101, out = A<<B[4:0]
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLL: op_out = sll_out;

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
module alu(ALUctl, A, B, ALUOut, Branch_Enable);
	input [6:0]		ALUctl;
	input [31:0]		A;
	input [31:0]		B;
	output reg [31:0]	ALUOut;
	output reg          Branch_Enable;

    wire[31:0] A_fwd;
    wire[31:0] B_fwd;
    wire sub;

    arg_forward ARG_FORWARD(
        .ALUctl(ALUctl),
        .A(A),
        .B(B),
        .A_fwd(A_fwd),
        .B_fwd(B_fwd)
    );
    sub_forward SUB_FORWARD(
        .ALUctl(ALUctl),
        .sub(sub)
    );

    wire [31:0] add_out;
    wire [31:0] and_out;
    wire [31:0] xor_out;
    wire [31:0] srl_out;
    wire [31:0] sra_out;
    wire [31:0] sll_out;
    wire [31:0] slt_out;

    // Implement addition/subtraction with an SB_MAC16 instance
    // Input 1 (A_fwd) = {A[15:0], B[15:0]}
    // Input 2 (B_fwd) = {C[15:0], D[15:0]}
    //
    wire [31:0] sb_mac16_out;
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
        .O(sb_mac16_out)
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

    defparam sb_mac16_adder.TOPADDSUB_CARRYSELECT = 2'b10; // Pass CO from lower to CI of upper
    defparam sb_mac16_adder.BOTADDSUB_CARRYSELECT = 2'b11; // Pass CI(sub) to lower CI

    //assign add_out = A_fwd + (sub?~B_fwd:B_fwd) + sub;
    assign add_out = sub ? ~sb_mac16_out : sb_mac16_out;
    assign and_out = A_fwd & B_fwd;
    assign xor_out = A_fwd ^ B_fwd;
    assign srl_out = A_fwd >> B_fwd[4:0];
    assign sra_out = A_fwd >>> B_fwd[4:0];
    assign sll_out = A_fwd << B_fwd[4:0];
    assign slt_out = $signed(A_fwd) < $signed(B_fwd) ? 32'b1 : 32'b0;

    reg[31:0] op_out;


    always @* begin
        case (ALUctl[3:0])
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR: ALUOut = ~op_out;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS: ALUOut = ~op_out;
            default: ALUOut = op_out;
        endcase
    end

    wire ALUOut_Zero_Check;
    assign ALUOut_Zero_Check = op_out===0 ? 1'b1 : 1'b0;

    wire Branch_Result;
    assign Branch_Result = ALUctl[6] ? ALUOut : ALUOut_Zero_Check;

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
