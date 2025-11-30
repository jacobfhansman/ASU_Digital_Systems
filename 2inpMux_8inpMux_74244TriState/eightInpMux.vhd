library ieee;
use ieee.std_logic_1164.all;
 
entity eightInpMux is
  port (
    i_D                     : in  std_logic_vector(7 downto 0);
    i_C, i_B, i_A, i_strobe : in std_logic;
    o_out                   : out std_logic
    );
end eightInpMux;
 
architecture arch of eightInpMux is
  signal w_inps : std_logic_vector(7 downto 0);
  signal w_sel  : std_logic_vector(2 downto 0);
  signal w_EN   : std_logic;
begin
  w_inps <= i_D;
  w_sel <= i_A & i_B & i_C;
  w_EN <= i_strobe;
  process(w_inps, w_sel, w_EN)
    begin
      if (w_EN = '1') then
        o_out <= '0';
      else 
        case w_sel is
          when "000" => o_out <= w_inps(0);
          when "001" => o_out <= w_inps(1);
          when "010" => o_out <= w_inps(2);
          when "011" => o_out <= w_inps(3);
          when "100" => o_out <= w_inps(4);
          when "101" => o_out <= w_inps(5);
          when "110" => o_out <= w_inps(6);
          when "111" => o_out <= w_inps(7);
          when others => o_out <= '0';
        end case;
      end if;
    end process;
end arch;