library ieee;
use ieee.std_logic_1164.all;
 
entity twobitcomp is
  port (
    i_a1, i_a0, i_b1, i_b0    : in  std_logic;
    o_agtb, o_altb, o_aeq2b : out std_logic
    );
end twobitcomp;

architecture arch of twobitcomp is
  signal w_A : STD_LOGIC_VECTOR (1 downto 0);
  signal w_B : STD_LOGIC_VECTOR (1 downto 0);
  --signal w_gt, w_lt, w_eq : std_logic;
  
--Old method of component declaration
  component EQ
    port (
    i_a0, i_a1, i_b0, i_b1    : in  std_logic;
    o_eq_result : out std_logic
    );
  end component;
  
begin
  
  w_A <= i_a1 & i_a0;
  w_B <= i_b1 & i_b0;

  aeq2b: EQ port map(o_eq_result=>o_aeq2b, 
                     i_a1=>w_A(1), 
                     i_a0=>w_A(0), 
                     i_b1=>w_B(1), 
                     i_b0=>w_B(0));
                     
--New method of component declaration
  agtb: entity work.GT(arch) port map(i_a1=>w_A(1), 
                                      i_a0=>w_A(0), 
                                      i_b1=>w_B(1), 
                                      i_b0=>w_B(0), 
                                      o_gt_result=>o_agtb);
      
  altb: entity work.LT(arch) port map(i_a1=>w_A(1), 
                                      i_a0=>w_A(0), 
                                      i_b1=>w_B(1), 
                                      i_b0=>w_B(0), 
                                      o_lt_result=>o_altb);
------------------------
end arch;
