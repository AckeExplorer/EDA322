library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity tb_csa is
end entity tb_csa;

architecture tb_csa_arch of tb_csa is

    component csa
        port(
            A, B: in std_logic_vector(7 downto 0);
            cin: in std_logic;
            cout: out std_logic;
            O: out std_logic_vector(7 downto 0)
        );
    end component;

    signal tb_A : std_logic_vector(7 downto 0) := (others => '0');
    signal tb_B : std_logic_vector(7 downto 0) := (others => '0');
    signal tb_cin : std_logic := '0';
    signal tb_cout : std_logic;
    signal tb_O : std_logic_vector(7 downto 0);

begin

DUT: csa
    port map (
        A    => tb_A,
        B    => tb_B,
        cin  => tb_cin,
        cout => tb_cout,
        O    => tb_O
    );

process begin
    -- 0 + 0 + 0
    tb_A <= "00000000"; tb_B <= "00000000"; tb_cin <= '0'; wait for 10 ns;
    -- 15 + 10 + 0 = 25
    tb_A <= "00001111"; tb_B <= "00001010"; tb_cin <= '0'; wait for 10 ns;
    -- 15 + 1 = 16
    tb_A <= "00001111"; tb_B <= "00000000"; tb_cin <= '1'; wait for 10 ns;
    -- 100 + 28 + 0 = 128
    tb_A <= "01100100"; tb_B <= "00011100"; tb_cin <= '0'; wait for 10 ns;
    -- 255 + 1 + 0 = 256 (overflow, O = 0, cout = 1)
    tb_A <= "11111111"; tb_B <= "00000001"; tb_cin <= '0'; wait for 10 ns;
    -- 200 + 55 + 1 = 256 (overflow, O = 0, cout = 1)
    tb_A <= "11001000"; tb_B <= "00110111"; tb_cin <= '1'; wait for 10 ns;

    wait;
end process;
end architecture tb_csa_arch;
