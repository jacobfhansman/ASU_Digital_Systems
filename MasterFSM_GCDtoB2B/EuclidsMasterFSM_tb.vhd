library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EuclidsMasterFSM_tb is
end EuclidsMasterFSM_tb;

Architecture arch of EuclidsMasterFSM_tb is
  constant N: integer := 8;
  constant T: time := 20ns;
  signal clk, reset                        : std_logic;
  signal i_FSMstart                        : std_logic;
  signal o_FSMready, o_FSMdone             : std_logic;
  signal o_bcd3, o_bcd2, o_bcd1, o_bcd0    : std_logic_vector(3 downto 0);
  signal i_x, i_y                          : std_logic_vector(N-1 downto 0);
  signal w_gcdOut                          : std_logic_vector(7 downto 0);
  signal w_b2bIn                           : std_logic_vector(12 downto 0);
  signal w_gcdStart, w_b2bStart            : std_logic;
  signal w_gcdDone,  w_b2bDone             : std_logic;
  
  component EuclidsMasterFSM
    generic (N : integer := 8);
    port (
    clk, reset, i_FSMstart            : in std_logic;
    i_x, i_y                          : in std_logic_vector(N-1 downto 0);
    o_FSMready, o_FSMdone             : out std_logic;
    o_gcd_start, o_b2b_start          : out std_logic;
    o_gcd_done, o_b2b_done            : out std_logic;
    o_bcd3, o_bcd2, o_bcd1, o_bcd0    : out std_logic_vector(3 downto 0)
    );
  end component;
  
  component euclidsGCD
    generic (N : integer := 8);
    port (
      clk, reset, i_start_tick      : in std_logic;
      i_x, i_y                      : in std_logic_vector(N-1 downto 0);
      o_ready, o_done_tick          : out std_logic;
      o_GCD                         : out std_logic_vector(N-1 downto 0)
    );
  end component;
  
  component bin2bcd
    port(clk, reset, start    : in std_logic;
         bin                  : in std_logic_vector(12 downto 0);
         ready, done_tick     : out std_logic;
         bcd3,bcd2,bcd1,bcd0  : out std_logic_vector(3 downto 0)
         );
  end component;
  
  Begin
  --Euclids GCD
  gcd_unit: euclidsGCD generic map(N=>8) 
                       port map(clk=>clk, reset=>reset, i_start_tick=>w_gcdStart,
                                i_x=>i_x, i_y=>i_y, o_ready=>OPEN, o_done_tick=>w_gcdDone,
                                o_GCD=>w_gcdOut);
    --Bin2BCD
  b2b_unit: bin2bcd port map(clk=>clk, reset=>reset, start=>w_b2bStart,
                             bin=>w_b2bIn, ready=>OPEN, done_tick=>w_b2bDone,
                             bcd3=>o_bcd3, bcd2=>o_bcd2, bcd1=>o_bcd1, bcd0=>o_bcd0 
                             );
                             
  -- Pad GCD out with zeros at MSB to match B2B i_bin
  w_b2bIn <= "00000" & w_gcdOut;
                          
  --Instantiate EuclidsMasterFSM
  masterFSM: EuclidsMasterFSM generic map(N=>8) 
                              port map(clk=>clk, reset=>reset, i_x=>i_x, i_y=>i_y, 
                                       i_FSMstart=>i_FSMstart, o_FSMready=>o_FSMready, o_FSMdone=>o_FSMdone, 
                                       o_gcd_start=>w_gcdStart, o_gcd_done=>w_gcdDone, o_b2b_start=>w_b2bStart, 
                                       o_b2b_done=>w_b2bDone, o_bcd3=>o_bcd3, o_bcd2=>o_bcd2, o_bcd1=>o_bcd1,o_bcd0=>o_bcd0
                                       );
             
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
    begin
    --***********************************
    --Test x=255, y=221
    --***********************************
    i_x <= std_logic_vector(to_unsigned(255, 8));
    i_y <= std_logic_vector(to_unsigned(221, 8));
    i_FSMstart <= '1';
    for i in 1 to 25 loop --count down for 10 clock cycles
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