library verilog;
use verilog.vl_types.all;
entity ipml_spram_v1_0_ram is
    generic(
        c_ADDR_WIDTH    : integer := 10;
        c_DATA_WIDTH    : integer := 32;
        c_OUTPUT_REG    : integer := 0;
        c_RD_OCE_EN     : integer := 0;
        c_CLK_EN        : integer := 0;
        c_ADDR_STROBE_EN: integer := 0;
        c_RESET_TYPE    : string  := "ASYNC_RESET";
        c_POWER_OPT     : integer := 0;
        c_CLK_OR_POL_INV: integer := 0;
        c_INIT_FILE     : string  := "NONE";
        c_INIT_FORMAT   : string  := "BIN";
        c_WR_BYTE_EN    : integer := 0;
        c_BE_WIDTH      : integer := 8;
        c_RAM_MODE      : string  := "SINGLE_PORT";
        c_WRITE_MODE    : string  := "NORMAL_WRITE"
    );
    port(
        addr            : in     vl_logic_vector;
        wr_data         : in     vl_logic_vector;
        rd_data         : out    vl_logic_vector;
        wr_en           : in     vl_logic;
        clk             : in     vl_logic;
        clk_en          : in     vl_logic;
        addr_strobe     : in     vl_logic;
        rst             : in     vl_logic;
        wr_byte_en      : in     vl_logic_vector;
        rd_oce          : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of c_ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of c_DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of c_OUTPUT_REG : constant is 1;
    attribute mti_svvh_generic_type of c_RD_OCE_EN : constant is 1;
    attribute mti_svvh_generic_type of c_CLK_EN : constant is 1;
    attribute mti_svvh_generic_type of c_ADDR_STROBE_EN : constant is 1;
    attribute mti_svvh_generic_type of c_RESET_TYPE : constant is 1;
    attribute mti_svvh_generic_type of c_POWER_OPT : constant is 1;
    attribute mti_svvh_generic_type of c_CLK_OR_POL_INV : constant is 1;
    attribute mti_svvh_generic_type of c_INIT_FILE : constant is 1;
    attribute mti_svvh_generic_type of c_INIT_FORMAT : constant is 1;
    attribute mti_svvh_generic_type of c_WR_BYTE_EN : constant is 1;
    attribute mti_svvh_generic_type of c_BE_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of c_RAM_MODE : constant is 1;
    attribute mti_svvh_generic_type of c_WRITE_MODE : constant is 1;
end ipml_spram_v1_0_ram;
