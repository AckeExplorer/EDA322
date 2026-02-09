library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.ALL;

library work;
use work.chacc_pkg.all;

type MEMORY_ARRAY is array (ADDR_WIDTH - 1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);

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

    signal mem : MEMORY_ARRAY;
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


begin
    POC : process(clk)
        mem <= init_memory_wfile(INIT_FILE);
        reg : for i in 0 to ADDR_WIDTH-1 generate
            regs: entity.work.reg(behavioral)
                generic map(width => DATA_WIDTH)
                port map(
                    clk => clk,
                    rstn => '0',
                    en => writeEn,
                    d => dataIn,
                    q => mem(i)
                );
        end generate;

        dataOut <= mem(to_integer(unsigned(address))) when readEn = '1' and rise_edge(clk);
    end process;
end behavioral;
    
