
`include "../include/rv32i-defines.v"
`include "../include/sail-core-defines.v"

module ALUControl(FuncCode, ALUCtl, Opcode);
	input [3:0]		FuncCode;
	input [6:0]		Opcode;
	output reg [6:0]	ALUCtl;

	/*
	 *	The `initial` statement below uses Yosys's support for nonzero
	 *	initial values:
	 */
	initial begin
		ALUCtl = 7'b0;
	end

    // Set ALUCtl[3:0] which governs the operation

	always @(*) begin
		case (Opcode)
			/*
			 *	LUI, U-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_LUI:
				// ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_LUI;
                // Set to 0000010 instead of 0000000 in original alu_control
                // not sure if its a mistake, but leaving as they put it
				ALUCtl[3:0] = 4'b0010; // Equal to ADD

			/*
			 *	AUIPC, U-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_AUIPC:
				ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_AUIPC;

			/*
			 *	JAL, UJ-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_JAL:
				ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_JAL;

			/*
			 *	JALR, I-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_JALR:
				ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_JALR;

			/*
			 *	Branch, SB-Type
			 */
            `kRV32I_INSTRUCTION_OPCODE_BRANCH:
                // Make sure it is a valid Funct3
                // Not valid: 010, 011
                case (FuncCode[2:0])
                    3'b010:
                        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ILLEGAL;
                    3'b011:
                        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ILLEGAL;
                    default:
                        // The same for all valid branches
                        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_BEQ;
                endcase

			/*
			 *	Loads, I-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_LOAD:
				case (FuncCode[2:0])
					3'b000:
				        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_LB;
					3'b001:
				        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_LH;
					3'b010:
				        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_LW;
					3'b100:
				        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_LBU;
					3'b101:
				        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_LHU;
					default:
				        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ILLEGAL;
				endcase

			/*
			 *	Stores, S-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_STORE:
				case (FuncCode[2:0])

					3'b000:
				        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SB;
					3'b001:
				        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SH;
					3'b010:
				        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SW;
					default:
				        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ILLEGAL;
				endcase

			/*
			 *	Immediate operations, I-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_IMMOP:
				case (FuncCode[2:0])
					3'b000:
						ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ADDI;
					3'b010:
						ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLTI;
					3'b011:
						ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLTIU;
					3'b100:
						ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_XORI;
					3'b110:
						ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ORI;
					3'b111:
						ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ANDI;
					3'b001:
						ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLLI;
					3'b101:
						case (FuncCode[3])
							1'b0:
						        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRLI;
							1'b1:
						        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRAI;
							default:
						        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ILLEGAL;
						endcase
					default:
						ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ILLEGAL;
				endcase

			/*
			 *	ADD SUB & logic shifts, R-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_ALUOP:
				case (FuncCode[2:0])
					3'b000:
						case(FuncCode[3])
							1'b0:
						        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ADD;
							1'b1:
						        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB;
							default:
						        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ILLEGAL;
						endcase
					3'b001:
						ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLL;
					3'b010:
						ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT;
					3'b011:
						ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLTU;
					3'b100:
						ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_XOR;
					3'b101:
						case(FuncCode[3])
							1'b0:
						        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRL;
							1'b1:
						        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRA;
							default:
						        ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ILLEGAL;
						endcase
					3'b110:
						ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR;
					3'b111:
						ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_AND;
					default:
						ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ILLEGAL;
				endcase

			`kRV32I_INSTRUCTION_OPCODE_CSRR:
				case (FuncCode[1:0]) //use lower 2 bits of FuncCode to determine operation
					2'b01:
						ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW;
					2'b10:
						ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS;
					2'b11:
						ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRC;
					default:
						ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ILLEGAL;
				endcase

			default:
				ALUCtl[3:0] = `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ILLEGAL;
		endcase
        
        // Handle the branching
        // For valid branch codes, set ALUCtl[6:4] to Funct3 (FuncCode[2:0])
        // Otherwise, set to an unused value 010
        case (Opcode)
            `kRV32I_INSTRUCTION_OPCODE_BRANCH:
                // Make sure it is a valid Funct3
                // Not valid: 010, 011
                case (FuncCode[2:0])
                    3'b010:
                        ALUCtl[6:4] = 3'b010;
                    3'b011:
                        ALUCtl[6:4] = 3'b010;
                    default:
                        ALUCtl[6:4] = FuncCode[2:0];
                endcase
            default:
                ALUCtl[6:4] = 3'b010;
        endcase
	end
endmodule
