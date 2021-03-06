
/****************************************************************************
 * tiny_soc.sv
 ****************************************************************************/
`include "wishbone_macros.svh"
  
/**
 * Module: tiny_soc
 * 
 * TODO: Add module documentation
 */
module tiny_soc(
		input clock,
		input reset,
		
		// TODO: uart
		
		// periph spi
		output				spi_sck,
		output				spi_mosi,
		input				spi_miso,
		
		output				uart_tx_o,
		input				uart_rx_i,
		
		// TODO: mmio spi
		
		// TODO: sdram
		
		// TODO: gpio
		
		output[23:0]		bram_adr,
		output[3:0]			bram_sel,
		output				bram_we,
		input[31:0]			bram_dat_r,
		output[31:0]		bram_dat_w
		);

		/**
		 * Memory Map
		 * - 0x80000000         - Boot Memory
		 * - 0x40000000         - Peripherals
		 *   - DMA
		 *   - INTC
		 *   - 
		 * - 
		 */
		localparam N_INITIATORS = 4;
		localparam N_TARGETS    = 2;
		localparam I_FWI_IDX    = 0;
		localparam I_FWD_IDX    = (I_FWI_IDX+1);
		localparam I_DMA_I0_IDX = (I_FWD_IDX+1);
		localparam I_DMA_I1_IDX = (I_DMA_I0_IDX+1);
		
		localparam T_BRAM_IDX = 0;
		localparam T_REG_IDX = (T_BRAM_IDX+1);
	
		localparam N_R_TARGETS = 6;
		localparam TR_DMA_IDX  = 0;
		localparam TR_UART_IDX = (TR_DMA_IDX+1);
		localparam TR_PIC_IDX  = (TR_UART_IDX+1);
		localparam TR_PIT_IDX  = (TR_PIC_IDX+1);
		localparam TR_SPI_IDX  = (TR_PIT_IDX+1);
		localparam TR_GPIO_IDX  = (TR_SPI_IDX+1);
		
		`WB_WIRES_ARR(i2ic_, 32, 32, N_INITIATORS);
		`WB_WIRES_ARR(ic2t_, 32, 32, N_TARGETS);
		
		`WB_WIRES_ARR(i2ric_, 32, 32, N_INITIATORS);
		`WB_WIRES_ARR(ric2t_, 32, 32, N_R_TARGETS);
		
		`WB_WIRES(fwi2ic_, 32, 32);
		`WB_WIRES(fwi2dc_, 32, 32);

		wire core_irq;
		fwrisc_rv32i_wb u_core (
				.clock(			clock),
				.reset(			reset),
	
				`WB_CONNECT_ARR(wbi_, i2ic_, I_FWI_IDX, 32, 32), 
				`WB_CONNECT_ARR(wbd_, i2ic_, I_FWD_IDX, 32, 32),
				.irq(           core_irq)
			);

		wire dma_irq;
		fwperiph_dma_wb #(
			.ch_count    (8          ), 
			.ch0_conf    ('hf        ), 
			.ch1_conf    ('hf        ), 
			.ch2_conf    ('hf        ), 
			.ch3_conf    ('hf        )
			) u_dma (
			.clock       (clock      ), 
			.reset       (reset      ), 
			`WB_CONNECT_ARR(rt_, ric2t_, TR_DMA_IDX, 32, 32),
			`WB_CONNECT_ARR(i0_, i2ic_,  I_DMA_I0_IDX, 32, 32),
			`WB_CONNECT_ARR(i1_, i2ic_,  I_DMA_I1_IDX, 32, 32),
			.dma_req_i   (dma_req_i  ), 
			.dma_ack_o   (dma_ack_o  ), 
			.dma_nd_i    (dma_nd_i   ), 
			.dma_rest_i  (dma_rest_i ), 
			.inta_o      (dma_irq    )); 

		wire uart_irq;
		fwuart_16550_wb u_uart (
			.clock     (clock    ), 
			.reset     (reset    ), 
			`WB_CONNECT_ARR(rt_, ric2t_, TR_UART_IDX, 32, 32),
			.irq       (uart_irq ), 
			.tx_o      (uart_tx_o), 
			.rx_i      (uart_rx_i), 
			.cts_i     (1'b1     ), 
			.dsr_i     (1'b1     ), 
			.ri_i      (1'b0     ), 
			.dcd_i     (1'b1     ));

		fwgpio_wb #(
			.N_PINS    (32   ), 
			.N_BANKS   (4  )
			) u_gpio (
			.clock     (clock    ), 
			.reset     (reset    ), 
			`WB_CONNECT_ARR(rt_, ric2t_, TR_GPIO_IDX, 32, 32)
			/*
			,
			.banks_o   (banks_o  ), 
			.banks_i   (banks_i  ), 
			.banks_oe  (banks_oe ), 
			.pin_o     (pin_o    ), 
			.pin_i     (pin_i    ), 
			.pin_oe    (pin_oe   )
			 */
			);
	
		wire spi_irq;
		fwspi_initiator u_spi (
			.clock     (clock    ), 
			.reset     (reset    ),
			`WB_CONNECT_ARR(rt_, ric2t_, TR_SPI_IDX, 32, 32),
			.inta      (spi_irq  ), 
			.sck       (spi_sck  ), 
			.mosi      (spi_mosi ), 
			.miso      (spi_miso ));
	
		wire pit_irq;
		fwpit_wb #(
			.PRE_COUNT_SIZE  (16     ), 
			.COUNT_SIZE      (16     )
			) fwpit_wb (
			.clock           (clock          ), 
			.reset           (reset          ), 
			`WB_CONNECT_ARR(rt_, ric2t_, TR_PIT_IDX, 32, 32),
			.irq             (pit_irq        ));
	
		wire[7:0] pic_irq = {
				1'b0,
				1'b0,
				1'b0,
				1'b0,
				spi_irq,
				pit_irq,
				dma_irq,
				uart_irq};
		
		fwpic_wb #(
				.N_IRQ     (8        )
			) u_pic (
				.clock     (clock    ), 
				.reset     (reset    ), 
				`WB_CONNECT_ARR(rt_, ric2t_, TR_PIC_IDX, 32, 32),
				.int_o     (core_irq ), 
				.irq       (pic_irq  ));
		
	
		wb_interconnect_NxN #(
				.WB_ADDR_WIDTH(32),
				.WB_DATA_WIDTH(32),
				.N_INITIATORS(N_INITIATORS),
				.N_TARGETS(N_TARGETS),
				.T_ADR_MASK({
						32'hFF00_0000,
						32'hFFFF_0000
					}),
				.T_ADR({
					32'h8000_0000, // BRAM
					32'h4000_0000  // Peripherals
					})
			) u_ic (
				.clock(			clock),
				.reset(			reset),
				
				`WB_CONNECT(, i2ic_),
				`WB_CONNECT(t, ic2t_)
			);

		`WB_WIRES(ic2bram_, 32, 32);
		`WB_ASSIGN_ARR2WIRES(ic2bram_, ic2t_, T_BRAM_IDX, 32, 32);
		
		assign bram_adr      = ic2bram_adr;
		assign bram_dat_w    = ic2bram_dat_w;
		assign ic2bram_dat_r = bram_dat_r;
		assign bram_we       = (ic2bram_cyc && ic2bram_stb && ic2bram_we);
		assign bram_sel      = ic2bram_sel;
		reg ic2bram_ack_r = 0;
		assign ic2bram_ack   = ic2bram_ack_r;
		
		always @(posedge clock) begin
			if (ic2bram_ack_r) begin
				ic2bram_ack_r <= 0;
			end else if (ic2bram_cyc && ic2bram_stb) begin
				ic2bram_ack_r <= 1;
			end
		end
	
		// Register interconnect
		wb_interconnect_NxN #(
				.WB_ADDR_WIDTH(32),
				.WB_DATA_WIDTH(32),
				.N_TARGETS(4),
				.N_INITIATORS(1),
				.T_ADR_MASK({
						32'hFFFF_F000,
						32'hFFFF_F000,
						32'hFFFF_F000,
						32'hFFFF_F000
					}),
				.T_ADR({
					32'h4000_1000, // DMA
					32'h4000_2000, // UART
					32'h4000_3000, // PIC
					32'h4000_4000  // PIT
					})
			) u_regic (
				.clock(			clock),
				.reset(			reset),
				`WB_CONNECT_ARR(, ic2t_, T_REG_IDX, 32, 32),
				`WB_CONNECT(t, ric2t_)
			);

endmodule


