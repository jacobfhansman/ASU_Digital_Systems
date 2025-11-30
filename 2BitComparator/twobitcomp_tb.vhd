library ieee;
use ieee.std_logic_1164.all;

entity twobitcomp_tb is
end twobitcomp_tb;

architecture tb_arch of twobitcomp_tb is
  signal w_testA, w_testB : std_logic_vector(1 downto 0);
  signal w_testGT, w_testLT, w_testEQ : std_logic;
  
  begin
  --Top level design component declaration
    comparator: entity work.twobitcomp(arch) 
      port map(i_a1=>w_testA(1), 
               i_a0=>w_testA(0), 
               i_b1=>w_testB(1), 
               i_b0=>w_testB(0), 
               o_agtb=>w_testGT, 
               o_altb=>w_testLT, 
               o_aeq2b=>w_testEQ);
  --Test it
  process
  begin
    --case1
    w_testA <= "00";
    w_testB <= "00";
    wait for 200ns;
    --case2
    w_testA <= "00";
    w_testB <= "01";
    wait for 200ns;
    --case3
    w_testA <= "00";
    w_testB <= "10";
    wait for 200ns;
    --case4
    w_testA <= "00";
    w_testB <= "11";
    wait for 200ns;
    --case5
    w_testA <= "01";
    w_testB <= "00";
    wait for 200ns;
    --case6
    w_testA <= "01";
    w_testB <= "01";
    wait for 200ns;
    --case7
    w_testA <= "01";
    w_testB <= "10";
    wait for 200ns;
    --case8
    w_testA <= "01";
    w_testB <= "11";
    wait for 200ns;
    --case9
    w_testA <= "10";
    w_testB <= "00";
    wait for 200ns;
    --case10
    w_testA <= "10";
    w_testB <= "01";
    wait for 200ns;
    --case11
    w_testA <= "10";
    w_testB <= "10";
    wait for 200ns;
    --case12
    w_testA <= "10";
    w_testB <= "11";
    wait for 200ns;
    --case13
    w_testA <= "11";
    w_testB <= "00";
    wait for 200ns;
    --case14
    w_testA <= "11";
    w_testB <= "01";
    wait for 200ns;
    --case15
    w_testA <= "11";
    w_testB <= "10";
    wait for 200ns;
    --case16
    w_testA <= "11";
    w_testB <= "11";
    wait for 200ns;
    
    assert false
    report "Simulation Completed"
    severity FAILURE;
  end process;
end tb_arch;