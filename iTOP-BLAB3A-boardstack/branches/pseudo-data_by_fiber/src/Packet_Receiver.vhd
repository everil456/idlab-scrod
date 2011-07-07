	-- 2011-06-07 kurtis, modified by mza
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Packet_Receiver is
	generic (
		EXPECTED_PACKET_SIZE : unsigned := x"8c"
	);
	port (
		-- User Interface
		RX_D            : in  std_logic_vector(31 downto 0); 
		RX_SRC_RDY_N    : in  std_logic;
		-- System Interface
		USER_CLK        : in  std_logic;   
		RESET           : in  std_logic;
		CHANNEL_UP      : in  std_logic;
		WRONG_PACKET_SIZE_COUNTER          :   out std_logic_vector(31 downto 0);
		WRONG_PACKET_TYPE_COUNTER          :   out std_logic_vector(31 downto 0);
		WRONG_PROTOCOL_FREEZE_DATE_COUNTER :   out std_logic_vector(31 downto 0);
		WRONG_CHECKSUM_COUNTER             :   out std_logic_vector(31 downto 0);
		WRONG_FOOTER_COUNTER               :   out std_logic_vector(31 downto 0);
		UNKNOWN_ERROR_COUNTER              :   out std_logic_vector(31 downto 0);
		MISSING_ACKNOWLEDGEMENT_COUNTER    :   out std_logic_vector(31 downto 0);
		resynchronizing_with_header        :   out std_logic;
		start_event_transfer               :   out std_logic;
		acknowledge_start_event_transfer   : in    std_logic;
		ERR_COUNT       : out std_logic_vector(7 downto 0)
);
end Packet_Receiver;

architecture Behavioral of Packet_Receiver is
	type RECEIVE_STATE_TYPE is (WAITING_FOR_HEADER, READING_PACKET_SIZE, READING_PACKET_TYPE, READING_PROTOCOL_DATE, READING_VALUES, READING_CHECKSUM, READING_FOOTER, SET_SEND_EVENT_FLAG, WAITING_FOR_ACKNOWLEDGE);
	signal internal_RX_D : std_logic_vector(31 downto 0);
	signal internal_RX_SRC_RDY_N : std_logic;
	signal internal_WRONG_PACKET_SIZE_COUNTER          : std_logic_vector(31 downto 0);
	signal internal_WRONG_PACKET_TYPE_COUNTER          : std_logic_vector(31 downto 0);
	signal internal_WRONG_PROTOCOL_FREEZE_DATE_COUNTER : std_logic_vector(31 downto 0);
	signal internal_WRONG_CHECKSUM_COUNTER             : std_logic_vector(31 downto 0);
	signal internal_WRONG_FOOTER_COUNTER               : std_logic_vector(31 downto 0);
	signal internal_UNKNOWN_ERROR_COUNTER              : std_logic_vector(31 downto 0);
	signal internal_MISSING_ACKNOWLEDGEMENT_COUNTER    : std_logic_vector(31 downto 0);
	signal internal_resynchronizing_with_header : std_logic;
	signal internal_start_event_transfer : std_logic;
	signal RECEIVE_STATE : RECEIVE_STATE_TYPE := WAITING_FOR_HEADER;
begin
	internal_RX_D         <= RX_D;
	internal_RX_SRC_RDY_N <= RX_SRC_RDY_N;
	WRONG_PACKET_TYPE_COUNTER          <= internal_WRONG_PACKET_TYPE_COUNTER;
	WRONG_PACKET_SIZE_COUNTER          <= internal_WRONG_PACKET_SIZE_COUNTER;
	WRONG_PROTOCOL_FREEZE_DATE_COUNTER <= internal_WRONG_PROTOCOL_FREEZE_DATE_COUNTER;
	WRONG_CHECKSUM_COUNTER             <= internal_WRONG_CHECKSUM_COUNTER;
	WRONG_FOOTER_COUNTER               <= internal_WRONG_FOOTER_COUNTER;
	UNKNOWN_ERROR_COUNTER              <= internal_UNKNOWN_ERROR_COUNTER;
	MISSING_ACKNOWLEDGEMENT_COUNTER <= internal_MISSING_ACKNOWLEDGEMENT_COUNTER;
	resynchronizing_with_header <= internal_resynchronizing_with_header;
	start_event_transfer <= internal_start_event_transfer;
	process (USER_CLK, RX_SRC_RDY_N)
		variable packet_size               : unsigned(15 downto 0);
		variable remaining_words_in_packet : unsigned(15 downto 0);
		variable protocol_date             : unsigned(31 downto 0);
--		variable values_read               : integer range 0 to 255 := 0; ???
		variable value                     : unsigned(31 downto 0);
		variable checksum                  : unsigned(31 downto 0);
		variable checksum_from_packet      : unsigned(31 downto 0);
		variable footer                    : unsigned(31 downto 0);
		variable timeout_waiting_for_acknowledge_counter  : unsigned(31 downto 0);
		constant NUMBER_OF_CYCLES_TO_WAIT_FOR_ACKNOWLEDGE : unsigned(31 downto 0) := x"00000100";
	begin
		if (RESET = '1' or CHANNEL_UP = '0') then
			internal_resynchronizing_with_header <= '0';
			internal_WRONG_PACKET_TYPE_COUNTER   <= (others => '0');
			internal_WRONG_PACKET_SIZE_COUNTER   <= (others => '0');
			internal_UNKNOWN_ERROR_COUNTER       <= (others => '0');
			internal_WRONG_CHECKSUM_COUNTER      <= (others => '0');
			internal_WRONG_FOOTER_COUNTER        <= (others => '0');
			internal_start_event_transfer        <= '0';
		elsif (rising_edge(USER_CLK) and internal_RX_SRC_RDY_N = '0') then
			case RECEIVE_STATE is
				when WAITING_FOR_HEADER =>
--					values_read := 0;
					if (internal_RX_D = x"00BE11E2") then
						checksum := x"00BE11E2";
						RECEIVE_STATE <= READING_PACKET_SIZE;
						internal_resynchronizing_with_header <= '0';
					else
						internal_resynchronizing_with_header <= '1';
					end if;
				when READING_PACKET_SIZE =>
					packet_size := unsigned(internal_RX_D(15 downto 0));
					checksum := checksum + packet_size;
					remaining_words_in_packet := packet_size - 2; -- 1 each for header & packet size
					if (packet_size < EXPECTED_PACKET_SIZE) then
						internal_WRONG_PACKET_SIZE_COUNTER <= std_logic_vector(unsigned(internal_WRONG_PACKET_SIZE_COUNTER) + 1);
						RECEIVE_STATE <= WAITING_FOR_HEADER;
					end if;
					RECEIVE_STATE <= READING_PACKET_TYPE;
				when READING_PACKET_TYPE =>
					checksum := checksum + unsigned(internal_RX_D);
					remaining_words_in_packet := remaining_words_in_packet - 1;
					if (internal_RX_D = x"B01DFACE") then -- command packet
						RECEIVE_STATE <= READING_PROTOCOL_DATE;
					else
						internal_WRONG_PACKET_TYPE_COUNTER <= std_logic_vector(unsigned(internal_WRONG_PACKET_TYPE_COUNTER) + 1);
						RECEIVE_STATE <= WAITING_FOR_HEADER;
					end if;
				when READING_PROTOCOL_DATE =>
					protocol_date := unsigned(internal_RX_D);
					checksum := checksum + protocol_date;
					remaining_words_in_packet := remaining_words_in_packet - 1;
					if (protocol_date = x"20110629") then
						RECEIVE_STATE <= READING_VALUES;
					else
						internal_WRONG_PROTOCOL_FREEZE_DATE_COUNTER <= std_logic_vector(unsigned(internal_WRONG_PROTOCOL_FREEZE_DATE_COUNTER) + 1);
						RECEIVE_STATE <= WAITING_FOR_HEADER;
					end if;
				when READING_VALUES =>
					value := unsigned(internal_RX_D);
					checksum := checksum + value;
					remaining_words_in_packet := remaining_words_in_packet - 1;
					-- ignore stream of values other than to perform checksum
					if (remaining_words_in_packet = 2) then -- 1 each for checksum and footer
						RECEIVE_STATE <= READING_CHECKSUM;
					end if;
				when READING_CHECKSUM =>
					-- this state does not change the running checksum "checksum" like all other states do
					checksum_from_packet := unsigned(internal_RX_D);
					remaining_words_in_packet := remaining_words_in_packet - 1;
					RECEIVE_STATE <= READING_FOOTER;
				when READING_FOOTER =>
					footer := unsigned(internal_RX_D);
					checksum := checksum + footer;
					remaining_words_in_packet := remaining_words_in_packet - 1;
--					if (remaining_words_in_packet = '0') then
--							internal_WRONG__COUNTER <= std_logic_vector(unsigned(internal_WRONG__COUNTER) + 1);
--					end if;
					if (footer = x"62504944") then
						if (checksum = checksum_from_packet) then
							RECEIVE_STATE <= SET_SEND_EVENT_FLAG;
						else
							internal_WRONG_CHECKSUM_COUNTER <= std_logic_vector(unsigned(internal_WRONG_CHECKSUM_COUNTER) + 1);
							RECEIVE_STATE <= WAITING_FOR_HEADER;
						end if;
					else
						internal_WRONG_FOOTER_COUNTER <= std_logic_vector(unsigned(internal_WRONG_FOOTER_COUNTER) + 1);
						RECEIVE_STATE <= WAITING_FOR_HEADER;
					end if;
				when SET_SEND_EVENT_FLAG =>
					internal_start_event_transfer <= '1';
					timeout_waiting_for_acknowledge_counter := NUMBER_OF_CYCLES_TO_WAIT_FOR_ACKNOWLEDGE;
					RECEIVE_STATE <= WAITING_FOR_ACKNOWLEDGE;
				when WAITING_FOR_ACKNOWLEDGE =>
					timeout_waiting_for_acknowledge_counter := timeout_waiting_for_acknowledge_counter - 1;
					if (acknowledge_start_event_transfer = '1') then
						internal_start_event_transfer <= '0';
						RECEIVE_STATE <= WAITING_FOR_HEADER;
					elsif (timeout_waiting_for_acknowledge_counter = 0) then
						internal_start_event_transfer <= '0';
						internal_MISSING_ACKNOWLEDGEMENT_COUNTER <= std_logic_vector(unsigned(internal_MISSING_ACKNOWLEDGEMENT_COUNTER) + 1);
						RECEIVE_STATE <= WAITING_FOR_HEADER;
					end if;
				when others =>
					internal_UNKNOWN_ERROR_COUNTER <= std_logic_vector(unsigned(internal_UNKNOWN_ERROR_COUNTER) + 1);
					RECEIVE_STATE <= WAITING_FOR_HEADER;
			end case;
		end if;
	end process;
end Behavioral;
