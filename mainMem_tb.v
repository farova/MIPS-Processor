module mainMem_tb();

	reg clock, wren;
	wire enable;
	reg[0:31] addr, data_in;
	reg[0:2] acc_size;

	wire[0:31] data_out;
	wire busy;

	mainMem memory(clk, addr, data_in, data_out, acc_size, wren, busy, enable);

	
endmodule