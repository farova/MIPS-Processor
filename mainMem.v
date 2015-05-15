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

	output[0:DATA_SIZE-1] 		d_out;
	output reg 				busy;

<<<<<<< HEAD
	reg [0:MEM_WIDTH-1] 		mem_block [0:MEM_SIZE-1];
	wire [0:DATA_SIZE-1] output_val;
=======
	reg [0:MEM_WIDTH-1] 		mem_block [0:MEM_SIZE-1];
	reg [0:DATA_SIZE-1] output_val;
>>>>>>> c695340727f1128cc78dbd04090c5bb758c92182

	wire [0:3] num_words;
	reg [0:3] counter;
	wire enable;

	integer 					i;

	wire[0:ADDRESS_SIZE-1]  mem_index;	// translated address index inside memory
	wire[0:ADDRESS_SIZE-1] mem_index;
	wire valid_addr;

	// Initilization
	initial begin
		$display ("Initialize memory to zero");

		for (i = 0; i < MEM_SIZE; i = i + 1) begin
			mem_block[i] = 0;
		end
		counter = 0;

	end

	// Memory conversion
	assign mem_index = addr - START_ADDRESS;

	assign enable = (busy == 0) ? en : !en;
	
	// control signals
	assign valid_addr = addr >= START_ADDRESS && mem_index < MEM_SIZE;

	assign d_out = (!wren && valid_addr && enable)?
				{ mem_block[mem_index],
				mem_block[mem_index+1],
				mem_block[mem_index+2],
				mem_block[mem_index+3] } : 32'h0000_0000;
	
	assign busy = en && valid_addr && word_counter < total_word;
	
	// Write data
	always @ (posedge clk) begin

		if (enable && valid_addr) begin
			if(wren) begin
				mem_block[mem_index] = d_in[0:7];
				mem_block[mem_index+1] = d_in[8:15];
				mem_block[mem_index+2] = d_in[16:23];
				mem_block[mem_index+3] = d_in[24:31];
			end
		end
	end

	always @ (negedge clk) begin
		if (counter < num_words) begin
			counter <= counter + 1;
			busy = 1;
		end else begin
			busy = 0;
		end
	end
	
	assign num_words = 
		(acc_size == 2'b00)? 4'h0:
		(acc_size == 2'b01)? 4'h3:
		(acc_size == 2'b10)? 4'h7:
							4'hf;

	// somehow reset counter

endmodule