library ieee;
use ieee.std_logic_1164.all;
 
entity JKFF is
  port (
    i_J, i_K                : in  std_logic;
    i_pre, i_clr            : in std_logic;
    i_clk                   : in std_logic;
    o_Q                     : out std_logic;
    o_Qbar                  : out std_logic
    );
end JKFF;
 
architecture arch of JKFF is
  signal w_reg, w_regbar, w_next : std_logic;
  signal w_jk : std_logic_vector(1 downto 0);
begin
  w_jk <= i_J & i_k;
  --segment 1, sequential clocked
  process(i_pre, i_clr, i_clk)
    begin
      if (i_pre = '0' and i_clr = '1') then
        w_reg <= '1';
        w_regbar <= '0';
      elsif (i_clr = '0' and i_clr = '1') then 
        w_reg <= '0';
        w_regbar <= '1';
      elsif (i_clr = '0' and i_pre = '0') then
        w_reg <= '0';
        w_regbar <= '1';
      elsif (i_clk'event and i_clk = '1') then
        w_reg <= w_next;
        w_regbar <= (not w_next);       
      end if;
    end process;
    
  --segment 2, combinatorial
  --Next State Logic
  with w_jk select
    w_next <= w_reg    when "00",
              '0'      when "01",
              '1'      when "10",
              w_regbar when "11",
              'Z'      when others;
              
  --Output Logic
  o_Q <= w_reg;
  o_Qbar <= w_regbar;
       
end arch;