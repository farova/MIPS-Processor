`include "control.vh";

module Execute_tb();

reg clock;

reg wren, stall;
reg enable;

reg[0:31] addr;
reg[0:31] data_in;
reg[0:31] tempaddr;
reg[0:31] pc_in;

reg[0:31] insn;
reg[0:31] pc;
reg[0:CNTRL_REG_SIZE] control;


reg[0:4] rsIn;
reg[0:4] rtIn;
reg[0:4] rdIn;
reg[0:31] writeBackData;

wire[0:31] rsOut;
wire[0:31] rtOut;
wire[0:31] data_out;

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


// FETCH
mainMem 		mem_module(clock, addr, data_in, insn, acc_size, wren, busy, enable);
fetch 			fetch_module(clock, stall, pc_out, rw, acc_size_out);

// DECODE
decode 			decode_module(clock, insn, pc, valid_insn);
RegisterFile 	register_module(clock, rsIn, rtIn, rdIn, rsOut, rtOut, writeBackData);

// EXECUTE
Execute 		execute_module(clock, pc, rsOut, rtOut, insn, control, data_out);




// Call this to open the file
	task OpenFile;
		begin
			data_file = $fopen(filename, "r");
  	 		if (data_file == `NULL) begin
    			$display("data_file handle was NULL");
    			$finish;
 	 		end
		end
	endtask

// Call this to read a line of the file
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

// Increment time 
	always #10 clock = !clock;


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

// Opens file for read
	initial begin
		filename = "bench-v2/fact.x";
		$display("%s\n", filename);
  		OpenFile();
	end

	initial begin
		$dumpfile("test.vcd");
		$dumpvars;
	end

// Simulate clock
	always #10 clock = !clock;


	initial begin

		// -------------- Write data to memory
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

		//mem_module.dump();  for debugging purposes

		// -------------- Fetch data and decode it

		wren <= 0;
		stall <= 0;
		acc_size <= acc_size_out;
		loop_count <= 1;

		// These two clock cycles are needed initially because address will be available after one clock cycle
		// and data_out will be available the clock cycle after that -> hence two clock cycles
		@(posedge clock);

		addr <= pc_out;
		pc_in <= pc;
		pc <= pc_out;

		@(posedge clock);
		
		pc_in <= pc;
		pc <= pc_out;
		addr <= pc_out;

		while (loop_count < counter) begin
			@(posedge clock);
			if (loop_count == 1) begin
				valid_insn <= 1;
			end
			pc_in <= pc;
			pc <= pc_out;
			addr <= pc_out;
			loop_count <= loop_count + 1;












		end

	end



endmodule