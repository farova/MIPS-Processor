module main_mem (clk, addr, d_in, d_out, acc_size, wren, busy, en);
input clk, wren;
input [0:31] addr, data_in;
input [0:1] acc_size;

output [0:31] data_out;
output busy;

reg [0:31] mem_block [1048578];	// 1MB


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