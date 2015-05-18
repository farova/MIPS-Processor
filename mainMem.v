module mainMem (clk, addr, d_in, d_out, acc_size, wren, busy, enable);
	
	parameter ACCESS_SIZE 	= 2;
	parameter ADDRESS_SIZE 	= 32;
	parameter DATA_SIZE 	= 32;
	parameter MEM_SIZE 	= 1048578; // 1MB
	parameter MEM_WIDTH 	= 8;

	parameter START_ADDRESS = 32'h80020000;

	input	 			clk, wren, enable;
	input [0:ADDRESS_SIZE-1] 	addr;
	input [0:DATA_SIZE-1] 		d_in;
	input [0:ACCESS_SIZE-1] 	acc_size;

	output reg[0:DATA_SIZE-1] 	d_out;
	output reg			busy;

	reg reset_counter;

	reg [0:ADDRESS_SIZE-1]		addr_reg;
	reg [0:ACCESS_SIZE-1] 		acc_size_reg;
	reg				wren_reg;
	
	reg [0:MEM_WIDTH-1] 		mem_block [0:MEM_SIZE-1];

	wire [0:3] 			num_words;
	reg [0:5] 			counter;

	integer 			i;

	wire[0:ADDRESS_SIZE-1]  	mem_index;	// translated address index inside memory
	wire[0:ADDRESS_SIZE-1] 		start_index;
	wire 				valid_addr;

	// Initilization
	initial begin
		// Initialize memory to 0
		for (i = 0; i < MEM_SIZE; i = i + 1) begin
			mem_block[i] = 0;
		end
		
		counter = 0;

	end

	// Memory conversion
	assign start_index = addr - START_ADDRESS;

	//increments memory index to do burst reads
	assign mem_index = start_index + (counter << 2);
	
	// control signals
	assign valid_addr = addr >= START_ADDRESS && mem_index < MEM_SIZE;
	
	// Write data
	always @ (posedge clk) begin

		if (counter < num_words) begin
			counter <= counter + 1;
			busy = 1;
		end else begin
			busy = 0;
		end

		if ((enable || busy) && valid_addr) begin
			if(wren) begin
				mem_block[mem_index] = d_in[0:7];
				mem_block[mem_index+1] = d_in[8:15];
				mem_block[mem_index+2] = d_in[16:23];
				mem_block[mem_index+3] = d_in[24:31];
			end else begin
				d_out = 
					{ mem_block[mem_index],
					mem_block[mem_index+1],
					mem_block[mem_index+2],
					mem_block[mem_index+3] };
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

	// assign number of words to read based on access size
	assign num_words = 
		(acc_size == 2'b00)? 4'h0:
		(acc_size == 2'b01)? 4'h3:
		(acc_size == 2'b10)? 4'h7:
					4'hf;


	/* THINGS TO DO STILL:
			- busy deasserts 1 cycle too early 
	*/

endmodule