library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity EuclidsMasterFSM is
  generic (N : integer := 8);
  port (
    clk, reset, i_FSMstart            : in std_logic;
    i_x, i_y                          : in std_logic_vector(N-1 downto 0);
    o_FSMready, o_FSMdone             : out std_logic;
    o_gcd_start, o_b2b_start          : out std_logic;
    o_gcd_done, o_b2b_done            : out std_logic;
    o_bcd3, o_bcd2, o_bcd1, o_bcd0    : out std_logic_vector(3 downto 0)
    );
end EuclidsMasterFSM;

architecture arch of EuclidsMasterFSM is
  type state_type is (idle, gcd, b2b);
  attribute syn_encoding: string;
  attribute syn_encoding of state_type: type is "safe, one-hot";
  signal state_reg, state_next  : state_type;
  signal w_gcdOut               : std_logic_vector(7 downto 0);
  signal w_b2bIn                : std_logic_vector(12 downto 0);
  signal w_gcdStart, w_b2bStart : std_logic;
  signal w_gcdDone, w_b2bDone   : std_logic := '0';
  constant zero_vector          : std_logic_vector(N-1 downto 0) := (others=>'0');
  
  component euclidsGCD
    generic (N: integer := 8);
    port (clk, reset, i_start_tick      : in std_logic;
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
  
  begin
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
    
    --Segment 1
    process(clk, reset)
    begin
      if (reset='1') then
        state_reg <= idle;
      elsif (clk'event and clk='1') then
        state_reg <= state_next;
      end if;
    end process;
    
    --Segment 2
    process(state_reg, i_FSMstart, w_gcdDone, w_b2bDone)
    begin
      state_next <= state_reg;
      w_gcdStart <= '0';
      w_b2bStart <= '0';
      o_FSMdone <= '0';
      o_FSMready <= '0';
      case state_reg is
        when idle =>
          o_FSMready <= '1';
          if i_FSMstart = '1' then
            w_gcdStart <= '1';
            state_next <= gcd;
          else
            w_gcdStart <= '0';
            state_next <= idle;
          -- Else default to same state
          end if;
        when gcd =>
          if w_gcdDone = '1' then
            w_b2bStart <= '1';
            state_next <= b2b;
          else
            w_b2bStart <= '0';
            state_next <= gcd;
            -- Else default
          end if;
        when b2b =>
          if w_b2bDone = '1' then
            o_FSMdone <= '1';
            state_next <= idle;
          else
            o_FSMdone <= '0';
            state_next <= b2b;
            -- Else default
          end if;
        end case;
      end process;
      
      
      o_gcd_start <= w_gcdStart;
      o_b2b_start <= w_b2bStart;
      o_gcd_done <= w_gcdDone;
      o_b2b_done <= w_b2bDone;
end arch;
       