library ieee;
use ieee.std_logic_1164.all;
 
entity sevSegAdder is
  port (
    i_A, i_B    : in  std_logic_vector(2 downto 0);
    o_Y         : out std_logic_vector(7 downto 0)
    );
end sevSegAdder;
 
architecture arch of sevSegAdder is
  signal w_A, w_B : std_logic_vector(2 downto 0);
  signal w_out    : std_logic_vector(7 downto 0);
  signal w_sum    : std_logic_vector(2 downto 0);
  signal w_cout   : std_logic;
begin
  w_A <= i_A;
  w_B <= i_B;
  
  segDec: entity work.sevSeg(arch)
    port map(i_switches(3)=> w_cout, i_switches(2) => w_sum(2), i_switches(1) => w_sum(1),
             i_switches(0) => w_sum(0), o_sevSegOut => w_out);
  
  nBit: entity work.nBitAdder(arch)
    generic map(N => 3)
    port map(i_a => w_A, i_b => w_B, o_cout => w_cout, o_sum => w_sum);
      
  o_Y <= w_out;
         
end arch;