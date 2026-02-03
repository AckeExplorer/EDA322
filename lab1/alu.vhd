library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

library work;
use work.chacc_pkg.all;

entity alu is
    generic (width: integer := 8);
    port(
        alu_inA, alu_inB: in std_logic_vector(width-1 downto 0);
        alu_op: in std_logic_vector(1 downto 0);
        E,Z: out std_logic;
        alu_out: out std_logic_vector(width-1 downto 0)
    );
end alu;

architecture structural of alu is

    signal sum: std_logic_vector(width-1 downto 0);
    signal a_xor_b: std_logic_vector(width-1 downto 0);
    signal a_and_b: std_logic_vector(width-1 downto 0);
    signal carry_in: std_logic;
    signal inB: std_logic_vector(width-1 downto 0);
    signal outout: std_logic_vector(width-1 downto 0);

begin
    axorb: entity work.a_xor_b(dataflow)
        port map (
            A => alu_inA,
            B => alu_inB,
            O => a_xor_b
        );

    aandb: entity work.a_and_b(dataflow)
        port map (
            A => alu_inA,
            B => alu_inB,
            O => a_and_b
        );
        
    bsub: entity work.b_sub(dataflow)
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
            O => sum,
            cin => carry_in
        );

    cmp: entity work.cmp(dataflow)
        port map (
            a => alu_inA,
            b => alu_inB,
            e => E
        );
    -- mux
    mux_inst: entity work.mux_4_1(dataflow)
        generic map (d_width => width)
        port map (
            s => alu_op,
            i0 => a_xor_b,
            i1 => a_and_b,
            i2 => sum,
            i3 => sum,
            O => alu_out
        );

    Z_inst: entity work.z(dataflow)
        port map (
            alu => alu_out,
            Z => Z
        );

end structural;