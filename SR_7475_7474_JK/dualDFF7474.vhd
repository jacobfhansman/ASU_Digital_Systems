library ieee;
use ieee.std_logic_1164.all;
 
entity dualDFF7474 is
  port (
    i_D                     : in  std_logic_vector(1 downto 0);
    i_pre1, i_clr1          : in std_logic;     
    i_pre2, i_clr2          : in std_logic;
    i_clk                   : in std_logic;
    o_Q                     : out std_logic_vector(1 downto 0);
    o_Qbar                  : out std_logic_vector(1 downto 0)
    );
end dualDFF7474;
 
architecture arch of dualDFF7474 is
begin
  --DFF 1
  process(i_pre1, i_clr1, i_clk)
    begin
      if (i_pre1 = '0' and i_clr1 = '1') then
        o_Q(1) <= '1';
        o_Qbar(1) <= '0';
      elsif (i_clr1 = '0' and i_pre1 = '1') then 
        o_Q(1) <= '0';
        o_Qbar(1) <= '1';
      elsif (i_clr1 = '0' and i_pre1 = '0') then
        o_Q(1) <= '1';
        o_Qbar(1) <= '1';
      elsif (i_clk'event and i_clk = '1') then
        --No else statement, implied latch when clk = '0' (last line of truth table)
        if (i_pre1 = '1' and i_clr1 = '1') then
          o_Q(1) <= i_D(1);
          o_Qbar(1) <= not i_D(1);
        end if;        
      end if;
    end process;
    
  --DFF 2
  process(i_pre2, i_clr2, i_clk)
    begin
      if (i_pre2 = '0' and i_clr2 = '1') then
        o_Q(0) <= '1';
        o_Qbar(0) <= '0';
      elsif (i_clr2 = '0' and i_pre2 = '1') then 
        o_Q(0) <= '0';
        o_Qbar(0) <= '1';
      elsif (i_clr2 = '0' and i_pre2 = '0') then
        o_Q(0) <= '1';
        o_Qbar(0) <= '1';
      elsif (i_clk'event and i_clk = '1') then
        --No else statement, implied latch when clk = '0' (last line of truth table)
        if (i_pre2 = '1' and i_clr2 = '1') then
          o_Q(0) <= i_D(0);
          o_Qbar(0) <= not i_D(0);
        end if;        
      end if;
    end process;
    
       
end arch;