`include "control.vh"

module Execute_tb();

parameter START_ADDRESS = 32'h80020000;
parameter MAIN_RTRN_ADDR = 32'h77777777;


reg clock;

//Fetch registers and wires
wire[0:31] pc_fetch;
wire[0:31] jump_addr;

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
reg insnMem_wren, stall, insnMem_enable;
reg[0:1] insnMem_acc_size;
wire insnMem_busy;
wire[0:31] insnMem_addr;
wire[0:31] insnMem_data_in;
wire[0:31] insnMem_out;

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
wire[0:`CNTRL_REG_SIZE-1] control_ex;
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


//Macros
`define NULL 0
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// MODULE DEFINITIONS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	fetch 			fetch_module(clock, stall, pc_fetch, rw, acc_size_out, control_ex, jump_addr);
	mainMem 		insnMem_module(clock, insnMem_addr, insnMem_data_in, insnMem_out, insnMem_acc_size, insnMem_wren, insnMem_busy, insnMem_enable);
	decode 			decode_module(clock, insn_dec, pc_dec, valid_insn, control);
	RegisterFile 	register_module(clock, insn_dec, rtIn_reg, rdIn_reg, rsOut_reg, rtOut_reg, writeBackData, control_reg2);
	Execute 		execute_module(clock, pc_ex, rsIn_ex, rtIn_ex, insn_ex, valid_ex, control_ex, exec_out, effective_addr);
	mainMem			dataMem_module(clock, dataMem_addr, dataMem_data_in, dataMem_out, dataMem_acc_size, dataMem_wren, dataMem_busy, dataMem_enable);
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


	assign insnMem_addr = eof_flag ? pc_fetch: load_mem_addr;
	assign dataMem_addr = eof_flag ? exec_out: load_mem_addr;

	assign jump_addr = effective_addr;

	assign pc_dec = pc_reg1;
	assign pc_ex = pc_reg2;

	assign insn_dec = insn_reg1;
	assign insn_ex = insn_reg2;

	assign rsAddr = insn_reg1[6:10];
	assign rtAddr = insn_reg1[11:15];


	assign rsIn_ex = A_reg;
	assign rtIn_ex = B_reg;

	assign control_ex = control;

	assign dataMem_data_in = eof_flag ? B_reg2: data_in;
	assign insnMem_data_in = data_in;

	assign rtIn_reg = insn_reg4[11:15];
	assign rdIn_reg = insn_reg4[6:20];


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// Initilization of values
	initial begin
		clock <= 0;
		load_mem_addr <= START_ADDRESS;
		insnMem_enable <= 1;
		insnMem_wren <= 1;
		insnMem_acc_size <= 2'b00;
		dataMem_enable <= 1;
		dataMem_wren <= 0;
		dataMem_acc_size <= 2'b00;
		stall <= 1;
		valid_insn <= 0;
		valid_ex <= 0;
		loop_count <= 1;	
	end

	// Opens file for read
	initial begin
		filename = "bench-v2/BubbleSort.x";
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
		
		/*------------- START PROGRAM EXECUTION -------------*/

		while (1) begin
		
			@(posedge clock); 
			
				$display("\nPC: %h", pc_fetch);
				stall <= 1;
				/*------------- ENDS THE PROGRAM IF PC IS MAIN RETURN ADDRESS -------------*/
				if (pc_fetch == MAIN_RTRN_ADDR) begin
					$display("END OF PROGRAM\n");
					register_module.PrintRegs();
					dataMem_module.PrintStack();
					$finish;
				end
				/*------------- PRINTS THE STACK FOR BUBBLE SORT ONCE THE ARRAY HAS BEEN LOADED TO STACK -------------*/
				if (pc_fetch == 32'h8002005c) begin
					dataMem_module.PrintStack();
				end

			@(posedge clock); 
				pc_reg1 <= pc_fetch; //Loads PC + 4 into PC register
				insn_reg1 <= insnMem_out;
				valid_insn <= 1;

			@(posedge clock); 

				$display("Register file: Addresses: Rs: %d, Rt: %d Values: Rs: %d, Rt: %d", rsAddr, rtAddr, rsOut_reg, rtOut_reg);
				A_reg <= rsOut_reg;
				B_reg <= rtOut_reg;
				insn_reg2 <= insn_reg1;
				pc_reg2 <= pc_reg1;


				valid_insn <= 0; //Turn off valid insn so data is printed properly
				valid_ex <= 1;

			@(posedge clock);

				$display("Control bits: BR: %b JP: %b DMWE: %b RWE: %b RWD: %b RDST: %b ALUOP: %b ALUINB: %b JR: %b", control_ex[0], 
					control_ex[1], control_ex[2], 
					control_ex[3], control_ex[4], 
					control_ex[5], control_ex[6], 
					control_ex[7], control_ex[8]);
				$display("Effective Address (Branches/Jumps Only): %h", effective_addr);

				control_reg <= control_ex;

				B_reg2 <= B_reg;
				insn_reg3 <= insn_reg2;

				dataMem_wren <= control_ex[`DMWE]; //Sets the write enable for data memory

				valid_ex <= 0;

			@(posedge clock);

				$display("ALU_Output/Memory address: %h, Memory data (storing only): %d, Memory WREN %b", exec_out, B_reg2, dataMem_wren);

				control_reg2 <= control_reg;
				O_reg <= exec_out;
				insn_reg4 <= insn_reg3;

				dataMem_wren <= 0; //Turns write enable off so that garbage data isn't written into memory accidentally. Remove for pipeline

			@(posedge clock);

				stall <= 0; //Turn stall off so PC_Fetch increments the next clock cycle

				$display("O register: %h, Memory Output: %d", O_reg, dataMem_out);
				control_reg2[`RWE] <= 0; //Sets write enable for register file to 0 so that garbage data doesnt get written. Remove for
										 //pipeline


		end

		$finish;

	end



endmodule