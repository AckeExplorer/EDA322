library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

library work;
use work.chacc_pkg.all;

entity alu is
    generic (width: integer := 8);
    port (
        alu_inA, alu_inB: in std_logic_vector(width-1 downto 0);
        alu_op: in std_logic_vector(1 downto 0);
        E, Z: out std_logic;
        alu_out: out std_logic_vector(width-1 downto 0)
    );
end alu;

architecture structural of alu is

component a_xor_b
    generic (width: integer := 8);
    port (
        A, B: in std_logic_vector(width-1 downto 0);
        O: out std_logic_vector(width-1 downto 0)
    );
end component;

component a_and_b
    generic (width: integer := 8);
    port (
        A, B: in std_logic_vector(width-1 downto 0);
        O: out std_logic_vector(width-1 downto 0)
    );  
end component;

component b_sub
    generic (width: integer := 8);
    port (
        B: in std_logic_vector(width-1 downto 0);
        s: in std_logic_vector(1 downto 0);
        O: out std_logic_vector(width-1 downto 0);
        c: out std_logic
    );
end component;

component csa 
    port (
        A, B: in std_logic_vector(width-1 downto 0);
        cin: in std_logic;
        cout: out std_logic;
        O: out std_logic_vector(width-1 downto 0)
    );
end component;

component cmp
    port (
        a, b: in std_logic_vector(width-1 downto 0);
        e: out std_logic
    );
end component;

component mux_4_1
    generic (d_width: integer := 8;
             s_width: integer := 2);
    port (
        s: in std_logic_vector(1 downto 0);
        i0, i1, i2, i3: in std_logic_vector(width-1 downto 0);
        O: out std_logic_vector(width-1 downto 0)
    );
end component;

component z_out
    port (
        alu: in std_logic_vector(width-1 downto 0);
        z: out std_logic
    );
end component;

    signal sum: std_logic_vector(width-1 downto 0);
    signal aXb: std_logic_vector(width-1 downto 0);
    signal aAb: std_logic_vector(width-1 downto 0);
    signal carry_in: std_logic;
    signal carry_out: std_logic;
    signal inB: std_logic_vector(width-1 downto 0);
    signal almostout: std_logic_vector(width-1 downto 0);

begin
    axorb: entity work.a_xor_b(dataflow)
        generic map(width => width)
        port map (
            A => alu_inA,
            B => alu_inB,
            O => aXb
        );

    aandb: entity work.a_and_b(dataflow)
        generic map(width => width)
        port map (
            A => alu_inA,
            B => alu_inB,
            O => aAb
        );
        
    bsub: entity work.b_sub(dataflow)
        generic map(width => width)
        port map (
            B => alu_inB,
            s => alu_op,
            O => inB,
            c => carry_in
        );    

    add: entity work.csa(structural)
        port map (
            A => alu_inA,
            B => inB,
            cin => carry_in,
            cout => carry_out,
            O => sum
        );

    compare: entity work.cmp(dataflow)
        port map (
            a => alu_inA,
            b => alu_inB,
            e => E
        );
    -- mux
    mux_inst: entity work.mux_4_1(dataflow)
        generic map(d_width => width,
                    s_width => 2)
        port map (
            s => alu_op,
            i0 => aXb,
            i1 => aAb,
            i2 => sum,
            i3 => sum,
            O => almostout
        );

    Z_inst: entity work.z_out(dataflow)
        generic map(width => width) 
        port map (
            alu => almostout,
            z => Z
        );

    alu_out <= almostout;
end structural;