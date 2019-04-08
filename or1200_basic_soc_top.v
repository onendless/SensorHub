`include "or1200/or1200_defines.v"
`include "or1200_basic_soc_defines.v"
module or1200_basic_soc_top(
	// CLK and RESET
	wb_clk_pad_i, 		// 50 MHz to pll for cpu and other logic
	rst_n_pad_i,// 50 MHz to ddr_pll for ddr
`ifdef I2C_MASTER
	i2c_scl,
	i2c_sda,
`endif
`ifdef SIMPLE_SPI
	sck_o,
	mosi_o,
	miso_i,    
	ss_o,
`endif
`ifdef UART
		UART_TXD,						//	UART Transmitter
		UART_RXD//,						//	UART Receiver
`endif
); /* end module or1200_basic_soc_top */
	
// System pads
`ifdef I2C_MASTER
	inout i2c_scl;
	inout i2c_sda;
`endif
`ifdef UART
output			UART_TXD;				//	UART Transmitter
input			UART_RXD;				//	UART Receiver
`endif
`ifdef SIMPLE_SPI
output sck_o;
output mosi_o;
input miso_i;
output ss_o;
`endif /* endif SIMPLE_SPI */

input wb_clk_pad_i;
input rst_n_pad_i;

parameter dw = `OR1200_OPERAND_WIDTH;
parameter aw = `OR1200_OPERAND_WIDTH;
wire clk_for_all;
wire rst_for_all;
assign clk_for_all =wb_clk_pad_i ;
assign rst_for_all =rst_n_pad_i;
wire [15:0]SW;
wire [31:0]LEDR;
assign SW =16'haaaa ;
//
// Signals for OR1200
//
// Instruction WISHBONE interface for OR1200
//
wire			or1k_iwb_clk_i;		// clock input
wire			or1k_iwb_rst_i;		// reset input
wire			or1k_iwb_ack_i;		// normal termination
wire			or1k_iwb_err_i;		// termination w/ error
wire			or1k_iwb_rty_i;		// termination w/ retry
wire	[dw-1:0]	or1k_iwb_dat_i;		// input data bus
wire			or1k_iwb_cyc_o;	// cycle valid output
wire	[aw-1:0]	or1k_iwb_adr_o;	// address bus outputs
wire			or1k_iwb_stb_o;		// strobe output
wire			or1k_iwb_we_o;		// indicates write transfer
wire	[3:0]		or1k_iwb_sel_o;		// byte select outputs
wire	[dw-1:0]	or1k_iwb_dat_o;	// output data bus
wire	[2:0]		or1k_iwb_cti_o;		// cycle type identifier
wire	[1:0]		or1k_iwb_bte_o;	// burst type extension

//
// Data WISHBONE interface for OR1200
//
wire			or1k_dwb_clk_i;		// clock input
wire			or1k_dwb_rst_i;		// reset input
wire			or1k_dwb_ack_i;	// normal termination
wire			or1k_dwb_err_i;		// termination w/ error
wire			or1k_dwb_rty_i;		// termination w/ retry
wire	[dw-1:0]	or1k_dwb_dat_i;	// input data bus
wire			or1k_dwb_cyc_o;	// cycle valid output
wire	[aw-1:0]	or1k_dwb_adr_o;	// address bus outputs
wire			or1k_dwb_stb_o;	// strobe output
wire			or1k_dwb_we_o;	// indicates write transfer
wire	[3:0]		or1k_dwb_sel_o;	// byte select outputs
wire	[dw-1:0]	or1k_dwb_dat_o;	// output data bus
wire [31:0]wb_ram_adr_i;
wire wb_ram_cyc_i;
wire [31:0]wb_ram_dat_i;
wire [3:0]wb_ram_sel_i;
wire wb_ram_stb_i;
wire wb_ram_we_i;
wire wb_ram_ack_o;
wire wb_ram_err_o;
wire [31:0]wb_ram_dat_o;

`ifdef GPIO
	wire wire_gpio_ack_o;
	wire wire_gpio_cyc_i;
	wire wire_gpio_stb_i;
	wire [31:0] wire_gpio_data_i;
	wire [31:0] wire_gpio_data_o;
	wire [31:0] wire_gpio_addr_i;
	wire [3:0] wire_gpio_sel_i;
	wire wire_gpio_we_i;
	wire wire_gpio_err_o;
	wire wire_gpio_interrupt;
`endif

`ifdef I2C_MASTER
	wire [2:0] wb_i2c_adr_i;
	wire [7:0] wb_i2c_dat_i;
	wire [7:0] wb_i2c_dat_o;
	wire [3:0]  wb_i2c_sel_i;
	wire wb_i2c_stb_i;
	wire wb_i2c_we_i;
	wire wb_i2c_ack_o;
	wire wb_i2c_cyc_i;
	wire wb_i2c_inta_o;

	wire [31:0] wb_i2c_dat32_i;
	wire [31:0] wb_i2c_dat32_o;

	wire scl_pad_i;
	wire scl_pad_o;
	wire scl_padoen_o;
	wire sda_pad_i;
	wire sda_pad_o;
	wire sda_padoen_o;
i2c_master_top i2c_master_top(
	//wishbone interfaces
	.wb_clk_i(clk_for_all), 
	.wb_rst_i(rst_for_all),
	.arst_i(1'b1),
	
	.wb_adr_i(wb_i2c_adr_i),
	.wb_dat_i(wb_i2c_dat_i), 
	.wb_dat_o(wb_i2c_dat_o),
	.wb_we_i(wb_i2c_we_i), 
	.wb_stb_i(wb_i2c_stb_i), 
	.wb_cyc_i(wb_i2c_cyc_i), 
	.wb_ack_o(wb_i2c_ack_o),
	.wb_inta_o(/*pic_ints[`APP_INT_I2C]*/),//此处应该是中断响应输出
	
	//i2c interface
	.scl_pad_i(scl_pad_i), 
	.scl_pad_o(scl_pad_o), 
	.scl_padoen_o(scl_padoen_o), 
	.sda_pad_i(sda_pad_i), 
	.sda_pad_o(sda_pad_o), 
	.sda_padoen_o(sda_padoen_o)		
	);

assign i2c_scl = scl_padoen_o ? 1'bz : scl_pad_o;  
assign i2c_sda = sda_padoen_o ? 1'bz : sda_pad_o; 
assign scl_pad_i = i2c_scl;
assign sda_pad_i = i2c_sda;

assign wb_i2c_dat32_o ={4{wb_i2c_dat_o}};
assign wb_i2c_dat_i =wb_i2c_dat32_i[7:0];
`endif
`ifdef UART
	wire wire_uart_ack_o;
	wire wire_uart_cyc_i;
	wire wire_uart_stb_i;
	wire [31:0] wire_uart_data_i;
	wire [31:0] wire_uart_data_o;
	wire [31:0] wire_uart_addr_i;
	wire [3:0] wire_uart_sel_i;
	wire wire_uart_we_i;
	wire wire_uart_interrupt;

	uart_top u_uart(
  .wb_clk_i(clk_i), 
  
  // Wishbone signals
  .wb_rst_i(rst), 
  .wb_adr_i(wire_uart_addr_i[4:0]), 
  .wb_dat_i(wire_uart_data_i), 
  .wb_dat_o(wire_uart_data_o), 
  .wb_we_i(wire_uart_we_i), 
  .wb_stb_i(wire_uart_stb_i), 
  .wb_cyc_i(wire_uart_cyc_i), 
  .wb_ack_o(wire_uart_ack_o), 
  .wb_sel_i(wire_uart_sel_i),
  // .int_o(wire_uart_interrupt), // interrupt request

  // UART  signals
  // serial input/output
  .stx_pad_o(uart_txd), 
  .srx_pad_i(uart_rxd),

  // modem signals
  .rts_pad_o(), 
  .cts_pad_i(1'b0), 
  .dtr_pad_o(), 
  .dsr_pad_i(1'b0), 
  .ri_pad_i(1'b0), 
  .dcd_pad_i(1'b0)//,
//`ifdef UART_HAS_BAUDRATE_OUTPUT
//  .baud_o()
//`endif
  );
`endif


`ifdef SIMPLE_SPI
wire [31:0] wb_spi_adr_i;
wire [7:0] wb_spi_dat_i;
wire [7:0] wb_spi_dat_o;
wire [31:0] wb_spi_dat32_i;
wire [31:0] wb_spi_dat32_o;
wire [3:0]  wb_spi_sel_i;
wire wb_spi_stb_i;
wire wb_spi_we_i;
wire wb_spi_ack_o;
wire wb_spi_cyc_i;

simple_spi simple_spi(
	//wishbone interfaces
	.clk_i(clk_logic), 
	.rst_i(wb_rst_pad_i),
	
	.adr_i(wb_spi_adr_i[2:0]),
	.dat_i(wb_spi_dat_i), 
	.dat_o(wb_spi_dat_o),
	.we_i(wb_spi_we_i), 
	.stb_i(wb_spi_stb_i), 
	.cyc_i(wb_spi_cyc_i), 
	.ack_o(wb_spi_ack_o),
	// .inta_o(pic_ints[`APP_INT_SPI]),
	
	//simple spi interface
	.sck_o(sck_o), 
	.mosi_o(mosi_o), 
	.miso_i(miso_i), 
	.ss_o(ss_o)
	);

assign wb_spi_dat32_o = {4{wb_spi_dat_o}};
assign wb_spi_dat_i = wb_spi_dat32_i[7:0];

`else
// assign pic_ints[`APP_INT_SPI] = 'b0;

`endif/*endif SIMPLE_SPI*/

//
// OR1K CPU
//

or1200_top cpu(
	// System
	.clk_i		(wb_clk_pad_i),
	.rst_i		( rst_n_pad_i),


	.clmode_i	(2'b00),

	// Interrupts
	.pic_ints_i	(20'b0),
	// .sig_tick(sig_tick),

	// Instruction WISHBONE INTERFACE
	.iwb_clk_i	(clk_for_all),
	.iwb_rst_i	(rst_for_all),
	.iwb_ack_i	(or1k_iwb_ack_i),
	.iwb_err_i	(or1k_iwb_err_i),
	.iwb_rty_i	(or1k_iwb_rty_i),
	.iwb_dat_i	(or1k_iwb_dat_i),
	.iwb_cyc_o	(or1k_iwb_cyc_o),
	.iwb_adr_o	(or1k_iwb_adr_o),
	.iwb_stb_o	(or1k_iwb_stb_o),
	.iwb_we_o	(or1k_iwb_we_o),
	.iwb_sel_o	(or1k_iwb_sel_o),
	.iwb_dat_o	(or1k_iwb_dat_o),
//	.iwb_cti_o		(  ),
//	.iwb_bte_o	(  ),

	// Data WISHBONE INTERFACE
	.dwb_clk_i	(clk_for_all),
	.dwb_rst_i	(rst_for_all),
	.dwb_ack_i	(or1k_dwb_ack_i),
	.dwb_err_i	(or1k_dwb_err_i),
	.dwb_rty_i	(or1k_dwb_rty_i),
	.dwb_dat_i	(or1k_dwb_dat_i),
	.dwb_cyc_o	(or1k_dwb_cyc_o),
	.dwb_adr_o	(or1k_dwb_adr_o),
	.dwb_stb_o	(or1k_dwb_stb_o),
	.dwb_we_o	(or1k_dwb_we_o),
	.dwb_sel_o	(or1k_dwb_sel_o),
	.dwb_dat_o	(or1k_dwb_dat_o),
//	.dwb_cti_o			(  ),
//	.dwb_bte_o		(  ),

	// External Debug Interface
	.dbg_stall_i	(1'b0),
//	.dbg_ewt_i	(1'b0),
	.dbg_lss_o	(),
	.dbg_is_o	(),
	.dbg_wp_o	(),
	.dbg_bp_o	(),
	.dbg_stb_i	(1'b0),
	.dbg_we_i	(1'b0),
	.dbg_adr_i	(0),
	.dbg_dat_i	(0),
	.dbg_dat_o	(),
	.dbg_ack_o	(),

	// Power Management
	.pm_cpustall_i	(1'b0),
	.pm_clksd_o	(),
	.pm_dc_gate_o	(),
	.pm_ic_gate_o	(),
	.pm_dmmu_gate_o	(), 
	.pm_immu_gate_o	(),
	.pm_tt_gate_o	(),
	.pm_cpu_gate_o	(),
	.pm_wakeup_o	(),
	.pm_lvolt_o	()
);




wb_switch_b3 #(
	.slave0_sel_addr ( `FLASH_BASE_ADDR ),
	.slave2_sel_addr ( `GPIO_BASE_ADDR),
	.slave3_sel_addr (`I2C_MASTER_ADDR),
	.slave4_sel_addr (`SIMPLE_MASTER_ADDR),
	.slave5_sel_addr (`UART_BASE_ADDR)
	)
	
	wb_switch_b3(
	// Clocks, resets
   	.wb_clk(clk_for_all),
   	.wb_rst(rst_for_all),
   	
   	// Master 0 Interface.  Connect to or32 IWB
	.wbm0_adr_o( or1k_iwb_adr_o ),
	.wbm0_bte_o(  ),
	.wbm0_cti_o(  ),
	.wbm0_cyc_o( or1k_iwb_cyc_o ),
	.wbm0_dat_o( or1k_iwb_dat_o ),
	.wbm0_sel_o( or1k_iwb_sel_o ),
	.wbm0_stb_o( or1k_iwb_stb_o ),
	.wbm0_we_o( or1k_iwb_we_o ),
	.wbm0_ack_i( or1k_iwb_ack_i ),
	.wbm0_err_i( or1k_iwb_err_i ),
	.wbm0_rty_i( or1k_iwb_rty_i ),
	.wbm0_dat_i( or1k_iwb_dat_i ),
	
	// Master 1 Interface. Connect to or32 DWB 
	.wbm1_adr_o( or1k_dwb_adr_o ),
	.wbm1_bte_o(  ),
	.wbm1_cti_o(  ),
	.wbm1_cyc_o( or1k_dwb_cyc_o ),
	.wbm1_dat_o( or1k_dwb_dat_o ),
	.wbm1_sel_o( or1k_dwb_sel_o ),
	.wbm1_stb_o( or1k_dwb_stb_o ),
	.wbm1_we_o( or1k_dwb_we_o ),
	.wbm1_ack_i( or1k_dwb_ack_i ),
	.wbm1_err_i( or1k_dwb_err_i ),
	.wbm1_rty_i( or1k_dwb_rty_i ),
	.wbm1_dat_i( or1k_dwb_dat_i ),
		
	// Slave 0 Interface. Connect to FLASH
	.wbs0_adr_i( wb_ram_adr_i ),
	.wbs0_bte_i(  ),
	.wbs0_cti_i(  ),
	.wbs0_cyc_i( wb_ram_cyc_i ),
	.wbs0_dat_i( wb_ram_dat_i ),
	.wbs0_sel_i( wb_ram_sel_i ),
	.wbs0_stb_i( wb_ram_stb_i ),
	.wbs0_we_i( wb_ram_we_i ),
	.wbs0_ack_o( wb_ram_ack_o ),
	.wbs0_err_o( 1'b0 ),
	.wbs0_rty_o( 1'b0 ),
	.wbs0_dat_o( wb_ram_dat_o ),

`ifdef GPIO
	.wbs2_adr_i( wire_gpio_addr_i ),
	.wbs2_bte_i(  ),
	.wbs2_cti_i(  ),
	.wbs2_cyc_i( wire_gpio_cyc_i ),
	.wbs2_dat_i( wire_gpio_data_i ),
	.wbs2_sel_i( wire_gpio_sel_i ),
	.wbs2_stb_i( wire_gpio_stb_i ),
	.wbs2_we_i( wire_gpio_we_i ),
	.wbs2_ack_o( wire_gpio_ack_o ),
	.wbs2_err_o( wire_gpio_err_o),
	.wbs2_rty_o( 1'b0 ),
	.wbs2_dat_o( wire_gpio_data_o ),
`endif

`ifdef I2C_MASTER
	.wbs3_adr_i( wb_i2c_adr_i ),
	.wbs3_bte_i(  ),
	.wbs3_cti_i(  ),
	.wbs3_cyc_i( wb_i2c_cyc_i ),
	.wbs3_dat_i( wb_i2c_dat32_i ),
	.wbs3_sel_i( wb_i2c_sel_i ),
	.wbs3_stb_i( wb_i2c_stb_i ),
	.wbs3_we_i( wb_i2c_we_i ),
	.wbs3_ack_o( wb_i2c_ack_o ),
	.wbs3_err_o(1'b0),
	.wbs3_rty_o( 1'b0 ),
	.wbs3_dat_o( wb_i2c_dat32_o),
`endif

`ifdef SIMPLE_SPI
	.wbs4_adr_i( wb_spi_adr_i ),
	.wbs4_bte_i(  ),
	.wbs4_cti_i(  ),
	.wbs4_cyc_i( wb_spi_cyc_i ),
	.wbs4_dat_i( wb_spi_dat32_i ),
	.wbs4_sel_i( wb_spi_sel_i ),
	.wbs4_stb_i( wb_spi_stb_i ),
	.wbs4_we_i( wb_spi_we_i ),
	.wbs4_ack_o( wb_spi_ack_o ),
	.wbs4_err_o( 'b0 ),
	.wbs4_rty_o( 'b0 ),
	.wbs4_dat_o( wb_spi_dat32_o ),
`endif

`ifdef UART
	.wbs5_adr_i(wire_uart_addr_i ),
	.wbs5_bte_i(  ),
	.wbs5_cti_i(  ),
	.wbs5_cyc_i(wire_uart_cyc_i  ),
	.wbs5_dat_i(wire_uart_data_i  ),
	.wbs5_sel_i(wire_uart_sel_i ),
	.wbs5_stb_i(wire_uart_stb_i  ),
	.wbs5_we_i(wire_uart_we_i  ),
	.wbs5_ack_o(wire_uart_ack_o),
	.wbs5_err_o( 'b0 ),
	.wbs5_rty_o( 'b0 ),
	.wbs5_dat_o(wire_uart_data_o  )
`endif
	);


`ifdef GPIO

gpio_top u_gpio(
	// WISHBONE Interface
	.wb_clk_i(clk_for_all), 
	.wb_rst_i(rst_for_all), 
	.wb_cyc_i(wire_gpio_cyc_i), 
	.wb_adr_i(wire_gpio_addr_i), 
	.wb_dat_i(wire_gpio_data_i), 
	.wb_sel_i(wire_gpio_sel_i), 
	.wb_we_i(wire_gpio_we_i), 
	.wb_stb_i(wire_gpio_stb_i),
	.wb_dat_o(wire_gpio_data_o), 
	.wb_ack_o(wire_gpio_ack_o), 
	.wb_err_o(wire_gpio_err_o), 
	.wb_inta_o(wire_gpio_interrupt),

//`ifdef GPIO_AUX_IMPLEMENT
//	// Auxiliary inputs interface
//	.aux_i(),
//`endif //  GPIO_AUX_IMPLEMENT

	// External GPIO Interface
	.ext_pad_i({16'b0,SW}), 
	.ext_pad_o(LEDR), 
	.ext_padoe_o()//,
//`ifdef GPIO_CLKPAD
//  .clk_pad_i()
//`endif
);
`endif

	// ram_top ram(
 //          .clk_i(clk_for_all),
 //          .rst_i(rst_for_all),
 //          .wb_stb_i(wb_ram_stb_i),
 //          .wb_cyc_i(wb_ram_cyc_i),
 //          .wb_ack_o(wb_ram_ack_o),
 //          .wb_addr_i(wb_ram_adr_i),
 //          .wb_sel_i(wb_ram_sel_i),
 //          .wb_we_i(wb_ram_we_i),
 //          .wb_data_i(wb_ram_dat_i),
 //          .wb_data_o(wb_ram_dat_o)
 //       );


endmodule