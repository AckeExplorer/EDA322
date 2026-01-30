
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity csa is
    port(
        A, B: in std_logic_vector(7 downto 0);
        cin: in std_logic;
        cout: out std_logic;
        O: out std_logic_vector(7 downto 0)
    );
end csa;

architecture structural of csa is
component rca
    generic (width: integer := 4);
    port(
        A, B: in std_logic_vector(width-1 downto 0);
        cin: in std_logic;
        cout: out std_logic;
        O: out std_logic_vector(width-1 downto 0)
    );
end component;

component mux
    port (
        s : in std_logic;
        i0 : in std_logic_vector(7 downto 0);
        i1 : in std_logic_vector(7 downto 0);
        o : out std_logic_vector(7 downto 0)
    );
end component;

signal c4: std_logic;
signal c0: std_logic;
signal c1: std_logic;

signal O0: std_logic_vector(3 downto 0);
signal O1: std_logic_vector(3 downto 0);

begin

L: entity work.rca(structural)
    port map(
        A => A(3 downto 0),
        B => B(3 downto 0),
        cin => cin,
        cout => c4,
        O => O(3 downto 0)
    );

U1: entity work.rca(structural)
    port map(
        A => A(7 downto 4),
        B => B(7 downto 4),
        cin => '0',
        cout => c0,
        O => O0
    );

U2: entity work.rca(structural)
    port map(
        A => A(7 downto 4),
        B => B(7 downto 4),
        cin => '1',
        cout => c1,
        O => O1
    );

M1: entity work.mux(dataflow)
    generic map(d_width => 4)
    port map(
        s => c4,
        i0 => O0,
        i1 => O1,
        o => O(7 downto 4)
    );

M2: entity work.mux(dataflow)
    generic map(d_width => 1)
    port map(
        s => c4,
        i0(0) => c0,
        i1(0) => c1,
        o(0) => cout
    );

end architecture structural; 




