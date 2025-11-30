library ieee;
use ieee.std_logic_1164.all;
 
entity twoInpMux is
  port (
    i_A, i_B, i_sel    : in  std_logic;
    o_out              : out std_logic
    );
end twoInpMux;
 
architecture arch of twoInpMux is
begin
  with i_sel select
    o_out <= i_A when '0',
             i_B when '1',
             '0' when others;      
end arch;