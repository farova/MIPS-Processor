
`include "control.vh"

module decode(clk, insn, pc, valid_insn, rs, rt, rd, control);


input clk, valid_insn;
input[0:31] insn;
input[0:31] pc;

output reg[0:`CNTRL_REG_SIZE-1] control;

wire isNoop;


wire[0:5] opcode;
output wire[0:4] rs;
output wire[0:4] rd;
output wire[0:4] rt;
wire[0:4] sa;
wire[0:15] imm;
wire[0:5] calc_type;
wire[0:15] offset;
wire[0:4] base;
wire[0:26] insn_index;




assign opcode = insn[0:5];
assign base = insn[6:10];
assign rs = insn[6:10];
assign rt = insn[11:15];
assign rd = insn[16:20];
assign sa = insn[21:25];
assign imm = insn[16:31];
assign offset = insn[16:31];
assign calc_type = insn[26:31];
assign insn_index = insn[6:31];

integer i;


//Basic noop check

assign isNoop = insn == 32'h00000000 ? 1 : 0;

initial begin
	for (i = 0; i < `CNTRL_REG_SIZE; i = i+1) begin
		control[i] = 0;
	end
end




always @(posedge clk) begin
	
	control[`BR] <= 0;
	control[`JP] <= 0;
	control[`ALUINB] <= 0;
	control[`ALUOP] <= 0;
	control[`DMWE] <= 0;
	control[`RWE] <= 0;
	control[`RDST] <= 0;
	control[`RWD] <= 0;


	// Need this check because otherwise random instructions can sometimes be passed
	
	if (insn == 32'h70621002) begin
		$display("stupid mul");
	end

	if (valid_insn) begin

		$display("PC: %h Instruction: %h", pc, insn);

		if (!isNoop) begin
			case(opcode)
				6'b000000: begin
					case(calc_type)
						6'b100000: begin //ADD

						end
						6'b100001: begin //ADDU
							control[`RWE] <= 1;
							control[`RDST] <= 1;
						end
						6'b100010: begin //SUB
							control[`RWE] <= 1;
							control[`RDST] <= 1;
						end
						6'b100011: begin //SUBU
							control[`RWE] <= 1;
							control[`RDST] <= 1;
						end
						6'b011010: begin //DIV
							control[`RWE] <= 1;
						end
						6'b011011: begin //DIVU
							control[`RWE] <= 1;
						end
						6'b010000: begin //MFHI
							control[`RDST] <= 1;
						end
						6'b010010: begin //MFLO
							control[`RDST] <= 1;
						end
						6'b101010: begin //SLT
							control[`RWE] <= 1;
							control[`RDST] <= 1;
						end
						6'b101011: begin //SLTU
							control[`RWE] <= 1;
							control[`RDST] <= 1;
						end
						6'b000000: begin //SLL
							control[`RWE] <= 1;
							control[`RDST] <= 1;
						end
						6'b000100: begin //SLLV
							control[`RWE] <= 1;
							control[`RDST] <= 1;
						end
						6'b000010: begin //SRL
							control[`RWE] <= 1;
							control[`RDST] <= 1;
						end
						6'b000110: begin //SRLV
							control[`RWE] <= 1;
							control[`RDST] <= 1;
						end
						6'b000011: begin //SRA
							control[`RWE] <= 1;
							control[`RDST] <= 1;
						end
						6'b000111: begin //SRAV
							control[`RWE] <= 1;
							control[`RDST] <= 1;
						end
						6'b100100: begin //AND
							control[`RWE] <= 1;
							control[`RDST] <= 1;
						end
						6'b100101: begin //OR
							control[`RWE] <= 1;
							control[`RDST] <= 1;
						end
						6'b100110: begin //XOR
							control[`RWE] <= 1;
							control[`RDST] <= 1;
						end
						6'b100111: begin //NOR
							control[`RWE] <= 1;
							control[`RDST] <= 1;
						end
						6'b001001: begin //JALR
							control[`JP] <= 1;
							control[`JR] <= 1;
						end
						6'b001000: begin //JR
							control[`JP] <= 1;
							control[`JR] <= 1;
						end
						default: begin
							$display("unimplemented calculation type instruction\n");
						end
					endcase

				end

				6'b001001: begin //ADDIU
					control[`ALUINB] <= 1;
					control[`RWE] <= 1;
					control[`RDST] <= 1;
				end

				6'b001010: begin //SLTI
					control[`ALUINB] <= 1;
					control[`RWE] <= 1;
					control[`RDST] <= 1;				
				end

				6'b001011: begin //SLTIU
					control[`ALUINB] <= 1;
					control[`RWE] <= 1;
					control[`RDST] <= 1;
				end

				6'b001101: begin //ORI
					control[`ALUINB] <= 1;
					control[`RWE] <= 1;
					control[`RDST] <= 1;
				end

				6'b001110: begin //XORI
					control[`ALUINB] <= 1;
					control[`RWE] <= 1;
					control[`RDST] <= 1;
				end

				6'b100011: begin //LW
					control[`ALUINB] <= 1;
					control[`RWE] <= 1;
					control[`RWD] <= 1;
				end

				6'b101011: begin //SW
					control[`ALUINB] <= 1;
					control[`DMWE] <= 1;
				end

				6'b001111: begin //LUI
					control[`ALUINB] <= 1;
					control[`RWE] <= 1;
					control[`RWD] <= 1;
				end

				6'b100000: begin //LB
					control[`ALUINB] <= 1;
					control[`RWE] <= 1;
					control[`RWD] <= 1;
				end

				6'b101000: begin //SB
					control[`ALUINB] <= 1;
					control[`DMWE] <= 1;
				end

				6'b100100: begin //LBU
					control[`ALUINB] <= 1;
					control[`DMWE] <= 1;
				end

				6'b000010: begin //J
					control[`JP] <= 1;
				end		

				6'b000011: begin //JAL
					control[`JP] <= 1;
				end

				6'b000100: begin //BEQ and BEQZ
					control[`BR] <= 1;
					control[`ALUOP] <= 1;	
					
				end

				6'b000101: begin //BNE and BNEZ
					control[`BR] <= 1;
					control[`ALUOP] <= 1;		
				end

				6'b000001: begin //BGEZ and BLTZ
					control[`BR] <= 1;
					control[`ALUOP] <= 1;
				end

				6'b000111: begin //BGTZ
					control[`BR] <= 1;
					control[`ALUOP] <= 1;
				end

				6'b000110: begin //BLEZ
					control[`BR] <= 1;
					control[`ALUOP] <= 1;
				end

				6'b011100: begin //MUL
					control[`RWE] <= 1;
					control[`RDST] <= 1;
				end

				default: begin
					$display("unimplemented instruction\n");
				end

			endcase
		end else begin
			$display("noop\n");
		end

	end

end







endmodule