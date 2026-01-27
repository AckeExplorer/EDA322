library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity rca is
    generic (width: integer := 4);
    port(
        A, B: in std_logic_vector(width-1 downto 0);
        cin: in std_logic;
        cout: out std_logic;
        O: out std_logic_vector(width-1 downto 0)
    );
end rca;

architecture structural of rca is:

component fa
    port(
        a, b: in std_logic;
        cin: in std_logic;
        cout: out std_logic;
        s: out std_logic
    );
end component

begin
    G1: for i in 0 to 7 generate
        adders: entity work.fa(dataflow) port map(
            cin => cin
            a => A(i)
            b => B(i)
            O(i) <= s
            cout <= cout
        );
    end generate
end structural