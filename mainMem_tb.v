module mainMem_tb();

	reg clock, wren;
	wire enable;
	reg[0:31] addr, data_in;
	reg[0:1] acc_size;

	wire[0:31] data_out;
	wire busy;

	parameter START_ADDRESS = 32'h80020000;

	integer data_file, scan_file;

	reg [0:31] captured_data;

	`define NULL 0

	mainMem dut(clock, addr, data_in, data_out, acc_size, wren, busy, enable);

	// Initilization
	initial begin
		clock = 0;
		addr = START_ADDRESS - 4;
	end

	initial begin
  		data_file = $fopen("bench-v1/SimpleAdd.x", "r");
  	 	if (data_file == `NULL) begin
    		$display("data_file handle was NULL");
    		$finish;
 	 	end
	end

	// Simulate clock
	always #10 clock = !clock;

	always @(posedge clock) begin

  		scan_file = $fscanf(data_file, "%h\n", captured_data); 
  		if (!$feof(data_file)) begin
  			addr <= addr + 4;
  			data_in <= captured_data;
    		//use captured_data as you would any other wire or reg value;
  		end
	end

	initial begin
		// Display output, only when value changes
        	$display("address,\tdata_in,\tdata_out");
        	$monitor("%h,\t%h,\t%h", addr, data_in, data_out);
    end

	
endmodule