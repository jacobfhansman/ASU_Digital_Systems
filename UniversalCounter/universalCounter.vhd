library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity universalCounter is
  generic(N : integer := 8);
  port( clk, reset, i_clr, i_load, i_en, i_up : in std_logic;
        i_D                                   : in std_logic_vector(N-1 downto 0);
        o_mintick, o_maxtick                  : out std_logic;
        o_Q                                   : out std_logic_vector(N-1 downto 0)
      );
end universalCounter;

Architecture arch of universalCounter is
  signal r_reg, r_next : unsigned(N-1 downto 0);
  signal synch_options : std_logic_vector(3 downto 0);
  Begin
    --Segment 1
    process(clk, reset)
      Begin
        if (reset = '1') then
          r_reg <= (others => '0');
        elsif (clk'event and clk = '1') then
          r_reg <= r_next;
        end if;
      end process;
    --Segment 2
    --N.S. Logic
    synch_options <= i_clr & i_load & i_en & i_up;
    with synch_options select
      r_next <= (others => '0') when "1000"|"1001"|"1010"|"1011"|
                                     "1100"|"1101"|"1110"|"1111",
                unsigned(i_D)   when "0100"|"0101"|"0110"|"0111",
                r_reg + 1       when "0011",
                r_reg - 1       when "0010",
                r_reg           when "0000"|"0001",
                (others => 'Z') when others;
    --Output Logic
    o_Q <= std_logic_vector(r_reg);
    o_maxtick <= '1' when r_reg = (2**N-1) else '0';
    o_mintick <= '1' when r_reg = (0) else '0';
    
end arch;
  
  