library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

library work;
use work.chacc_pkg.all;

begin entity mux_4_1 is
    generic (d_width: integer := 8);
    port (
        s : in std_logic_vector(1 downto 0);
        i0 : in std_logic_vector(d_width-1 downto 0);
        i1 : in std_logic_vector(d_width-1 downto 0);
        i2 : in std_logic_vector(d_width-1 downto 0);
        i3 : in std_logic_vector(d_width-1 downto 0);
        o : out std_logic_vector(d_width-1 downto 0)
    );
end mux_4_1;

architecture dataflow of mux_4_1 is
