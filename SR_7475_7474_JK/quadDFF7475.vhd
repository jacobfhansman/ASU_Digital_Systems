library ieee;
use ieee.std_logic_1164.all;
 
entity quadDFF7475 is
  port (
    i_D1                    : in  std_logic_vector(1 downto 0);
    i_D2                    : in std_logic_vector(1 downto 0);
    i_EN1, i_EN2            : in std_logic;
    o_Q1                    : buffer std_logic_vector(1 downto 0);
    o_Q1bar                 : buffer std_logic_vector(1 downto 0);
    o_Q2                    : buffer std_logic_vector(1 downto 0);
    o_Q2bar                 : buffer std_logic_vector(1 downto 0)
    );
end quadDFF7475;
 
architecture arch of quadDFF7475 is
begin
  
  process(i_D1, i_EN1, o_Q1, o_Q1bar)
    begin
      if (i_EN1 = '0') then
        o_Q1 <= o_Q1;
        o_Q1bar <= o_Q1bar;
      else 
        o_Q1 <= i_D1;
        o_Q1bar <= not i_D1;
      end if;
    end process;
    
  process
    begin
      if (i_EN2 = '0') then
        o_Q2 <= o_Q2;
        o_Q2bar <= o_Q2bar;
      else
        o_Q2 <= i_D2;
        o_Q2bar <= not i_D2;
      end if;
    end process; 
       
end arch;