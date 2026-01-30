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

begin architecture structural of alu is

    signal sum: std_logic_vector(width-1 downto 0);
    signal a_xor_b: std_logic_vector(width-1 downto 0);
    signal a_and_b: std_logic_vector(width-1 downto 0);
    signal carry_in: std_logic;
    signal neg_b: std_logic_vector(width-1 downto 0);

    a_and_b <= alu_inA AND alu_inB;
    a_xor_b <= alu_inA XOR alu_inB;
    neg_b <= NOT alu_inB;
    carry_in <= '1' when alu_op = "11" else '0';

    add: entity work.csa
        port map (
            A => alu_inA,
            B => alu_inB,
            O => sum,
            cin => carry_in
        );

    cmp: entity work.cmp
        port map (
            a => alu_inA,
            b => alu_inB,
            e => E
        );
    -- mux
    alu_out <= a_xor_b when alu_op = "00" else
                a_and_b when alu_op = "01" else
                sum when others;

    Z <= NOT OR_REDUCE(alu_out);


end structural;