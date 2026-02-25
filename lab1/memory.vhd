library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.ALL;

library work;
use work.chacc_pkg.all;

entity memory is
    generic (DATA_WIDTH : integer := 8;
             ADDR_WIDTH : integer := 8;
             INIT_FILE : string := "memory.mif");
     port (
        clk     : in std_logic;
        readEn  : in std_logic;
        writeEn : in std_logic;
        address : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        dataIn  : in std_logic_vector(DATA_WIDTH-1 downto 0);
        dataOut : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity;

architecture behavioral of memory is

    type MEMORY_ARRAY is array (0 to 2**ADDR_WIDTH - 1) of std_logic_vector(DATA_WIDTH-1 downto 0);

    impure function init_memory_wfile(mif_file_name : in string) return
        MEMORY_ARRAY is
            file mif_file : text open read_mode is mif_file_name;
            variable mif_line : line;
            variable temp_bv : bit_vector(DATA_WIDTH-1 downto 0);
            variable temp_mem : MEMORY_ARRAY;
        begin
            for i in MEMORY_ARRAY'range loop
            readline(mif_file, mif_line);
            read(mif_line, temp_bv);
            temp_mem(i) := to_stdlogicvector(temp_bv);
        end loop;
        return temp_mem;
    end function;
    
    signal mem : MEMORY_ARRAY := init_memory_wfile(INIT_FILE);
    signal writeEn_reg: std_logic_vector(ADDR_WIDTH-1 downto 0);

begin

    process(clk) begin
        if rising_edge(clk) then
            if writeEn = '1' then
                mem(to_integer(unsigned(address))) <= dataIn;
            end if;
            if readEn = '1' then
                dataOut <= mem(to_integer(unsigned(address)));
            end if;
        end if;
    end process;

        

end behavioral;
    
