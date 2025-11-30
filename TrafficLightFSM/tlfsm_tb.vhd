library ieee;
use ieee.std_logic_1164.all;

entity tlfsm_tb is
end tlfsm_tb;

architecture arch of tlfsm_tb is
  
  constant T: time := 20 ns; --clk period 50MHz
  signal clk, reset: std_logic;
  signal NEmer, YNite: std_logic;
  signal NSG, NSY, NSR, EWG, EWY, EWR: std_logic;
  
begin 
  --installation of fsm-tl
  fsmtl : entity work.tlfsm(two_seg_arch)
  port map(clk=>clk, reset=>reset, NEmer=>NEmer, YNite=>YNite, NSG=>NSG, 
  NSY=>NSY, NSR=>NSR, EWG=>EWG, EWY=>EWY, EWR=>EWR);
  
  --clock (50MHz {20ns} clock running forever
  process
  begin
    clk <= '0';
    wait for T/2;
    clk <= '1';
    wait for T/2;
  end process;
  
  --reset for T/2
  reset <= '1', '0' after T/2;
  
  --all other paths
  process
  begin
    --S0_Emer
    NEmer <= '0';
    YNite <= '0';
    wait until falling_edge(clk);
    --S0_NSG-EWR
    NEmer <= '1';
    YNite <= '0';
    wait until falling_edge(clk);
    --S1_Emer
    NEmer <= '0';
    wait until falling_edge(clk);
    --S1_NSY-EWR
    NEmer <= '1';
    YNite <= '0';
    wait until falling_edge(clk);
    --S2_Emer
    NEmer <= '0';
    wait until falling_edge(clk);
    --S2_NSR-EWG
    NEmer <= '1';
    wait until falling_edge(clk);   
    --S3_Emer
    NEmer <= '0';
    wait until falling_edge(clk);
    --S3_NSR_EWY
    NEmer <= '1';
    wait until falling_edge(clk);  
    --S0_YNite-Emer
    NEmer <= '0';
    YNite <= '1';
    wait until falling_edge(clk);
    --S0_YNite
    NEmer <= '1';
    YNite <= '1';
    wait until falling_edge(clk);
    --S1_YNite-Emer
    NEmer <= '0';
    YNite <= '1';
    wait until falling_edge(clk);
    --S1_YNite
    NEmer <= '1';
    YNite <= '1';
    wait until falling_edge(clk);
    --S0_Emer
    NEmer <= '0';
    wait until falling_edge(clk);
    --S0_NSG-EWR
    NEmer <= '1';
    YNite <= '0';
    wait until falling_edge(clk);
    --S1_Emer
    NEmer <= '0';
    wait until falling_edge(clk);
    --S1_NSY-EWR
    NEmer <= '1';
    YNite <= '0';
    wait until falling_edge(clk);
    
    assert False
    report "Simulation Completed"
    severity failure;
    
  end process;
end arch; 
  
