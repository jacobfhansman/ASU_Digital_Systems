library ieee;
use ieee.std_logic_1164.all;
 
entity sevSeg is
  port (
    i_switches: in  std_logic_vector (3 downto 0);
    o_sevSegOut: out std_logic_vector (7 downto 0)
    );
end sevSeg;
 
architecture arch of sevSeg is
  signal w_swStatus : std_logic_vector (3 downto 0);
  --signal w_sevSegBits : std_logic_vector (7 downto 0);
begin
  w_swStatus <= i_switches(3) & i_switches(2) & i_switches(1) & i_switches(0);
  with w_swStatus select
    o_sevSegOut <= "00000011" when "0000",
                   "10011111" when "0001",
                   "00100101" when "0010",
                   "00001101" when "0011",
                   "10011001" when "0100",
                   "01001001" when "0101",
                   "01000001" when "0110",
                   "00011111" when "0111",
                   "00000001" when "1000",
                   "00001001" when "1001",
                   "00010001" when "1010",
                   "11000001" when "1011",
                   "01100011" when "1100",
                   "10000101" when "1101",
                   "01100001" when "1110",
                   "01110001" when "1111",
                   "11111111" when others;
    
end arch;
