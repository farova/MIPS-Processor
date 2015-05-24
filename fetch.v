module Fetch(clk, stall, pc_out, rw, acc_size_out);

input clk, stall;
output[0:31] pc_out;
output rw;
output[0:1] acc_size_out;

reg[0:31] pc;
reg[0:1]acc_size;


initial begin
	pc = 32'h80020000;
	acc_size = 0;
end

assign pc_out = pc;
assign acc_size_out = 2'b00;


always @(posedge clk) begin
	if (!stall) begin
		pc <= pc + 4;
	end
end

endmodule