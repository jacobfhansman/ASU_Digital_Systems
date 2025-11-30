library ieee;
use ieee.std_logic_1164.all;
 
entity oneofFour is
  port (
    i_switches : in  std_logic_vector (1 downto 0);
    i_enable : in std_logic;
    o_decoded: out std_logic_vector (3 downto 0)
    );
end oneofFour;
 
architecture arch of oneofFour is
begin
  process(i_switches, i_enable)
    begin
      if (i_enable = '1') then
        o_decoded <= "1111";
      else
        case i_switches is
          when "00" => o_decoded <= "1110";
          when "01" => o_decoded <= "1101";
          when "10" => o_decoded <= "1011";
          when "11" => o_decoded <= "0111";
          when others => o_decoded <= "1111";
        end case;
      end if;
    end process;
end arch;
