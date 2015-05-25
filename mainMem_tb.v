module mainMem_tb();

	reg clock, wren;
	reg enable;
	reg[0:31] addr, data_in;
	reg[0:1] acc_size;
	reg[0:31] tempaddr;

	wire[0:31] data_out;
	wire busy;

	parameter START_ADDRESS = 32'h80020000;

	integer data_file, scan_file;

	integer loop_count;

	reg eof_flag;

	integer counter;

	reg[0:21*8] filename;

	reg [0:31] captured_data;

	reg [0:31] 		captured_data_blk [0:(1048578 - 1)];

	`define NULL 0

	task OpenFile;
		begin
			data_file = $fopen(filename, "r");
  	 		if (data_file == `NULL) begin
    			$display("data_file handle was NULL");
    			$finish;
 	 		end
		end
	endtask

	task ReadFile;
		begin
			if (!$feof(data_file)) begin
  				scan_file = $fscanf(data_file, "%h\n", captured_data);
  				eof_flag = 1'b0;
  			end else begin
  				$display("Reached the end of file!");
  				eof_flag = 1'b1;
  			end
		end
	endtask

	// defining our memory module
	mainMem dut(clock, addr, data_in, data_out, acc_size, wren, busy, enable);

	// Initilization of values
	initial begin
		clock = 0;
		addr = START_ADDRESS - 4;
		enable = 1;
		wren = 1;
		acc_size = 2'b00;
	end

	// Opens file for read, we should prolly close this somewhere
	initial begin
		filename = "bench-v2/SumArray.x";
  		OpenFile();
	end

	initial begin
		$dumpfile("test.vcd");
		$dumpvars;
	end

	// Simulate clock
	always #10 clock = !clock;


	initial begin

		//TESTING SINGLE WRITE

		@(posedge clock)

		ReadFile();
		addr <= addr + 4;
		data_in <= captured_data;

  		wren = 1'b1;
  		acc_size = 2'b00;

		// TESTING SINGLE READ

		@(posedge clock);

		wren = 1'b0;
		acc_size = 2'b00;
		
		@(posedge clock);
		
		$display("waste clock cycle");

		@(posedge clock);

		if (data_out == captured_data) begin
			$display("Retrieved value: %h at address: %h - PASS", captured_data, addr);
		end else begin
			$display ("Expected value is %h, actual value is %h", captured_data, data_out);
		end

		// TESTING BURST WRITE 4 WORDS
		@(posedge clock);

		ReadFile();
		addr <= addr + 4;
		data_in <= captured_data;
  		captured_data_blk[0] <= captured_data;

  		wren = 1'b1;
		acc_size = 2'b01;

		for (loop_count = 1; loop_count <= 3; loop_count = loop_count + 1) begin
			@(posedge clock);
			ReadFile();
			data_in <= captured_data;
			captured_data_blk[loop_count] <= captured_data;
		end


		// TESTING BURST READ 4 WORDS

		@(posedge clock);

		wren = 1'b0;

		@(posedge clock);

		for (loop_count = 0; loop_count < 4; loop_count = loop_count + 1) begin
			@(posedge clock);
			if (data_out == captured_data_blk[loop_count]) begin
				$display("Retrieved value: %h at starting address: %h - PASS", captured_data_blk[loop_count], addr);
			end else begin
				$display ("Expected value is %h, actual value is %h", captured_data_blk[loop_count], data_out);
			end
		end


		// TESTING BURST WRITE 8 WORDS

		@(posedge clock);

		ReadFile();
		addr <= addr + 16;
		data_in <= captured_data;
  		captured_data_blk[0] <= captured_data;

  		wren = 1'b1;
		acc_size = 2'b10;

		for (loop_count = 1; loop_count < 8; loop_count = loop_count + 1) begin
			@(posedge clock);
			ReadFile();
			data_in <= captured_data;
			captured_data_blk[loop_count] <= captured_data;
		end

		// TESTING BURST READ 8 WORDS

		@(posedge clock);

		wren = 1'b0;

		@(posedge clock);

		for (loop_count = 0; loop_count < 8; loop_count = loop_count + 1) begin
			@(posedge clock);
			if (data_out == captured_data_blk[loop_count]) begin
				$display("Retrieved value: %h at starting address: %h - PASS", captured_data_blk[loop_count], addr);
			end else begin
				$display ("Expected value is %h, actual value is %h", captured_data_blk[loop_count], data_out);
			end
		end

		// TESTING BURST WRITE 16 WORDS

		@(posedge clock);

		ReadFile();
		addr <= addr + 32;
		data_in <= captured_data;
  		captured_data_blk[0] <= captured_data;

  		wren = 1'b1;
		acc_size = 2'b11;

		for (loop_count = 1; loop_count < 16; loop_count = loop_count + 1) begin
			@(posedge clock);
			ReadFile();
			data_in <= captured_data;
			captured_data_blk[loop_count] <= captured_data;
		end

		// TESTING BURST READ 16 WORDS

		@(posedge clock);

		wren = 1'b0;

		@(posedge clock);

		for (loop_count = 0; loop_count < 16; loop_count = loop_count + 1) begin
			@(posedge clock);
			if (data_out == captured_data_blk[loop_count]) begin
				$display("Retrieved value: %h at starting address: %h - PASS", captured_data_blk[loop_count], addr);
			end else begin
				$display ("Expected value is %h, actual value is %h", captured_data_blk[loop_count], data_out);
			end
		end


		//WRITE THE REST OF FILE

		@(posedge clock);

		wren = 1'b1;
		acc_size = 2'b00;
		counter <= 1;
		
		ReadFile();
		data_in <= captured_data;
		captured_data_blk[0] <= captured_data;
		addr <= addr + 60;
		
		while (!eof_flag) begin
			@(posedge clock);
			ReadFile();
			data_in <= captured_data;
			addr <= addr + 4;
			captured_data_blk[counter] <= captured_data;
			counter <= counter + 1;
		end
		
		@(posedge clock);
		
		// READ THE REST OF THE FILE

		counter <= counter - 1;
		wren = 1'b0;
		addr <= addr - ((counter-1) << 2);			

		@(posedge clock); // because addr is reg, wont see it until one cycle later, and data comes cycle after that
		addr <= addr + 4;

		for (loop_count = 0; loop_count < counter; loop_count = loop_count + 1) begin
			@(posedge clock);

			addr <= addr + 4;

			if (data_out == captured_data_blk[loop_count]) begin
				$display("Retrieved value: %h at address: %h - PASS", captured_data_blk[loop_count], addr);
			end else begin
				$display ("Expected value is %h, actual value is %h", captured_data_blk[loop_count], data_out);
			end
			
		end

		// TURN OFF WHEN DONE
		
		@(posedge clock);

		enable = 0;

		$display("FINISHED THE SIMULATION");
		$finish;

	end


	// This just helps see our changing data
	always @(addr, data_in, data_out) begin
		// Display output, only when value changes
        	$display("%h,\t%h,\t%h\t%h", addr, data_in, data_out, wren);
    end

	
endmodule