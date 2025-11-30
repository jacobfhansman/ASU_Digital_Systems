library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity mod10counter is
  generic(N : integer := 4);
  port( clk, reset, i_load, i_en              : in std_logic;
        i_D                                   : in std_logic_vector(N-1 downto 0);
        o_rco                                 : out std_logic;
        o_Q                                   : out std_logic_vector(N-1 downto 0)
      );
end mod10counter;

Architecture arch of mod10counter is
  signal r_reg, r_next : unsigned(N-1 downto 0);
  Begin
    --Segment 1
    process(clk, reset)
      Begin
        if (reset = '1') then
          r_reg <= (others => '0');
        elsif (clk'event and clk = '0') then --Falling edge clk
          r_reg <= r_next;
        end if;
      end process;
    --Segment 2
    --N.S. Logic             
    process(r_reg, r_next, i_load, i_D, i_en)
      Begin
        if (i_load = '1' and unsigned(i_D) > 9) then --Load priority and load 0 when D > 9
          r_next <= (others => '0');
        elsif (i_load = '1' and unsigned(i_D) <= 9) then --Load D when D <= 9
          r_next <= unsigned(i_D);
        else
          if (i_en = '1') then --Enabled operation
            if (r_reg = 9) then --roll over
              r_next <= (others => '0');
            elsif (r_reg < 9) then --regular counting when less than 9
              r_next <= r_reg + 1;
            else --Incase count somehow gets larger than 9?
              r_next <= (others => '0');
            end if;
          else --Hold
            r_next <= r_reg;
          end if;
        end if;
      end process;
           
    --Output Logic
    o_Q <= std_logic_vector(r_reg);
    o_rco <= '1' when (r_reg = (9) and i_en = '1') else '0';
    
end arch;
  