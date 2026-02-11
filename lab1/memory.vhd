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

    type MEMORY_ARRAY is array (ADDR_WIDTH - 1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);

    component reg
        generic(width: integer := 8);
        port (
            clk, rstn, en: in std_logic;
            d: in std_logic_vector(width-1 downto 0);
            q: out std_logic_vector(width-1 downto 0)
        );
    end component;

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
    
    signal mem : MEMORY_ARRAY;
    signal writeEn_reg: std_logic_vector(ADDR_WIDTH-1 downto 0);

begin
    mem <= init_memory_wfile(INIT_FILE);
    
    registry: for i in 0 to ADDR_WIDTH-1 generate
        writeEn_reg(i) <= writeEn when (to_integer(unsigned(address)) = i) else '0';
        regs: entity work.reg(behavioral)
            generic map(width => DATA_WIDTH)
            port map(
                clk => clk,
                rstn => '1',
                en => writeEn_reg(i),
                d => dataIn,
                q => mem(i)
            );
    end generate;
    dataOut <= mem(to_integer(unsigned(address))) when (readEn = '1' and rising_edge(clk));

end behavioral;
    
