library ieee;
use ieee.std_logic_1164.all;
 
entity LT is
  port (
    i_a0, i_a1, i_b0, i_b1    : in  std_logic;
    o_lt_result : out std_logic
    );
end LT;
 
architecture arch of LT is
  signal w_status : STD_LOGIC_VECTOR (3 downto 0);
begin
  w_status <= i_a1 & i_a0 & i_b1 & i_b0;
  with w_status select
    o_lt_result <= '0' when "0000",
                   '1' when "0001",
                   '1' when "0010",
                   '1' when "0011",
                   '0' when "0100",
                   '0' when "0101",
                   '1' when "0110",
                   '1' when "0111",
                   '0' when "1000",
                   '0' when "1001",
                   '0' when "1010",
                   '1' when "1011",
                   '0' when "1100",
                   '0' when "1101",
                   '0' when "1110",
                   '0' when "1111",
                   '0' when others;
end arch;

