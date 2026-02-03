library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

begin entity a_and_b is
    generic (width: integer := 8);
    port(
        A, B: in std_logic_vector(width-1 downto 0);
        O: out std_logic_vector(width-1 downto 0)
    );
end a_and_b;

architecture dataflow of a_and_b is
begin
    O <= A AND B;
end dataflow;