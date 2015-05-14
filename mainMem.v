module mainMem (clk, addr, d_in, d_out, acc_size, wren, busy, en);
	
	parameter ACCESS_SIZE 	= 2;
	parameter ADDRESS_SIZE 	= 32;
	parameter DATA_SIZE 	= 32;
	parameter MEM_SIZE 	= 1048578; // 1MB
	parameter MEM_WIDTH 	= 8;

	parameter START_ADDRESS = 32'h80020000;

	input	 			clk, wren, en;
	input [0:ADDRESS_SIZE-1] 	addr;
	input [0:DATA_SIZE-1] 		d_in;
	input [0:ACCESS_SIZE-1] 	acc_size;

	output reg[0:DATA_SIZE-1] 		d_out;
	output 				busy;

	reg [0:MEM_WIDTH-1] 		mem_block [0:MEM_SIZE-1];

	integer 					i, word_counter, total_word;
	wire[0:ADDRESS_SIZE-1]		mem_index;	// translated address index inside memory
	wire valid_addr;

	// Initilization
	initial begin
		$display ("Initialize memory to zero");

		for (i = 0; i < MEM_SIZE; i = i + 1) begin
			mem_block[i] = 0;
		end
	end

	// Memory conversion
	assign mem_index = addr - START_ADDRESS;
	
	// control signals
	assign valid_addr = addr > START_ADDRESS && mem_index < MEM_SIZE;
	
	// Write data
	always @ (posedge clk) begin
		if(en && wren && valid_addr && word_counter < total_word) begin
			mem_block[mem_index] = d_in[0:7];
			mem_block[mem_index+1] = d_in[8:15];
			mem_block[mem_index+2] = d_in[16:23];
			mem_block[mem_index+3] = d_in[24:31];
		end
		
		if(word_counter == total_word) begin
			word_counter = 0;
		end
	end
	

	// Read data
	always @ (negedge clk) begin
		if(en && !wren && valid_addr && word_counter < total_word) begin
			d_out = { mem_block[mem_index],
				mem_block[mem_index+1],
				mem_block[mem_index+2],
				mem_block[mem_index+3] };
				
			word_counter = word_counter + 1;
		end	
		
		if(word_counter == total_word) begin
			word_counter = 0;
		end
	end

	always @ (acc_size) begin
		case (acc_size)
			2'b01:
				total_word = 4;
			2'b10:
				total_word = 8;
			2'b11:
				total_word = 16;
			default:
				total_word = 1;
		endcase
	end

endmodule