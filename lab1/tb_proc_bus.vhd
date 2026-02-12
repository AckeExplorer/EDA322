library ieee;
use ieee.std_logic_1164.all;

library work;
use work.chacc_pkg.all;

entity tb_proc_bus is
end tb_proc_bus;

architecture tb_proc_bus_arch of tb_proc_bus is

    component proc_bus 
        port (
            busSel     : in std_logic_vector(3 downto 0);
            imDataOut  : in std_logic_vector(7 downto 0);
            dmDataOut  : in std_logic_vector(7 downto 0);
            accOut     : in std_logic_vector(7 downto 0);
            extIn      : in std_logic_vector(7 downto 0);
            busOut     : out std_logic_vector(7 downto 0)
        );
    end component;

    signal tb_busSel     : std_logic_vector(3 downto 0);
    signal tb_imDataOut  : std_logic_vector(7 downto 0);
    signal tb_dmDataOut  : std_logic_vector(7 downto 0);
    signal tb_accOut     : std_logic_vector(7 downto 0);
    signal tb_extIn      : std_logic_vector(7 downto 0);
    signal tb_busOut     : std_logic_vector(7 downto 0);

begin
    DUT: entity work.proc_bus(structural)
        port map (
            busSel => tb_busSel,
            imDataOut => tb_imDataOut,
            dmDataOut => tb_dmDataOut,
            accOut => tb_accOut,
            extIn => tb_extIn,
            busOut => tb_busOut
        );

    process begin

        -- Test case 1: busSel = "0000" (imDataOut)
        tb_busSel <= "0000";
        tb_imDataOut <= "10101010";
        tb_dmDataOut <= "01010101";
        tb_accOut <= "11001100";
        tb_extIn <= "00110011";
        wait for 10 ns;

        -- Test case 2: busSel = "0001" (dmDataOut)
        tb_busSel <= "0001";
        wait for 10 ns;

        tb_busSel <= "0010";
        wait for 10 ns; 

        tb_busSel <= "0100";
        wait for 10 ns;

        tb_busSel <= "1000";
        wait for 10 ns;
       
    end process;
end tb_proc_bus_arch;
