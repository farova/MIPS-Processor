module decode(clk, insn, pc, valid_insn);


input clk, valid_insn;
input[0:31] insn;
input[0:31] pc;

wire isNoop;


wire[0:5] opcode;
wire[0:4] rs;
wire[0:4] rd;
wire[0:4] rt;
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

//Basic noop check

assign isNoop = insn == 32'h00000000 ? 1 : 0;




always @(posedge clk) begin

	// Need this check because otherwise random instructions can sometimes be passed

	if (valid_insn) begin

		$display("PC: %h Instruction: %h", pc, insn);

		if (!isNoop) begin
			case(opcode)
				6'b000000: begin
					case(calc_type)
						6'b100000: begin //ADD
							$display("ADD Rs: %d Rt: %d Rd: %d\n", rs, rt, rd);	
						end
						6'b100001: begin //ADDU
							$display("ADDU Rs: %d Rt: %d Rd: %d\n", rs, rt, rd);
						end
						6'b100010: begin //SUB
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
						end
						default: begin
							$display("unimplemented calculation type instruction\n");
						end
					endcase

				end

				6'b001001: begin //ADDIU
					$display("ADDIU Rs: %d Rt: %d Imm: %d\n", rs, rt, imm);
				end

				6'b001010: begin //SLTI
					$display("SLTI Rs: %d Rt: %d Imm: %d\n", rs, rt, imm);
				end

				6'b001011: begin //SLTIU
					$display("SLTIU Rs: %d Rt: %d Imm: %d\n", rs, rt, imm);
				end

				6'b001101: begin //ORI
					$display("ORI Rs: %d Rt: %d Imm: %d\n", rs, rt, imm);
				end

				6'b001110: begin //ORI
					$display("XORI Rs: %d Rt: %d Imm: %d\n", rs, rt, imm);
				end

				6'b100011: begin //LW
					$display("LW base: %d Rt: %d offset: %d\n", base, rt, offset);
				end

				6'b101011: begin //SW
					$display("SW base: %d Rt: %d offset: %d\n", base, rt, offset);
				end

				6'b001111: begin //LUI
					$display("LUI Rt: %d Imm: %d\n", rt, imm);
				end

				6'b100000: begin //LB
					$display("LB base: %d Rt: %d offset: %d\n", base, rt, offset);
				end

				6'b101000: begin //SB
					$display("SB base: %d Rt: %d offset: %d\n", base, rt, offset);
				end

				6'b100100: begin //LBU
					$display("LBU base: %d Rt: %d offset: %d\n", base, rt, offset);
				end

				6'b000010: begin //J
					$display("J target: %d\n", insn_index);
				end		

				6'b000011: begin //JAL
					$display("JAL target: %d\n", insn_index);
				end

				6'b000100: begin //BEQ and BEQZ
					$display("BEQ Rs: %d Rt: %d offset: %d\n", rs, rt, offset);	
					
				end

				6'b000101: begin //BNE and BNEZ
					$display("BNE Rs: %d Rt: %d offset: %d\n", rs, rt, offset);	
					
				end

				6'b000001: begin //BGEZ and BLTZ

					if (rt == 6'b000000) begin
						$display("BLTZ Rs: %d offset: %d\n", rs, offset);
					end else if (rt == 6'b000001) begin
						$display("BGEZ Rs: %d offset: %d\n", rs, offset);
					end else begin
						$display("REGGIM not implemented\n");
					end
					
				end

				6'b000111: begin //BGTZ
					$display("BGTZ Rs: %d offset: %d\n", rs, offset);
				end

				6'b000110: begin //BLEZ
					$display("BLEZ Rs: %d offset: %d\n", rs, offset);
				end

				6'b011100: begin //MUL
					$display("MUL Rs: %d Rt: %d Rd: %d\n", rs, rt, rd);
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