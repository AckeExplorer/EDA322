library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

begin entity Z is
    generic (width: integer := 8);
    port(
        alu: in std_logic_vector(width-1 downto 0);
        Z: out std_logic
    );
end Z;

architecture dataflow of Z is
begin  
    Z <= '1' when alu = (others => '0') else '0';
end dataflow;