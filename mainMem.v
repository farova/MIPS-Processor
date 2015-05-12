module main_mem (clk, addr, d_in, d_out, acc_size, wren, busy, en);

parameter ACCESS_SIZE 	= 2;
parameter ADDRESS_SIZE 	= 32;
parameter DATA_SIZE 	= 32;
parameter MEM_SIZE 	= 1048578; // 1MB
parameter MEM_WIDTH 	= 8;

input clk, wren;
input [0:ADDRESS_SIZE-1] 	addr;
input [0:DATA_SIZE-1] 		data_in;
input [0:ACCESS_SIZE-1] 	acc_size;

output [0:DATA_SIZE-1] 		data_out;
output 				busy;

reg [0:DATA_SIZE-1] 		mem_block [0:MEM_SIZE-1];


always @ (posedge clk) begin
		
end

case (acc_size)
	00: 
	01:
	10:
	11: 
	default:
endcase


endmodule