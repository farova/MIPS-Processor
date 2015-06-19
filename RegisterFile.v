`include "control.vh"

module RegisterFile(clock, rsIn, rtIn, rdIn, rsOut, rtOut, writeBackData, control);

input wire clock;
input wire[0:4] rsIn;
input wire[0:4] rtIn;
input wire[0:4] rdIn;
input wire[0:`CNTRL_REG_SIZE] control;

input wire[0:31] writeBackData;

output reg[0:31] rsOut;
output reg[0:31] rtOut;

reg[0:31] registers[0:31];

integer i;

initial begin
	for (i = 0; i < 32; i = i + 1) begin
		registers[i] = i;
	end
end

// Read on rising edge
always @(posedge clock) begin
	rsOut <= registers[rsIn];
	rtOut <= registers[rtIn];
end

// Write on falling edge
always @(negedge clock) begin
	if (control[`RWE]) begin
		if (control[`RDST]) begin
			registers[rdIn] <= writeBackData;
		end else begin
			registers[rtIn] <= writeBackData;
		end
		
	end
	
end

endmodule