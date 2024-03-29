module mainMem (clk, addr, d_in, d_out, acc_size, wren, busy, enable, byteOnly, ubyte, outputNop, halfWord);
	
	// Parameters
	parameter ACCESS_SIZE 	= 2;
	parameter ADDRESS_SIZE 	= 32;
	parameter DATA_SIZE 	= 32;
	parameter MEM_SIZE 	= 1048578; // 1MB
	parameter MEM_WIDTH 	= 8;
	parameter START_ADDRESS = 32'h80020000;
	parameter STACK_PNTR_BASE_ADDR = 32'h80120002;
	parameter NOP = 32'h00000000;

	// Inputs
	input	 			clk, wren, enable;
	input [0:ADDRESS_SIZE-1] 	addr;
	input [0:DATA_SIZE-1] 		d_in;
	input [0:ACCESS_SIZE-1] 	acc_size;
	input byteOnly;
	input ubyte;
	input halfWord;
	input outputNop;

	// Outputs
	output reg[0:DATA_SIZE-1] 	d_out;
	output reg			busy;

	// Registers for inputs
	reg [0:ADDRESS_SIZE-1]		addr_reg;
	reg [0:ACCESS_SIZE-1] 		acc_size_reg;
	reg				wren_reg;
	
	// RAM
	reg [0:MEM_WIDTH-1] 		mem_block [0:MEM_SIZE-1];

	// Control counters
	wire [0:3] 			num_words;
	reg [0:5] 			counter;
	reg 				reset_counter;
	integer 			i;

	// Control vals
	wire[0:ADDRESS_SIZE-1]  	mem_index;	// translated address index inside memory
	wire[0:ADDRESS_SIZE-1] 		start_index;
	wire 				valid_addr;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// TASKS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	task dump; 
   		integer i; 
   		integer filenum; 
		begin 
   			$display("Writing external memory contents to mem_block.txt"); 
   			filenum = $fopen("mem_block.txt"); 
   			for (i = 0; i < MEM_SIZE-1; i = i + 1) begin 
      			if (mem_block[i] !== 16'hxxxx) 
         			$fdisplay(filenum,"%h : %h", i, mem_block[i]); 
   			end 
		end 
	endtask

	task PrintStack;
		integer i;
		reg[0:31] result;
		reg[0:31] address;
		begin
			$display("\nPrinting Stack\n");
			address = STACK_PNTR_BASE_ADDR;
			for (i = 0; i < 30; i = i + 1) begin
				result[0:7] = mem_block[address - START_ADDRESS];
				result[8:15] = mem_block[(address + 1) - START_ADDRESS];
				result[16:23] = mem_block[(address + 2) - START_ADDRESS]; 
				result[24:31] = mem_block[(address + 3) - START_ADDRESS];
				$display("Stack at address: %h, value: %d", address, result);
				address = address - 4;
			end
		end
	endtask
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// COMBINATIONAL LOGIC
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Memory conversion
	assign start_index = addr - START_ADDRESS;

	//increments memory index to do burst reads
	assign mem_index = start_index + (counter << 2);
	
	// control signals
	assign valid_addr = addr >= START_ADDRESS && mem_index < MEM_SIZE;

	// assign number of words to read based on access size
	assign num_words = 
		(acc_size == 2'b00)? 4'h0:
		(acc_size == 2'b01)? 4'h3:
		(acc_size == 2'b10)? 4'h7:
					4'hf;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// Initilization
	initial begin
		// Initialize memory to 0
		for (i = 0; i < MEM_SIZE; i = i + 1) begin
			mem_block[i] <= 0;
		end
		
		counter <= 0;

	end


	
	// Write data
	always @ (posedge clk) begin

		if (counter < num_words) begin
			counter <= counter + 1;
			busy <= 1;
		end else begin
			busy <= 0;
		end

		if ((enable || busy) && valid_addr) begin
			if(wren) begin
				if (byteOnly) begin
					mem_block[mem_index] <= d_in[24:31];
				end else if (halfWord) begin
					mem_block[mem_index] <= d_in[16:23];
					mem_block[mem_index+1] <= d_in[24:31];
				end else begin
					mem_block[mem_index] <= d_in[0:7];
					mem_block[mem_index+1] <= d_in[8:15];
					mem_block[mem_index+2] <= d_in[16:23];
					mem_block[mem_index+3] <= d_in[24:31];
				end
				
			end else begin
				if (outputNop) begin
					d_out <= NOP;
				end else begin
					if (byteOnly) begin
						if (ubyte) begin
							//$display("32 bit value: %h Byte value: %h", { {24{1'b0}}, mem_block[mem_index]}, mem_block[mem_index]);
							d_out <= { {24{1'b0}}, mem_block[mem_index]};
						end else begin
							//$display("First value: %b Byte value: %h", mem_block[mem_index][0], mem_block[mem_index]);
							d_out <= { {24{mem_block[mem_index][0]}}, mem_block[mem_index]};
						end
					end else begin
						d_out <= { mem_block[mem_index],
						mem_block[mem_index+1],
						mem_block[mem_index+2],
						mem_block[mem_index+3] };
					end
				end
				
				
			end
		end
	end

	//reset the counter
	always @ (addr_reg, acc_size_reg, wren_reg) begin
		if (enable) begin
			counter <= 3'b000;
		end
	end
	
	always @(negedge clk) begin
		addr_reg <= addr;
		acc_size_reg <= acc_size;
		wren_reg <= wren;
	end


endmodule