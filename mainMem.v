module mainMem (clk, addr, d_in, d_out, acc_size, wren, busy, en);

parameter ACCESS_SIZE 	= 2;
parameter ADDRESS_SIZE 	= 32;
parameter DATA_SIZE 	= 32;
parameter MEM_SIZE 	= 1048578; // 1MB
parameter MEM_WIDTH 	= 8;

input clk, wren, en;
input [0:ADDRESS_SIZE-1] 	addr;
input [0:DATA_SIZE-1] 		d_in;
input [0:ACCESS_SIZE-1] 	acc_size;

output [0:DATA_SIZE-1] 		d_out;
output 				busy;

reg [0:DATA_SIZE-1] 		mem_block [0:MEM_SIZE-1];

integer i;

initial begin
	$display ("Initialize memory to zero");

	for (i = 0; i < MEM_SIZE; i = i + 1) begin
		mem_block[i] = 0;
	end
end

always @ (posedge clk) begin
		
end

/*case (acc_size)
	//2'b00: 
	//2'b01:
	//2'b10:
	//2'b11: 
	//default:
endcase*/


endmodule