module RegisterFile(clock, rsIn, rtIn, rdIn, rsOut, rtOut, writeBackData);

input wire clock;
input wire[4:0] rsIn;
input wire[4:0] rtIn;
input wire[4:0] rdIn;

input wire[0:31] writeBackData;

output reg[0:31] rsOut;
output reg[0:31] rtOut;

reg[0:31] registers[0:31];

integer i;

initial begin
	for (i = 0; i < 32; i = i + 1) begin
		registers[i] = 32'h00000000;
	end
end

always @(posedge clock) begin
	rsOut <= registers[rsIn];
	rtOut <= registers[rtIn];

	registers[rdIn] <= writeBackData;
end

endmodule