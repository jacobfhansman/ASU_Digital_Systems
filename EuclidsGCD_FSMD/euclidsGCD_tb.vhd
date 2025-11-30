library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity euclidsGCD_tb is
end euclidsGCD_tb;

Architecture arch of euclidsGCD_tb is
  constant N: integer := 8;
  constant T: time := 20ns;
  signal clk, reset                : std_logic;
  signal i_start_tick              : std_logic;
  signal i_x, i_y                  : std_logic_vector(N-1 downto 0);
  signal o_done_tick               : std_logic;
  signal o_GCD                     : std_logic_vector(N-1 downto 0);
  
  component euclidsGCD
    generic (N : integer := 8);
    port (
      clk, reset, i_start_tick      : in std_logic;
      i_x, i_y                      : in std_logic_vector(N-1 downto 0);
      o_ready, o_done_tick          : out std_logic;
      o_GCD                         : out std_logic_vector(N-1 downto 0)
    );
  end component;
  
  Begin
  --Instantiate euclidsGCD
  GCD: euclidsGCD generic map(N=>8)
                  port map(clk=>clk, reset=>reset, i_x=>i_x, i_y=>i_y, 
                           i_start_tick=>i_start_tick, o_done_tick=>o_done_tick, 
                           o_GCD=>o_GCD);
             
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
    --Test x=255, y=221
    --***********************************
    i_x <= std_logic_vector(to_unsigned(255, 8));
    i_y <= std_logic_vector(to_unsigned(221, 8));
    i_start_tick<= '1';
    for i in 1 to 10 loop 
      wait until falling_edge(clk);
    end loop;
    
    --***********************************
    --Test x=199, y=251
    --***********************************
    i_x <= std_logic_vector(to_unsigned(199, 8));
    i_y <= std_logic_vector(to_unsigned(251, 8));
    i_start_tick<= '1';
    for i in 1 to 17 loop 
      wait until falling_edge(clk);
    end loop;
    
    --**********************************************
    --Test x=0, y=88
    --**********************************************
    i_x <= std_logic_vector(to_unsigned(0, 8));
    i_y <= std_logic_vector(to_unsigned(88, 8));
    i_start_tick<= '1';
    for i in 1 to 8 loop 
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