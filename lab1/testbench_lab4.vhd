library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_misc.all;

entity processor_tb is
end processor_tb;

architecture tb_processor_arch of processor_tb is

    signal clk, g_clk : std_logic;
    signal resetn, g_resetn : std_logic;
    signal master_load_enable, g_master_load_enable : std_logic;
    signal extIn, g_extIn : std_logic_vector(7 downto 0);
    signal inValid, g_inValid : std_logic;
    signal outReady, g_outReady : std_logic;
    signal pc2seg, g_pc2seg : std_logic_vector(7 downto 0);
    signal imDataOut2seg, g_imDataOut2seg : std_logic_vector(11 downto 0);
    signal dmDataOut2seg, g_dmDataOut2seg : std_logic_vector(7 downto 0);
    signal aluOut2seg, g_aluOut2seg : std_logic_vector(7 downto 0);
    signal acc2seg, g_acc2seg : std_logic_vector(7 downto 0);
    signal busOut2seg, g_busOut2seg : std_logic_vector(7 downto 0);
    signal extOut, g_extOut : std_logic_vector(7 downto 0);
    signal inReady, g_inReady : std_logic;
    signal outValid, g_outValid : std_logic;

begin
    golden: entity work.reference_processor(behavioral)
            port map (
                clk => g_clk,
                resetn => g_resetn,
                master_load_enable => g_master_load_enable,
                extIn => g_extIn,
                inValid => g_inValid,
                outReady => g_outReady,
                pc2seg => g_pc2seg,
                imDataOut2seg => g_imDataOut2seg,
                dmDataOut2seg => g_dmDataOut2seg,
                aluOut2seg => g_aluOut2seg,
                acc2seg => g_acc2seg,
                busOut2seg => g_busOut2seg,
                extOut => g_extOut,
                inReady => g_inReady,
                outValid => g_outValid
            );

    real: entity work.EDA322_processor(behavioral)
            port map (
                clk => clk,
                resetn => resetn,
                master_load_enable => master_load_enable,
                extIn => extIn,
                inValid => inValid,
                outReady => outReady,
                pc2seg => pc2seg,
                imDataOut2seg => imDataOut2seg,
                dmDataOut2seg => dmDataOut2seg,
                aluOut2seg => aluOut2seg,
                acc2seg => acc2seg,
                busOut2seg => busOut2seg,
                extOut => extOut,
                inReady => inReady,
                outValid => outValid              
            );

    clk_process : process
    begin
        wait for 25 ns;
        tb_clk <= not tb_clk;
    end process;

    
    process
    begin
        
        
    end process;

end architecture tb_processor_arch;