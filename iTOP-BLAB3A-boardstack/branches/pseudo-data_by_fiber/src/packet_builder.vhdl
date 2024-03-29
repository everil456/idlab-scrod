-- 2011-08-11 to 2011-08-13 mza
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Board_Stack_Definitions.ALL;
-----------------------------------------------------------------------------
entity packet_builder is
	generic (
		NUMBER_OF_INPUT_BLOCK_RAMS               : integer :=  2;
		WIDTH_OF_INPUT_ADDRESS_BUS               : integer := 13; -- (128 channels/qevent * 64 samples/window/channel * 4 windows = 32768 samples/qevent) / 2^NUMBER_OF_INPUT_BLOCK_RAMS
		WIDTH_OF_OUTPUT_ADDRESS_BUS              : integer := 17; -- 132 packets/qevent * 140 words/packet = 73920 words/qevent
--		WIDTH_OF_INPUT_ADDRESS_BUS               : integer :=  8; -- 64 samples/window * 4 windows = 256 samples
		WIDTH_OF_INPUT_DATA_BUS                  : integer := 16;
--		WIDTH_OF_OUTPUT_ADDRESS_BUS              : integer :=  9; -- 140 words/packet
		WIDTH_OF_OUTPUT_DATA_BUS                 : integer := 32;
		NUMBER_OF_WORDS_IN_A_PACKET              : integer := 140;
		NUMBER_OF_PACKETS_IN_AN_EVENT            : integer := 132;
		HEADER                                   : std_logic_vector(31 downto 0) := x"00be11e2";
		PACKET_SIZE_IN_WORDS                     : std_logic_vector(31 downto 0) := x"0000008c";
		CURRENT_PROTOCOL_FREEZE_DATE             : std_logic_vector(31 downto 0) := x"20110901";
		PACKET_TYPE_EVENT_HEADER                 : std_logic_vector(31 downto 0) := x"0000EADA";
		PACKET_TYPE_COFFEE                       : std_logic_vector(31 downto 0) := x"00c0ffee";
		PACKET_TYPE_TRIGGER_SCALER_DATA          : std_logic_vector(31 downto 0) := x"ce11b10c";
		PACKET_TYPE_HOUSEKEEPING                 : std_logic_vector(31 downto 0) := x"000ab0de";
		PACKET_RESERVED_WORD                     : std_logic_vector(31 downto 0) := x"99999999";
		PACKET_TYPE_EVENT_FOOTER                 : std_logic_vector(31 downto 0) := x"000F00DA";
		WIDTH_OF_EVENT_NUMBER                    : integer := 32;
		WIDTH_OF_PACKET_NUMBER                   : integer := 8;
		INPUT_BLOCK_RAM_PHASE_OFFSET             : integer := 1;
--		NUMBER_OF_WORDS_NEEDED_TO_PACK_8_SAMPLES : integer := 8;
		NUMBER_OF_WORDS_NEEDED_TO_PACK_8_SAMPLES : integer := 4;
--		NUMBER_OF_WORDS_NEEDED_TO_PACK_8_SAMPLES : integer := 3;
		NUMBER_OF_SAMPLES_IN_A_PACKET            : integer := 256;
		LOG_BASE_2_OF_NUMBER_OF_WAVEFORM_WINDOWS_IN_ASIC : integer := 9;
--		SCROD_REVISION                           : std_logic_vector(15 downto 0) := x"000a";
--		SCROD_ID                                 : std_logic_vector(15 downto 0) := x"0001";
		FOOTER                                   : std_logic_vector(31 downto 0) := x"62504944"
	);
	port (
		RESET                                              : in    std_logic;
		CLOCK                                              : in    std_logic;
		SCROD_REVISION													: in 	  std_logic_vector(15 downto 0);
		SCROD_ID															: in	  std_logic_vector(15 downto 0);
		INPUT_DATA_BUS                                     : in    std_logic_vector(WIDTH_OF_INPUT_DATA_BUS-1                          downto 0);
		INPUT_ADDRESS_BUS                                  : out   std_logic_vector(WIDTH_OF_INPUT_ADDRESS_BUS-1                       downto 0);
		INPUT_BLOCK_RAM_ADDRESS                            : out   std_logic_vector(NUMBER_OF_INPUT_BLOCK_RAMS-1                       downto 0);
		ASIC_START_WINDOW                                  : in    std_logic_vector(LOG_BASE_2_OF_NUMBER_OF_WAVEFORM_WINDOWS_IN_ASIC-1 downto 0);
		ASIC_END_WINDOW                                    : in    std_logic_vector(LOG_BASE_2_OF_NUMBER_OF_WAVEFORM_WINDOWS_IN_ASIC-1 downto 0);
		ADDRESS_OF_STARTING_WINDOW_IN_ASIC                 : in    std_logic_vector(LOG_BASE_2_OF_NUMBER_OF_WAVEFORM_WINDOWS_IN_ASIC-1 downto 0);
		OUTPUT_DATA_BUS                                    :   out std_logic_vector(WIDTH_OF_OUTPUT_DATA_BUS-1                         downto 0);
		OUTPUT_ADDRESS_BUS                                 :   out std_logic_vector(WIDTH_OF_OUTPUT_ADDRESS_BUS-1                      downto 0);
		OUTPUT_FIFO_WRITE_ENABLE                           :   out std_logic;
		START_BUILDING_A_PACKET                            : in    std_logic;
		PACKET_BUILDER_IS_GOING_TO_START_BUILDING_A_PACKET :   out std_logic;
		PACKET_BUILDER_IS_BUILDING_A_PACKET                :   out std_logic;
		PACKET_BUILDER_IS_DONE_BUILDING_A_PACKET           :   out std_logic;
		THIS_PACKET_IS_A_QUARTER_EVENT_HEADER              : in    std_logic;
		THIS_PACKET_IS_A_QUARTER_EVENT_FOOTER              : in    std_logic;
		THIS_PACKET_IS_QUARTER_EVENT_MEAT                  : in    std_logic;
		THIS_PACKET_IS_A_TRIGGER_SCALER_DATA_PACKET        : in    std_logic;
		THIS_PACKET_IS_A_HOUSEKEEPING_PACKET               : in    std_logic;
		EVENT_NUMBER                                       : in    std_logic_vector(WIDTH_OF_EVENT_NUMBER-1       downto 0);
		PACKET_NUMBER                                      : in    std_logic_vector(WIDTH_OF_PACKET_NUMBER-1      downto 0);
		INPUT_BASE_ADDRESS                                 : in    std_logic_vector(WIDTH_OF_INPUT_ADDRESS_BUS-1  downto 0);
		OUTPUT_BASE_ADDRESS                                : in    std_logic_vector(WIDTH_OF_OUTPUT_ADDRESS_BUS-1 downto 0);
		ASIC_SCALERS                                       : in    ASIC_Scalers_C_R_CH;
		ASIC_TRIGGER_STREAMS                               : in    ASIC_Trigger_Stream_C_R_CH;
		FEEDBACK_WILKINSON_COUNTER_C_R                     : in    Wilkinson_Rate_Counters_C_R;
		FEEDBACK_SAMPLING_RATE_COUNTER_C_R                 : in    Sampling_Rate_Counters_C_R;	
		TEMPERATURE_R1                                     : in    std_logic_vector(11 downto 0);
		SAMPLING_RATE_FEEDBACK_GOAL                        : in    std_logic_vector(31 downto 0);
		WILKINSON_RATE_FEEDBACK_GOAL                       : in    std_logic_vector(31 downto 0);     
		TRIGGER_WIDTH_FEEDBACK_GOAL                        : in    std_logic_vector(31 downto 0);     
		SAMPLING_RATE_FEEDBACK_ENABLE                      : in    std_logic_vector(15 downto 0);     
		WILKINSON_RATE_FEEDBACK_ENABLE                     : in    std_logic_vector(15 downto 0);     
		TRIGGER_WIDTH_FEEDBACK_ENABLE                      : in    std_logic_vector(15 downto 0);     
		DESIRED_DAC_SETTINGS                               : in    Board_Stack_Voltages;
		CURRENT_DAC_SETTINGS                               : in    Board_Stack_Voltages		
	);
end packet_builder;
-----------------------------------------------------------------------------
architecture packet_builder_architecture of packet_builder is
	signal internal_RESET                                              : std_logic;
	signal internal_CLOCK                                              : std_logic;
	signal internal_INPUT_DATA_BUS                                     : std_logic_vector(WIDTH_OF_INPUT_DATA_BUS-1     downto 0);
	signal internal_INPUT_ADDRESS_BUS                                  : std_logic_vector(WIDTH_OF_INPUT_ADDRESS_BUS-1  downto 0) := (others => '0');
	signal internal_INPUT_BLOCK_RAM_ADDRESS                            : std_logic_vector(NUMBER_OF_INPUT_BLOCK_RAMS-1  downto 0) := (others => '0');
	signal internal_OUTPUT_DATA_BUS                                    : std_logic_vector(WIDTH_OF_OUTPUT_DATA_BUS-1    downto 0) := (others => '0');
	signal internal_OUTPUT_ADDRESS_BUS                                 : std_logic_vector(WIDTH_OF_OUTPUT_ADDRESS_BUS-1 downto 0) := (others => '0');
	signal internal_OUTPUT_FIFO_WRITE_ENABLE                           : std_logic := '0';
	signal internal_START_BUILDING_A_PACKET                            : std_logic;
	signal internal_THIS_PACKET_IS_A_QUARTER_EVENT_HEADER              : std_logic;
	signal internal_THIS_PACKET_IS_A_QUARTER_EVENT_FOOTER              : std_logic;
	signal internal_THIS_PACKET_IS_QUARTER_EVENT_MEAT                  : std_logic;
	signal internal_THIS_PACKET_IS_A_TRIGGER_SCALER_DATA_PACKET			 : std_logic;
	signal internal_THIS_PACKET_IS_A_HOUSEKEEPING_PACKET               : std_logic;
	signal internal_PACKET_BUILDER_IS_GOING_TO_START_BUILDING_A_PACKET : std_logic := '0';
	signal internal_PACKET_BUILDER_IS_BUILDING_A_PACKET                : std_logic := '0';
	signal internal_PACKET_BUILDER_IS_DONE_BUILDING_A_PACKET           : std_logic := '0';
	signal internal_EVENT_NUMBER                                       : std_logic_vector(WIDTH_OF_EVENT_NUMBER-1       downto 0);
	signal internal_PACKET_NUMBER                                      : std_logic_vector(WIDTH_OF_PACKET_NUMBER-1      downto 0);
--	signal internal_INPUT_BASE_ADDRESS                                 : std_logic_vector(WIDTH_OF_INPUT_ADDRESS_BUS-1  downto 0);
--	signal internal_OUTPUT_BASE_ADDRESS                                : std_logic_vector(WIDTH_OF_OUTPUT_ADDRESS_BUS-1 downto 0);
	signal CHECKSUM                                                    : std_logic_vector(31 downto 0) := (others => '0');
	signal internal_ADDRESS_OF_STARTING_WINDOW_IN_ASIC                 : std_logic_vector(8 downto 0) := (others => '0');
	type packet_builder_state_type is (IDLE,
		ABOUT_TO_BUILD_A_PACKET, BUILD_THE_FIRST_PART_OF_A_PACKET, DONE_BUILDING_THE_FIRST_PART_OF_A_PACKET,
		ABOUT_TO_FETCH_SOME_INPUT_DATA, FETCH_SOME_INPUT_DATA, PACK_DATA, WRITE_SOME_OUTPUT_DATA, WRITE_AN_ORIGIN_WINDOW_WORD,
		WRITE_RESERVED_WORDS_UNTIL_LAST_PART_OF_PACKET, 
		GET_TRIGGER_STREAM_DATA, WRITE_TRIGGER_STREAM_DATA, GET_SCALER_DATA, WRITE_SCALER_DATA,
		GET_FEEDBACK_DATA, WRITE_FEEDBACK_DATA,
		GET_HOUSEKEEPING_DATA, WRITE_HOUSEKEEPING_DATA,
		WRITE_THE_LAST_PART_OF_A_PACKET, ALMOST_DONE_BUILDING_PACKET, DONE_BUILDING_PACKET);
	signal packet_builder_state : packet_builder_state_type := IDLE;
	signal ROW     : std_logic_vector(1 downto 0) := "00"; -- ASIC row # within board stack
	signal COL     : std_logic_vector(1 downto 0) := "00"; -- ASIC column # within board stack
	signal CHANNEL : std_logic_vector(2 downto 0) := "000"; -- channel # within ASIC
	signal WINDOW  : std_logic_vector(8 downto 0) := "000000000"; -- 64 sample waveform window within analog memory in ASIC
	signal origin_window : std_logic_vector(31 downto 0) := x"00000000";
	signal FLATTENED_BLOCK_RAM_ADDRESS_COUNTER : std_logic_vector(8 downto 0) := (others => '0');
	signal internal_ASIC_START_WINDOW : std_logic_vector(8 downto 0);
	signal internal_ASIC_END_WINDOW   : std_logic_vector(8 downto 0);
begin
	internal_CLOCK     <= CLOCK;
	internal_RESET     <= RESET;
	INPUT_ADDRESS_BUS       <= internal_INPUT_ADDRESS_BUS;
	INPUT_BLOCK_RAM_ADDRESS <= internal_INPUT_BLOCK_RAM_ADDRESS;
	OUTPUT_DATA_BUS    <= internal_OUTPUT_DATA_BUS;
	OUTPUT_ADDRESS_BUS <= internal_OUTPUT_ADDRESS_BUS;
	PACKET_BUILDER_IS_BUILDING_A_PACKET                <= internal_PACKET_BUILDER_IS_BUILDING_A_PACKET;
	PACKET_BUILDER_IS_DONE_BUILDING_A_PACKET           <= internal_PACKET_BUILDER_IS_DONE_BUILDING_A_PACKET;
	PACKET_BUILDER_IS_GOING_TO_START_BUILDING_A_PACKET <= internal_PACKET_BUILDER_IS_GOING_TO_START_BUILDING_A_PACKET;
	OUTPUT_FIFO_WRITE_ENABLE <= internal_OUTPUT_FIFO_WRITE_ENABLE;

	CHANNEL <= FLATTENED_BLOCK_RAM_ADDRESS_COUNTER(2 downto 0);
	ROW <= FLATTENED_BLOCK_RAM_ADDRESS_COUNTER(4 downto 3);
--	WINDOW <= std_logic_vector( unsigned(internal_ADDRESS_OF_STARTING_WINDOW_IN_ASIC) + unsigned(FLATTENED_BLOCK_RAM_ADDRESS_COUNTER(6 downto 5)) );
	COL <= FLATTENED_BLOCK_RAM_ADDRESS_COUNTER(8 downto 7);
	internal_INPUT_BLOCK_RAM_ADDRESS <= FLATTENED_BLOCK_RAM_ADDRESS_COUNTER(8 downto 7);	
	
	process (internal_CLOCK, internal_RESET)
		constant HEADER_INDEX                       : integer := 0;
		constant PACKET_SIZE_IN_WORDS_INDEX         : integer := 1;
		constant CURRENT_PROTOCOL_FREEZE_DATE_INDEX : integer := 2;
		constant PACKET_TYPE_INDEX                  : integer := 3;
		constant EVENT_NUMBER_INDEX                 : integer := 4;
		constant PACKET_NUMBER_INDEX                : integer := 5;
		constant START_OF_SAMPLE_DATA_INDEX         : integer := 6;
		constant END_OF_SAMPLE_DATA_INDEX           : integer := START_OF_SAMPLE_DATA_INDEX + 3 + NUMBER_OF_SAMPLES_IN_A_PACKET * NUMBER_OF_WORDS_NEEDED_TO_PACK_8_SAMPLES / 8;
--		constant START_OF_RESERVED_WORDS_INDEX      : integer := END_OF_SAMPLE_DATA_INDEX + 1;
--		constant END_OF_RESERVED_WORDS_INDEX        : integer := NUMBER_OF_WORDS_IN_A_PACKET - 4;
		constant SCROD_REV_AND_ID_INDEX             : integer := NUMBER_OF_WORDS_IN_A_PACKET - 3;
		constant CHECKSUM_INDEX                     : integer := NUMBER_OF_WORDS_IN_A_PACKET - 2;
		constant	FOOTER_INDEX                       : integer := NUMBER_OF_WORDS_IN_A_PACKET - 1;
		-----------------------------------------------------------------------------
		variable word_counter          : integer range 0 to NUMBER_OF_WORDS_IN_A_PACKET := 0;
		variable packet_sample_counter : integer range 0 to NUMBER_OF_SAMPLES_IN_A_PACKET := 0;
		variable eight_sample_counter  : integer range 0 to 10 := 0;
		type eight_samples_type is array(7 downto 0) of unsigned(11 downto 0);
		variable eight_samples        : eight_samples_type;
		variable window_sample_counter : integer range 0 to 256 := 0; -- # of samples in a window (64)
		variable output_word_counter : integer range 0 to 16 := 0;
		variable block_ram_phase_counter : integer range 0 to 10 := 0;
		variable stream_and_scaler_counter_flattened : unsigned(6 downto 0) := (others => '0');
		variable temporary_data_word : std_logic_vector(31 downto 0);
		-----------------------------------------------------------------------------
		variable current_window : unsigned(9 downto 0);
		variable overage        : unsigned(9 downto 0);
		variable start_window   : unsigned(9 downto 0);
		variable end_window     : unsigned(9 downto 0);
		-----------------------------------------------------------------------------
		variable m : integer range 0 to NUMBER_OF_WORDS_IN_A_PACKET := 0;
		variable should_increment_blockram_address : boolean := false;
	begin
		if falling_edge(internal_CLOCK) then
			internal_INPUT_DATA_BUS <= INPUT_DATA_BUS;
		end if;
		if (internal_RESET = '1') then
			packet_builder_state <= IDLE;
			internal_INPUT_ADDRESS_BUS       <= (others => '0');
			internal_OUTPUT_DATA_BUS    <= (others => '0');
			internal_OUTPUT_ADDRESS_BUS <= (others => '0');
			internal_PACKET_BUILDER_IS_GOING_TO_START_BUILDING_A_PACKET <= '0';
			internal_PACKET_BUILDER_IS_BUILDING_A_PACKET                <= '0';
			internal_PACKET_BUILDER_IS_DONE_BUILDING_A_PACKET           <= '0';
			word_counter := 0;
			packet_sample_counter := 0;
			eight_sample_counter := 0;
			stream_and_scaler_counter_flattened := (others => '0');
			internal_OUTPUT_FIFO_WRITE_ENABLE <= '0';
			FLATTENED_BLOCK_RAM_ADDRESS_COUNTER <= (others => '0');
		elsif rising_edge(internal_CLOCK) then
			internal_START_BUILDING_A_PACKET <= START_BUILDING_A_PACKET;
			case packet_builder_state is
				when IDLE =>
					internal_THIS_PACKET_IS_A_QUARTER_EVENT_HEADER <= THIS_PACKET_IS_A_QUARTER_EVENT_HEADER;
					internal_THIS_PACKET_IS_A_QUARTER_EVENT_FOOTER <= THIS_PACKET_IS_A_QUARTER_EVENT_FOOTER;
					internal_THIS_PACKET_IS_QUARTER_EVENT_MEAT     <= THIS_PACKET_IS_QUARTER_EVENT_MEAT;
					internal_THIS_PACKET_IS_A_TRIGGER_SCALER_DATA_PACKET <= THIS_PACKET_IS_A_TRIGGER_SCALER_DATA_PACKET;
					internal_THIS_PACKET_IS_A_HOUSEKEEPING_PACKET  <= THIS_PACKET_IS_A_HOUSEKEEPING_PACKET;
					internal_PACKET_BUILDER_IS_GOING_TO_START_BUILDING_A_PACKET <= '0';
					internal_PACKET_BUILDER_IS_BUILDING_A_PACKET                <= '0';
					internal_PACKET_BUILDER_IS_DONE_BUILDING_A_PACKET           <= '0';
					internal_OUTPUT_FIFO_WRITE_ENABLE <= '0';
					if (internal_START_BUILDING_A_PACKET = '1') then
						internal_ADDRESS_OF_STARTING_WINDOW_IN_ASIC <= ADDRESS_OF_STARTING_WINDOW_IN_ASIC;
						internal_ASIC_START_WINDOW <= ASIC_START_WINDOW;
						internal_ASIC_END_WINDOW   <= ASIC_END_WINDOW;
						internal_PACKET_BUILDER_IS_GOING_TO_START_BUILDING_A_PACKET <= '1';
						packet_builder_state <= ABOUT_TO_BUILD_A_PACKET;
					end if;
				when ABOUT_TO_BUILD_A_PACKET =>
					start_window := "0" & unsigned(internal_ASIC_START_WINDOW);
					end_window   := "0" & unsigned(internal_ASIC_END_WINDOW);
					packet_sample_counter := 0;
					word_counter := 0;
					internal_EVENT_NUMBER        <= EVENT_NUMBER;
					internal_PACKET_NUMBER       <= PACKET_NUMBER;
--					internal_INPUT_BASE_ADDRESS  <= INPUT_BASE_ADDRESS;
--					internal_OUTPUT_BASE_ADDRESS <= OUTPUT_BASE_ADDRESS;
--					internal_INPUT_ADDRESS_BUS  <= INPUT_BASE_ADDRESS;
--					internal_OUTPUT_ADDRESS_BUS <= OUTPUT_BASE_ADDRESS;
					internal_PACKET_BUILDER_IS_BUILDING_A_PACKET <= '1';
					packet_builder_state <= BUILD_THE_FIRST_PART_OF_A_PACKET;
				when BUILD_THE_FIRST_PART_OF_A_PACKET =>
					internal_OUTPUT_FIFO_WRITE_ENABLE <= '1';
					internal_PACKET_BUILDER_IS_GOING_TO_START_BUILDING_A_PACKET <= '0';
				-----------------------------------------------------------------------------
					if (word_counter = 0) then
					--For some reason the following line doesn't work after adding Board_Stack_Definitions
--						CHECKSUM <= std_logic_vector(unsigned(FOOTER) + unsigned(SCROD_REVISION & SCROD_ID)); -- there's nothing valid on the OUTPUT_DATA_BUS the first time through, so we might as well start with the words that come too late at the end...
					--The following is a crappy workaround for the above.
						temporary_data_word := SCROD_REVISION & SCROD_ID;
						CHECKSUM <= std_logic_vector(unsigned(FOOTER) + unsigned(temporary_data_word));
					else
						internal_OUTPUT_ADDRESS_BUS <= std_logic_vector(unsigned(internal_OUTPUT_ADDRESS_BUS) + 1);
						CHECKSUM <= std_logic_vector(unsigned(CHECKSUM) + unsigned(internal_OUTPUT_DATA_BUS)); -- grabs the previous word
					end if;
					if (word_counter = HEADER_INDEX) then
						internal_OUTPUT_DATA_BUS <= HEADER;
					elsif (word_counter = PACKET_SIZE_IN_WORDS_INDEX) then
						internal_OUTPUT_DATA_BUS <= PACKET_SIZE_IN_WORDS;
					elsif (word_counter = CURRENT_PROTOCOL_FREEZE_DATE_INDEX) then
						internal_OUTPUT_DATA_BUS <= CURRENT_PROTOCOL_FREEZE_DATE;
					-----------------------------------------------------------------------------
					elsif (word_counter = PACKET_TYPE_INDEX) then
						if (internal_THIS_PACKET_IS_A_QUARTER_EVENT_HEADER = '1') then
							internal_OUTPUT_DATA_BUS <= PACKET_TYPE_EVENT_HEADER;
							current_window(9 downto 0) := "0" & unsigned(internal_ADDRESS_OF_STARTING_WINDOW_IN_ASIC); --2011-11-12 Kurtis: Added to make sure we always start at the beginning
							FLATTENED_BLOCK_RAM_ADDRESS_COUNTER <= (others => '0');  --2011-11-12 Kurtis: Added to reset this once per event
						elsif (internal_THIS_PACKET_IS_QUARTER_EVENT_MEAT = '1') then
							internal_OUTPUT_DATA_BUS <= PACKET_TYPE_COFFEE;
						elsif (internal_THIS_PACKET_IS_A_QUARTER_EVENT_FOOTER = '1') then
							internal_OUTPUT_DATA_BUS <= PACKET_TYPE_EVENT_FOOTER;
						elsif (internal_THIS_PACKET_IS_A_TRIGGER_SCALER_DATA_PACKET = '1') then
							internal_OUTPUT_DATA_BUS <= PACKET_TYPE_TRIGGER_SCALER_DATA;
						elsif (internal_THIS_PACKET_IS_A_HOUSEKEEPING_PACKET = '1') then
							internal_OUTPUT_DATA_BUS <= PACKET_TYPE_HOUSEKEEPING;
						else
							--internal_OUTPUT_DATA_BUS <= (others => '0');
							internal_OUTPUT_DATA_BUS <= PACKET_RESERVED_WORD; -- should never get here
						end if;
					elsif (word_counter = EVENT_NUMBER_INDEX) then
						internal_OUTPUT_DATA_BUS <= internal_EVENT_NUMBER;
--						origin_window <= "00" & ROW & "00" & COL & internal_PACKET_NUMBER & "0" & CHANNEL & "000" & WINDOW; -- calculate before it's needed
						if (internal_THIS_PACKET_IS_QUARTER_EVENT_MEAT = '1') then
							window_sample_counter := 64;
							--The following line is a bit of a shitty workaround since we now have a different path through the state machine for C0FFEE packets vs. all other packets
							CHECKSUM <= std_logic_vector(unsigned(CHECKSUM) + unsigned(internal_EVENT_NUMBER) + unsigned(internal_OUTPUT_DATA_BUS));
							should_increment_blockram_address := false;
							packet_builder_state <= WRITE_AN_ORIGIN_WINDOW_WORD;
						end if;
					elsif (word_counter = PACKET_NUMBER_INDEX) then
						if (internal_THIS_PACKET_IS_A_QUARTER_EVENT_HEADER = '1') then
							internal_OUTPUT_DATA_BUS <= x"00" & internal_PACKET_NUMBER & x"0000";
						elsif (internal_THIS_PACKET_IS_A_QUARTER_EVENT_FOOTER = '1') then
							internal_OUTPUT_DATA_BUS <= x"00" & internal_PACKET_NUMBER & x"0000";
						elsif (internal_THIS_PACKET_IS_A_TRIGGER_SCALER_DATA_PACKET = '1') then
							internal_OUTPUT_DATA_BUS <= x"00" & internal_PACKET_NUMBER & x"0000";							
						elsif (internal_THIS_PACKET_IS_A_HOUSEKEEPING_PACKET = '1') then
							internal_OUTPUT_DATA_BUS <= x"00" & internal_PACKET_NUMBER & x"0000";
						else
							internal_OUTPUT_DATA_BUS <= origin_window;
						end if;
						packet_builder_state <= DONE_BUILDING_THE_FIRST_PART_OF_A_PACKET;
					end if;
					word_counter := word_counter + 1;
				-----------------------------------------------------------------------------
				when DONE_BUILDING_THE_FIRST_PART_OF_A_PACKET =>
					internal_OUTPUT_FIFO_WRITE_ENABLE <= '0';
					CHECKSUM <= std_logic_vector(unsigned(CHECKSUM) + unsigned(internal_OUTPUT_DATA_BUS));
					if (internal_THIS_PACKET_IS_A_QUARTER_EVENT_HEADER = '1') then
						internal_OUTPUT_DATA_BUS <= PACKET_RESERVED_WORD;
						packet_builder_state <= WRITE_RESERVED_WORDS_UNTIL_LAST_PART_OF_PACKET;
					elsif (internal_THIS_PACKET_IS_A_QUARTER_EVENT_FOOTER = '1') then
						packet_builder_state <= GET_FEEDBACK_DATA;
					elsif (internal_THIS_PACKET_IS_A_TRIGGER_SCALER_DATA_PACKET = '1') then
						stream_and_scaler_counter_flattened := (others => '0');
						packet_builder_state <= GET_TRIGGER_STREAM_DATA;
					elsif (internal_THIS_PACKET_IS_QUARTER_EVENT_MEAT = '1') then
						packet_builder_state <= ABOUT_TO_FETCH_SOME_INPUT_DATA;
					elsif (internal_THIS_PACKET_IS_A_HOUSEKEEPING_PACKET = '1') then
						packet_builder_state <= GET_HOUSEKEEPING_DATA;
					end if;
					window_sample_counter := 0;
				when ABOUT_TO_FETCH_SOME_INPUT_DATA =>
					internal_OUTPUT_FIFO_WRITE_ENABLE <= '0'; -- for when it comes here from WRITE_AN_ORIGIN_WINDOW_WORD
					eight_sample_counter := 0;
					block_ram_phase_counter := 0;
					packet_builder_state <= FETCH_SOME_INPUT_DATA;
				when FETCH_SOME_INPUT_DATA =>
					if (block_ram_phase_counter < INPUT_BLOCK_RAM_PHASE_OFFSET) then -- block_ram_phase_counter = 0
						internal_INPUT_ADDRESS_BUS <= std_logic_vector(unsigned(internal_INPUT_ADDRESS_BUS) + 1);
						block_ram_phase_counter := block_ram_phase_counter + 1;
					elsif (eight_sample_counter < 8) then -- eight_sample_counter = 0,1,2,3,4,5,6,7
						eight_samples(eight_sample_counter) := unsigned(internal_INPUT_DATA_BUS(11 downto 0));
						if (eight_sample_counter < 8 - INPUT_BLOCK_RAM_PHASE_OFFSET) then -- eight_sample_counter = 0,1,2,3,4
							internal_INPUT_ADDRESS_BUS <= std_logic_vector(unsigned(internal_INPUT_ADDRESS_BUS) + 1);
						end if;
						eight_sample_counter  := eight_sample_counter + 1;
						packet_sample_counter := packet_sample_counter + 1;
					else -- eight_sample_counter = 8
						output_word_counter := 0;
						window_sample_counter := window_sample_counter + 8;
						packet_builder_state <= PACK_DATA;
					end if;
				-----------------------------------------------------------------------------
				when PACK_DATA =>
					internal_OUTPUT_FIFO_WRITE_ENABLE <= '0'; -- for when it gets here from WRITE_SOME_OUTPUT_DATA
					if (NUMBER_OF_WORDS_NEEDED_TO_PACK_8_SAMPLES = 4) then
						if (output_word_counter = 0) then
							internal_OUTPUT_DATA_BUS <= x"0" & std_logic_vector(eight_samples(0)) & x"0" & std_logic_vector(eight_samples(1));
						elsif (output_word_counter = 1) then
							internal_OUTPUT_DATA_BUS <= x"0" & std_logic_vector(eight_samples(2)) & x"0" & std_logic_vector(eight_samples(3));
						elsif (output_word_counter = 2) then
							internal_OUTPUT_DATA_BUS <= x"0" & std_logic_vector(eight_samples(4)) & x"0" & std_logic_vector(eight_samples(5));
						elsif (output_word_counter = 3) then
							internal_OUTPUT_DATA_BUS <= x"0" & std_logic_vector(eight_samples(6)) & x"0" & std_logic_vector(eight_samples(7));
						end if;
					elsif (NUMBER_OF_WORDS_NEEDED_TO_PACK_8_SAMPLES = 3) then
						-- do some stuff...
					end if;
					if (output_word_counter < NUMBER_OF_WORDS_NEEDED_TO_PACK_8_SAMPLES) then -- output_word_counter = 0,1,2,3
						internal_OUTPUT_ADDRESS_BUS <= std_logic_vector(unsigned(internal_OUTPUT_ADDRESS_BUS) + 1);
						packet_builder_state <= WRITE_SOME_OUTPUT_DATA;
					else -- output_word_counter = 4
						if (packet_sample_counter < NUMBER_OF_SAMPLES_IN_A_PACKET) then
							if (window_sample_counter = 64) then
								FLATTENED_BLOCK_RAM_ADDRESS_COUNTER <= std_logic_vector( unsigned(FLATTENED_BLOCK_RAM_ADDRESS_COUNTER) + 1 );
								packet_builder_state <= WRITE_AN_ORIGIN_WINDOW_WORD;
							else
								packet_builder_state <= ABOUT_TO_FETCH_SOME_INPUT_DATA;
							end if;
						else
							FLATTENED_BLOCK_RAM_ADDRESS_COUNTER <= std_logic_vector( unsigned(FLATTENED_BLOCK_RAM_ADDRESS_COUNTER) + 1 );						
							packet_builder_state <= WRITE_THE_LAST_PART_OF_A_PACKET;
						end if;
					end if;
				when WRITE_SOME_OUTPUT_DATA =>
					internal_OUTPUT_FIFO_WRITE_ENABLE <= '1';
					CHECKSUM <= std_logic_vector(unsigned(CHECKSUM) + unsigned(internal_OUTPUT_DATA_BUS)); -- grabs the previous word
					output_word_counter := output_word_counter + 1;
					word_counter        := word_counter + 1;
					packet_builder_state <= PACK_DATA;
				when WRITE_AN_ORIGIN_WINDOW_WORD =>
					if (window_sample_counter = 64) then
						internal_OUTPUT_FIFO_WRITE_ENABLE <= '0';
						window_sample_counter := 65;
						current_window(9 downto 0) := "0" & unsigned(internal_ADDRESS_OF_STARTING_WINDOW_IN_ASIC);
					elsif (window_sample_counter = 65) then
						window_sample_counter := 66;
						current_window := current_window + unsigned(FLATTENED_BLOCK_RAM_ADDRESS_COUNTER(6 downto 5));
					elsif (window_sample_counter = 66) then
						window_sample_counter := 67;
						if (current_window > end_window) then
							overage := current_window - end_window - 1;
							current_window := start_window + overage; -- this won't work if we have fewer than 4 windows enabled
						end if;
					elsif (window_sample_counter = 67) then
						window_sample_counter := 68;
						WINDOW <= std_logic_vector(current_window(8 downto 0));
					elsif (window_sample_counter = 68) then
						window_sample_counter := 0;
						origin_window <= "00" & ROW & "00" & COL & internal_PACKET_NUMBER & "0" & CHANNEL & "000" & WINDOW;
					else
						internal_OUTPUT_DATA_BUS <= origin_window;
						if (should_increment_blockram_address) then
							internal_OUTPUT_ADDRESS_BUS <= std_logic_vector(unsigned(internal_OUTPUT_ADDRESS_BUS) + 1);
						else
							should_increment_blockram_address := true;
						end if;
						CHECKSUM <= std_logic_vector(unsigned(CHECKSUM) + unsigned(origin_window));
						word_counter := word_counter + 1;
						internal_OUTPUT_FIFO_WRITE_ENABLE <= '1';
						packet_builder_state <= ABOUT_TO_FETCH_SOME_INPUT_DATA;
					end if;
				-----------------------------------------------------------------------------
				when GET_TRIGGER_STREAM_DATA =>
						internal_OUTPUT_FIFO_WRITE_ENABLE <= '0';
						internal_OUTPUT_DATA_BUS <= ASIC_TRIGGER_STREAMS(to_integer(stream_and_scaler_counter_flattened(6 downto 5)))(to_integer(stream_and_scaler_counter_flattened(4 downto 3)))(to_integer(stream_and_scaler_counter_flattened(2 downto 0)) + 1) & ASIC_TRIGGER_STREAMS(to_integer(stream_and_scaler_counter_flattened(6 downto 5)))(to_integer(stream_and_scaler_counter_flattened(4 downto 3)))(to_integer(stream_and_scaler_counter_flattened(2 downto 0)));
						packet_builder_state <= WRITE_TRIGGER_STREAM_DATA;
				-----------------------------------------------------------------------------
				when WRITE_TRIGGER_STREAM_DATA =>
						internal_OUTPUT_FIFO_WRITE_ENABLE <= '1';
						word_counter        := word_counter + 1;
						CHECKSUM <= std_logic_vector(unsigned(CHECKSUM) + unsigned(internal_OUTPUT_DATA_BUS));
						if (stream_and_scaler_counter_flattened = 126) then
							stream_and_scaler_counter_flattened := (others => '0');
							packet_builder_state <= GET_SCALER_DATA;
						else
							stream_and_scaler_counter_flattened := stream_and_scaler_counter_flattened + 2;						
							packet_builder_state <= GET_TRIGGER_STREAM_DATA;							
						end if;
				-----------------------------------------------------------------------------
				when GET_SCALER_DATA =>
						internal_OUTPUT_FIFO_WRITE_ENABLE <= '0';
						internal_OUTPUT_DATA_BUS <= ASIC_SCALERS(to_integer(stream_and_scaler_counter_flattened(6 downto 5)))(to_integer(stream_and_scaler_counter_flattened(4 downto 3)))(to_integer(stream_and_scaler_counter_flattened(2 downto 0)) + 1) & ASIC_SCALERS(to_integer(stream_and_scaler_counter_flattened(6 downto 5)))(to_integer(stream_and_scaler_counter_flattened(4 downto 3)))(to_integer(stream_and_scaler_counter_flattened(2 downto 0)));
						packet_builder_state <= WRITE_SCALER_DATA;
				-----------------------------------------------------------------------------
				when WRITE_SCALER_DATA =>
						internal_OUTPUT_FIFO_WRITE_ENABLE <= '1';
						word_counter        := word_counter + 1;
						CHECKSUM <= std_logic_vector(unsigned(CHECKSUM) + unsigned(internal_OUTPUT_DATA_BUS));
						if (stream_and_scaler_counter_flattened = 126) then
							stream_and_scaler_counter_flattened := (others => '0');
							packet_builder_state <= WRITE_RESERVED_WORDS_UNTIL_LAST_PART_OF_PACKET;
						else
							stream_and_scaler_counter_flattened := stream_and_scaler_counter_flattened + 2;						
							packet_builder_state <= GET_SCALER_DATA;							
						end if;
				-----------------------------------------------------------------------------
				when GET_HOUSEKEEPING_DATA =>
						internal_OUTPUT_FIFO_WRITE_ENABLE <= '0';
						m := word_counter;
						if    (word_counter >=   6 and word_counter <=  13) then --TRGbias
--							internal_OUTPUT_DATA_BUS <= x"0" & DESIRED_DAC_SETTINGS( (m-6)/2 )( 4*((m-6) mod 2)+2 )(4) & 
--							                            x"0" & DESIRED_DAC_SETTINGS( (m-6)/2 )( 4*((m-6) mod 2)   )(4);
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS( (m-6)/2 )( 4*((m-6) mod 2)+2 )(4) & 
							                            x"0" & CURRENT_DAC_SETTINGS( (m-6)/2 )( 4*((m-6) mod 2)   )(4);

--						elsif (word_counter >=  14 and word_counter <=  45) then --TRGthresh
--							internal_OUTPUT_DATA_BUS <= x"0" & DESIRED_DAC_SETTINGS( (m-14)/8 )( ((m-14)/2*2) mod 8 )( ((m-14) mod 2)*6+1 ) & 
--							                            x"0" & DESIRED_DAC_SETTINGS( (m-14)/8 )( ((m-14)/2*2) mod 8 )( ((m-14) mod 2)*6   );
--							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS( (m-14)/8 )( ((m-14)/2*2) mod 8 )( ((m-14) mod 2)*6+1 ) & 
--							                            x"0" & CURRENT_DAC_SETTINGS( (m-14)/8 )( ((m-14)/2*2) mod 8 )( ((m-14) mod 2)*6   );
-- This is the brute force way to do this mapping, since we've had problems with the above.
						elsif (word_counter = 14) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(0)(0)(1) & x"0" & CURRENT_DAC_SETTINGS(0)(0)(0);
						elsif (word_counter = 15) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(0)(0)(7) & x"0" & CURRENT_DAC_SETTINGS(0)(0)(6);
						elsif (word_counter = 16) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(0)(2)(1) & x"0" & CURRENT_DAC_SETTINGS(0)(2)(0);
						elsif (word_counter = 17) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(0)(2)(7) & x"0" & CURRENT_DAC_SETTINGS(0)(2)(6);
						elsif (word_counter = 18) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(0)(4)(1) & x"0" & CURRENT_DAC_SETTINGS(0)(4)(0);
						elsif (word_counter = 19) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(0)(4)(7) & x"0" & CURRENT_DAC_SETTINGS(0)(4)(6);
						elsif (word_counter = 20) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(0)(6)(1) & x"0" & CURRENT_DAC_SETTINGS(0)(6)(0);
						elsif (word_counter = 21) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(0)(6)(7) & x"0" & CURRENT_DAC_SETTINGS(0)(6)(6);
						elsif (word_counter = 22) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(1)(0)(1) & x"0" & CURRENT_DAC_SETTINGS(1)(0)(0);
						elsif (word_counter = 23) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(1)(0)(7) & x"0" & CURRENT_DAC_SETTINGS(1)(0)(6);
						elsif (word_counter = 24) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(1)(2)(1) & x"0" & CURRENT_DAC_SETTINGS(1)(2)(0);
						elsif (word_counter = 25) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(1)(2)(7) & x"0" & CURRENT_DAC_SETTINGS(1)(2)(6);
						elsif (word_counter = 26) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(1)(4)(1) & x"0" & CURRENT_DAC_SETTINGS(1)(4)(0);
						elsif (word_counter = 27) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(1)(4)(7) & x"0" & CURRENT_DAC_SETTINGS(1)(4)(6);
						elsif (word_counter = 28) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(1)(6)(1) & x"0" & CURRENT_DAC_SETTINGS(1)(6)(0);
						elsif (word_counter = 29) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(1)(6)(7) & x"0" & CURRENT_DAC_SETTINGS(1)(6)(6);
						elsif (word_counter = 30) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(2)(0)(1) & x"0" & CURRENT_DAC_SETTINGS(2)(0)(0);
						elsif (word_counter = 31) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(2)(0)(7) & x"0" & CURRENT_DAC_SETTINGS(2)(0)(6);
						elsif (word_counter = 32) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(2)(2)(1) & x"0" & CURRENT_DAC_SETTINGS(2)(2)(0);
						elsif (word_counter = 33) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(2)(2)(7) & x"0" & CURRENT_DAC_SETTINGS(2)(2)(6);
						elsif (word_counter = 34) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(2)(4)(1) & x"0" & CURRENT_DAC_SETTINGS(2)(4)(0);
						elsif (word_counter = 35) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(2)(4)(7) & x"0" & CURRENT_DAC_SETTINGS(2)(4)(6);
						elsif (word_counter = 36) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(2)(6)(1) & x"0" & CURRENT_DAC_SETTINGS(2)(6)(0);
						elsif (word_counter = 37) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(2)(6)(7) & x"0" & CURRENT_DAC_SETTINGS(2)(6)(6);
						elsif (word_counter = 38) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(3)(0)(1) & x"0" & CURRENT_DAC_SETTINGS(3)(0)(0);
						elsif (word_counter = 39) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(3)(0)(7) & x"0" & CURRENT_DAC_SETTINGS(3)(0)(6);
						elsif (word_counter = 40) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(3)(2)(1) & x"0" & CURRENT_DAC_SETTINGS(3)(2)(0);
						elsif (word_counter = 41) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(3)(2)(7) & x"0" & CURRENT_DAC_SETTINGS(3)(2)(6);
						elsif (word_counter = 42) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(3)(4)(1) & x"0" & CURRENT_DAC_SETTINGS(3)(4)(0);
						elsif (word_counter = 43) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(3)(4)(7) & x"0" & CURRENT_DAC_SETTINGS(3)(4)(6);
						elsif (word_counter = 44) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(3)(6)(1) & x"0" & CURRENT_DAC_SETTINGS(3)(6)(0);
						elsif (word_counter = 45) then
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS(3)(6)(7) & x"0" & CURRENT_DAC_SETTINGS(3)(6)(6);

						elsif (word_counter >=  46 and word_counter <=  53) then --Wbias
--							internal_OUTPUT_DATA_BUS <= x"0" & DESIRED_DAC_SETTINGS( (m-46)/2 )( 4*((m-46) mod 2)+3 )(7) & 
--							                            x"0" & DESIRED_DAC_SETTINGS( (m-46)/2 )( 4*((m-46) mod 2)+1 )(7);
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS( (m-46)/2 )( 4*((m-46) mod 2)+3 )(7) & 
							                            x"0" & CURRENT_DAC_SETTINGS( (m-46)/2 )( 4*((m-46) mod 2)+1 )(7);																 
						elsif (word_counter >=  54 and word_counter <=  61) then --VadjP
--							internal_OUTPUT_DATA_BUS <= x"0" & DESIRED_DAC_SETTINGS( (m-54)/2 )( 4*((m-54) mod 2)+2 )(2) & 
--							                            x"0" & DESIRED_DAC_SETTINGS( (m-54)/2 )( 4*((m-54) mod 2)   )(2);
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS( (m-54)/2 )( 4*((m-54) mod 2)+2 )(2) & 
							                            x"0" & CURRENT_DAC_SETTINGS( (m-54)/2 )( 4*((m-54) mod 2)   )(2);																 
						elsif (word_counter >=  62 and word_counter <=  69) then	--VadjN					
--							internal_OUTPUT_DATA_BUS <= x"0" & DESIRED_DAC_SETTINGS( (m-62)/2 )( 4*((m-62) mod 2)+2 )(3) & 
--							                            x"0" & DESIRED_DAC_SETTINGS( (m-62)/2 )( 4*((m-62) mod 2)   )(3);
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS( (m-62)/2 )( 4*((m-62) mod 2)+2 )(3) & 
							                            x"0" & CURRENT_DAC_SETTINGS( (m-62)/2 )( 4*((m-62) mod 2)   )(3);																 
						elsif (word_counter >=  70 and word_counter <=  77) then	--Vbias
--							internal_OUTPUT_DATA_BUS <= x"0" & DESIRED_DAC_SETTINGS( (m-70)/2 )( 4*((m-70) mod 2)+2 )(5) & 
--							                            x"0" & DESIRED_DAC_SETTINGS( (m-70)/2 )( 4*((m-70) mod 2)   )(5);
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS( (m-70)/2 )( 4*((m-70) mod 2)+2 )(5) & 
							                            x"0" & CURRENT_DAC_SETTINGS( (m-70)/2 )( 4*((m-70) mod 2)   )(5);																 
						elsif (word_counter >=  78 and word_counter <=  85) then --SBbias
--							internal_OUTPUT_DATA_BUS <= x"0" & DESIRED_DAC_SETTINGS( (m-78)/2 )( 4*((m-78) mod 2)+3 )(2) & 
--							                            x"0" & DESIRED_DAC_SETTINGS( (m-78)/2 )( 4*((m-78) mod 2)+1 )(2);
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS( (m-78)/2 )( 4*((m-78) mod 2)+3 )(2) & 
							                            x"0" & CURRENT_DAC_SETTINGS( (m-78)/2 )( 4*((m-78) mod 2)+1 )(2);
						elsif (word_counter >=  86 and word_counter <=  93) then --Isel
--							internal_OUTPUT_DATA_BUS <= x"0" & DESIRED_DAC_SETTINGS( (m-86)/2 )( 4*((m-86) mod 2)+3 )(1) & 
--							                            x"0" & DESIRED_DAC_SETTINGS( (m-86)/2 )( 4*((m-86) mod 2)+1 )(1);
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS( (m-86)/2 )( 4*((m-86) mod 2)+2 )(5) & 
							                            x"0" & CURRENT_DAC_SETTINGS( (m-86)/2 )( 4*((m-86) mod 2)   )(5);
						elsif (word_counter >=  94 and word_counter <= 101) then --Vdly
--							internal_OUTPUT_DATA_BUS <= x"0" & DESIRED_DAC_SETTINGS( (m-94)/2 )( 4*((m-94) mod 2)+3 )(4) & 
--							                            x"0" & DESIRED_DAC_SETTINGS( (m-94)/2 )( 4*((m-94) mod 2)+1 )(4);						
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS( (m-94)/2 )( 4*((m-94) mod 2)+3 )(4) & 
							                            x"0" & CURRENT_DAC_SETTINGS( (m-94)/2 )( 4*((m-94) mod 2)+1 )(4);						
						elsif (word_counter >= 102 and word_counter <= 109) then --CMPbias
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS( (m-102)/2 )( 4*((m-102) mod 2)+3 )(5) & 
							                            x"0" & CURRENT_DAC_SETTINGS( (m-102)/2 )( 4*((m-102) mod 2)+1 )(5);
--							internal_OUTPUT_DATA_BUS <= x"0" & DESIRED_DAC_SETTINGS( (m-102)/2 )( 4*((m-102) mod 2)+3 )(5) & 
--							                            x"0" & DESIRED_DAC_SETTINGS( (m-102)/2 )( 4*((m-102) mod 2)+1 )(5);																 
						elsif (word_counter >= 110 and word_counter <= 117) then --PUbias
--							internal_OUTPUT_DATA_BUS <= x"0" & DESIRED_DAC_SETTINGS( (m-110)/2 )( 4*((m-110) mod 2)+3 )(3) & 
--							                            x"0" & DESIRED_DAC_SETTINGS( (m-110)/2 )( 4*((m-110) mod 2)+1 )(3);
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS( (m-110)/2 )( 4*((m-110) mod 2)+3 )(3) & 
							                            x"0" & CURRENT_DAC_SETTINGS( (m-110)/2 )( 4*((m-110) mod 2)+1 )(3);																 
						elsif (word_counter >= 118 and word_counter <= 125) then	--TRGthreshref
--							internal_OUTPUT_DATA_BUS <= x"0" & DESIRED_DAC_SETTINGS( (m-118)/2 )( 4*((m-118) mod 2)+3 )(0) & 
--							                            x"0" & DESIRED_DAC_SETTINGS( (m-118)/2 )( 4*((m-118) mod 2)+1 )(0);
							internal_OUTPUT_DATA_BUS <= x"0" & CURRENT_DAC_SETTINGS( (m-118)/2 )( 4*((m-118) mod 2)+3 )(0) & 
							                            x"0" & CURRENT_DAC_SETTINGS( (m-118)/2 )( 4*((m-118) mod 2)+1 )(0);
						elsif (word_counter  = 126) then
							internal_OUTPUT_DATA_BUS <= x"0000" & x"0" & TEMPERATURE_R1;
						else
							internal_OUTPUT_DATA_BUS <= PACKET_RESERVED_WORD;
						end if;
						packet_builder_state <= WRITE_HOUSEKEEPING_DATA;
				-----------------------------------------------------------------------------
				when WRITE_HOUSEKEEPING_DATA =>
						internal_OUTPUT_FIFO_WRITE_ENABLE <= '1';
						word_counter        := word_counter + 1;
						CHECKSUM <= std_logic_vector(unsigned(CHECKSUM) + unsigned(internal_OUTPUT_DATA_BUS));
						if (word_counter = 127) then
							packet_builder_state <= WRITE_RESERVED_WORDS_UNTIL_LAST_PART_OF_PACKET;
						else
							packet_builder_state <= GET_HOUSEKEEPING_DATA;
						end if;
				-----------------------------------------------------------------------------
				when GET_FEEDBACK_DATA => 
						internal_OUTPUT_FIFO_WRITE_ENABLE <= '0';
						if (word_counter = 6) then
							internal_OUTPUT_DATA_BUS <= x"0000" & WILKINSON_RATE_FEEDBACK_ENABLE;
						elsif (word_counter >= 7 and word_counter <= 22) then
							internal_OUTPUT_DATA_BUS <= x"0000" & FEEDBACK_WILKINSON_COUNTER_C_R( (word_counter - 7) / 4 )( (word_counter - 7) mod 4 );
						elsif (word_counter = 23) then
							internal_OUTPUT_DATA_BUS <= x"0000" & SAMPLING_RATE_FEEDBACK_ENABLE;
						elsif (word_counter >= 24 and word_counter <= 39) then
							internal_OUTPUT_DATA_BUS <= x"0000" & FEEDBACK_SAMPLING_RATE_COUNTER_C_R( (word_counter - 25) / 4 )( (word_counter - 25) mod 4 );
						else
							internal_OUTPUT_DATA_BUS <= PACKET_RESERVED_WORD;
						end if;
						packet_builder_state <= WRITE_FEEDBACK_DATA;
				when WRITE_FEEDBACK_DATA =>
						internal_OUTPUT_FIFO_WRITE_ENABLE <= '1';
						word_counter := word_counter + 1;
						CHECKSUM <= std_logic_vector(unsigned(CHECKSUM) + unsigned(internal_OUTPUT_DATA_BUS));
						if (word_counter = 41) then
							packet_builder_state <= WRITE_RESERVED_WORDS_UNTIL_LAST_PART_OF_PACKET;
						else
							packet_builder_state <= GET_FEEDBACK_DATA;
						end if;
				-----------------------------------------------------------------------------
				when WRITE_RESERVED_WORDS_UNTIL_LAST_PART_OF_PACKET =>
					internal_OUTPUT_DATA_BUS <= PACKET_RESERVED_WORD;
					internal_OUTPUT_FIFO_WRITE_ENABLE <= '1';
					CHECKSUM <= std_logic_vector(unsigned(CHECKSUM) + unsigned(PACKET_RESERVED_WORD));
					if (word_counter <= FOOTER_INDEX) then
						internal_OUTPUT_ADDRESS_BUS <= std_logic_vector(unsigned(internal_OUTPUT_ADDRESS_BUS) + 1);
					end if;
					if (word_counter = SCROD_REV_AND_ID_INDEX - 1) then
						packet_builder_state <= WRITE_THE_LAST_PART_OF_A_PACKET;
					end if;
					word_counter := word_counter + 1;
				-----------------------------------------------------------------------------
				when WRITE_THE_LAST_PART_OF_A_PACKET => -- word_counter = 137, 138, 139, 140
					internal_OUTPUT_FIFO_WRITE_ENABLE <= '1';
					if (word_counter <= FOOTER_INDEX) then
						internal_OUTPUT_ADDRESS_BUS <= std_logic_vector(unsigned(internal_OUTPUT_ADDRESS_BUS) + 1);
					end if;
					if (word_counter = SCROD_REV_AND_ID_INDEX) then
						internal_OUTPUT_DATA_BUS <= SCROD_REVISION & SCROD_ID;
					elsif (word_counter = CHECKSUM_INDEX) then
						internal_OUTPUT_DATA_BUS <= CHECKSUM;
					elsif (word_counter = FOOTER_INDEX) then
						internal_OUTPUT_DATA_BUS <= FOOTER;
					elsif (word_counter > FOOTER_INDEX) then
						internal_PACKET_BUILDER_IS_DONE_BUILDING_A_PACKET <= '1';
						internal_OUTPUT_FIFO_WRITE_ENABLE <= '0';
						packet_builder_state <= ALMOST_DONE_BUILDING_PACKET;
					end if;
					word_counter := word_counter + 1;
				-----------------------------------------------------------------------------
				when ALMOST_DONE_BUILDING_PACKET =>
					internal_PACKET_BUILDER_IS_BUILDING_A_PACKET <= '0';
					packet_builder_state <= DONE_BUILDING_PACKET;
				when DONE_BUILDING_PACKET =>
					internal_PACKET_BUILDER_IS_DONE_BUILDING_A_PACKET <= '0';
					packet_builder_state <= IDLE;
				when others =>
					packet_builder_state <= IDLE;
			end case;
		end if;
	end process;
end architecture packet_builder_architecture;
-----------------------------------------------------------------------------
-- internal_INPUT_ADDRESS_BUS <= std_logic_vector(to_unsigned(word_counter, 15) + 1); -- an example of how to add to a std_logic_vector
