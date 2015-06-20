
`include "control.vh"


module Execute(clock, pc, rs, rt, insn, control, data_out);

input wire clock;
input wire[0:31]rs;
input wire[0:31]rt;
input[0:31]insn;
input wire[0:31]pc;

input wire[0:`CNTRL_REG_SIZE-1] control;


output reg[0:31]data_out;


wire[0:15] imm;
wire[0:31] temp_imm;
wire[0:31] imm_leftshift;
wire[0:31] alu_A;
wire[0:31] alu_B;
wire[0:5] func;
wire[0:31] insn_leftshift;
wire[0:27] jump_insn_index;
wire[0:31] jump_addr;
wire[0:31] branch_address;
wire[0:31] effective_branch_addr;
wire[0:5] sa;
wire[0:6] opcode;
wire[0:4] base;
wire[0:15] offset;

reg z;

reg[0:31] HI;
reg[0:31] LO;

assign imm = insn[16:31];
assign imm_leftshift = $signed(imm);
assign func = insn[26:31];
assign jump_insn_index = insn[6:31];
assign sa = insn[21:25];
assign offset = insn[16:31];
assign base = insn[6:10];
assign opcode = insn[0:5];



assign alu_A = control[`ALUINB] ? $signed(imm): rt; 
assign alu_B = rs;
assign insn_leftshift = insn;
assign branch_address = (imm_leftshift << 2) + pc;
assign effective_branch_addr = (control[`BR] & z) ? branch_address : pc;
assign effective_addr = control[`JP] ? jump_addr : effective_branch_addr;
assign jump_addr = control[`JR] ? rs : (jump_insn_index << 2);


always @(posedge clock) begin
	
	if (!control[`ALUOP]) begin
		case(func)
			6'b100000: begin //ADD
				data_out <= alu_A + alu_B;
			end
			6'b100001: begin //ADDU
				data_out <= $unsigned(alu_A) + $unsigned(alu_B);
			end
			6'b100010: begin //SUB
				data_out <= alu_A - alu_B;
			end
			6'b100011: begin //SUBU
				data_out <= $unsigned(alu_A) - $unsigned(alu_B);
			end
			6'b011010: begin //DIV
				HI <= alu_A/alu_B;
				LO <= alu_A % alu_B;
			end
			6'b011011: begin //DIVU
				HI <= $unsigned(alu_A)/$unsigned(alu_B);
				LO <= $unsigned(alu_A) % $unsigned(alu_B);
			end
			6'b010000: begin //MFHI
				data_out <= HI;
			end
			6'b010010: begin //MFLO
				data_out <= LO;
			end
			6'b101010: begin //SLT
				data_out <= (alu_A < alu_B) ? 32'h00000001 : 32'h00000000;
			end
			6'b101011: begin //SLTU
				data_out <= (alu_A < alu_B) ? 32'h00000001 : 32'h00000000;
			end
			6'b000000: begin //SLL
				data_out <= alu_B << sa;
			end
			6'b000100: begin //SLLV
				data_out <= alu_B << alu_A[27:31];
			end
			6'b000010: begin //SRL
				data_out <= alu_B >> sa;	
			end
			6'b000110: begin //SRLV
				data_out <= alu_B >> alu_A[27:31];
			end
			6'b000011: begin //SRA
				data_out <= alu_B >>> sa;
			end
			6'b000111: begin //SRAV
				data_out <= alu_B >>> alu_A[27:31];
			end
			6'b100100: begin //AND
				data_out <= alu_A & alu_B;
			end
			6'b100101: begin //OR
				data_out <= alu_A | alu_B;
			end
			6'b100110: begin //XOR
				data_out <= alu_A ^ alu_B;
			end
			6'b100111: begin //NOR
				data_out <= ~(alu_A | alu_B);
			end
			6'b001001: begin //JALR
				data_out <= pc + 4;
			end
			default: begin
			end
		endcase
		case(opcode)
			6'b001001: begin //ADDIU
				data_out <= alu_A + alu_B;
			end

			6'b001010: begin //SLTI
				data_out <= (alu_A < alu_B) ? 32'h00000001 : 32'h00000000;
			end

			6'b001011: begin //SLTIU
				data_out <= (alu_A < alu_B) ? 32'h00000001 : 32'h00000000;
			end

			6'b001101: begin //ORI
				data_out <= alu_A | alu_B;
			end

			6'b001110: begin //XORI
				data_out <= alu_A ^ alu_B;
			end

			6'b011100: begin //MUL
				
			end
			default: begin
			end
		endcase
		$display("ALU_A: %d, ALU_B: %d, ALU_OUTPUT: %d", alu_A, alu_B, data_out);
	end else begin
		case(opcode)
				6'b000100: begin //BEQ and BEQZ
					z <= (alu_A == alu_B) ? 1 : 0;
					
				end

				6'b000101: begin //BNE and BNEZ
					z <= (alu_A != alu_B) ? 1 : 0;
				end

				6'b000001: begin //BGEZ and BLTZ
					if (insn[11:15] == 5'b00000) begin
						z <= (alu_A >= 5'b00000) ? 1 : 0;
					end else if (insn[11:15] == 5'b00001) begin
						z <= (alu_A < 5'b00000) ? 1 : 0;
					end
				end

				6'b000111: begin //BGTZ
					z <= (alu_A > 5'b00000) ? 1 : 0;
				end

				6'b000110: begin //BLEZ
					z <= (alu_A <= 5'b00000) ? 1 : 0;
				end
		endcase
		$display("ALU_A: %d, ALU_B: %d, ALU_OUTPUT: %d, Eff_Addr: %d", alu_A, alu_B, z, effective_addr);
	end

	

end


	



endmodule