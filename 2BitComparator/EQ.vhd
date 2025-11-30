library ieee;
use ieee.std_logic_1164.all;
 
entity EQ is
  port (
    i_a0, i_a1, i_b0, i_b1    : in  std_logic;
    o_eq_result : out std_logic
    );
end EQ;
 
architecture arch of EQ is
signal w_status : STD_LOGIC_VECTOR (3 downto 0);
begin
  w_status <= i_a1 & i_a0 & i_b1 & i_b0;
process(w_status)
  begin
    case w_status is
    when "0000" => o_eq_result <= '1';
    when "0101" => o_eq_result <= '1';
    when "1010" => o_eq_result <= '1';
    when "1111" => o_eq_result <= '1';
    when others => o_eq_result <= '0';
    end case;
  end process;
end arch;
