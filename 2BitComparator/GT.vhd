library ieee;
use ieee.std_logic_1164.all;
 
entity GT is
  port (
    i_a0, i_a1, i_b0, i_b1    : in  std_logic;
    o_gt_result : out std_logic
    );
end GT;
 
architecture arch of GT is
  signal w_a : STD_LOGIC_VECTOR (1 downto 0);
  signal w_b : STD_LOGIC_VECTOR (1 downto 0);
begin
  w_a <= i_a1 & i_a0;
  w_b <= i_b1 & i_b0;
  process(w_a, w_b)
    begin
      if (w_a > w_b) then
        o_gt_result <= '1';
      else
        o_gt_result <= '0';
    end if;
  end process;
end arch;
