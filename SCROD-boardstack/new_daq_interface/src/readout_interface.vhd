----------------------------------------------------------------------------------
-- Module Name:      readout_interface.vhd
-- Target Devices:   SCROD (Spartan-6 XC6SLX150T) & 
--                   Universal Eval Rev A/B (Spartan-3 XC3S400)
-- Tool versions:    Developed in ISE 13.2
-- Description:      
-- Revision history: 2012-10-25 Preliminary release by Kurtis Nishimura
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.readout_definitions.all;

entity readout_interface is
	Port ( 
		CLOCK                       : in  STD_LOGIC;
	
		OUTPUT_REGISTERS            : out GPR;
		INPUT_REGISTERS             : in  RR;

		--These connections allow another interface to connect to the
		--same FIFO as the command interpreter.
		WAVEFORM_FIFO_DATA_IN        : in  STD_LOGIC_VECTOR(31 downto 0);
		WAVEFORM_FIFO_EMPTY          : in  STD_LOGIC;
		WAVEFORM_FIFO_DATA_VALID     : in  STD_LOGIC;
		WAVEFORM_FIFO_READ_CLOCK     : out STD_LOGIC;
		WAVEFORM_FIFO_READ_ENABLE    : out STD_LOGIC;
		WAVEFORM_PACKET_BUILDER_BUSY : in  STD_LOGIC;
		WAVEFORM_PACKET_BUILDER_VETO : out STD_LOGIC;
	
		FIBER_0_RXP                 : in  STD_LOGIC;
		FIBER_0_RXN                 : in  STD_LOGIC;
		FIBER_1_RXP                 : in  STD_LOGIC;
		FIBER_1_RXN                 : in  STD_LOGIC;
		FIBER_0_TXP                 : out STD_LOGIC;
		FIBER_0_TXN                 : out STD_LOGIC;
		FIBER_1_TXP                 : out STD_LOGIC;
		FIBER_1_TXN                 : out STD_LOGIC;
		FIBER_REFCLKP               : in  STD_LOGIC;
		FIBER_REFCLKN               : in  STD_LOGIC;
		FIBER_0_DISABLE_TRANSCEIVER : out STD_LOGIC;
		FIBER_1_DISABLE_TRANSCEIVER : out STD_LOGIC;
		FIBER_0_LINK_UP             : out STD_LOGIC;
		FIBER_1_LINK_UP             : out STD_LOGIC;
		FIBER_0_LINK_ERR            : out STD_LOGIC;
		FIBER_1_LINK_ERR            : out STD_LOGIC;

		USB_IFCLK                   : in  STD_LOGIC;
		USB_CTL0                    : in  STD_LOGIC;
		USB_CTL1                    : in  STD_LOGIC;
		USB_CTL2                    : in  STD_LOGIC;
		USB_FDD                     : inout STD_LOGIC_VECTOR(15 downto 0);
		USB_PA0                     : out STD_LOGIC;
		USB_PA1                     : out STD_LOGIC;
		USB_PA2                     : out STD_LOGIC;
		USB_PA3                     : out STD_LOGIC;
		USB_PA4                     : out STD_LOGIC;
		USB_PA5                     : out STD_LOGIC;
		USB_PA6                     : out STD_LOGIC;
		USB_PA7                     : in  STD_LOGIC;
		USB_RDY0                    : out STD_LOGIC;
		USB_RDY1                    : out STD_LOGIC;
		USB_WAKEUP                  : in  STD_LOGIC;
		USB_CLKOUT		             : in  STD_LOGIC
	);
end readout_interface;

architecture Behavioral of readout_interface is

	signal internal_EVT_OUT_FIFO_DATA         : std_logic_vector(31 downto 0);
	signal internal_EVT_OUT_FIFO_WRITE_ENABLE : std_logic;
	signal internal_EVT_OUT_FIFO_WRITE_CLOCK  : std_logic;
	signal internal_EVT_OUT_FIFO_FULL         : std_logic;
	signal internal_TRG_OUT_FIFO_DATA         : std_logic_vector(31 downto 0);
	signal internal_TRG_OUT_FIFO_WRITE_ENABLE : std_logic;
	signal internal_TRG_OUT_FIFO_WRITE_CLOCK  : std_logic;
	signal internal_TRG_OUT_FIFO_FULL         : std_logic;
	signal internal_TRG_INP_FIFO_DATA         : std_logic_vector(31 downto 0);
	signal internal_TRG_INP_FIFO_READ_ENABLE  : std_logic;
	signal internal_TRG_INP_FIFO_READ_CLOCK   : std_logic;
	signal internal_TRG_INP_FIFO_EMPTY        : std_logic;
	signal internal_TRG_INP_FIFO_VALID        : std_logic;
	
	--Command interpreter (picoblaze) signals
	signal internal_PB_CLOCK          : std_logic;
	signal internal_PB_ADDRESS        : std_logic_vector(11 downto 0);
	signal internal_PB_INSTRUCTION    : std_logic_vector(17 downto 0);
	signal internal_PB_BRAM_ENABLE    : std_logic;
	signal internal_PB_IN_PORT        : std_logic_vector(7 downto 0);
	signal internal_PB_OUT_PORT       : std_logic_vector(7 downto 0);
	signal internal_PB_PORT_ID        : std_logic_vector(7 downto 0);
	signal internal_PB_WRITE_STROBE   : std_logic;
	signal internal_PB_K_WRITE_STROBE : std_logic;
	signal internal_PB_READ_STROBE    : std_logic;
	signal internal_PB_INTERRUPT      : std_logic;
	signal internal_PB_INTERRUPT_ACK  : std_logic;
	signal internal_PB_SLEEP          : std_logic;
	signal internal_PB_RESET          : std_logic;
	--Command interpreter reads from the input event fifo
	signal internal_EVT_INP_FIFO_DATA            : std_logic_vector(31 downto 0);
	signal internal_EVT_INP_FIFO_READ_ENABLE_pre : std_logic;
	signal internal_EVT_INP_FIFO_READ_ENABLE_reg : std_logic;
	signal internal_EVT_INP_FIFO_READ_ENABLE     : std_logic;
	signal internal_EVT_INP_FIFO_READ_CLOCK      : std_logic;
	signal internal_EVT_INP_FIFO_EMPTY           : std_logic;
	signal internal_EVT_INP_FIFO_VALID           : std_logic;
	--Command interpreter can write to the output event fifo
	signal internal_CI_DATA_TO_FIFO      : std_logic_vector(31 downto 0);
	signal internal_CI_FIFO_WRITE_ENABLE : std_logic;
	--Memory mapped address space (General Purpose Registers)
	signal internal_GPR_ADDRESS          : std_logic_vector(15 downto 0);
	signal internal_GPR_DATA_TO_WRITE    : std_logic_vector(15 downto 0);
	signal internal_GPR_WRITE_STROBE     : std_logic;
	signal internal_GPR                  : GPR;
	--Memory mapped address space (Read Only Registers)
	signal internal_RR_DATA_OUT          : std_logic_vector(15 downto 0);
	signal internal_RR                   : RR;
	--Interface to multiplex between waveform event data and command responses
	signal internal_WAVEFORM_DATA_INTERFACE    : std_logic_vector(7 downto 0);
	signal internal_SELECT_WAVEFORM_DATA       : std_logic;
	signal internal_WAVEFORM_FIFO_WRITE_ENABLE : std_logic;
	signal internal_WAVEFORM_FIFO_DATA_IN      : std_logic_vector(31 downto 0);
	
--	--Chipscope debugging crap
--	signal internal_CHIPSCOPE_CONTROL : std_logic_vector(35 downto 0);
--	signal internal_CHIPSCOPE_ILA     : std_logic_vector(127 downto 0);
--	signal internal_CHIPSCOPE_ILA_REG : std_logic_vector(127 downto 0);	
	
begin
	OUTPUT_REGISTERS <= internal_GPR;
	internal_RR <= INPUT_REGISTERS;

	--The TRG input/output fifos are a simple loopback right now
	internal_TRG_OUT_FIFO_DATA         <= internal_TRG_INP_FIFO_DATA;
	internal_TRG_OUT_FIFO_WRITE_ENABLE <= internal_TRG_INP_FIFO_VALID;
	internal_TRG_INP_FIFO_READ_ENABLE  <= (not(internal_TRG_INP_FIFO_EMPTY)) and (not(internal_TRG_OUT_FIFO_FULL));
	--Use the same clock for everything for now:
	internal_TRG_OUT_FIFO_WRITE_CLOCK <= CLOCK;
	internal_TRG_INP_FIFO_READ_CLOCK  <= CLOCK;
	
	--Multiplex signal to choose between waveform event data and command interpreter responses
	internal_SELECT_WAVEFORM_DATA <= internal_WAVEFORM_DATA_INTERFACE(0);
	WAVEFORM_PACKET_BUILDER_VETO  <= internal_WAVEFORM_DATA_INTERFACE(1);
	
	------Picoblaze command interpreter that reads the event/waveform input FIFO-----
	internal_PB_CLOCK <= CLOCK;
	internal_EVT_INP_FIFO_READ_CLOCK  <= internal_PB_CLOCK;
	---
	command_interpreter_processor : entity work.kcpsm6
	generic map(
		hwbuild                 => x"00",
		interrupt_vector        => x"3FF",
		scratch_pad_memory_size => 64
	) port map (
		address        => internal_PB_ADDRESS,
		instruction    => internal_PB_INSTRUCTION,
		bram_enable    => internal_PB_BRAM_ENABLE,
		port_id        => internal_PB_PORT_ID,
		write_strobe   => internal_PB_WRITE_STROBE,
		k_write_strobe => internal_PB_K_WRITE_STROBE,
		out_port       => internal_PB_OUT_PORT,
		read_strobe    => internal_PB_READ_STROBE,
		in_port        => internal_PB_IN_PORT,
		interrupt      => internal_PB_INTERRUPT,
		interrupt_ack  => internal_PB_INTERRUPT_ACK,
		sleep          => internal_PB_SLEEP,
		reset          => internal_PB_RESET,
		clk            => internal_PB_CLOCK
	);
	command_interpreter_rom : entity work.command_interpreter
	generic map(
		C_FAMILY             => "S6",
		C_RAM_SIZE_KWORDS    => 1,
		C_JTAG_LOADER_ENABLE => 0
	) port map (
		address     => internal_PB_ADDRESS,
		instruction => internal_PB_INSTRUCTION,
		enable      => internal_PB_BRAM_ENABLE,
		rdl         => internal_PB_RESET,
		clk         => internal_PB_CLOCK
	);
	
	-----Handle the connections of the input and output ports to the command processor----
	--First connect input FIFO 0 to the first four ports of the processor
	--This connection is made as in Figure 6-4 of UG129 (PicoBlaze user guide)
	--Asynchronous logic for the read enable
	process(internal_PB_PORT_ID) begin
		if (internal_PB_PORT_ID = x"01") then
			internal_EVT_INP_FIFO_READ_ENABLE_pre <= '1';
		else
			internal_EVT_INP_FIFO_READ_ENABLE_pre <= '0';
		end if;
	end process;
	--Register for the read enable
	process(internal_PB_CLOCK) begin
		if (rising_edge(internal_PB_CLOCK)) then
				internal_EVT_INP_FIFO_READ_ENABLE_reg <= 	internal_EVT_INP_FIFO_READ_ENABLE_pre;
		end if;
	end process;
	--Final read enable for the input fifo with the read strobe
	process(internal_EVT_INP_FIFO_READ_ENABLE_reg, internal_PB_READ_STROBE) begin
		internal_EVT_INP_FIFO_READ_ENABLE <= internal_EVT_INP_FIFO_READ_ENABLE_reg and internal_PB_READ_STROBE;
	end process;

	--Multiplex the inputs to the command interpreter (it can only read 8 bits at a time)
	process(internal_PB_PORT_ID, internal_EVT_INP_FIFO_EMPTY, internal_EVT_INP_FIFO_DATA, internal_RR_DATA_OUT, WAVEFORM_FIFO_EMPTY) begin
		case internal_PB_PORT_ID is
			--Addresses 0x00 through 0x04 are for reading the fifo:
			--0x00: Read whether the command fifo is empty
			--0x01: Asserts the read enable for the fifo
			--0x02: First 8 bits of the command input (also turns on read enable)
			--0x03: Second 8 bits
			--0x04: Third 8 bits
			--0x05: Last 8 bits
			when x"00" => internal_PB_IN_PORT <= "00000" & WAVEFORM_FIFO_EMPTY & WAVEFORM_PACKET_BUILDER_BUSY & internal_EVT_INP_FIFO_EMPTY;
			when x"01" => internal_PB_IN_PORT <= (others => '0'); --No input, but this asserts the read strobe
			when x"02" => internal_PB_IN_PORT <= internal_EVT_INP_FIFO_DATA( 7 downto  0);
			when x"03" => internal_PB_IN_PORT <= internal_EVT_INP_FIFO_DATA(15 downto  8);
			when x"04" => internal_PB_IN_PORT <= internal_EVT_INP_FIFO_DATA(23 downto 16);
			when x"05" => internal_PB_IN_PORT <= internal_EVT_INP_FIFO_DATA(31 downto 24);
			--Addresses 0x06-0x07 are the outputs of the general purpose registers
			when x"06" => internal_PB_IN_PORT <= internal_RR_DATA_OUT( 7 downto  0);
			when x"07" => internal_PB_IN_PORT <= internal_RR_DATA_OUT(15 downto  8);
			--Define further addresses here
			when others => internal_PB_IN_PORT <= "XXXXXXXX";
		end case;
	end process;
	--Multiplex the outputs from the command interpreter (8 bits wide)
	process(internal_PB_WRITE_STROBE, internal_PB_CLOCK, internal_PB_OUT_PORT) begin
		if (internal_PB_WRITE_STROBE = '1') then
			if (rising_edge(internal_PB_CLOCK)) then
				case internal_PB_PORT_ID is
					--Addresses 0x00-0x04 are for writing to the waveform/event output FIFO
					--0x04 pulses the write enable to the output fifo
					when x"00"  => internal_CI_DATA_TO_FIFO( 7 downto  0) <= internal_PB_OUT_PORT;
					when x"01"  => internal_CI_DATA_TO_FIFO(15 downto  8) <= internal_PB_OUT_PORT;
					when x"02"  => internal_CI_DATA_TO_FIFO(23 downto 16) <= internal_PB_OUT_PORT;
					when x"03"  => internal_CI_DATA_TO_FIFO(31 downto 24) <= internal_PB_OUT_PORT;
					when x"04"  => --Logic to generate the write strobe sits in another process
					--Addresses 0x05-0x06 are the general purpose register address
					when x"05"  => internal_GPR_ADDRESS( 7 downto  0) <= internal_PB_OUT_PORT;
					when x"06"  => internal_GPR_ADDRESS(15 downto  8) <= internal_PB_OUT_PORT;
					--Addresses 0x07-0x08 are the general purpose register data
					when x"07"  => internal_GPR_DATA_TO_WRITE( 7 downto  0) <= internal_PB_OUT_PORT;
					when x"08"  => internal_GPR_DATA_TO_WRITE(15 downto  8) <= internal_PB_OUT_PORT;
					--Address 0x09 will cause the general purpose write strobe to be asserted for one clock cycle
					when x"09"  => --The write strobe logic sits in another process
					--Address 0x0A is a veto to receiving event data
					when x"0A"  => internal_WAVEFORM_DATA_INTERFACE <= internal_PB_OUT_PORT;
					--Define further addresses here
					when others =>
				end case;
			end if;
		end if;
	end process;	
	--Generation of the write enable for the CI output FIFO
	process(internal_PB_WRITE_STROBE, internal_PB_PORT_ID)
		variable activate_write_strobe : std_logic;
	begin
		activate_write_strobe := '1' when internal_PB_PORT_ID = x"04" else
		                         '0';
		internal_CI_FIFO_WRITE_ENABLE <= internal_PB_WRITE_STROBE and activate_write_strobe;
	end process;
	--Generation of the GPR write strobe (Does this need to be registered?)
	process(internal_PB_WRITE_STROBE, internal_PB_PORT_ID) 
		variable activate_write_strobe : std_logic;
	begin
		activate_write_strobe := '1' when internal_PB_PORT_ID = x"09" else
		                         '0';
		internal_GPR_WRITE_STROBE <= internal_PB_WRITE_STROBE and activate_write_strobe;
	end process;
	--Control writing to the output FIFO.  This multiplexes the command interpreter 
	--responses with the waveform data, to allow these two sources to share a single
	--fiberoptic interface.  The PicoBlaze Command Intepreter decides when to switch
	--between these sources (see command_interpreter.psm for details).
	process(internal_SELECT_WAVEFORM_DATA, internal_CI_DATA_TO_FIFO, internal_WAVEFORM_FIFO_DATA_IN) begin
		case internal_SELECT_WAVEFORM_DATA is
			when '0' => internal_EVT_OUT_FIFO_DATA <= internal_CI_DATA_TO_FIFO;
			when '1' => internal_EVT_OUT_FIFO_DATA <= internal_WAVEFORM_FIFO_DATA_IN;
			when others => internal_EVT_OUT_FIFO_DATA <= (others => 'X');
		end case;
	end process;
	process(internal_SELECT_WAVEFORM_DATA, internal_CI_FIFO_WRITE_ENABLE, internal_WAVEFORM_FIFO_WRITE_ENABLE) begin
		case internal_SELECT_WAVEFORM_DATA is
			when '0' => internal_EVT_OUT_FIFO_WRITE_ENABLE <= internal_CI_FIFO_WRITE_ENABLE;
			when '1' => internal_EVT_OUT_FIFO_WRITE_ENABLE <= internal_WAVEFORM_FIFO_WRITE_ENABLE;
			when others => internal_EVT_OUT_FIFO_WRITE_ENABLE <= 'X';
		end case;
	end process;
	WAVEFORM_FIFO_READ_CLOCK <= internal_PB_CLOCK;
	WAVEFORM_FIFO_READ_ENABLE <= not(WAVEFORM_FIFO_EMPTY) and not(internal_EVT_OUT_FIFO_FULL) and internal_SELECT_WAVEFORM_DATA;
	internal_EVT_OUT_FIFO_WRITE_CLOCK  <= internal_PB_CLOCK;
	--Add one stage of pipeline delay between the waveform data and here.
	process(internal_PB_CLOCK) begin
		if (rising_edge(internal_PB_CLOCK)) then
			internal_WAVEFORM_FIFO_WRITE_ENABLE <= WAVEFORM_FIFO_DATA_VALID and internal_SELECT_WAVEFORM_DATA;
			internal_WAVEFORM_FIFO_DATA_IN      <= WAVEFORM_FIFO_DATA_IN;
		end if;
	end process;

	------General register logic (reading/writing) -----
	--Read from the read registers (asynchronous mux)
	process(internal_GPR_ADDRESS, internal_RR) 
		variable address : integer range 0 to N_RR-1;
	begin
		address := to_integer(unsigned(internal_GPR_ADDRESS));
		internal_RR_DATA_OUT <= (others => '0');
		for i in 0 to N_RR-1 loop
			if (i = address) then
				internal_RR_DATA_OUT <= internal_RR(address);
			end if;
		end loop;
	end process;
	--Write to the general purpose registers
	process(internal_PB_CLOCK, internal_GPR_ADDRESS, internal_GPR_WRITE_STROBE) begin
		for i in 0 to N_GPR-1 loop
			if ( i = to_integer(unsigned(internal_GPR_ADDRESS)) and internal_GPR_WRITE_STROBE = '1' ) then
				if (rising_edge(internal_PB_CLOCK)) then
					internal_GPR(i) <= internal_GPR_DATA_TO_WRITE;
				end if;
			end if;
		end loop;
	end process;

	------FIFO layer that connects to USB and/or Aurora------
	map_daq_fifo_layer : entity work.daq_fifo_layer
	generic map(
		INCLUDE_AURORA => 1,
		INCLUDE_USB    => 1
	)
	port map (
		SYSTEM_CLOCK        => CLOCK,
		
		--FIFO signals for the 4 FIFOs
		FIFO_OUT_0_DATA     => internal_EVT_OUT_FIFO_DATA,
		FIFO_OUT_0_WR_EN    => internal_EVT_OUT_FIFO_WRITE_ENABLE,
		FIFO_OUT_0_WR_CLK   => internal_EVT_OUT_FIFO_WRITE_CLOCK,
		FIFO_OUT_0_FULL     => internal_EVT_OUT_FIFO_FULL,
		FIFO_INP_0_DATA     => internal_EVT_INP_FIFO_DATA,
		FIFO_INP_0_RD_EN    => internal_EVT_INP_FIFO_READ_ENABLE,
		FIFO_INP_0_RD_CLK   => internal_EVT_INP_FIFO_READ_CLOCK,
		FIFO_INP_0_EMPTY    => internal_EVT_INP_FIFO_EMPTY,
		FIFO_INP_0_VALID    => internal_EVT_INP_FIFO_VALID,
		FIFO_OUT_1_DATA     => internal_TRG_OUT_FIFO_DATA,
		FIFO_OUT_1_WR_EN    => internal_TRG_OUT_FIFO_WRITE_ENABLE,
		FIFO_OUT_1_WR_CLK   => internal_TRG_OUT_FIFO_WRITE_CLOCK,
		FIFO_OUT_1_FULL     => internal_TRG_OUT_FIFO_FULL,
		FIFO_INP_1_DATA     => internal_TRG_INP_FIFO_DATA,
		FIFO_INP_1_RD_EN    => internal_TRG_INP_FIFO_READ_ENABLE,
		FIFO_INP_1_RD_CLK   => internal_TRG_INP_FIFO_READ_CLOCK,
		FIFO_INP_1_EMPTY    => internal_TRG_INP_FIFO_EMPTY,
		FIFO_INP_1_VALID    => internal_TRG_INP_FIFO_VALID,

		--Signals that need to go to the top level for USB
		USB_IFCLK           => USB_IFCLK,
		USB_CTL0            => USB_CTL0,
		USB_CTL1            => USB_CTL1,
		USB_CTL2            => USB_CTL2,
		USB_FDD             => USB_FDD,
		USB_PA0             => USB_PA0,
		USB_PA1             => USB_PA1,
		USB_PA2             => USB_PA2,
		USB_PA3             => USB_PA3,
		USB_PA4             => USB_PA4,
		USB_PA5             => USB_PA5,
		USB_PA6             => USB_PA6,
		USB_PA7             => USB_PA7,
		USB_RDY0            => USB_RDY0,
		USB_RDY1            => USB_RDY1,
		USB_WAKEUP          => USB_WAKEUP,
		USB_CLKOUT          => USB_CLKOUT,

		--Signals that need to go to the top level for fiberoptic
		FIBER_0_RXP                 => FIBER_0_RXP,
		FIBER_0_RXN                 => FIBER_0_RXN,
		FIBER_1_RXP                 => FIBER_1_RXP,
		FIBER_1_RXN                 => FIBER_1_RXN,
		FIBER_0_TXP                 => FIBER_0_TXP,
		FIBER_0_TXN                 => FIBER_0_TXN,
		FIBER_1_TXP                 => FIBER_1_TXP,
		FIBER_1_TXN                 => FIBER_1_TXN,
		FIBER_REFCLKP               => FIBER_REFCLKP,
		FIBER_REFCLKN               => FIBER_REFCLKN,
		FIBER_0_DISABLE_TRANSCEIVER => FIBER_0_DISABLE_TRANSCEIVER,
		FIBER_1_DISABLE_TRANSCEIVER => FIBER_1_DISABLE_TRANSCEIVER,
		FIBER_0_LINK_UP             => FIBER_0_LINK_UP,
		FIBER_1_LINK_UP             => FIBER_1_LINK_UP,
		FIBER_0_LINK_ERR            => FIBER_0_LINK_ERR,
		FIBER_1_LINK_ERR            => FIBER_1_LINK_ERR
	);
	
--	--DEBUGGING SHIT
--	map_ILA : entity work.s6_ila
--	port map (
--		CONTROL => internal_CHIPSCOPE_CONTROL,
--		CLK     => internal_PB_CLOCK,
--		TRIG0   => internal_CHIPSCOPE_ILA_REG
--	);
--	map_ICON : entity work.s6_icon
--	port map (
--		CONTROL0 => internal_CHIPSCOPE_CONTROL
--	);
--	
--	--Workaround for CS/picoblaze stupidness
--	process(internal_PB_CLOCK) begin
--		if (rising_edge(internal_PB_CLOCK)) then
--			internal_CHIPSCOPE_ILA_REG <= internal_CHIPSCOPE_ILA;
--		end if;
--	end process;
--	
--	internal_CHIPSCOPE_ILA(0) <= internal_SELECT_WAVEFORM_DATA;                     
--	internal_CHIPSCOPE_ILA(32 downto  1) <= internal_WAVEFORM_FIFO_DATA_IN;                     
--	internal_CHIPSCOPE_ILA(64 downto 33) <= internal_EVT_OUT_FIFO_DATA;                      
--	internal_CHIPSCOPE_ILA(65) <= internal_EVT_OUT_FIFO_WRITE_ENABLE;                
--	internal_CHIPSCOPE_ILA(66) <= internal_WAVEFORM_FIFO_WRITE_ENABLE;                      
--	internal_CHIPSCOPE_ILA(67) <= internal_CI_FIFO_WRITE_ENABLE;                   
--	internal_CHIPSCOPE_ILA(68) <= not(WAVEFORM_FIFO_EMPTY) and not(internal_EVT_OUT_FIFO_FULL) and internal_SELECT_WAVEFORM_DATA;
--	internal_CHIPSCOPE_ILA(69) <= WAVEFORM_FIFO_DATA_VALID;
	
end Behavioral;
