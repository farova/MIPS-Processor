include "control.vh"

module Execute(clock, pc, rs, rt, insn, control, data_out);

input wire clock;
input wire[0:31]rs;
input wire[0:31]rt;
input wire[0:31]insn;
input wire[0:31]pc;

input reg[0:CNTRL_REG_SIZE] control;


output reg[0:31]data_out;


wire[0:15] imm;
wire[0:31] imm_leftshift;
wire[0:31] alu_A;
wire[0:5] func;
wire[0:33] insn_leftshift;
wire[0:27] jump_insn_index;
wire[0:31] branch_address;
wire[0:31] effective_branch_addr;
wire z;

assign imm = insn[16:31];
assign imm_leftshift = $signed(imm);
assign func = insn[26:31];
assign jump_insn_index = insn[6:31];

assign alu_A = control[ALUINB] ? $signed(imm): rt; 
assign alu_B = rs;

assign insn_leftshift = insn;

assign branch_address = (imm_leftshift << 2) + pc;

assign effective_branch_addr = control[BR] ? branch_address : pc;

assign effective_addr = control[JP] ? (jump_insn_index << 2) : effective_branch_addr;




always @(posedge clock) begin
	
	if (control[ALUOP]) begin
		case(func)
			6'b100000: begin //ADD
				data_out <= $signed(alu_A) + $signed(alu_B);
			end
			6'b100001: begin //ADDU
				data_out <= $unsigned(alu_A) + $unsigned(alu_B);
			end
			6'b100010: begin //SUB
				data_out <= $signed(alu_A) - $signed(alu_B);
			end
			6'b100011: begin //SUBU
				data_out <= $unsigned(alu_A) - $unsigned(alu_B);
			end
			6'b011010: begin //DIV
				
			end
			6'b011011: begin //DIVU
				
			end
			6'b010000: begin //MFHI
				
			end
			6'b010010: begin //MFLO
				
			end
			6'b101010: begin //SLT
				z <= rs < rt;
			end
			6'b101011: begin //SLTU
				
			end
			6'b000000: begin //SLL
				
			end
			6'b000010: begin //SLLV
				
			end
			6'b000010: begin //SRL
				
			end
			6'b000110: begin //SRLV
				
			end
			6'b000011: begin //SRA
				
			end
			6'b000111: begin //SRAV
				
			end
			6'b100100: begin //AND
				
			end
			6'b100101: begin //OR
				
			end
			6'b100110: begin //XOR
				
			end
			6'b100111: begin //NOR
				
			end
			6'b001001: begin //JALR

			end
			6'b001000: begin //JR

			end
			default: begin
				$display("unimplemented calculation type instruction\n");
			end
		endcase
	end

	

	
end


	



endmodule