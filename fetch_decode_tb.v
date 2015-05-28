module fetch_decode_tb();


reg clock, wren, stall;
reg enable;
reg[0:31] addr, data_in;
reg[0:31] tempaddr;
reg[0:31] pc;
reg[0:31] pc_in;
reg[0:31] insn;

parameter START_ADDRESS = 32'h80020000;

integer data_file, scan_file;

reg eof_flag;

reg[0:1] acc_size;
reg valid_insn;

wire[0:31] data_out;
wire busy;
wire[0:1] acc_size_out;
wire[0:31] pc_out;
integer counter, loop_count;

reg[0:21*8] filename;

reg [0:31] captured_data;

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


mainMem mem_module(clock, addr, data_in, data_out, acc_size, wren, busy, enable);

fetch fetch_module(clock, stall, pc_out, rw, acc_size_out);

decode decode_module(clock, data_out, pc_in, valid_insn);

// Initilization of values
	initial begin
		clock <= 0;
		addr <= START_ADDRESS;
		enable <= 1;
		wren <= 1;
		acc_size <= 2'b00;
		stall <= 1;
		valid_insn <= 0;
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

		//Write to Memory
		@(posedge clock);

		wren <= 1'b1;
		acc_size <= 2'b00;
		
		ReadFile();
		data_in <= captured_data;

		counter <= 1;

		while (!eof_flag) begin
			@(posedge clock);
			ReadFile();
			data_in <= captured_data;
			addr <= addr + 4;
			counter <= counter + 1;
		end

		wren <= 0;
		stall <= 0;
		addr <= pc_out;
		pc_in <= pc_out;
		acc_size <= acc_size_out;
		loop_count <= 1;
		@(posedge clock);
		
		valid_insn <= 1;
		pc <= pc_in;
		pc_in <= pc_out;
		addr <= pc_out;

		while (loop_count < counter) begin
			@(posedge clock);
			pc <= pc_in;
			pc_in <= pc_out;
			addr <= pc_out;
			loop_count <= loop_count + 1;
		end


			

		$finish;






	end




endmodule