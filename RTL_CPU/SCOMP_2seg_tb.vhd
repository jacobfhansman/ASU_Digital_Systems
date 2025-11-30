library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity scomp_2seg_tb is
end scomp_2seg_tb;

Architecture arch of scomp_2seg_tb is
  constant N: integer := 8;
  constant T: time := 20ns;
  signal clk, reset 				             : std_logic;
  signal program_counter_out 		      : std_logic_vector(7 downto 0);
  signal register_AC_out 			         : std_logic_vector(15 downto 0);
	signal memory_data_bus_out	        : std_logic_vector(15 downto 0);
	signal memory_address_bus_out	     : std_logic_vector(7 downto 0);
  
  component scomp_2seg
    port(clk, reset 				            : in std_logic;
        program_counter_out 		      : out std_logic_vector(7 downto 0);
        register_AC_out 			         : out std_logic_vector(15 downto 0);
		    memory_data_bus_out	        : out std_logic_vector(15 downto 0);
		    memory_address_bus_out	     : out std_logic_vector(7 downto 0)
		   );
  end component;
  
  Begin
  --Instantiate euclidsGCD
  scomp2seg: scomp_2seg port map(clk=>clk, reset=>reset, program_counter_out=>program_counter_out,
                                 register_AC_out=>register_AC_out, memory_data_bus_out=>memory_data_bus_out,
		                             memory_address_bus_out=>memory_address_bus_out);
             
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
    for i in 1 to 45 loop --count down for 10 clock cycles
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
