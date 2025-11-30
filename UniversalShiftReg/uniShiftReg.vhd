library ieee;
use ieee.std_logic_1164.all;
 
entity uniShiftReg is
  generic(
    N: integer := 4   --Number of bits in the shift register
    );
  port (
    clk, i_reset            : in  std_logic;
    i_d                     : in std_logic_vector(N-1 downto 0);
    i_ctrl                  : in std_logic_vector(1 downto 0);
    o_q                     : out std_logic_vector(N-1 downto 0)
    );
end uniShiftReg;
 
architecture arch of uniShiftReg is
  signal r_reg  : std_logic_vector (N-1 downto 0);
  signal r_next : std_logic_vector (N-1 downto 0);
begin
  --Segment 1: Clocked
  process(clk, i_reset)
    begin
      if (i_reset = '1') then
        r_reg <= (others => '0');
      elsif(clk'event and clk = '1') then
        r_reg <= r_next;
      end if;
  end process;
  
  --Segment 2, Next state logic (i_ctrl 00: no change, 01: shift left, 10: shift right, 11: load)
  process(i_ctrl, i_d)
    begin
      if (i_ctrl = "00") then --No Change
        r_next <= r_reg;
      elsif (i_ctrl = "01") then --Shift Left
        r_next <= r_reg(N-2 downto 0) & i_d(0);
      elsif (i_ctrl = "10") then --Shift Right
        r_next <= i_d(N-1) & r_reg(N-1 downto 1);
      elsif (i_ctrl = "11") then --Load
        r_next <= i_d;
      end if;
    end process;
    
    --Output logic
    o_q <= r_reg;
    
end arch;