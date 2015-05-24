module Decode(clk, insn, pc);


input clk;
input[0:31] insn;
input[0:31] pc;


wire[0:5] opcode;
wire[0:4] rs;
wire[0:4] rd;
wire[0:4] rt;
wire[0:4] sa;
wire[0:5] calc_type;
wire[0:15] offset;

assign opcode = insn[0:5];
assign rs = insn[6:10];
assign rt = insn[11:15];
assign rd = insn[16:20];
assign sa = insn[21:25];

assign calc_type = insn[26:31];


always @(posedge clk) begin
	
	case(opcode)
		6'b000000: begin
			case(calc_type)
				6'b100000: begin //ADD
					$display("ADD Rs: %d Rt: %d Rd: %d", rs, rt, rd);
				end
				6'b100001: begin //ADDU
					$display("ADDU Rs: %d Rt: %d Rd: %d", rs, rt, rd);
				end
				6'b100010: begin //SUB
					$display("SUB Rs: %d Rt: %d Rd: %d", rs, rt, rd);
				end
				6'b100011: begin //SUBU
					$display("SUBU Rs: %d Rt: %d Rd: %d", rs, rt, rd);
				end
				6'b011000: begin //MULT
					$display("MULT Rs: %d Rt: %d", rs, rt);
				end
				6'b011001: begin //MULTU
					 $display("MULTU Rs: %d Rt: %d", rs, rt);
				end
				6'b011010: begin //DIV
					$display("DIV Rs: %d Rt: %d", rs, rt);
				end
				6'b011011: begin //DIVU
					$display("DIVU Rs: %d Rt: %d", rs, rt);
				end
				6'b010000: begin //MFHI
					$display("MFHI Rd: %d", rd);
				end
				6'b010010: begin //MFLO
					$display("MFLO Rd: %d", rd);
				end
				6'b101010: begin //SLT
					$display("SLT Rs: %d Rt: %d Rd: %d", rs, rt, rd);
				end
				6'b101011: begin //SLTU
					$display("SLTU Rs: %d Rt: %d Rd: %d", rs, rt, rd);
				end
				6'b000000: begin //SLL
					$display("SLL Sa: %d Rt: %d Rd: %d", sa, rt, rd);
				end
				6'b000010: begin //SLLV
					$display("SLLV Rs: %d Rt: %d Rd: %d", rs, rt, rd);
				end
				6'b000010: begin //SRL
					$display("SRL Sa: %d Rt: %d Rd: %d", sa, rt, rd);
				end
				6'b000110: begin //SRLV
					$display("SRLV Rs: %d Rt: %d Rd: %d", rs, rt, rd);
				end
				6'b000011: begin //SRA
					$display("SRA Sa: %d Rt: %d Rd: %d", sa, rt, rd);
				end
				6'b000111: begin //SRAV
					$display("SRAV Rs: %d Rt: %d Rd: %d", rs, rt, rd);
				end
				6'b100100: begin //AND
					$display("AND Rs: %d Rt: %d Rd: %d", rs, rt, rd);
				end
				6'b100101: begin //OR
					$display("OR Rs: %d Rt: %d Rd: %d", rs, rt, rd);
				end
				6'b100110: begin //XOR
					$display("XOR Rs: %d Rt: %d Rd: %d", rs, rt, rd);
				end
				6'b100111: begin //NOR
					$display("NOR Rs: %d Rt: %d Rd: %d", rs, rt, rd);
				end
				default: begin
					$display("unimplemented calculation type instruction");
				end
			endcase
		end

		default: begin
			$display("Noop");
		end

	endcase

end







endmodule