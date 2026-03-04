library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_misc.all;

entity processor_tb is
end processor_tb;

architecture tb_processor_arch of processor_tb is

    component reference_processor
        port(
            clk                : in  std_logic;
            resetn             : in  std_logic;
            master_load_enable : in  std_logic;
            extIn              : in  std_logic_vector(7 downto 0);
            inValid            : in  std_logic;
            outReady           : in  std_logic;
            pc2seg             : out std_logic_vector(7 downto 0);
            imDataOut2seg      : out std_logic_vector(11 downto 0);
            dmDataOut2seg      : out std_logic_vector(7 downto 0);
            aluOut2seg         : out STD_LOGIC_VECTOR(7 downto 0);
            acc2seg            : out std_logic_vector(7 downto 0);
            busOut2seg         : out std_logic_vector(7 downto 0);
            extOut             : out std_logic_vector(7 downto 0);
            inReady            : out std_logic;
            outValid           : out std_logic
        );
    end component;

    component EDA322_processor
        port(
            clk                : in  std_logic;
            resetn             : in  std_logic;
            master_load_enable : in  std_logic;
            extIn              : in  std_logic_vector(7 downto 0);
            inValid            : in  std_logic;
            outReady           : in  std_logic;
            pc2seg             : out std_logic_vector(7 downto 0);
            imDataOut2seg      : out std_logic_vector(11 downto 0);
            dmDataOut2seg      : out std_logic_vector(7 downto 0);
            aluOut2seg         : out STD_LOGIC_VECTOR(7 downto 0);
            acc2seg            : out std_logic_vector(7 downto 0);
            busOut2seg         : out std_logic_vector(7 downto 0);
            extOut             : out std_logic_vector(7 downto 0);
            inReady            : out std_logic;
            outValid           : out std_logic
        );
    end component;

    signal tb_clk : std_logic := '0';
    signal tb_resetn : std_logic := '0';
    signal tb_master_load_enable : std_logic := '0';
    signal tb_extIn : std_logic_vector(7 downto 0):= (others => '0');
    signal tb_inValid : std_logic := '0';
    signal tb_outReady : std_logic := '0';
    signal pc2seg, g_pc2seg : std_logic_vector(7 downto 0);
    signal imDataOut2seg, g_imDataOut2seg : std_logic_vector(11 downto 0);
    signal dmDataOut2seg, g_dmDataOut2seg : std_logic_vector(7 downto 0);
    signal aluOut2seg, g_aluOut2seg : std_logic_vector(7 downto 0);
    signal acc2seg, g_acc2seg : std_logic_vector(7 downto 0);
    signal busOut2seg, g_busOut2seg : std_logic_vector(7 downto 0);
    signal extOut, g_extOut : std_logic_vector(7 downto 0);
    signal inReady, g_inReady : std_logic;
    signal outValid, g_outValid : std_logic;
    signal last2ExtOut : std_logic_vector(15 downto 0);

begin
    golden: entity work.reference_processor
            port map (
                clk => tb_clk,
                resetn => tb_resetn,
                master_load_enable => tb_master_load_enable,
                extIn => tb_extIn,
                inValid => tb_inValid,
                outReady => tb_outReady,
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

    real: entity work.EDA322_processor(structural)
            port map (
                clk => tb_clk,
                resetn => tb_resetn,
                master_load_enable => tb_master_load_enable,
                extIn => tb_extIn,
                inValid => tb_inValid,
                outReady => tb_outReady,
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

    reset_process : process
    begin
        wait for 50 ns;
        tb_resetn <= '1';
        wait;
    end process;
    
    clk_process : process
    begin
        wait for 25 ns;
        if last2ExtOut /= x"DEAD" then
            tb_clk <= not tb_clk;
        end if;
    end process;

    master_load_enable_process : process
    begin
        wait for 50 ns;
        tb_master_load_enable <= '1';
        tb_inValid <= '1';
        tb_outReady <= '1';
        wait for 250 ns;
        tb_inValid <= '0';
        tb_master_load_enable <= '0';
        tb_outReady <= '0';
    end process;

    extIn_process : process(tb_clk)
    begin
        if rising_edge(tb_clk) then
            if tb_master_load_enable = '1' then
                if tb_inValid = '1' then
                    if inReady = '1' then
                        tb_extIn <= std_logic_vector(unsigned(tb_extIn) + 1);
                    end if;
                end if;
            end if;
        end if;
    end process;

    stimulus_process : process
    begin
        loop
            wait until rising_edge(tb_clk);
            wait for 10 ns; -- wait for outputs to stabilize
            assert (g_pc2seg ?= pc2seg) report "PC mismatch" severity error;
            assert (g_imDataOut2seg = imDataOut2seg) report "Instruction Memory Data mismatch" severity error;
            assert (g_dmDataOut2seg = dmDataOut2seg) report "Data Memory Data mismatch" severity error;
            assert (g_aluOut2seg ?= aluOut2seg) report "ALU Output mismatch" severity error;
            assert (g_acc2seg ?= acc2seg) report "Accumulator mismatch" severity error;
            assert (g_busOut2seg ?= busOut2seg) report "Bus Output mismatch" severity error;
            assert (g_extOut ?= extOut) report "External Output mismatch" severity error;
            assert (g_inReady ?= inReady) report "inReady signal mismatch" severity error;
            assert (g_outValid ?= outValid) report "outValid signal mismatch" severity error;
            assert (last2ExtOut /= x"DEAD") report "Testbench completed successfully!" severity note;
        end loop;
    end process;

    end_process: process(tb_clk)
    begin
        if rising_edge(tb_clk) then
            if tb_master_load_enable = '1' then
                if outValid = '1' then
                    if tb_outReady = '1' then
                        last2ExtOut <= last2ExtOut(7 downto 0) & extOut;
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture tb_processor_arch;