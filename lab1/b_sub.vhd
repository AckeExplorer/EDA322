library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

begin entity b_sub is
    generic (width: integer := 8);
    port(
        B: in std_logic_vector(width-1 downto 0);
        s: in std_logic_vector(1 downto 0);
        O: out std_logic_vector(width-1 downto 0);
        c: out std_logic
    );
end b_sub;

architecture dataflow of b_sub is
begin
    O <= NOT B when ((s = "10") OR (s = "11")) else B;
    c <= '1' when ((s = "10") OR (s = "11")) else '0';
end dataflow;