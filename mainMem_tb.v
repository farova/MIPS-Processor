module mainMem_tb();

	reg clock, wren;
	reg enable;
	reg[0:31] addr, data_in;
	reg[0:1] acc_size;

	wire[0:31] data_out;
	wire busy;

	parameter START_ADDRESS = 32'h80020000;

	integer data_file, scan_file;

	reg [0:31] captured_data;

	reg[0:31] output_val;

	`define NULL 0

	// defining our memory module
	Mem dut(clock, addr, data_in, data_out, acc_size, wren, busy, enable);

	// Initilization of values
	initial begin
		clock = 0;
		addr = START_ADDRESS - 4;
		enable = 1;
		wren = 1;
		acc_size = 2'b00;
		output_val = 32'h0000_0000;
	end

	// Opens file for read, we should prolly close this somewhere
	initial begin
  		data_file = $fopen("bench-v1/SimpleAdd.x", "r");
  	 	if (data_file == `NULL) begin
    		$display("data_file handle was NULL");
    		$finish;
 	 	end
	end

	// Simulate clock
	always #10 clock = !clock;


	initial begin

		// Testing single read at first address
		@(posedge clock);

		wren = 1'b1;
		addr = 32'h80020000;
		data_in = 32'h55cc_55cc;
		acc_size = 2'b00;

		@(posedge clock);

		wren = 1'b0;
		acc_size = 2'b00;
		
		@(posedge clock);
		// waste mon

		@(posedge clock);

		if (data_out == 32'h55cc_55cc) begin
			$display("Retrieved at starting address: %h - PASS", addr);
			output_val <= data_out;
		end else begin
			$display ("Expected value is 55cc55cc, actual value is %h", data_out);
		end

		enable = 0;



		// Test Burst Read for 4 words
		@(posedge clock);

		enable = 1;
		wren = 1'b1;
		addr = 32'h80020004;
		acc_size = 2'b01;
		data_in = 32'h55cc_55cd;

		@(posedge clock);

		data_in = 32'h55cc_55ce;

		@(posedge clock);

		data_in = 32'h55cc_55cf;

		@(posedge clock);

		data_in = 32'h55cc_55c1;

		@(posedge clock);

		addr = 32'h80020000;		
		wren = 1'b0;

		@(posedge clock);

		//waste mon

		@(posedge clock);

		if (data_out == 32'h55cc_55cc) begin
			$display("Retrieved 1st value at starting address: %h - PASS", addr);
			output_val <= data_out;
		end else begin
			$display ("Expected value is 55cc55cc, actual value is %h", data_out);
		end

		@(posedge clock);

		if (data_out == 32'h55cc_55cd) begin
			$display("Retrieved 2nd value at starting address: %h - PASS", addr);
			output_val <= data_out;
		end else begin
			$display ("Expected value is 55cc55cd, actual value is %h", data_out);
		end

		@(posedge clock);

		if (data_out == 32'h55cc_55ce) begin
			$display("Retrieved 3rd value at starting address: %h - PASS", addr);
			output_val <= data_out;
		end else begin
			$display ("Expected value is 55cc55ce, actual value is %h", data_out);
		end

		@(posedge clock);

		if (data_out == 32'h55cc_55cf) begin
			$display("Retrieved 4th value at starting address: %h - PASS", addr);
			output_val <= data_out;
		end else begin
			$display ("Expected value is 55cc55cf, actual value is %h", data_out);
		end

		enable = 0;
	end

	/* Loading data from .x file, this should be incorporated into testing once we're sure our memory works for hardcoded values

	always @(posedge clock) begin
 
  		if (!$feof(data_file)) begin
  			scan_file = $fscanf(data_file, "%h\n", captured_data);
  			addr <= addr + 4;
  			data_in <= captured_data;
    		//use captured_data as you would any other wire or reg value;
  		end
	end

	*/


	// This just helps see our changing data
	always @(addr, data_in, data_out) begin
		// Display output, only when value changes
        	$display("%h,\t%h,\t%h", addr, data_in, data_out);
    end

	
endmodule