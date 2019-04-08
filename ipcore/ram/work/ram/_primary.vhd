library verilog;
use verilog.vl_types.all;
entity ram is
    port(
        addr            : in     vl_logic_vector(12 downto 0);
        wr_data         : in     vl_logic_vector(31 downto 0);
        rd_data         : out    vl_logic_vector(31 downto 0);
        wr_en           : in     vl_logic;
        clk             : in     vl_logic;
        rst             : in     vl_logic
    );
end ram;
