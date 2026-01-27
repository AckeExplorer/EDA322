library ieee;
use ieee.std_logic_1164.all;

entity fa is
    port(
        a, b: in std_logic;
        cin: in std_logic;
        cout: out std_logic;
        s: out std_logic
    );
end fa;

architecture dataflow of fa is:

signal a_xor_b: std_logic;

begin
    a_xor_b <= a XOR b;
    s <= cin XOR a_xor_b;
    cout <= (cin AND a_xor_b) OR (a AND b);
end