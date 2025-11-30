library ieee;
use ieee.std_logic_1164.all;
library altera;
use altera.altera_primitives_components.all;
 
entity stopwatch is
  generic (N : integer := 4);
  port (
    clk, reset, i_enbutton          : in  std_logic;
    o_disp1, o_disp2                : out std_logic_vector(7 downto 0)
    );
end stopwatch;

architecture arch of stopwatch is
  signal w_clkdivOut, w_globalOut    : std_logic;
  signal w_carry, w_button, w_enable : std_logic;
  signal w_q1toSS, w_q2toSS          : std_logic_vector(N-1 downto 0);
  signal w_toDisp1, w_toDisp2			 : std_logic_vector(7 downto 0);
  
--Old method of component declaration
  component mod10counter
    generic(N : integer := 4);
    port( clk, reset, i_load, i_en : in std_logic;
          i_D                      : in std_logic_vector(N-1 downto 0);
          o_rco                    : out std_logic;
          o_Q                      : out std_logic_vector(N-1 downto 0)
    );
  end component;
  
  component clockdivider
    port( clock_50Mhz			: IN	STD_LOGIC;
		      clock_1MHz				: OUT	STD_LOGIC;
		      clock_100KHz		: OUT	STD_LOGIC;
		      clock_10KHz			: OUT	STD_LOGIC;
		      clock_1KHz				: OUT	STD_LOGIC;
		      clock_100Hz			: OUT	STD_LOGIC;
		      clock_10Hz				: OUT	STD_LOGIC;
		      clock_1Hz				 : OUT	STD_LOGIC
		 );
  end component;
  
--  
begin

  clkdiv: clockdivider    port map(clock_50MHz=>clk, clock_1MHz=>OPEN, clock_100KHZ=>OPEN, clock_10KHz=>OPEN, 
                                clock_1KHz=>OPEN, clock_100Hz=>OPEN, clock_10Hz=>w_clkdivOut, clock_1Hz=>OPEN);
                                
  clkbuff: global         port map(a_in=>w_clkdivOut, a_out=>w_globalOut);
  
  counter1: mod10counter  port map(clk=>w_globalOut, reset=>not(reset), i_load=>'0', i_en=>w_enable, i_D=>"0000", 
                                   o_rco=>w_carry, o_Q=>w_q1toSS);
                                   
  counter2: mod10counter  port map(clk=>w_globalOut, reset=>not(reset), i_load=>'0', i_en=>w_carry, i_D=>"0000",
                                   o_rco=>OPEN, o_Q=>w_q2toSS);
  
  buttonlatch: jkff        port map(j=>'1', clk=>not(i_enbutton), clrn=>reset, prn=>'1', k=>'1', q=>w_enable);
-----------------------
  
--New method of component declaration
  disp1: entity work.sevSeg(arch)
    port map(i_switches=>w_q1toSS, o_sevSegOut=>o_disp1);
      
  disp2: entity work.sevSeg(arch)
    port map(i_switches=>w_q2toSS, o_sevSegOut=>o_disp2);
------------------------

--o_disp1 <= w_toDisp1;
--o_disp2 <= w_toDisp2;
--  
end arch;
