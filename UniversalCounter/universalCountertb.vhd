library ieee;
use ieee.std_logic_1164.all;

entity universalCountertb is
end universalCountertb;

Architecture arch of universalCountertb is
  constant four: integer := 4;
  constant T: time := 20ns;
  signal clk, reset : std_logic;
  signal i_clr, i_load, i_en, i_up : std_logic;
  signal i_D : std_logic_vector(four-1 downto 0);
  signal o_maxtick, o_mintick : std_logic;
  signal o_Q : std_logic_vector(four-1 downto 0);
  
  Begin
  --Instantiate the counter
  counter: entity work.universalCounter(arch)
    generic map(N=>4)
    port map(clk=>clk, reset=>reset, i_clr=>i_clr, i_load=>i_load, 
             i_en=>i_en, i_up=>i_up, i_D=>i_D, o_maxtick=>o_maxtick,
             o_mintick=>o_mintick, o_Q=>o_Q);
             
  --****************************       
  --Clock, 20ns running forever
  --****************************
  process
    Begin
      clk <= '0';
      wait for T/2;
      clk <= '1';
      wait for T/2;
  end process;
  
  --***********************************
  --Reset test, reset asserted for T/2;
  --***********************************
  reset <= '1', '0' after T/2;
  
  --***********************************
  --Synchronous Stimuli
  --***********************************
  process
    Begin
    --***********************************
    --Initial Input
    --***********************************
    i_clr <= '0';
    i_load <= '0';
    i_en <= '0';
    i_up <= '1'; --Count up
    i_D <= (others => '0');
    wait until falling_edge(clk);
    wait until falling_edge(clk);
    
    --***********************************
    --Test load, should work without EN
    --***********************************
    i_load <= '1';
    i_D <= "1010";
    wait until falling_edge(clk);
    i_load <= '0';
    wait until falling_edge(clk);
    wait until falling_edge(clk); --Pause for 2 clock cycles
    
    --**********************************************
    --Test synchronous clear, doesn't need EN either
    --**********************************************
    i_clr <= '1';
    wait until falling_edge(clk);
    i_clr <= '0';
    
    --***********************************
    --Test UP counter and Pause
    --***********************************
    i_en <= '1'; --enable counting
    i_up <= '1';
    for i in 1 to 10 loop --count up for 10 clock cycles
      wait until falling_edge(clk);
    end loop;
    i_en <= '0'; --Pause
    wait until falling_edge(clk);
    wait until falling_edge(clk); --Pause held 2 clock cycles
    i_en <= '1'; --re-Enable
    wait until falling_edge(clk);
    wait until falling_edge(clk); --Count up for another 2 cycles
    
    --***********************************
    --Test DOWN counter
    --***********************************
    i_up <= '0';
    for i in 1 to 10 loop --count down for 10 clock cycles
      wait until falling_edge(clk);
    end loop;
    
    --***********************************
    --End Simulation
    --***********************************
    assert false;
      report "Simulation Completed!"
    severity failure;
  
  end process;
end arch;
  
  
  
  