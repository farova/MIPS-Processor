`include "control.vh"

module Execute_tb();

parameter START_ADDRESS = 32'h80020000;
parameter MAIN_RTRN_ADDR = 32'h77777777;
parameter NOP = 32'h00000000;


reg clock;

//Fetch registers and wires
wire[0:31] pc_fetch;
wire[0:31] jump_addr;
wire[0:31] fetch_insn_addr;
wire fetch_stall;
reg shouldStall;

//PC Registers
reg[0:31] pc_reg1;
reg[0:31] pc_reg2;

//Insn Registers
reg[0:31] insn_reg1;
reg[0:31] insn_reg2;
reg[0:31] insn_reg3;
reg[0:31] insn_reg4;

//A and B registers for X/M
reg[0:31] A_reg;
reg[0:31] B_reg;

//The B and O registers for M/W
reg[0:31] B_reg2;
reg[0:31] O_reg;

//Insn Mem registers and wires
reg insnMem_wren, stall, insnMem_enableReg;
wire insnMem_enable;
reg[0:1] insnMem_acc_size;
wire insnMem_busy;
wire[0:31] insnMem_addr;
wire[0:31] insnMem_data_in;
wire[0:31] insnMem_out;
reg insnMem_Nop;
wire insnMem_byteOnly, insnMem_ubyte, insnMem_halfword;

//Registers for address and data_in
reg[0:31] load_mem_addr;
reg[0:31] data_in;

//Decode registers and wires
reg valid_insn;
wire[0:31] pc_dec;
wire[0:31] insn_dec;
wire[0:`CNTRL_REG_SIZE-1] control;

//Execute registers and wires
reg valid_ex;
wire[0:31] pc_ex;
wire[0:31] insn_ex;
reg[0:`CNTRL_REG_SIZE-1] control_ex;
wire[0:31] rsIn_ex;
wire[0:31] rtIn_ex;
wire [0:31] exec_out;
wire[0:31] effective_addr;

//Control register 1
reg[0:`CNTRL_REG_SIZE-1] control_reg;

//Register File registers and wires
reg[0:`CNTRL_REG_SIZE-1] control_reg2;
wire[0:4] rtIn_reg;
wire[0:4] rdIn_reg;
wire[0:31] writeBackData;
wire[0:31] rsOut_reg;
wire[0:31] rtOut_reg;

//Data Memory registers and wires
reg[0:1] dataMem_acc_size;
reg dataMem_wren, dataMem_enable;
wire[0:31] dataMem_addr;
wire[0:31] dataMem_data_in;
wire[0:31] dataMem_out;
wire dataMem_busy;
reg dataMem_Nop;
wire dataMem_byteOnly, dataMem_ubyte, dataMem_halfword;


//File reading registers and values
integer data_file, scan_file;
reg eof_flag;
reg[0:21*8] filename;
reg [0:31] captured_data;


//Counter which counts number of addresses and loop_count which counts to counter
integer counter, loop_count;


wire[0:1] acc_size_out;
wire[0:4] rsAddr;
wire[0:4] rtAddr;

//Bypassing wires and Branch Recover
wire[0:4] DX_Rs;
wire[0:4] DX_Rt;
wire[0:4] DX_Rd;
wire[0:4] XM_Rd;
wire[0:4] XM_Rt;
wire[0:4] XM_Rs;
wire[0:4] MW_Rd;
wire[0:4] MW_Rt;
wire[0:4] FD_Rs;
wire[0:4] FD_Rt;
reg[0:31] A_mux_Output;
reg[0:31] B_mux_Output;
reg[0:31] data_in_mux;
reg[0:31] insnReg2Mux;


reg isLoad;
reg isStore;


//Macros
`define NULL 0
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// MODULE DEFINITIONS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	fetch 			fetch_module(clock, fetch_stall, pc_fetch, rw, acc_size_out, control_ex, jump_addr, fetch_insn_addr);
	mainMem 		insnMem_module(clock, insnMem_addr, insnMem_data_in, insnMem_out, insnMem_acc_size, insnMem_wren, insnMem_busy, insnMem_enable, insnMem_byteOnly, insnMem_ubyte, insnMem_Nop, insnMem_halfword);
	decode 			decode_module(clock, insn_dec, pc_dec, valid_insn, control);
	RegisterFile 	register_module(clock, insn_dec, rtIn_reg, rdIn_reg, rsOut_reg, rtOut_reg, writeBackData, control_reg2);
	Execute 		execute_module(clock, pc_ex, rsIn_ex, rtIn_ex, insn_ex, valid_ex, control_ex, exec_out, effective_addr);
	mainMem			dataMem_module(clock, dataMem_addr, dataMem_data_in, dataMem_out, dataMem_acc_size, dataMem_wren, dataMem_busy, dataMem_enable, dataMem_byteOnly, dataMem_ubyte, dataMem_Nop, dataMem_halfword);
	writeBack 		writeBack_module(dataMem_out, O_reg, control_reg2, writeBackData);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// TASKS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Open the file
	task OpenFile;
		begin
			data_file = $fopen(filename, "r");
		 		if (data_file == `NULL) begin
				$display("data_file handle was NULL");
				$finish;
		 		end
		end
	endtask

	// Read a line of the file
	task ReadFile;
		begin
			if (!$feof(data_file)) begin
					scan_file = $fscanf(data_file, "%h\n", captured_data);
					eof_flag = 1'b0;
				end else begin
					$display("Reached the end of file!");
					eof_flag = 1'b1;
				end
		end
	endtask

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// COMBINATIONAL LOGIC
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//fetch
	assign fetch_stall = shouldStall ? 1 : stall;
	assign jump_addr = effective_addr;

	//Insn Mem
	assign insnMem_byteOnly = 0;
	assign insnMem_ubyte = 0;
	assign insnMem_halfword = 0;
	assign insnMem_addr = eof_flag ? fetch_insn_addr: load_mem_addr;
	assign insnMem_enable = shouldStall ? 0 : insnMem_enableReg;
	assign insnMem_data_in = data_in;

	//Decode
	assign pc_dec = pc_fetch;
	assign insn_dec = insnMem_out;

	//Register File 
	assign rsAddr = insnMem_out[6:10];
	assign rtAddr = insnMem_out[11:15];
	assign rtIn_reg = insn_reg4[11:15];
	assign rdIn_reg = insn_reg4[16:20];

	//Execute
	assign pc_ex = pc_reg2;
	assign insn_ex = insn_reg2;
	assign rsIn_ex = A_mux_Output;
	assign rtIn_ex = B_mux_Output;

	//Data Mem
	assign dataMem_addr = eof_flag ? exec_out: load_mem_addr;
	assign dataMem_data_in = eof_flag ? data_in_mux: data_in;
	assign dataMem_byteOnly = control_reg[`BYTE];
	assign dataMem_ubyte = control_reg[`UBYTE];
	assign dataMem_halfword = control_reg[`HALFWRD];
	
	//Bypassing signals
	assign FD_Rs = insnMem_out[6:10];
	assign FD_Rt = insnMem_out[11:15];
	assign DX_Rs = insn_reg2[6:10];
	assign DX_Rt = insn_reg2[11:15];
	assign XM_Rd = control_reg[`ALUINB] ? insn_reg3[11:15]: insn_reg3[16:20];
	assign XM_Rt = insn_reg3[11:15];
	assign XM_Rs = insn_reg3[6:10];
	assign MW_Rd = control_reg2[`ALUINB] ? insn_reg4[11:15]:insn_reg4[16:20];
	assign MW_Rt = insn_reg4[11:15];
	

	//Branch Recovery for first IR
	always@(*) begin
		dataMem_Nop = 0;
		if ((control_ex[`BR] || control_ex[`JP]) && effective_addr != pc_fetch) begin
			insnMem_Nop = 1;
		end else begin
			insnMem_Nop = 0;
		end
	end

	//Insert Nop on Load-Use Stall and check for Branch Recovery for second IR
	always@(*) begin
		if (control_ex[`LOAD] && ((FD_Rs == DX_Rt && control[`SRC1]) || ((FD_Rt == DX_Rt && control[`SRC2]) && !control[`STORE]))) begin
			insnReg2Mux = NOP;
			shouldStall = 1;
		end else begin
			if ((control_ex[`BR] || control_ex[`JP]) && effective_addr != pc_fetch) begin
				insnReg2Mux = NOP;
			end else begin
				insnReg2Mux = insnMem_out;
			end
			shouldStall = 0;
		end
	end

	//Bypassing MUX for ALU_A
	always@(*) begin
		if (DX_Rs == XM_Rd && control_ex[`SRC1] && control_reg[`DEST]) begin
			A_mux_Output = exec_out;
		end else if (DX_Rs == MW_Rd && control_ex[`SRC1] && control_reg2[`DEST]) begin
			A_mux_Output = writeBackData;
		end else begin
			A_mux_Output = A_reg;
		end
		
	end

	//Bypassing MUX for ALU_B
	always@(*) begin
		if (DX_Rt == XM_Rd && control_ex[`SRC2] && control_reg[`DEST]) begin
			B_mux_Output = exec_out;
		end else if (DX_Rt == MW_Rd && control_ex[`SRC2] && control_reg2[`DEST]) begin
			B_mux_Output = writeBackData;
		end else begin
			B_mux_Output = B_reg;
		end
	end

	// Bypassing mux for data memory input
	always@(*) begin
		if (control_reg[`STORE] && control_reg2[`LOAD]) begin
			if (XM_Rt == MW_Rt) begin
				data_in_mux = writeBackData;
			end else begin
				data_in_mux = B_reg2;
			end
		end else begin
			data_in_mux = B_reg2;
		end
	end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// CLOCKED LOGIC
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// Initilization of values
	initial begin
		clock <= 0;
		load_mem_addr <= START_ADDRESS;
		insnMem_enableReg <= 1;
		insnMem_wren <= 1;
		insnMem_acc_size <= 2'b00;
		dataMem_enable <= 1;
		dataMem_wren <= 0;
		dataMem_acc_size <= 2'b00;
		stall <= 1;
		valid_insn <= 0;
		valid_ex <= 0;
		loop_count <= 1;
		shouldStall = 0;	
	end

	// Opens file for read
	initial begin
		filename = "DemoDoom2015.x";
		$display("%s\n", filename);
  		OpenFile();
	end

	initial begin
		$dumpfile("test.vcd");
		$dumpvars;
	end

	// Simulate clock
	always #10 clock = !clock;


	initial begin

		/*------------- Write data to memory -------------*/
		@(posedge clock);

			insnMem_wren <= 1'b1;
			insnMem_acc_size <= 2'b00;
			dataMem_wren <= 1'b1;
			dataMem_acc_size <= 2'b00;
			
			ReadFile();
			data_in <= captured_data;

			counter <= 1;

			while (!eof_flag) begin
				@(posedge clock);
				ReadFile();
				data_in <= captured_data;
				load_mem_addr <= load_mem_addr + 4;
				counter <= counter + 1;
			end

			register_module.PrintRegs();
			//dataMem_module.dump();  //for debugging purposes


			insnMem_wren <= 0;
			dataMem_wren <= 0;
			stall <= 0;
			insnMem_acc_size <= acc_size_out;

		@(posedge clock);
		valid_insn <= 1;
		
		/*------------- START PROGRAM EXECUTION -------------*/

		while (1) begin
		
			@(posedge clock); 
			
				/*------------- ENDS THE PROGRAM IF PC IS MAIN RETURN ADDRESS -------------*/
				if (fetch_insn_addr == MAIN_RTRN_ADDR) begin
					$display("END OF PROGRAM\n");
					register_module.PrintRegs();
					dataMem_module.PrintStack();
					$finish;
				end
				//$display("INSTRUCTION: %h", fetch_insn_addr);

				// Prints the registers and the stack (DEBUGGING)
				//register_module.PrintRegs();
				//dataMem_module.PrintStack();

				//PC
				pc_reg1 <= pc_fetch;
				pc_reg2 <= pc_reg1;

				//Insn
				insn_reg2 <= insnReg2Mux;
				insn_reg3 <= insn_reg2;
				insn_reg4 <= insn_reg3;
				
				//Register outputs of reg file
				A_reg <= rsOut_reg;
				B_reg <= rtOut_reg;

				//Register B value for data_in
				B_reg2 <= B_mux_Output;

				O_reg <= exec_out;

				//Sets the write enable for data memory
				dataMem_wren <= control_ex[`DMWE]; 
				
				//Turns on valid_ex in the first clock cycle
				valid_ex <= 1; 

				// Make sure to stall control signals if theres a stall
				if (shouldStall) begin
					for (counter = 0; counter < `CNTRL_REG_SIZE-1; counter = counter + 1) begin
						control_ex[counter] <= 0;
					end
				end else begin
					control_ex <= control;
				end
				control_reg <= control_ex;
				control_reg2 <= control_reg;
		end

		$finish;

	end



endmodule