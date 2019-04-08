library verilog;
use verilog.vl_types.all;
entity ram_tb is
    generic(
        T_CLK_PERIOD    : integer := 10;
        T_RST_TIME      : integer := 200
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of T_CLK_PERIOD : constant is 1;
    attribute mti_svvh_generic_type of T_RST_TIME : constant is 1;
end ram_tb;
