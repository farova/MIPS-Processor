`include "control.vh"
module fetch(clk, stall, pc_out, rw, acc_size_out, control, jump_addr, address);

input clk, stall;
input wire[0:`CNTRL_REG_SIZE-1] control;
input wire[0:31] jump_addr;
output reg[0:31] pc_out;
output reg[0:31] address;
output rw;
output[0:1] acc_size_out;

reg[0:31] pc;
reg[0:1]acc_size;


initial begin
	pc_out <= 32'h80020000;
end

assign acc_size_out = 2'b00; //access size doesnt change for fetch


// if stall is high, we shouldn't increment PC

always @(posedge clk) begin
	if (!stall) begin
		if (control[`JP] || control[`BR]) begin
			address <= jump_addr;
			pc_out <= jump_addr + 4;
		end else begin
			address <= pc_out;
			pc_out <= pc_out + 4;	
		end
		
	end

end

endmodule