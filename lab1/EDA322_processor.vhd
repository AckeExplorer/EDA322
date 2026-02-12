library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity EDA322_processor is
    generic (dInitFile : string := "d_memory_lab2.mif";
             iInitFile : string := "i_memory_lab2.mif");
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
end EDA322_processor;

architecture structural of EDA322_processor is

    signal pc_out, next_pc, pc_incr_out, pc_jump_addr : std_logic_vector(7 downto 0);
    signal imDataOut : std_logic_vector(11 downto 0);
    signal dmDataOut : std_logic_vector(7 downto 0);
    signal aluOut : std_logic_vector(7 downto 0);
    signal aluOp : std_logic_vector(1 downto 0);
    signal acc, acc_in : std_logic_vector(7 downto 0);
    signal busOut : std_logic_vector(7 downto 0);
    signal extOut : std_logic_vector(7 downto 0);
    signal inReady, outValid, acc_sel, accLd, pcLd : std_logic;
    signal busSel : std_logic_vector(3 downto 0);
    signal pc_b_in : std_logic_vector(7 downto 0);
    signal pc_sel, imRead, dmRead, dmWrite, e_flag, z_flag, e_flag_out, z_flag_out : std_logic;
    signal bus_sel: std_logic_vector(3 downto 0);

begin
    pc_b_in <= not ('0' & busOut(6 downto 0)) when busOut(7) else '0' & busOut(6 downto 0);

    pc_inc: entity work.csa(structural)
        port map(A => pc_out,
        B => (others => '0'),
        cin => '1',
        O => pc_incr_out);
    pc_jump_address: entity work.csa(structural)
        port map(A => pc,
        B => '0' & busOut(6 downto 0),
        cin => '1',
        O => pc_jump_addr);

    pc_next <= pc_jump_addr when pc_sel = '1' else pc_incr_out;
    pc2seg <= pc_out;

    alu: entity work.alu(structural)
        port map(a => acc,
        b => busOut,
        alu_op =>  aluOp,
        alu_out => aluOut,
        E => e_flag,
        Z => z_flag);

    e_reg: entity work.reg(behavioral)
        generic map(width => 1)
        port map(clk => clk,
        rstn => resetn,
        en => flagLd,
        d => e_flag,
        q => e_flag_out);
    z_reg: entity work.reg(behavioral)
        generic map(width => 1)
        port map(clk => clk,
        rstn => resetn,
        en => flagLd,
        d => z_flag,
        q => z_flag_out);

    acc_in <= aluOut when acc_sel = '0' else busOut;

    acc_reg: entity work.reg(behavioral)
        generic map(width => 8)
        port map(clk => clk,
        rstn => resetn,
        en => accLd,
        d => busOut,
        q => acc);
    extOut <= acc;
    acc2seg <= acc;

    pc_reg: entity work.reg(behavioral)
        generic map(width => 8)
        port map(clk => clk,
        rstn => resetn,
        en => pcLd,
        d => next_pc,
        q => pc_out);
    
    imem: entity work.memory(behavioral)
        generic map(DATA_WIDTH => 12,
        ADDR_WIDTH => 8,
        INIT_FILE => iInitFile)
        port map(clk => clk,
        readEn => imRead,
        writeEn => '0',
        address => pc_out,
        dataIn => (others => '0'),
        dataOut => imDataOut);
    imDataOut2seg <= imDataOut;
    
    dmem: entity work.memory(behavioral)
        generic map(DATA_WIDTH => 8,
        ADDR_WIDTH => 8,
        INIT_FILE => dInitFile)
        port map(clk => clk,
        readEn => dmRead,
        writeEn => dmWrite,
        address => busOut,
        dataIn => acc,
        dataOut => dmDataOut);
    
    proc_bus: entity work.proc_bus(structural)
        port map(busSel => bus_sel,
        imDataOut => imDataOut(7 downto 0),
        dmDataOut => dmDataOut,
        acc => acc,
        extIn => extIn,
        busOut => busOut);