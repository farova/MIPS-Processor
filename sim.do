vsim Execute_tb
add wave clock
add wave fetch_insn_addr
add wave pc_fetch
add wave pc_reg1
add wave pc_reg2
add wave insnMem_out
add wave insn_reg1
add wave insn_reg2
add wave insn_reg3
add wave insn_reg4
add wave A_reg
add wave B_reg
add wave A_mux_Output
add wave B_mux_Output
add wave exec_out
add wave writeBackData
add wave O_reg
add wave B_reg2
add wave control
add wave control_ex
add wave control_reg
add wave control_reg2
run 60000