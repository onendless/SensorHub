//	vsim -L altera_lpm -L altera_mf -novopt work.or1200_soc_top_vlg_tst

/* Interrupts */ 
`define APP_INT_RES1	1:0  
`define APP_INT_UART	2
`define APP_INT_I2C		3
`define APP_INT_ETH	4
`define APP_INT_SPI		5
`define APP_INT_KEY0	6
`define APP_INT_KEY1	7
`define APP_INT_RES		19:8

/* Peripheral Addr, modify by manual */
`define FLASH_BASE_ADDR	4'h0		//slave X address, connect to 
`define GPIO_BASE_ADDR 8'h10
`define I2C_MASTER_ADDR 8'h20
`define SIMPLE_MASTER_ADDR 8'h30
`define UART_BASE_ADDR 8'h40
// `define SDRAM_BASE_ADDR	4'h0		//slave X address, connect to DDR_SDRAM
// `define UART_BASE_ADDR	8'h90	//slave X address, connect to UART

// `define I2C_BASE_ADDR		8'h91	//slave X address, connect to 
// `define SPI_BASE_ADDR		8'h94	//slave X address, connect to 
// `define GPIO_BASE_ADDR	8'h93	//slave X address, connect to 
// `define ETH_BASE_ADDR		8'h92	//slave X address, connect to 
// `define I2S_BASE_ADDR		8'h95	//slave X address, connect to

/* DDR SDRAM paremeter */
`define DDR_DW	32 
`define DDR_BW	4
`define GPIO
`define I2C_MASTER
`define SIMPLE_SPI
`define UART
//
// SRAM
// decide to use inner sram or extern sram ,uncomment to use an externl one and comment to use a inner one
// we design inner sram in order to run simulation on modelsim
//
// NOTE : choose one of macro definitions followed behind
// `define EXT_SRAM , `define ON_CHIP_SRAM ,`define NO_SRAM
//
// `define EXT_SRAM
// `define ON_CHIP_SRAM
// `define NO_SRAM
 
// /* Flash */
// `define FLASH

// /* Ethernet */
// `define ETHERNET

// /* i2c master */
// `define I2C_MASTER

//  simple gpio 
// `define SIMPLE_GPIO

// /* simple_spi */
// `define SIMPLE_SPI

// /* i2s */
// `define I2S

// /* interrupt KEYs */
// `define IRQ_KEY
