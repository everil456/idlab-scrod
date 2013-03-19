library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use IEEE.NUMERIC_STD.ALL;
use work.IRS3B_CarrierRevB_DAC_definitions.all; -- Definitions in irs3b_carrierRevB_DAC_definitions.vhd

entity irs3b_program_dacs_parallel is
   Port ( 
		CLK                      :  in STD_LOGIC;
		CE                       :  in STD_LOGIC;
		PCLK                     : out STD_LOGIC_VECTOR(15 downto 0);
		SCLK                     : out STD_LOGIC;
		SIN                      : out STD_LOGIC;
		SHOUT                    :  in STD_LOGIC;
		--ASIC DAC values
		--DAC_setting indicates a global for the whole boardstack
		--DAC_setting_C_R indicates a (4)(4) to set DACs separately by row/col
		--DAC_setting_C_R_CH indicates a (4)(4)(8) to set DACs separately by row/col/ch
		ASIC_TRIG_THRESH         : in DAC_setting_C_R_CH;
		ASIC_DAC_BUF_BIASES      : in DAC_setting;
		ASIC_DAC_BUF_BIAS_ISEL   : in DAC_setting;
		ASIC_DAC_BUF_BIAS_VADJP  : in DAC_setting;
		ASIC_DAC_BUF_BIAS_VADJN  : in DAC_setting;
		ASIC_VBIAS               : in DAC_setting_C_R;
		ASIC_VBIAS2              : in DAC_setting_C_R;
		ASIC_REG_TRG             : in Timing_setting; --Not a DAC but set with the DACs.  Global for all ASICs.
		ASIC_WBIAS               : in DAC_setting_C_R;
		ASIC_VADJP               : in DAC_setting_C_R;
		ASIC_VADJN               : in DAC_setting_C_R;
		ASIC_VDLY                : in DAC_setting_C_R;
		ASIC_TRG_BIAS            : in DAC_setting;
		ASIC_TRG_BIAS2           : in DAC_setting;
		ASIC_TRGTHREF            : in DAC_setting;
		ASIC_CMPBIAS             : in DAC_setting;
		ASIC_PUBIAS              : in DAC_setting;
		ASIC_SBBIAS              : in DAC_setting;
		ASIC_ISEL                : in DAC_setting;
		--Timing settings go here too, since they're set with the DACs
		ASIC_TIMING_SSP_LEADING      : in Timing_setting_C_R;
		ASIC_TIMING_SSP_TRAILING     : in Timing_setting_C_R;
		ASIC_TIMING_WR_STRB_LEADING  : in Timing_setting_C_R;
		ASIC_TIMING_WR_STRB_TRAILING : in Timing_setting_C_R;
		ASIC_TIMING_S1_LEADING       : in Timing_setting_C_R;
		ASIC_TIMING_S1_TRAILING      : in Timing_setting_C_R;
		ASIC_TIMING_S2_LEADING       : in Timing_setting_C_R;
		ASIC_TIMING_S2_TRAILING      : in Timing_setting_C_R;
		ASIC_TIMING_PHASE_LEADING    : in Timing_setting_C_R;
		ASIC_TIMING_PHASE_TRAILING   : in Timing_setting_C_R;
		ASIC_TIMING_GENERATOR_REG    : in Timing_setting
	 );
end irs3b_program_dacs_parallel;

architecture Behavioral of irs3b_program_dacs_parallel is
	--State machine signals
	type dac_state is (IDLE, LOAD_BIT, SEND_BIT, NEXT_BIT, PREPARE_LATCH, LATCH_BUS_DATA, PREPARE_LOAD, LOAD_DESTINATION, INCREMENT);
	signal internal_STATE      : dac_state := IDLE;
	signal internal_NEXT_STATE : dac_state := IDLE;
	--Internal copies of signals so we can monitor via chipscope if needed
	signal internal_PCLK_SINGLE : std_logic;
	signal internal_PCLK  : std_logic_vector(15 downto 0);
	signal internal_SCLK  : std_logic;
	signal internal_SIN   : std_logic;
	--Counter to grab row/col for settings that are unique
	signal internal_ROW_COL_COUNTER    : unsigned(3 downto 0) := (others => '0');
	signal internal_ROW                : integer := 0;
	signal internal_COL                : integer := 0;
	signal internal_INCREMENT_ROWCOL   : std_logic := '0';
	signal internal_RESET_ROWCOL       : std_logic := '0';
	--Determine what register address to read
	signal internal_REGISTER_COUNTER   : unsigned(5 downto 0) := (others => '0');
	signal internal_INCREMENT_REGISTER : std_logic := '0';
	signal internal_RESET_REGISTER     : std_logic := '0';
	signal internal_REG_ADDR           : std_logic_vector(5 downto 0);
	--Counter for choosing which bit to send
	signal internal_BIT_COUNTER        : unsigned(5 downto 0) := (others => '0');
	signal internal_INCREMENT_BIT      : std_logic := '0';
	signal internal_RESET_BIT_COUNTER  : std_logic := '0';
	--Generic counter for delays
	signal internal_GENERIC_COUNTER    : unsigned(3 downto 0) := (others => '0');
	signal internal_INCREMENT_COUNTER  : std_logic := '0';
	signal internal_RESET_COUNTER      : std_logic := '0';
	--Types for different register updates
	type reg_type is (global, unique); 
	type all_reg_types is array(46 downto 0) of reg_type;
	signal reg_map : all_reg_types;
	--Register that has the DAC value we'd like to load
	signal internal_REG_VALUE_TO_LOAD : std_logic_vector(11 downto 0);
	signal internal_LATCHED_REG_VALUE : std_logic_vector(11 downto 0);
	signal internal_LATCH_REG_VALUE   : std_logic := '0';
	signal internal_SERIAL_VALUE      : std_logic_vector(17 downto 0);
begin
	--Connections to the top
	PCLK <= internal_PCLK;
	SCLK <= internal_SCLK;
	SIN  <= internal_SIN;
	
	-------------------------
	--Primary state machine--
	-------------------------
	--Output logic
	process(internal_STATE,internal_SERIAL_VALUE,internal_REGISTER_COUNTER,reg_map,internal_BIT_COUNTER) begin
		--Defaults here
		internal_LATCH_REG_VALUE    <= '0';
		internal_PCLK_SINGLE        <= '0';
		internal_SCLK               <= '0';
		internal_SIN                <= '0';
		internal_RESET_ROWCOL       <= '0';
		internal_RESET_BIT_COUNTER  <= '0';
		internal_RESET_ROWCOL       <= '0';
		internal_INCREMENT_BIT      <= '0';
		internal_INCREMENT_REGISTER <= '0';
		internal_RESET_COUNTER      <= '0';
		internal_INCREMENT_COUNTER  <= '0';
		internal_RESET_REGISTER     <= '0';
		internal_INCREMENT_ROWCOL   <= '0';
		--
		case(internal_STATE) is
			when IDLE =>
				internal_LATCH_REG_VALUE    <= '1';
				internal_RESET_REGISTER     <= '1';
				internal_RESET_BIT_COUNTER  <= '1';
				internal_RESET_ROWCOL       <= '1';
			when LOAD_BIT =>
				internal_SIN                <= internal_SERIAL_VALUE(to_integer(internal_BIT_COUNTER));
			when SEND_BIT => 
				internal_SIN                <= internal_SERIAL_VALUE(to_integer(internal_BIT_COUNTER));
				internal_SCLK               <= '1';
			when NEXT_BIT =>
				internal_SIN                <= internal_SERIAL_VALUE(to_integer(internal_BIT_COUNTER));
				internal_INCREMENT_BIT      <= '1';
			when PREPARE_LATCH =>
				internal_RESET_COUNTER      <= '1';
			when LATCH_BUS_DATA =>
				internal_PCLK_SINGLE        <= '1';
				internal_INCREMENT_COUNTER  <= '1';
			when PREPARE_LOAD =>
				internal_SIN                <= '1';
				internal_RESET_COUNTER      <= '1';
			when LOAD_DESTINATION => 
				internal_PCLK_SINGLE        <= '1';
				internal_SIN                <= '1';
				internal_INCREMENT_COUNTER  <= '1';
			when INCREMENT =>
				if (reg_map(to_integer(internal_REGISTER_COUNTER)) = unique) then
					internal_INCREMENT_ROWCOL   <= '1';
				else 
					internal_RESET_ROWCOL       <= '1';
					internal_INCREMENT_REGISTER <= '1';
				end if;
		end case;
	end process;

	--Next state selection logic
	process(internal_STATE, internal_BIT_COUNTER, internal_GENERIC_COUNTER,reg_map,internal_REGISTER_COUNTER, internal_ROW_COl_COUNTER) begin
		case(internal_STATE) is
			when IDLE =>      
				internal_NEXT_STATE <= LOAD_BIT;
			when LOAD_BIT =>
				internal_NEXT_STATE <= SEND_BIT;
			when SEND_BIT => 
				internal_NEXT_STATE <= NEXT_BIT;
			when NEXT_BIT =>
				if (internal_BIT_COUNTER < 15) then --CHECK VALUE HERE
					internal_NEXT_STATE <= LOAD_BIT;
				else
					internal_NEXT_STATE <= PREPARE_LATCH;
				end if;
			when PREPARE_LATCH =>
				internal_NEXT_STATE <= LATCH_BUS_DATA;
			when LATCH_BUS_DATA =>
				if (internal_GENERIC_COUNTER < 9) then
					internal_NEXT_STATE <= LATCH_BUS_DATA;
				else 
					internal_NEXT_STATE <= PREPARE_LOAD;
				end if;
			when PREPARE_LOAD =>
				internal_NEXT_STATE <= LOAD_DESTINATION;
			when LOAD_DESTINATION => 
				if (internal_GENERIC_COUNTER < 9) then
					internal_NEXT_STATE <= LOAD_DESTINATION;
				else 
					internal_NEXT_STATE <= INCREMENT;
				end if;
			when INCREMENT =>
				if (reg_map(to_integer(internal_REGISTER_COUNTER)) = global or
				                             internal_ROW_COL_COUNTER = 15) then
					if (internal_REGISTER_COUNTER < 46) then
						internal_NEXT_STATE <= LOAD_BIT;
					else
						internal_NEXT_STATE <= IDLE;
					end if;
				else 
					internal_NEXT_STATE <= LOAD_BIT;
				end if;
			when others =>
				internal_NEXT_STATE <= IDLE;
		end case;
	end process;

	--Synchronous update to next state
	process(CLK, CE) begin
		if (CE = '1') then
			if (rising_edge(CLK)) then
				internal_STATE <= internal_NEXT_STATE;
			end if;
		end if;
	end process;


	-----------------
	--SUPPORT LOGIC--
	-----------------
	
	--List which registers should be done globally and which individually by ASIC
	--Numbers in the comments correspond to Gary's notation in the register map spreadsheet
	reg_map( 0) <= unique; -- 1: THR1
	reg_map( 1) <= unique; -- 2: THR2
	reg_map( 2) <= unique; -- 3: THR3
	reg_map( 3) <= unique; -- 4: THR4
	reg_map( 4) <= unique; -- 5: THR5
	reg_map( 5) <= unique; -- 6: THR6
	reg_map( 6) <= unique; -- 7: THR7
	reg_map( 7) <= unique; -- 8: THR8
	reg_map( 8) <= global; -- 9: VBDBIAS
	reg_map( 9) <= unique; --10: VBIAS
	reg_map(10) <= unique; --11: VBIAS2
	reg_map(11) <= global; --12: MiscReg (LSB: TRG_SIGN)
	reg_map(12) <= global; --13: WBDbias
	reg_map(13) <= unique; --14: Wbias
	reg_map(14) <= global; --15: TCDbias
	reg_map(15) <= global; --16: TRGbias
	reg_map(16) <= global; --17: THDbias
	reg_map(17) <= global; --18: Tbbias
	reg_map(18) <= global; --19: TRGDbias
	reg_map(19) <= global; --20: TRGbias2
	reg_map(20) <= global; --21: TRGthref
	reg_map(21) <= unique; --22: LeadSSPin
	reg_map(22) <= unique; --23: TrailSSPin
	reg_map(23) <= unique; --24: LeadS1
	reg_map(24) <= unique; --25: TrailS1
	reg_map(25) <= unique; --26: LeadS2
	reg_map(26) <= unique; --27: TrailS2
	reg_map(27) <= unique; --28: LeadPHASE
	reg_map(28) <= unique; --29: TrailPHASE
	reg_map(29) <= unique; --30: LeadWR_STRB
	reg_map(30) <= unique; --31: TrailWR_STRB
	reg_map(31) <= global; --32: TimGenReg
	reg_map(32) <= global; --33: PDDbias
	reg_map(33) <= global; --34: CMPbias
	reg_map(34) <= global; --35: PUDbias
	reg_map(35) <= global; --36: PUbias
	reg_map(36) <= global; --37: SBDbias
	reg_map(37) <= global; --38: Sbbias
	reg_map(38) <= global; --39: ISDbias
	reg_map(39) <= global; --40: ISEL
	reg_map(40) <= global; --41: VDDbias
	reg_map(41) <= unique; --42: Vdly
	reg_map(42) <= global; --43: VAPDbias
	reg_map(43) <= unique; --44: VadjP
	reg_map(44) <= global; --45: VANDbias
	reg_map(45) <= unique; --46: VadjN
	reg_map(46) <= global; --62: Start_WilkMon

	--Register increment
	process(CLK, CE, internal_INCREMENT_REGISTER) begin
		if (CE = '1' and internal_INCREMENT_REGISTER = '1') then
			if (rising_edge(CLK)) then
				if (internal_RESET_REGISTER = '1') then
					internal_REGISTER_COUNTER <= (others => '0');
				else
					internal_REGISTER_COUNTER <= internal_REGISTER_COUNTER + 1;
				end if;
			end if;
		end if;
	end process;
	--Map out what we actually update on each cycle
	--Usually this is just the counter value, but after registers 0-45
	--  we skip ahead to register 61 to start the Wilk monitor.
	process(internal_REGISTER_COUNTER) 
		constant reg61 : integer := 61;
	begin
		if (internal_REGISTER_COUNTER = 46) then
			internal_REG_ADDR <= std_logic_vector(to_unsigned(reg61,internal_REG_ADDR'length));
		else 
			internal_REG_ADDR <= std_logic_vector(internal_REGISTER_COUNTER);
		end if;
	end process;
	
	--Row/column counter increment
	process(CLK, CE, internal_INCREMENT_ROWCOL) begin
		if (CE = '1' and internal_INCREMENT_ROWCOL = '1') then
			if (rising_edge(CLK)) then
				if (internal_RESET_ROWCOL = '1') then
					internal_ROW_COL_COUNTER <= (others => '0');
				else
					internal_ROW_COL_COUNTER <= internal_ROW_COL_COUNTER + 1;
				end if;
			end if;
		end if;
	end process;
	--Grab the row and col
	process(internal_ROW_COL_COUNTER) begin
		internal_ROW <= to_integer(unsigned(internal_ROW_COL_COUNTER(1 downto 0)));
		internal_COL <= to_integer(unsigned(internal_ROW_COL_COUNTER(3 downto 2)));
	end process;

	--Bit counter increment
	process(CLK,CE,internal_INCREMENT_BIT) begin
		if (CE = '1' and internal_INCREMENT_BIT = '1') then
			if (rising_edge(CLK)) then
				if (internal_RESET_BIT_COUNTER = '1') then
					internal_BIT_COUNTER <= (others => '0');
				else
					internal_BIT_COUNTER <= internal_BIT_COUNTER + 1;
				end if;
			end if;
		end if;
	end process;

	--Generic counter for setting long PCLK, e.g.,
	process(CLK,CE,internal_INCREMENT_COUNTER) begin
		if (CE = '1' and internal_INCREMENT_COUNTER = '1') then
			if (rising_edge(CLK)) then
				if (internal_RESET_COUNTER = '1') then
					internal_GENERIC_COUNTER <= (others => '0');
				else
					internal_GENERIC_COUNTER <= internal_GENERIC_COUNTER + 1;
				end if;
			end if;
		end if;
	end process;	
	
	--Choose which register value to use
	--Numbers in the comments correspond to Gary's notation in the register map spreadsheet
	--Actual address choice is chosen by "internal_REG_ADDR" (see above)
	process(internal_ROW, internal_COL, internal_REG_ADDR, ASIC_TRIG_THRESH, internal_COL, internal_ROW,
	        ASIC_DAC_BUF_BIASES, ASIC_VBIAS, ASIC_VBIAS2, ASIC_REG_TRG, ASIC_WBIAS, ASIC_TRG_BIAS, 
	        ASIC_TRG_BIAS2, ASIC_TRGTHREF, ASIC_TIMING_SSP_LEADING, ASIC_TIMING_SSP_TRAILING, 
	        ASIC_TIMING_S1_LEADING, ASIC_TIMING_S1_TRAILING, ASIC_TIMING_S2_LEADING,
	        ASIC_TIMING_S2_TRAILING, ASIC_TIMING_PHASE_LEADING, ASIC_TIMING_PHASE_TRAILING, 
	        ASIC_TIMING_WR_STRB_LEADING, ASIC_TIMING_WR_STRB_TRAILING, ASIC_TIMING_GENERATOR_REG, 
	        ASIC_CMPBIAS, ASIC_PUBIAS, ASIC_SBBIAS, ASIC_DAC_BUF_BIAS_ISEL, ASIC_ISEL, 
	        ASIC_VDLY, ASIC_DAC_BUF_BIAS_VADJP, ASIC_VADJP, ASIC_DAC_BUF_BIAS_VADJN, ASIC_VADJN) begin
		case(to_integer(unsigned(internal_REG_ADDR))) is
			when  0 => internal_REG_VALUE_TO_LOAD <= ASIC_TRIG_THRESH(internal_COL)(internal_ROW)(0); -- 1: THR1
			when  1 => internal_REG_VALUE_TO_LOAD <= ASIC_TRIG_THRESH(internal_COL)(internal_ROW)(1); -- 2: THR2
			when  2 => internal_REG_VALUE_TO_LOAD <= ASIC_TRIG_THRESH(internal_COL)(internal_ROW)(2); -- 3: THR3
			when  3 => internal_REG_VALUE_TO_LOAD <= ASIC_TRIG_THRESH(internal_COL)(internal_ROW)(3); -- 4: THR4
			when  4 => internal_REG_VALUE_TO_LOAD <= ASIC_TRIG_THRESH(internal_COL)(internal_ROW)(4); -- 5: THR5
			when  5 => internal_REG_VALUE_TO_LOAD <= ASIC_TRIG_THRESH(internal_COL)(internal_ROW)(5); -- 6: THR6
			when  6 => internal_REG_VALUE_TO_LOAD <= ASIC_TRIG_THRESH(internal_COL)(internal_ROW)(6); -- 7: THR7
			when  7 => internal_REG_VALUE_TO_LOAD <= ASIC_TRIG_THRESH(internal_COL)(internal_ROW)(7); -- 8: THR8
			when  8 => internal_REG_VALUE_TO_LOAD <= ASIC_DAC_BUF_BIASES;                             -- 9: VBDBIAS
			when  9 => internal_REG_VALUE_TO_LOAD <= ASIC_VBIAS(internal_COL)(internal_ROW);          --10: VBIAS
			when 10 => internal_REG_VALUE_TO_LOAD <= ASIC_VBIAS2(internal_COL)(internal_ROW);         --11: VBIAS2
			when 11 => internal_REG_VALUE_TO_LOAD <= "0000" & ASIC_REG_TRG;                           --12: MiscReg (LSB: TRG_SIGN)
			when 12 => internal_REG_VALUE_TO_LOAD <= ASIC_DAC_BUF_BIASES;                             --13: WBDbias
			when 13 => internal_REG_VALUE_TO_LOAD <= ASIC_WBIAS(internal_COL)(internal_ROW);          --14: Wbias
			when 14 => internal_REG_VALUE_TO_LOAD <= ASIC_DAC_BUF_BIASES;                             --15: TCDbias
			when 15 => internal_REG_VALUE_TO_LOAD <= ASIC_TRG_BIAS;                                   --16: TRGbias
			when 16 => internal_REG_VALUE_TO_LOAD <= ASIC_DAC_BUF_BIASES;                             --17: THDbias
			when 17 => internal_REG_VALUE_TO_LOAD <= ASIC_DAC_BUF_BIASES;                             --18: Tbbias
			when 18 => internal_REG_VALUE_TO_LOAD <= ASIC_DAC_BUF_BIASES;                             --19: TRGDbias
			when 19 => internal_REG_VALUE_TO_LOAD <= ASIC_TRG_BIAS2;                                  --20: TRGbias2
			when 20 => internal_REG_VALUE_TO_LOAD <= ASIC_TRGTHREF;                                   --21: TRGthref
			when 21 => internal_REG_VALUE_TO_LOAD <= "0000" & ASIC_TIMING_SSP_LEADING(internal_COL)(internal_ROW);      --22: LeadSSPin
			when 22 => internal_REG_VALUE_TO_LOAD <= "0000" & ASIC_TIMING_SSP_TRAILING(internal_COL)(internal_ROW);     --23: TrailSSPin
			when 23 => internal_REG_VALUE_TO_LOAD <= "0000" & ASIC_TIMING_S1_LEADING(internal_COL)(internal_ROW);       --24: LeadS1
			when 24 => internal_REG_VALUE_TO_LOAD <= "0000" & ASIC_TIMING_S1_TRAILING(internal_COL)(internal_ROW);      --25: TrailS1
			when 25 => internal_REG_VALUE_TO_LOAD <= "0000" & ASIC_TIMING_S2_LEADING(internal_COL)(internal_ROW);       --26: LeadS2
			when 26 => internal_REG_VALUE_TO_LOAD <= "0000" & ASIC_TIMING_S2_TRAILING(internal_COL)(internal_ROW);      --27: TrailS2
			when 27 => internal_REG_VALUE_TO_LOAD <= "0000" & ASIC_TIMING_PHASE_LEADING(internal_COL)(internal_ROW);    --28: LeadPHASE
			when 28 => internal_REG_VALUE_TO_LOAD <= "0000" & ASIC_TIMING_PHASE_TRAILING(internal_COL)(internal_ROW);   --29: TrailPHASE
			when 29 => internal_REG_VALUE_TO_LOAD <= "0000" & ASIC_TIMING_WR_STRB_LEADING(internal_COL)(internal_ROW);  --30: LeadWR_STRB
			when 30 => internal_REG_VALUE_TO_LOAD <= "0000" & ASIC_TIMING_WR_STRB_TRAILING(internal_COL)(internal_ROW); --31: TrailWR_STRB
			when 31 => internal_REG_VALUE_TO_LOAD <= "0000" & ASIC_TIMING_GENERATOR_REG;              --32: TimGenReg
			when 32 => internal_REG_VALUE_TO_LOAD <= ASIC_DAC_BUF_BIASES;                             --33: PDDbias
			when 33 => internal_REG_VALUE_TO_LOAD <= ASIC_CMPBIAS;                                    --34: CMPbias
			when 34 => internal_REG_VALUE_TO_LOAD <= ASIC_DAC_BUF_BIASES;                             --35: PUDbias
			when 35 => internal_REG_VALUE_TO_LOAD <= ASIC_PUBIAS;                                     --36: PUbias
			when 36 => internal_REG_VALUE_TO_LOAD <= ASIC_DAC_BUF_BIASES;                             --37: SBDbias
			when 37 => internal_REG_VALUE_TO_LOAD <= ASIC_SBBIAS;                                     --38: Sbbias
			when 38 => internal_REG_VALUE_TO_LOAD <= ASIC_DAC_BUF_BIAS_ISEL;                          --39: ISDbias
			when 39 => internal_REG_VALUE_TO_LOAD <= ASIC_ISEL;                                       --40: ISEL
			when 40 => internal_REG_VALUE_TO_LOAD <= ASIC_DAC_BUF_BIASES;                             --41: VDDbias
			when 41 => internal_REG_VALUE_TO_LOAD <= ASIC_VDLY(internal_COL)(internal_ROW);           --42: Vdly
			when 42 => internal_REG_VALUE_TO_LOAD <= ASIC_DAC_BUF_BIAS_VADJP;                         --43: VAPDbias
			when 43 => internal_REG_VALUE_TO_LOAD <= ASIC_VADJP(internal_COL)(internal_ROW);          --44: VadjP
			when 44 => internal_REG_VALUE_TO_LOAD <= ASIC_DAC_BUF_BIAS_VADJN;                         --45: VANDbias
			when 45 => internal_REG_VALUE_TO_LOAD <= ASIC_VADJN(internal_COL)(internal_ROW);          --46: VadjN
			when 61 => internal_REG_VALUE_TO_LOAD <= (others => '1');                                 --62: Start_WilkMon
			when others => internal_REG_VALUE_TO_LOAD <= (others => '0');
		end case;
	end process;
	--Latch that choice 
	process(CLK,CE,internal_LATCH_REG_VALUE) begin
		if (CE = '1' and internal_LATCH_REG_VALUE = '1') then
			if (rising_edge(CLK)) then
				internal_LATCHED_REG_VALUE <= internal_REG_VALUE_TO_LOAD;
			end if;
		end if;
	end process;
	--Map out the full register
	internal_SERIAL_VALUE <= internal_REG_ADDR & internal_LATCHED_REG_VALUE;
	
	--Choose PCLK outputs based on which register we're reading
	process(internal_REGISTER_COUNTER, internal_PCLK_SINGLE, reg_map, internal_ROW, internal_COL) begin
		if(reg_map(to_integer(internal_REGISTER_COUNTER)) = global) then
			internal_PCLK(15 downto 0) <= (others => internal_PCLK_SINGLE);
		elsif(reg_map(to_integer(internal_REGISTER_COUNTER)) = unique) then
			internal_PCLK(15 downto 0) <= (others => '0');
			internal_PCLK(internal_COL*3 + internal_ROW) <= internal_PCLK_SINGLE;
		else
			internal_PCLK(15 downto 0) <= (others => '0');
		end if;
	end process;
	
end Behavioral;