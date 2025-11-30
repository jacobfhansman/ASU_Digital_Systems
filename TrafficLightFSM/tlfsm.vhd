library ieee;
use ieee.std_logic_1164.all;

entity tlfsm is
  port(
    clk, reset: in std_logic;
    NEmer, YNite: in std_logic;
    NSG, NSY, NSR, EWG, EWY, EWR: out std_logic
  );
end tlfsm;

architecture two_seg_arch of tlfsm is
  type eg_state_type is (S0, S1, S2, S3);
  signal state_reg, state_next: eg_state_type;
  begin
    
--state register (Segment 1)
    process(clk, reset)
    begin
      if (reset = '1') then
        state_reg <= S0;
      elsif (clk'event and clk = '1') then
        state_reg <= state_next;
      end if;
    end process;
--Next state / Output logic (Segment 2):
     process(state_reg, NEmer, YNite)
     begin
      state_next <= state_reg; --default back to same state
      NSG <= '0';
      NSY <= '0'; 
      NSR <= '0';
      EWG <= '0'; 
      EWY <= '0'; 
      EWR <= '0'; --default 0
      case state_reg is
      when S0 =>
        if NEmer = '1' then
          if YNite = '0' then
            state_next <= S1;
            NSG <= '1';
            EWR <= '1';
          else
            state_next <= S1;
            EWY <=  '1';
          end if;
        else --assumes default back to state S0
          NSR <= '1';
          EWR <= '1';
        end if;
      when S1 =>
        if NEmer = '1' then
          if YNite = '1' then
            state_next <= S0;
            NSR <= '1';
          else
            state_next <= S2;
            NSY <= '1';
            EWR <= '1';
          end if;
        else --assumes default back to state S1
          NSR <= '1';
          EWR <= '1';
        end if;
      when S2 =>
        NSR <= '1';
        if NEmer = '1' then
          state_next <= S3;
          EWG <= '1';
        else --assumes default back to state S2
          EWR <= '1';
        end if;
      when S3 =>
        NSR <= '1';
        if NEmer = '1' then
          state_next <= S0;
          EWY <= '1';
        else --assumes default back to state S3
          EWR <= '1';
        end if;
      end case;
  end process;
end two_seg_arch;
  
        
          


