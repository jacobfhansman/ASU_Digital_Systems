library ieee;
use ieee.std_logic_1164.all;
 
entity NANDlatch is
  port (
    i_S, i_R                : in  std_logic;
    o_Q                     : buffer std_logic;
    o_Qbar                  : buffer std_logic
    );
end NANDlatch;
 
architecture arch of NANDlatch is
begin
  o_Q <= (i_S) nand (o_Qbar);
  o_Qbar <= (i_R) nand (o_Q);
end arch;