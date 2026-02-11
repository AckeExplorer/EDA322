library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity tb_reg is
    generic(width: integer := 10);
end entity tb_reg;

architecture tb_reg_arch of tb_reg is

    component reg
        generic(width: integer := 10);
        port (
            clk, rstn, en: in std_logic;
            d: in std_logic_vector(width-1 downto 0);
            q: out std_logic_vector(width-1 downto 0)
        );
    end component;

    signal tb_clk : std_logic := '0';
    signal tb_rstn : std_logic := '0';
    signal tb_en : std_logic := '0';
    signal tb_d : std_logic_vector(width-1 downto 0) := (others => '0');
    signal tb_q : std_logic_vector(width-1 downto 0);

begin

    DUT: entity work.reg(behavioral)
            generic map(width => 10)
            port map (
                clk => tb_clk,
                rstn => tb_rstn,
                en => tb_en,
                d => tb_d,
                q => tb_q
            );

    clk_process : process
    begin
        wait for 25 ns;
        tb_clk <= not tb_clk;
    end process;

    
    process
    begin
        
        tb_rstn <= '0'; wait for 50 ns; 
        tb_rstn <= '1'; wait for 50 ns;

        tb_en <= '1'; tb_d <= "0010101010"; wait for 50 ns;
       
        tb_en <= '0'; tb_d <= "0001010101"; wait for 50 ns;

        tb_rstn <= '0'; wait for 50 ns;

        tb_en <= '1'; wait for 50 ns;

        tb_rstn <= '0'; wait for 50 ns;

        tb_en <= '0'; wait for 50 ns;

        tb_rstn <= '1'; wait for 50 ns;

        tb_en <= '1'; wait for 50 ns;

        tb_d <= "0011110000"; wait for 50 ns;
        tb_d <= "0000001111"; wait for 50 ns;

        tb_en <= '0'; tb_d <= (others => '0'); wait for 50 ns;

        tb_rstn <= '0'; wait for 50 ns;
        tb_rstn <= '1'; wait for 50 ns;

        tb_en <= '1'; wait for 50 ns;

        wait;
    end process;

end architecture tb_reg_arch;