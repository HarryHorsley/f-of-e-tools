`include "../include/rv32i-defines.v"
`include "../include/sail-core-defines.v"

// For some reason it uses less resources when this is put in a module
// but not for other sections such as argument forwarding
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

module alu(ALUctl, A, B, ALUOut, Branch_Enable);
	input [6:0]		ALUctl;
	input [31:0]		A;
	input [31:0]		B;
	output reg [31:0]	ALUOut;
	output reg          Branch_Enable;

    reg [31:0] A_fwd;
    reg[31:0] B_fwd;
    wire sub;

    always @* begin
        case (ALUctl[3:0])
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR:
                A_fwd = ~A;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS:
                A_fwd = ~A;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRC:
                A_fwd = ~A;
            default:
                A_fwd = A;
        endcase
    end

    always @* begin
        case (ALUctl[3:0])
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR:
                B_fwd = ~B;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW:
                B_fwd = A;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS:
                B_fwd = ~B;
            default:
                B_fwd = B;
        endcase
    end

    sub_forward SUB_FORWARD(
        .ALUctl(ALUctl),
        .sub(sub)
    );

    wire [31:0] add_out, and_out, xor_out, srl_out,
                sra_out, sll_out, slt_out, sltu_out;

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
    assign srl_out = A_fwd >> B_fwd[4:0];
    assign sra_out = A_fwd >>> B_fwd[4:0];
    assign sll_out = A_fwd << B_fwd[4:0];
    assign slt_out = $signed(A_fwd) < $signed(B_fwd) ? 32'b1 : 32'b0;
    // sltu only used for branch conditions
    assign sltu_out = $unsigned(A_fwd) < $unsigned(B_fwd) ? 32'b1 : 32'b0;
    assign xor_out = A_fwd ^ B_fwd;

    wire[31:0] op_out;

    wire and_sel, add_sel, slt_sel, srl_sel, sra_sel, sll_sel, xor_sel;
    // sltu is not used as an operation
    assign and_sel = ALUctl[3:0] === `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_AND ||
                     ALUctl[3:0] === `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR ||
                     ALUctl[3:0] === `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW ||
                     ALUctl[3:0] === `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS ||
                     ALUctl[3:0] === `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRC;
    assign add_sel = ALUctl[3:0] === `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ADD ||
                     ALUctl[3:0] === `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB;
    assign slt_sel = ALUctl[3:0] === `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT;
    assign srl_sel = ALUctl[3:0] === `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRL;
    assign sra_sel = ALUctl[3:0] === `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRA;
    assign sll_sel = ALUctl[3:0] === `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLL;
    assign xor_sel = ALUctl[3:0] === `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_XOR;

    assign op_out = {32{and_sel}} & and_out |
                    {32{add_sel}} & add_out |
                    {32{slt_sel}} & slt_out |
                    {32{srl_sel}} & srl_out |
                    {32{sra_sel}} & sra_out |
                    {32{sll_sel}} & sll_out |
                    {32{xor_sel}} & xor_out;

    always @* begin
        case (ALUctl[3:0])
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR: ALUOut = ~op_out;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS: ALUOut = ~op_out;
            default: ALUOut = op_out;
        endcase
    end

    reg Branch_Result;
    always @* begin
        case (ALUctl[6:5])
            // More efficient to use add_out instead of ALUOut, even though
            // they are equal for branch operations
            2'b00: Branch_Result = (add_out == 0 ? 1'b1 : 1'b0);
            2'b10: Branch_Result = slt_out;
            2'b11: Branch_Result = sltu_out;
            default: Branch_Result = slt_out; // Invalid branch, re-use something
        endcase
    end

    always @* begin
        // ALUctl[6:4] = 010 when branching is unused.
        // Also return 0 for an invalid branch
        if ((~ALUctl[6] & ALUctl[5] & ~ALUctl[4]) || ALUctl[6:5] == 2'b01)
            Branch_Enable = 1'b0;
        else
            Branch_Enable = Branch_Result ^ ALUctl[4];
    end

endmodule
