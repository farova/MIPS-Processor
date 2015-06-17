module Execute(clock, rs, rt, func, data_out);

input wire clock;
input wire[0:31]rs;
input wire[0:31]rt;
input wire[0:5]func;


output reg[0:31]data_out;


always @(posedge clock) begin
	case(func)
		6'b100000: begin //ADD
			data_out <= $signed(rs) + $signed(rt);	
		end
		6'b100001: begin //ADDU
			data_out <= $unsigned(rs) + $unsigned(rt);
		end
		/*6'b100010: begin //SUB
			$display("SUB Rs: %d Rt: %d Rd: %d\n", rs, rt, rd);
		end
		6'b100011: begin //SUBU
			$display("SUBU Rs: %d Rt: %d Rd: %d\n", rs, rt, rd);
		end
		6'b011000: begin //MULT
			$display("MULT Rs: %d Rt: %d\n", rs, rt);
		end
		6'b011001: begin //MULTU
			 $display("MULTU Rs: %d Rt: %d\n", rs, rt);
		end
		6'b011010: begin //DIV
			$display("DIV Rs: %d Rt: %d\n", rs, rt);
		end
		6'b011011: begin //DIVU
			$display("DIVU Rs: %d Rt: %d\n", rs, rt);
		end
		6'b010000: begin //MFHI
			$display("MFHI Rd: %d\n", rd);
		end
		6'b010010: begin //MFLO
			$display("MFLO Rd: %d\n", rd);
		end
		6'b101010: begin //SLT
			$display("SLT Rs: %d Rt: %d Rd: %d\n", rs, rt, rd);
		end
		6'b101011: begin //SLTU
			$display("SLTU Rs: %d Rt: %d Rd: %d\n", rs, rt, rd);
		end
		6'b000000: begin //SLL
			$display("SLL Sa: %d Rt: %d Rd: %d\n", sa, rt, rd);
		end
		6'b000010: begin //SLLV
			$display("SLLV Rs: %d Rt: %d Rd: %d\n", rs, rt, rd);
		end
		6'b000010: begin //SRL
			$display("SRL Sa: %d Rt: %d Rd: %d\n", sa, rt, rd);
		end
		6'b000110: begin //SRLV
			$display("SRLV Rs: %d Rt: %d Rd: %d\n", rs, rt, rd);
		end
		6'b000011: begin //SRA
			$display("SRA Sa: %d Rt: %d Rd: %d\n", sa, rt, rd);
		end
		6'b000111: begin //SRAV
			$display("SRAV Rs: %d Rt: %d Rd: %d\n", rs, rt, rd);
		end
		6'b100100: begin //AND
			$display("AND Rs: %d Rt: %d Rd: %d\n", rs, rt, rd);
		end
		6'b100101: begin //OR
			$display("OR Rs: %d Rt: %d Rd: %d\n", rs, rt, rd);
		end
		6'b100110: begin //XOR
			$display("XOR Rs: %d Rt: %d Rd: %d\n", rs, rt, rd);
		end
		6'b100111: begin //NOR
			$display("NOR Rs: %d Rt: %d Rd: %d\n", rs, rt, rd);
		end
		6'b001001: begin
			$display("JALR Rs: %d Rd: %d\n", rs, rd);
		end
		6'b001000: begin
			$display("JR Rs: %d\n", rs);
		end*/
		default: begin
			$display("unimplemented calculation type instruction\n");
		end
	endcase
end


	



endmodule