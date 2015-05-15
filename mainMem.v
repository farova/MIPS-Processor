module mainMem (clk, addr, d_in, d_out, acc_size, wren, busy, en);
	
	parameter ACCESS_SIZE 	= 2;
	parameter ADDRESS_SIZE 	= 32;
	parameter DATA_SIZE 	= 32;
	parameter MEM_SIZE 		= 1048578; // 1MB
	parameter MEM_WIDTH 	= 8;

	parameter START_ADDRESS = 32'h80020000;

	input	 					clk, wren, en;
	input [0:ADDRESS_SIZE-1] 	addr;
	input [0:DATA_SIZE-1] 		d_in;
	input [0:ACCESS_SIZE-1] 	acc_size;

	output[0:DATA_SIZE-1] 		d_out;
	output reg 					busy;

	reg [0:MEM_WIDTH-1] 		mem_block [0:MEM_SIZE-1];

	wire [0:3] num_words;
	reg [0:5] counter;
	wire enable;

	integer 					i;

	wire[0:ADDRESS_SIZE-1]  	mem_index;	// translated address index inside memory
	wire[0:ADDRESS_SIZE-1] 		start_index;
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
	assign start_index = addr - START_ADDRESS;

	// we need to use this wire to figure out how to make sure that enable cant change while this is busy
	assign enable = en;

	//increments memory index to do burst reads
	assign mem_index = start_index + counter;
	
	// control signals
	assign valid_addr = addr >= START_ADDRESS && mem_index < MEM_SIZE;


	/*data_out needs to be combinational for burst reads to work. This is because since counter is a register
	it will be zero in the first cycle since it takes a cycle for counter's real value to appear. Since in the first cycle,
	counter is zero, we would be able to retrieve the data at (start_index + 0). */
	assign d_out = (!wren && valid_addr && enable)?
				{ mem_block[mem_index],
				mem_block[mem_index+1],
				mem_block[mem_index+2],
				mem_block[mem_index+3] } : 32'h0000_0000;

	
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

	//reset the counter when enable is off, this is the only way i can think of to reset this
	always @ (posedge clk) begin
		if (!enable) begin
			counter <= 3'b000;
		end
	end

	//increment counter on negative edge and set busy flag
	always @ (posedge clk) begin
		if (counter < (num_words << 2)) begin
			counter <= counter + 3'b100; 
			busy = 1;
		end else begin
			busy = 0;
		end
	end
	
	// assign number of words to read based on access size
	assign num_words = 
		(acc_size == 2'b00)? 4'h0:
		(acc_size == 2'b01)? 4'h3:
		(acc_size == 2'b10)? 4'h7:
							 4'hf;


	/* THINGS TO DO STILL:
			- turning enable off should not affect any ongoing memory operations
			- access size needs to be related to writes for burst writes which im not sure how
			- busy turns on a cycle late, not sure if thats a problem because apparently if were only retrieving one value, 
			busy doesnt have to be one for that one cycle... so its confusing
			- Reset counter based on changes in addr, which should be a registered value on rising edge
	*/

endmodule