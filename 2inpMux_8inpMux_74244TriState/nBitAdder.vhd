library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity nBitAdder is
  generic(N: integer:=4);
  port(
    i_a, i_b  : in std_logic_vector(N-1 downto 0);
    o_cout    : out std_logic;
    o_sum     : out std_logic_vector(N-1 downto 0)
  );
end nBitAdder;

architecture arch of nBitAdder is
  signal w_a, w_b, w_sum: unsigned(N downto 0);
  begin
    w_a <= unsigned('0' & i_a);
    w_b <= unsigned('0' & i_b);
    w_sum <= w_a + w_b;
    o_sum <= std_logic_vector(w_sum(N-1 downto 0));
    o_cout <= w_sum(N);
end arch;