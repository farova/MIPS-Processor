`include "control.vh"

module RegisterFile_tb();

reg clock;

reg[0:4] rsIn;
reg[0:4] rtIn;
reg[0:4] rdIn;
reg[0:31] writeBackData;
reg[0:`CNTRL_REG_SIZE] control;

wire[0:31] rsOut;
wire[0:31] rtOut;


RegisterFile register_module(clock, rsIn, rtIn, rdIn, rsOut, rtOut, writeBackData, control);


always #10 clock = !clock;

initial begin
	clock = 1;
	writeBackData = 0;

	control[`RWE] = 1;
	control[`RDST] = 1;	

end

initial begin
	
	rsIn = 5'b00000;
	rtIn = 5'b00000;

	rdIn = 5'b00010; // R2
	writeBackData = 32'hdeed_deed;
	
	@(posedge clock);
	
	rsIn = 5'b00010; // R2
	rtIn = 5'b00000;

	rdIn = 5'b00101; // R5
	writeBackData = 32'haaaa_dddd;
	
	@(posedge clock);
	
	rsIn = 5'b00101; // R5
	rtIn = 5'b00010; // R2

	rdIn = 5'b00111; // R5
	writeBackData = 32'hbeef_deed;
	

	@(posedge clock);


end



endmodule