`include "control.vh"

module writeBack(mem_out, exec_out, control, data_out);

input wire[0:31] mem_out;
input wire[0:31] exec_out;
input wire[0:`CNTRL_REG_SIZE-1] control;
output wire[0:31] data_out;


assign data_out = control[`RWD] ? mem_out : exec_out;



endmodule