`include "control.vh"

module RegisterFile(clock, insn, rtIn, rdIn, rsOut, rtOut, writeBackData, control);

parameter RETURN_ADDRESS = 31;
parameter STACK_PNTR_BASE_ADDR = 32'h80120002;
parameter MAIN_RTRN_ADDR = 32'h77777777;

input wire clock;
input wire[0:31] insn;
input wire[0:`CNTRL_REG_SIZE-1] control;
input wire[0:4] rdIn;
input wire[0:4] rtIn;

input wire[0:31] writeBackData;

output wire[0:31] rsOut;
output wire[0:31] rtOut;


wire[0:4] rs;
wire[0:4] rt;
wire[0:4] rd;
wire[0:31] zero;

reg[0:31] registers[0:31];

integer i;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// TASKS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
task PrintRegs;
	integer k;
	begin
		$display("\n PRINTING REGISTER VALUES\n");
		for (k = 0; k < 32; k = k + 1) begin
			$display("register %d: has value: %d", k, registers[k]);
		end
	end
endtask
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// COMBINATIONAL LOGIC
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign rs = insn[6:10];
assign rt = insn[11:15];
assign rd = insn[16:20];

assign zero = registers[0];

assign rsOut = registers[rs];
assign rtOut = registers[rt];
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

initial begin
	for (i = 0; i < 32; i = i + 1) begin
	if (i == 29) begin
		registers[i] = STACK_PNTR_BASE_ADDR;
	end else if (i == 31) begin
		registers[i] = MAIN_RTRN_ADDR;
	end else begin
		registers[i] = i;
	end

	
	end
end


always @(posedge clock) begin
	if (control[`RWE]) begin
		if (control[`RDST]) begin
			if (control[`RA]) begin
				registers[RETURN_ADDRESS] <= writeBackData;
				$display("WriteBack data: %h, at Rd address: %d", writeBackData, RETURN_ADDRESS);
			end else begin
				registers[rdIn] <= writeBackData;
				$display("WriteBack data: %h, at Rd address: %d", writeBackData, rdIn);
			end
		end else begin
			registers[rtIn] <= writeBackData;
			$display("WriteBack data: %h, at Rt address: %d", writeBackData, rtIn);
		end
		
	end
	
end

endmodule