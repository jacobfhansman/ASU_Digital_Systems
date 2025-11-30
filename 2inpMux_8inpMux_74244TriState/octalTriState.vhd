library ieee;
use ieee.std_logic_1164.all;
 
entity octalTriState is
  port (
    i_GA, i_GB     : in  std_logic;
    i_inpA, i_inpB : in std_logic_vector(3 downto 0);
    o_YA, o_YB     : out std_logic_vector(3 downto 0)
    );
end octalTriState;
 
architecture arch of octalTriState is
  signal w_ENA, w_ENB     : std_logic;
  signal w_Ainps, w_Binps : std_logic_vector(3 downto 0);
  begin
    w_ENA <= i_GA;
    w_ENB <= i_GB;
    w_Ainps <= i_inpA;
    w_Binps <= i_inpB;
    process(w_ENA, w_ENB, w_Ainps, w_Binps)
      begin
          if (w_ENA = '0') then
            o_YA <= w_Ainps;
          else
            o_YA <= (others => 'Z');
          end if;
          if (w_ENB = '0') then
            o_YB <= w_Binps;
          else
            o_YB <= (others => 'Z');
          end if;
      end process;
end arch;