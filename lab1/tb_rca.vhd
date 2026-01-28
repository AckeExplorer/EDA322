library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity tb_rca is
end entity tb_rca;

architecture tb_rca_arch of tb_rca is

    -- Component Declaration for the Unit Under Test (UUT)
    component rca
        generic (width: integer := 4);
        port(
            A, B: in std_logic_vector(width-1 downto 0);
            cin: in std_logic;
            cout: out std_logic;
            O: out std_logic_vector(width-1 downto 0)
        );
    end component;

    -- Signals to connect to Design Under Test (DUT)
    signal tb_A : std_logic_vector(3 downto 0) := (others => '0');
    signal tb_B : std_logic_vector(3 downto 0) := (others => '0');
    signal tb_cin : std_logic := '0';
    signal tb_cout : std_logic;
    signal tb_O : std_logic_vector(3 downto 0);

begin

    -- Instantiate the DUT. Assign signals to DUT inputs and outputs
    DUT: rca
        port map (
            A    => tb_A,
            B    => tb_B,
            cin  => tb_cin,
            cout => tb_cout,
            O    => tb_O
        );

    process begin
        -- Test: 0 + 0 + 0
        tb_A <= "0000"; tb_B <= "0000"; tb_cin <= '0'; wait for 10 ns;
        -- Test: 5 + 3 + 0 = 8
        tb_A <= "0101"; tb_B <= "0011"; tb_cin <= '0'; wait for 10 ns;
        -- Test: 7 + 7 + 0 = 14
        tb_A <= "0111"; tb_B <= "0111"; tb_cin <= '0'; wait for 10 ns;
        -- Test: 15 + 1 + 0 = 16 (overflow, O = 0, cout = 1)
        tb_A <= "1111"; tb_B <= "0001"; tb_cin <= '0'; wait for 10 ns;
        -- Test with carry in: 1 + 1 + 1 = 3
        tb_A <= "0001"; tb_B <= "0001"; tb_cin <= '1'; wait for 10 ns;

        wait;
     end process;
end architecture tb_rca_arch;