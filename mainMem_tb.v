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

	mainMem dut(clock, addr, data_in, data_out, acc_size, wren, busy, enable);

	// Initilization
	initial begin
		clock = 0;
		addr = START_ADDRESS - 4;
		enable = 1;
		wren = 1;
		output_val = 32'h0000_0000;
	end

	initial begin
  		data_file = $fopen("bench-v1/SimpleAdd.x", "r");
  	 	if (data_file == `NULL) begin
    		$display("data_file handle was NULL");
    		$finish;
 	 	end

 	 	//scan_file = $fscanf(data_file, "%h\n", captured_data);
	end

	// Simulate clock
	always #10 clock = !clock;


	initial begin
		// LOAD AT TOP OF MEMORY
		@(posedge clock);
		wren = 1'b1;
		addr = 32'h80020000;
		data_in = 32'h55cc_55cc;
		@(posedge clock);
		wren = 1'b0;
		acc_size = 2'b01;
		@(posedge clock);
		if (data_out == 32'h55cc_55cc) begin
			$display("Store at %h mem block - OK", addr);
			output_val <= data_out;
		end else begin
			$display ("Expected value is 55cc55cc, actual value is %h", data_out);
		end

		/*@(posedge clock);
		wren = 1'b1;
		addr = 32'h80020000;
		data_in = 32'h55cc_55cc;
		@(posedge clock);
		wren = 1'b0;
		@(posedge clock);
		if (data_out == 32'h55cc_55cc) begin
			$display("Store at %h mem block - OK", addr);
			output_val <= data_out;
		end else begin
			$display ("Expected value is 55cc55cc, actual value is %h", data_out);
		end*/
	end

	/*
	always @(posedge clock) begin
 
  		if (!$feof(data_file)) begin
  			scan_file = $fscanf(data_file, "%h\n", captured_data);
  			addr <= addr + 4;
  			data_in <= captured_data;
    		//use captured_data as you would any other wire or reg value;
  		end
	end

	*/

	always @(addr, data_in, data_out) begin
		// Display output, only when value changes
        	//$display("address,\tdata_in,\tdata_out");
        	$display("%h,\t%h,\t%h", addr, data_in, data_out);
    end

	
endmodule