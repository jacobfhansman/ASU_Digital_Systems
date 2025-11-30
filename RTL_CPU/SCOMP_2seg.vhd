library ieee;
use  ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library altera_mf;
use altera_mf.altera_mf_components.all;

entity scomp_2seg IS
  port( clk, reset 				        : in std_logic;
        i_IO                          : in std_logic_vector(3 downto 0);
        o_IO                          : out std_logic_vector(7 downto 0);
        program_counter_out 		     : out std_logic_vector(7 downto 0);
        register_AC_out 			     : out std_logic_vector(15 downto 0);
		  memory_data_bus_out	        : out std_logic_vector(15 downto 0);
		  memory_address_bus_out	     : out std_logic_vector(7 downto 0)
		   );
  end scomp_2seg;
  
architecture arch OF scomp_2seg IS
type state_type is ( reset_pc, fetch, decode, execute_add, execute_load, execute_store, 
		                 execute_store2, execute_jump, execute_jneg, execute_subt, execute_xor,
		                 execute_or, execute_and, execute_jpos, execute_jzero, execute_shl, execute_shr,
		                 execute_IOin, execute_IOout );
signal state_reg, state_next                       : state_type;
signal IR_reg, IR_next                             : unsigned(15 downto 0); 
signal memory_data_bus 	                           : std_logic_vector(15 downto 0);
signal ACC_reg, ACC_next 				               : unsigned(15 downto 0);
signal Output_reg												: std_logic_vector(7 downto 0); --Std logic to map to sevSeg switches
signal Output_next                     				: unsigned(7 downto 0);
signal pc_reg, pc_next 			                     : unsigned(7 downto 0);
signal memory_address_bus	                        : unsigned(7 downto 0);
signal memory_write 			                        : std_logic;
signal addrAmount                                  : natural;	
signal w_sevSegDisp											: std_logic_vector(7 downto 0); --Std logic to map to sevSeg output and drive IO output pins										
signal shiftZeroVector                             : unsigned(15 downto 0) := (others=>'0');

component sevSeg
  port (i_switches: in  std_logic_vector (3 downto 0);
        o_sevSegOut: out std_logic_vector (7 downto 0)
        );
end component;

begin
  --Use sevSeg component
  --Tie IO Output Register to switches to determine sevSeg output
  sevenSeg: sevSeg
    port map (i_switches=>Output_reg(3 downto 0), o_sevSegOut=>w_sevSegDisp);
      
	-- Use Altsyncram function for computer's memory (256 16-bit words)
  memory: altsyncram
    generic map ( operation_mode => "SINGLE_PORT",
		              width_a => 16,
		              widthad_a => 8,
		              lpm_type => "altsyncram",
		              outdata_reg_a => "UNREGISTERED",
			            -- Reads in mif file for initial program and data values
		              init_file => "program4.mif",
		              intended_device_family => "Cyclone")
		
	   port map (	wren_a => memory_write, clock0 => clk, 
				        address_a => std_logic_vector(memory_address_bus), 
				        data_a => std_logic_vector(ACC_reg), q_a => memory_data_bus );


    --Segment 1
    process(clk, reset)
    begin
		--Clk '0' for running on the board w/ active-low buttons. '1' for simulation
      if (reset='0') then
        state_reg <= reset_pc;
      elsif (clk'event and clk='0') then
        state_reg <= state_next;
        IR_reg <= IR_next;
        ACC_reg <= ACC_next;
        pc_reg <= pc_next;
        Output_reg <= std_logic_vector(Output_next);
      end if;
    end process;
    
    --Segment 2
    process(state_reg, IR_reg, pc_reg, memory_data_bus, ACC_reg, i_IO, Output_reg, addrAmount, shiftZeroVector)
    begin
      state_next <= state_reg;
      memory_write <= '0'; --default zero for other states, assert '1' in execute_store
      IR_next <= IR_reg;
      pc_next <= pc_reg;
      ACC_next <= ACC_reg;
      addrAmount <= to_integer(IR_reg(3 downto 0));
		shiftZeroVector <= (others=>'0');
      Output_next <= unsigned(Output_reg);
      
      case state_reg is
        --Reset state
        when reset_pc =>
          pc_next <= (others=>'0');
          ACC_next <= (others=>'0');
          memory_address_bus <= (others=>'0');
          IR_next <= (others=>'0');
          memory_write <= '0';
			 Output_next <= (others=>'0');
          state_next <= fetch;
        --Fetch state: data bus on IR, current PC on add. bus, PC increments
        when fetch =>
          IR_next <= unsigned(memory_data_bus);
          pc_next <= pc_reg + to_unsigned(1, pc_reg'length);
          memory_address_bus <= pc_reg;
          state_next <= decode;
        --Decode state: IR(7->0)LSbyte(address) on add. bus 1 state early for execute 
        --              and IR(15->8)MSbyte(opcode) decides execute
        when decode =>
          memory_address_bus <= IR_reg(7 downto 0);
          case IR_reg(15 downto 8) is
            when "00000000" =>
              state_next <= execute_add;
            when "00000001" =>
              state_next <= execute_store;
            when "00000010" =>
              state_next <= execute_load;
            when "00000011" =>
              state_next <= execute_jump;
            when "00000100" =>
              state_next <= execute_jneg;
            when "00000101" =>
              state_next <= execute_subt;
            when "00000110" =>
              state_next <= execute_xor;
            when "00000111" =>
              state_next <= execute_or;
            when "00001000" =>
              state_next <= execute_and;
            when "00001001" =>
              state_next <= execute_jpos;
            when "00001010" =>
              state_next <= execute_jzero;
          	 when "00001011" =>
          	   state_next <= execute_shl;
        	   when "00001100" =>
        	     state_next <= execute_shr;
      	     when "00001101" =>
      	       state_next <= execute_IOin;
    	       when "00001110" =>
    	         state_next <= execute_IOout;
            when others =>
              state_next <= fetch;
            end case;
        --Add instruction: adds 16b data bus to ACC, puts pc on add. bus for fetch
        when execute_add =>
          ACC_next <= ACC_reg + unsigned(memory_data_bus);
          memory_address_bus <= pc_reg;
          state_next <= fetch;
        --Store instruction 1/2: executes write signal and add. to write to on add. bus
        when execute_store =>
          memory_write <= '1';
          memory_address_bus <= IR_reg(7 downto 0); --add. to store data bus at
          state_next <= execute_store2;
        --Store instruction 2/2: actually writes it, puts pc on add. bus for fetch
        when execute_store2 =>
          memory_address_bus <= pc_reg;
          state_next <= fetch;
        --Load instruction: puts data bus on ACC, puts pc on add. bus for fetch
        when execute_load =>
          ACC_next <= unsigned(memory_data_bus);
          memory_address_bus <= pc_reg;
          state_next <= fetch;
        --Jump instruction: load address of instruction you're jumping to, put pc on add. bus for fetch
        when execute_jump =>
          pc_next <= IR_reg(7 downto 0); --add. of instruction to jump to
          memory_address_bus <= IR_reg(7 downto 0);
          state_next <= fetch;
        --Jump if Negative instruciton: If ACC negative, jump to the instruction at the loaded address
        --                              If ACC not negative, then continue to next sequential instruction
        when execute_jneg =>
          if signed(ACC_reg) < 0 then
            pc_next <= IR_reg(7 downto 0);
            memory_address_bus <= IR_reg(7 downto 0);
            state_next <= fetch;
          else
            memory_address_bus <= pc_reg;
            state_next <= fetch;
          end if;
        --Subtract instruction: Subtract data bus value from ACC, put pc on add. bus for fetch
        when execute_subt =>
          ACC_next <= ACC_reg - unsigned(memory_data_bus);
          memory_address_bus <= pc_reg;
          state_next <= fetch;
        --XOR instruction: XORs ACC and data bus value
        when execute_xor =>
          ACC_next <= ACC_reg XOR unsigned(memory_data_bus);
          memory_address_bus <= pc_reg;
          state_next <= fetch;
        --OR instruction: ORs ACC and data bus value
        when execute_or =>
          ACC_next <= ACC_reg OR unsigned(memory_data_bus);
          memory_address_bus <= pc_reg;
          state_next <= fetch;
        --AND instruction: ANDs ACC and data bus value
        when execute_and => 
          ACC_next <= ACC_reg AND unsigned(memory_data_bus);
          memory_address_bus <= pc_reg;
          state_next <= fetch;
        --Jump If Positive instruction: If ACC positive, jump to instruction at loaded address
        --                              If ACC not positive, move on to next sequential instruction 
        when execute_jpos =>
          if signed(ACC_reg) > 0 then
            pc_next <= IR_reg(7 downto 0);
            memory_address_bus <= IR_reg(7 downto 0);
            state_next <= fetch;
          else
            memory_address_bus <= pc_reg;
            state_next <= fetch;
          end if;
        --Jump If Zero instruction: If ACC is zero, jump to instruction at loaded address
        --                          If ACC is not zero, move on to next sequential instruction
        when execute_jzero =>
          if signed(ACC_reg) = 0 then
            pc_next <= IR_reg(7 downto 0);
            memory_address_bus <= IR_reg(7 downto 0);
            state_next <= fetch;
          else
            memory_address_bus <= pc_reg;
            state_next <= fetch;
          end if;
        --Shift Left instruction: Shifts the ACC left by the # of bits specified by low nibble of address in IR
        when execute_shl =>
          memory_address_bus <= pc_reg;
			 --Quartus does not allow variable vector lengths in synthesis. 
			 --Must explicitly define vector lengths for each case of addrAmount.
			 --There's probably a more elegant way to accomplish this, but I just want it to work
          --ACC_next <= ACC_reg(15-addrAmount downto 0) & shiftZeroVector(addrAmount - 1 downto 0);
			 case addrAmount is
				when 0 =>
					ACC_next <= ACC_reg;
				when 1 =>
					ACC_next <= ACC_reg(14 downto 0) & shiftZeroVector(0 downto 0);
				when 2 =>
					ACC_next <= ACC_reg(13 downto 0) & shiftZeroVector(1 downto 0);
				when 3 =>
					ACC_next <= ACC_reg(12 downto 0) & shiftZeroVector(2 downto 0);
				when 4 =>
					ACC_next <= ACC_reg(11 downto 0) & shiftZeroVector(3 downto 0);
				when 5 =>
					ACC_next <= ACC_reg(10 downto 0) & shiftZeroVector(4 downto 0);
				when 6 =>
					ACC_next <= ACC_reg(9 downto 0) & shiftZeroVector(5 downto 0);
				when 7 =>
					ACC_next <= ACC_reg(8 downto 0) & shiftZeroVector(6 downto 0);
				when 8 =>
					ACC_next <= ACC_reg(7 downto 0) & shiftZeroVector(7 downto 0);
				when 9 =>
					ACC_next <= ACC_reg(6 downto 0) & shiftZeroVector(8 downto 0);
				when 10 =>
					ACC_next <= ACC_reg(5 downto 0) & shiftZeroVector(9 downto 0);
				when 11 =>
					ACC_next <= ACC_reg(4 downto 0) & shiftZeroVector(10 downto 0);
				when 12 =>
					ACC_next <= ACC_reg(3 downto 0) & shiftZeroVector(11 downto 0);
				when 13 =>
					ACC_next <= ACC_reg(2 downto 0) & shiftZeroVector(12 downto 0);
				when 14 =>
					ACC_next <= ACC_reg(1 downto 0) & shiftZeroVector(13 downto 0);
				when 15 =>
					ACC_next <= ACC_reg(0 downto 0) & shiftZeroVector(14 downto 0);
				when others =>
					ACC_next <= ACC_reg;
			 end case;
          state_next <= fetch;
        --Shift Right instruction: Shifts the ACC right by the # of bits specified by low nibble of address in IR
        when execute_shr =>
          memory_address_bus <= pc_reg;
			 --Quartus does not allow variable vector lengths in synthesis. 
			 --Must explicitly define vector lengths for each case of addrAmount.
          --ACC_next <= shiftZeroVector(addrAmount - 1 downto 0) & ACC_reg(15 downto addrAmount);
			 case addrAmount is
				when 0 =>
					ACC_next <= ACC_reg;
				when 1 =>
					ACC_next <= shiftZeroVector(0 downto 0) & ACC_reg(15 downto 1);
				when 2 =>
					ACC_next <= shiftZeroVector(1 downto 0) & ACC_reg(15 downto 2);
				when 3 =>
					ACC_next <= shiftZeroVector(2 downto 0) & ACC_reg(15 downto 3);
				when 4 =>
					ACC_next <= shiftZeroVector(3 downto 0) & ACC_reg(15 downto 4);
				when 5 =>
					ACC_next <= shiftZeroVector(4 downto 0) & ACC_reg(15 downto 5);
				when 6 =>
					ACC_next <= shiftZeroVector(5 downto 0) & ACC_reg(15 downto 6);
				when 7 =>
					ACC_next <= shiftZeroVector(6 downto 0) & ACC_reg(15 downto 7);
				when 8 =>
					ACC_next <= shiftZeroVector(7 downto 0) & ACC_reg(15 downto 8);
				when 9 =>
					ACC_next <= shiftZeroVector(8 downto 0) & ACC_reg(15 downto 9);
				when 10 =>
					ACC_next <= shiftZeroVector(9 downto 0) & ACC_reg(15 downto 10);
				when 11 =>
					ACC_next <= shiftZeroVector(10 downto 0) & ACC_reg(15 downto 11);
				when 12 =>
					ACC_next <= shiftZeroVector(11 downto 0) & ACC_reg(15 downto 12);
				when 13 =>
					ACC_next <= shiftZeroVector(12 downto 0) & ACC_reg(15 downto 13);
				when 14 =>
					ACC_next <= shiftZeroVector(13 downto 0) & ACC_reg(15 downto 14);
				when 15 =>
					ACC_next <= shiftZeroVector(14 downto 0) & ACC_reg(15 downto 15);
				when others =>
					ACC_next <= ACC_reg;
			 end case;
          state_next <= fetch;
        --IO in instruction: Stores specified IO pins to specified Address in memory (I chose FE) {Modified Store instruction}
        when execute_IOin =>
          ACC_next(15 downto 4) <= (others=>'0');
			 ACC_next(3 downto 0) <= unsigned(i_IO);
          memory_address_bus <= IR_reg(7 downto 0); --IO add. to store data bus (IO in ACC) at
          state_next <= execute_store;
          --state_next <= execute_load;
        --IO out instruction: Loads the read-in i_IO pins to the Output register (connected to Sev-Seg or LED) {Modified Load instruction}
        when execute_IOout =>
          Output_next <= ACC_reg(7 downto 0);
          memory_address_bus <= pc_reg;
          state_next <= fetch; 
        when others =>
          state_next <= fetch;
        end case;
      end process;
		
		--Drive IO output pins
		o_IO <= w_sevSegDisp;
 							 
		-- Output major signals for simulation
   	program_counter_out 		<= std_logic_vector(pc_reg);
   	register_AC_out 			<= std_logic_vector(ACC_reg);
   	memory_data_bus_out <= memory_data_bus; 
   	memory_address_bus_out <= std_logic_vector(memory_address_bus);
				
end arch;