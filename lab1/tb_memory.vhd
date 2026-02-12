library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.ALL;

library work;
use work.chacc_pkg.all;

entity tb_memory is
    generic (DATA_WIDTH : integer := 8;
            ADDR_WIDTH : integer := 8;
            INIT_FILE : string := "d_memory_lab2.mif");
end entity;

architecture tb_memory_arch of tb_memory is

    component memory
        generic (DATA_WIDTH : integer := 8;
                 ADDR_WIDTH : integer := 8;
                 INIT_FILE : string := "d_memory_lab2.mif");
         port (
            clk     : in std_logic;
            readEn  : in std_logic;
            writeEn : in std_logic;
            address : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            dataIn  : in std_logic_vector(DATA_WIDTH-1 downto 0);
            dataOut : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
    signal tb_clk : std_logic := '0';
    signal tb_readEn : std_logic := '0';
    signal tb_writeEn : std_logic := '0';
    signal tb_address : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal tb_dataIn : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal tb_dataOut : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    DUT: entity work.memory(behavioral)
            generic map(
                DATA_WIDTH => 8,
                ADDR_WIDTH => 8,
                INIT_FILE => "d_memory_lab2.mif"
            )
            port map (
                clk => tb_clk,
                readEn => tb_readEn,
                writeEn => tb_writeEn,
                address => tb_address,
                dataIn => tb_dataIn,
                dataOut => tb_dataOut
            );

    clk_process : process
    begin
        wait for 25 ns;
        tb_clk <= not tb_clk;
    end process;

    
    process
    begin
        tb_address <= "00000000"; tb_readEn <= '1'; wait for 50 ns;
        tb_readEn <= '0'; tb_dataIn <= "11110000"; wait for 50 ns;
        tb_writeEn <= '1'; wait for 50 ns;
        tb_writeEn <= '0'; wait for 50 ns;
        tb_readEn <= '1'; wait for 50 ns;
        tb_readEn <= '0'; tb_address <= "00000001";  wait for 50 ns;
        tb_readEn <= '1'; wait for 50 ns;
        tb_readEn <= '0'; wait for 50 ns;
        tb_dataIn <= "10101010"; tb_writeEn <= '1'; wait for 50 ns;
        tb_writeEn <= '0'; wait for 50 ns;
        tb_readEn <= '1'; wait for 50 ns;

        -- Finish simulation
        wait;
    end process;

end architecture;