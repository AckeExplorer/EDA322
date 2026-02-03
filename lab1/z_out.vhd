library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity z_out is
    generic (width: integer := 8);
    port(
        alu: in std_logic_vector(width-1 downto 0);
        z: out std_logic
    );
end z_out;

architecture dataflow of z_out is
    signal all_zeros: std_logic;
begin  
    z <= '1' when or_reduce(alu) = '0' else '0';
end dataflow;