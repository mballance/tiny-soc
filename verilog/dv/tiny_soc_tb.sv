
/****************************************************************************
 * tiny_soc_tb.sv
 ****************************************************************************/
`ifdef NEED_TIMESCALE
`timescale 1ns/1ns
`endif

  
/**
 * Module: tiny_soc_tb
 * 
 * TODO: Add module documentation
 */
module tiny_soc_tb(input clock);
	
`ifdef HAVE_HDL_CLOCKGEN
	reg clock_r = 0;
	initial begin
		forever begin
`ifdef NEED_TIMESCALE
			#5;
`else
			#5ns;
`endif
			clock_r <= ~clock_r;
		end
	end
	assign clock = clock_r;
`endif
	
`ifdef IVERILOG
`include "iverilog_control.svh"
`endif

	reg 		reset /* verilator public */= 0;
	reg[7:0]	reset_cnt = 0;
			
	always @(posedge clock) begin
		case (reset_cnt)
			2: begin
				reset <= 1;
				reset_cnt <= reset_cnt + 1;
			end
			20: reset <= 0;
			default: reset_cnt <= reset_cnt + 1;
		endcase
	end

	wire[31:0]			bram_adr;
	wire[31:0]			bram_dat_r;
	wire[31:0]			bram_dat_w;
	wire[3:0]			bram_sel;
	wire				bram_we;
	
	tiny_soc u_dut(
			.clock(			clock),
			.reset(			reset),
			.bram_adr(		bram_adr),
			.bram_dat_r(	bram_dat_r),
			.bram_dat_w(	bram_dat_w),
			.bram_sel(		bram_sel),
			.bram_we(		bram_we)
		);
	
	generic_sram_byte_en_target_bfm #(
			.ADR_WIDTH(24),
			.DAT_WIDTH(32)
		) u_bram_bfm (
			.clock(			clock),
			.adr(			bram_adr[25:2]),
			.dat_r(			bram_dat_r),
			.dat_w(			bram_dat_w),
			.sel(			bram_sel),
			.we(			bram_we)
		);

`define U_CORE_PATH u_dut.u_core.u_core.u_core
	wire 				rv_dbg_valid = `U_CORE_PATH .instr_complete;
	wire[31:0] 			rv_dbg_instr = `U_CORE_PATH .tracer_instr;
	wire				rv_dbg_trap  = `U_CORE_PATH .trap;
	wire[4:0] 			rv_dbg_rd_addr = `U_CORE_PATH .rd_waddr;
	wire[31:0] 			rv_dbg_rd_wdata = `U_CORE_PATH .rd_wdata;
	wire[31:0]			rv_dbg_pc = `U_CORE_PATH .tracer_pc;
	reg[31:0]			rv_dbg_mem_addr  = {32{1'b0}};
	wire				rv_dbg_mvalid    = (`U_CORE_PATH .dready && `U_CORE_PATH .dvalid);
	reg[3:0]			rv_dbg_mem_wmask = {4{1'b0}};
	reg[3:0]			rv_dbg_mem_rmask = {4{1'b0}};
	reg[31:0]			rv_dbg_mem_data  = {32{1'b0}};
	
	always @(posedge clock) begin
		if (rv_dbg_valid) begin
			rv_dbg_mem_wmask <= {4{1'b0}};
			rv_dbg_mem_rmask <= {4{1'b0}};
			rv_dbg_mem_addr  <= {32{1'b0}};
			rv_dbg_mem_data <= {32{1'b0}};
		end else if (rv_dbg_mvalid) begin
			rv_dbg_mem_addr  <= `U_CORE_PATH .daddr;
			if (`U_CORE_PATH .dwrite) begin
				rv_dbg_mem_wmask <= `U_CORE_PATH .dwstb;
				rv_dbg_mem_data <= `U_CORE_PATH .dwdata;
			end else begin
				rv_dbg_mem_rmask <= 'hf; // TMP
				rv_dbg_mem_data <= `U_CORE_PATH .drdata;
			end
		end
	end
`undef U_CORE_PATH
	
	riscv_debug_bfm u_dbg_bfm (
			.clock(				clock),
			.reset(				reset),
			.valid( 			rv_dbg_valid),
			.instr( 			rv_dbg_instr),
			.intr(				rv_dbg_trap),
			.rd_addr( 			rv_dbg_rd_addr),
			.rd_wdata( 			rv_dbg_rd_wdata),
			.pc(				rv_dbg_pc),
			.mem_addr(			rv_dbg_mem_addr),
			.mem_rmask(			rv_dbg_mem_rmask),
			.mem_wmask(			rv_dbg_mem_wmask),
			.mem_data(			rv_dbg_mem_data)
			);	

endmodule


