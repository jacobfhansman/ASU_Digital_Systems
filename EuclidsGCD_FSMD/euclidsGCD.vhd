library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity euclidsGCD is
  generic (N : integer := 8);
  port (
    clk, reset, i_start_tick      : in std_logic;
    i_x, i_y                      : in std_logic_vector(N-1 downto 0);
    o_ready, o_done_tick          : out std_logic;
    o_GCD                         : out std_logic_vector(N-1 downto 0)
    );
end euclidsGCD;

architecture arch of euclidsGCD is
  type state_type is (idle, op, done);
  attribute syn_encoding: string;
  attribute syn_encoding of state_type: type is "safe";
  signal w_clkdivOut            : std_logic;
  signal state_reg, state_next  : state_type;
  signal x_reg, x_next          : unsigned(N-1 downto 0);
  signal y_reg, y_next          : unsigned(N-1 downto 0);
  signal gcd_reg, gcd_next      : unsigned(N-1 downto 0);
  constant zero_vector          : std_logic_vector(N-1 downto 0) := (others=>'0');
  
  component clockdivider
    port( clock_50Mhz			: in	STD_LOGIC;
		      clock_1MHz				: out	STD_LOGIC;
		      clock_100KHz		: out	STD_LOGIC;
		      clock_10KHz			: out	STD_LOGIC;
		      clock_1KHz				: out	STD_LOGIC;
		      clock_100Hz			: out	STD_LOGIC;
		      clock_10Hz				: out	STD_LOGIC;
		      clock_1Hz				 : out	STD_LOGIC
		 );
  end component;
  
  begin
    --Clk divider
    clkdiv: clockdivider port map(clock_50MHz=>clk, clock_1MHz=>OPEN, clock_100KHZ=>OPEN, clock_10KHz=>OPEN, 
                                  clock_1KHz=>OPEN, clock_100Hz=>OPEN, clock_10Hz=>OPEN, clock_1Hz=>w_clkdivOut);

    --Segment 1
    process(clk, reset)
    begin
      if (reset='1') then
        state_reg <= idle;
        x_reg <= (others=>'0');
        y_reg <= (others=>'0');
        gcd_reg <= (others=>'0');
      elsif (clk'event and clk='1') then
        state_reg <= state_next;
        x_reg <= x_next;
        y_reg <= y_next;
        gcd_reg <= gcd_next;
      end if;
    end process;
    
    --Segment 2
    process(state_reg, state_next, i_x, i_y, i_start_tick, gcd_reg, x_reg, y_reg)
    begin
      state_next <= state_reg;
      x_next <= x_reg;
      y_next <= y_reg;
      gcd_next <= gcd_reg;
      o_ready <= '0';
      case state_reg is
        when idle =>
          o_ready <= '1';
          o_done_tick <= '0';
          if i_start_tick = '1' then
            x_next <= unsigned(i_x);
            y_next <= unsigned(i_y);
            --gcd_next <= (others=>'0');
            if i_x = zero_vector or i_y = zero_vector then
              gcd_next <= unsigned(zero_vector);
              state_next <= done;
            else
              state_next <= op;
            end if;
          else
            state_next <= idle; --Don't think this is necessary, defaults back to same state
          end if;
        when op =>
          x_next <= x_reg;
          y_next <= y_reg;
          gcd_next <= gcd_reg;
          if (x_reg = y_reg)  then
            gcd_next <= x_reg;
            state_next <= done;
          else
            if (x_reg < y_reg) then
              y_next <= y_reg - x_reg;
              state_next <= op; --Not necessary?
            else
              x_next <= x_reg - y_reg;
              state_next <= op; --Not necessary?
            end if;
          end if;
        when done =>
          o_done_tick <= '1';
          state_next <= idle;
        end case;
      end process;
      o_GCD <= std_logic_vector(gcd_reg);
end arch;
       