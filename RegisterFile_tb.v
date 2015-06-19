
module RegisterFile_tb();

reg clock;

reg[0:4] rsIn;
reg[0:4] rtIn;
reg[0:4] rdIn;
reg[0:31] writeBackData;

wire[0:31] rsOut;
wire[0:31] rtOut;


RegisterFile register_module(clock, rsIn, rtIn, rdIn, rsOut, rtOut, writeBackData);


always #10 clock = !clock;

initial begin
	clock = 1;
	writeBackData = 0;
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