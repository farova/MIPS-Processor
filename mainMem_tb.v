module mainMem_tb();

	reg clock, wren;
	wire enable;
	reg[0:31] addr, data_in;
	reg[0:1] acc_size;

	wire[0:31] data_out;
	wire busy;

	mainMem dut(clock, addr, data_in, data_out, acc_size, wren, busy, enable);

	// Initilization
	initial begin
		clock = 0;	
	end

	// Simulate clock
	always #10 clock = !clock;



	
endmodule