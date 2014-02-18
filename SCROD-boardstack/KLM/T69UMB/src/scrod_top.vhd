----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:20:38 10/25/2012 
-- Design Name: 
-- Module Name:    scrod_top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.readout_definitions.all;
--use work.asic_definitions_irs2_carrier_revA.all;
--use work.CarrierRevA_DAC_definitions.all;

entity scrod_top is
	Port(
		BOARD_CLOCKP                : in  STD_LOGIC;
		BOARD_CLOCKN                : in  STD_LOGIC;
		LEDS                        : out STD_LOGIC_VECTOR(15 downto 0);
		------------------FTSW pins------------------
		RJ45_ACK_P                  : out std_logic;
		RJ45_ACK_N                  : out std_logic;			  
		RJ45_TRG_P                  : in std_logic;
		RJ45_TRG_N                  : in std_logic;			  			  
		RJ45_RSV_P                  : in std_logic;
		RJ45_RSV_N                  : in std_logic;
		RJ45_CLK_P                  : in std_logic;
		RJ45_CLK_N                  : in std_logic;
		---------Jumper for choosing FTSW clock------
		MONITOR_INPUT               : in  std_logic_vector(0 downto 0);
		
		----------------------------------------------
		------------Fiberoptic Pins-------------------
		----------------------------------------------
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
		---------------------------------------------
		------------------USB pins-------------------
		---------------------------------------------
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
		USB_CLKOUT		             : in  STD_LOGIC;
		
		--MB Specific Signals
		EX_TRIGGER						 : out STD_LOGIC;
		
		--Global Bus Signals
		
		--ASIC related
		
		--BUS A Specific Signals
		BUSA_REGCLR						 : out STD_LOGIC;
		BUSA_SCLK						 : out STD_LOGIC;
		BUSA_WR_ADDRCLR				 : out STD_LOGIC;
		BUSA_RD_ENA						 : out STD_LOGIC;
		BUSA_RD_ROWSEL_S				 : out STD_LOGIC_VECTOR(2 downto 0);
		BUSA_RD_COLSEL_S				 : out STD_LOGIC_VECTOR(5 downto 0);
		BUSA_CLR							 : out STD_LOGIC;
		BUSA_START						 : out STD_LOGIC;
		BUSA_RAMP						 : out STD_LOGIC;
		BUSA_SAMPLESEL_S				 : out STD_LOGIC_VECTOR(4 downto 0);
		BUSA_SR_CLEAR					 : out STD_LOGIC;
		BUSA_SR_SEL						 : out STD_LOGIC;
		BUSA_DO							 : in STD_LOGIC_VECTOR(15 downto 0);
		
		--Bus B Specific Signals
		BUSB_REGCLR						 : out STD_LOGIC;
		BUSB_SCLK						 : out STD_LOGIC;
		BUSB_WR_ADDRCLR				 : out STD_LOGIC;
		BUSB_RD_ENA						 : out STD_LOGIC;
		BUSB_RD_ROWSEL_S				 : out STD_LOGIC_VECTOR(2 downto 0);
		BUSB_RD_COLSEL_S				 : out STD_LOGIC_VECTOR(5 downto 0);
		BUSB_CLR							 : out STD_LOGIC;
		BUSB_START						 : out STD_LOGIC;
		BUSB_RAMP						 : out STD_LOGIC;
		BUSB_SAMPLESEL_S				 : out STD_LOGIC_VECTOR(4 downto 0);
		BUSB_SR_CLEAR					 : out STD_LOGIC;
		BUSB_SR_SEL						 : out STD_LOGIC;
		BUSB_DO							 : in STD_LOGIC_VECTOR(15 downto 0);
		
		--ASIC DAC Update Signals
		SIN								 : out STD_LOGIC_VECTOR(9 downto 0);
		PCLK								 : out STD_LOGIC_VECTOR(9 downto 0);
		--SHOUT						 	    : in STD_LOGIC_VECTOR(9 downto 0)
		
		--Sampling Signals
		SSTIN								 : out STD_LOGIC;
		SSPIN								 : out STD_LOGIC;
		WR_STRB 							 : out STD_LOGIC;
		WR_ADVCLK 						 : out STD_LOGIC;
		WR_ENA 						 	 : out STD_LOGIC;
		
		--Digitization Signals

		-- HV DAC
		BUSA_SCK_DAC		          : out STD_LOGIC;
		BUSA_DIN_DAC		          : out STD_LOGIC;

		BUSB_SCK_DAC		          : out STD_LOGIC;
		BUSB_DIN_DAC		          : out STD_LOGIC;
		TDC_CS_DAC                  : out STD_LOGIC_VECTOR(9 downto 0);
		HV_DISABLE                  : out STD_LOGIC;
		TDC_AMUX_S                  : out STD_LOGIC_VECTOR(3 downto 0);
		TOP_AMUX_S                  : out STD_LOGIC_VECTOR(3 downto 0);
		
		--Serial Readout Signals
		SR_CLOCK							 : out STD_LOGIC;
		SAMPLESEL_ANY 					 : out STD_LOGIC;
		TDC1_TRG_16						 : in STD_LOGIC;
		TDC1_TRG							 : in STD_LOGIC_VECTOR(3 downto 0)
	);
end scrod_top;

architecture Behavioral of scrod_top is
	signal internal_BOARD_CLOCK      : std_logic;
	signal internal_CLOCK_50MHz_BUFG : std_logic;
	signal internal_CLOCK_4MHz_BUFG  : std_logic;
	signal internal_CLOCK_ENABLE_I2C : std_logic;
	signal internal_CLOCK_SST_BUFG   : std_logic;
	signal internal_CLOCK_4xSST_BUFG : std_logic;
	
	signal internal_OUTPUT_REGISTERS : GPR;
	signal internal_INPUT_REGISTERS  : RR;
	signal i_register_update         : RWT;
	
	--Trigger readout
	signal internal_SOFTWARE_TRIGGER : std_logic;
	signal internal_HARDWARE_TRIGGER : std_logic;
	signal internal_TRIGGER : std_logic;
	signal internal_TRIGGER_OUT : std_logic;
	
	--Vetoes for the triggers
	signal internal_SOFTWARE_TRIGGER_VETO : std_logic;
	signal internal_HARDWARE_TRIGGER_VETO : std_logic;
	
	--SCROD ID and REVISION Number
	signal internal_SCROD_REV_AND_ID_WORD        : STD_LOGIC_VECTOR(31 downto 0);
   signal internal_EVENT_NUMBER_TO_SET          : STD_LOGIC_VECTOR(31 downto 0) := (others => '0'); --This is what event number will be set to when set event number is enabled
   signal internal_SET_EVENT_NUMBER             : STD_LOGIC;
   signal internal_EVENT_NUMBER                 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

	--Event builder + readout interface waveform data flow related
	signal internal_WAVEFORM_FIFO_DATA_OUT       : std_logic_vector(31 downto 0);
	signal internal_WAVEFORM_FIFO_EMPTY          : std_logic;
	signal internal_WAVEFORM_FIFO_DATA_VALID     : std_logic;
	signal internal_WAVEFORM_FIFO_READ_CLOCK     : std_logic;
	signal internal_WAVEFORM_FIFO_READ_ENABLE    : std_logic;
	signal internal_WAVEFORM_PACKET_BUILDER_BUSY	: std_logic := '0';
	signal internal_WAVEFORM_PACKET_BUILDER_VETO : std_logic;
	
	signal internal_EVTBUILD_DATA_OUT       : std_logic_vector(31 downto 0);
	signal internal_EVTBUILD_EMPTY          : std_logic;
	signal internal_EVTBUILD_DATA_VALID     : std_logic;
	signal internal_EVTBUILD_READ_CLOCK     : std_logic;
	signal internal_EVTBUILD_READ_ENABLE    : std_logic;
	signal internal_EVTBUILD_PACKET_BUILDER_BUSY	: std_logic := '0';
	signal internal_EVTBUILD_PACKET_BUILDER_VETO : std_logic := '0';
	signal internal_EVTBUILD_START_BUILDING_EVENT : std_logic := '0';
	signal internal_EVTBUILD_DONE_SENDING_EVENT : std_logic := '0';
	
	--ASIC TRIGGER CONTROL
	signal internal_TRIGGER_ALL : std_logic := '0';
	signal INTERNAL_COUNTER : UNSIGNED(27 downto 0) :=  x"0000000";
	signal internal_triggerCounter : UNSIGNED(15 downto 0) :=  x"0000";
	signal internal_numTriggers : UNSIGNED(15 downto 0) :=  x"0000";
	
	--ASIC DAC CONTROL
	signal internal_DAC_CONTROL_UPDATE : std_logic := '0';
	signal internal_DAC_CONTROL_REG_DATA : std_logic_vector(17 downto 0) := (others => '0');
	signal internal_DAC_CONTROL_TDCNUM : std_logic_vector(9 downto 0) := (others => '0');
	signal internal_DAC_CONTROL_SIN : std_logic := '0';
	signal internal_DAC_CONTROL_SCLK : std_logic := '0';
	signal internal_DAC_CONTROL_PCLK : std_logic := '0';
	signal internal_DAC_CONTROL_LOAD_PERIOD : std_logic_vector(15 downto 0)  := (others => '0');
	signal internal_DAC_CONTROL_LATCH_PERIOD : std_logic_vector(15 downto 0)  := (others => '0');
	
	--READOUT CONTROL
	signal internal_READCTRL_trigger : std_logic := '0';
	signal internal_READCTRL_trig_delay : std_logic_vector(11 downto 0) := (others => '0');
	signal internal_READCTRL_readout_reset : std_logic := '0';
	signal internal_READCTRL_smp_stop : std_logic := '0';
	signal internal_READCTRL_dig_start  : std_logic := '0';
	signal internal_READCTRL_srout_start  : std_logic := '0';
	signal internal_READCTRL_evtbuild_start  : std_logic := '0';
	signal internal_READCTRL_evtbuild_make_ready  : std_logic := '0';
	
	signal internal_CMDREG_SOFTWARE_trigger : std_logic := '0';
	signal internal_CMDREG_SOFTWARE_TRIGGER_VETO : std_logic := '0';
	signal internal_CMDREG_HARDWARE_TRIGGER_VETO : std_logic := '0';
	signal internal_CMDREG_SMP_STOP : std_logic := '0';
	signal internal_CMDREG_READCTRL_trig_delay : std_logic_vector(11 downto 0) := (others => '0');
	signal internal_CMDREG_READCTRL_readout_reset : std_logic := '0';
	signal internal_CMDREG_DIG_STARTDIG : std_logic := '0';
	signal internal_CMDREG_DIG_RD_ROWSEL_S : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
	signal internal_CMDREG_DIG_RD_COLSEL_S : STD_LOGIC_VECTOR(5 downto 0) := (others => '0');
	signal internal_CMDREG_SROUT_START : std_logic := '0';
	signal internal_CMDREG_WAVEFORM_FIFO_RST : std_logic := '0';
	signal internal_CMDREG_EVTBUILD_START_BUILDING_EVENT : std_logic := '0';
	signal internal_CMDREG_EVTBUILD_MAKE_READY : std_logic := '0';
	signal internal_CMDREG_EVTBUILD_DONE_SENDING_EVENT : std_logic := '0';
	signal internal_CMDREG_EVTBUILD_PACKET_BUILDER_BUSY : std_logic := '0';

	--ASIC SAMPLING CONTROL
	signal internal_SMP_STOP : std_logic := '0';
	signal internal_SMP_IDLE_status : std_logic := '0';
	signal internal_SMP_MAIN_CNT : std_logic_vector(8 downto 0) := (others => '0');
	signal internal_SSTIN : std_logic := '0';
	signal internal_SSPIN : std_logic := '0';
	signal internal_WR_STRB : std_logic := '0';
	signal internal_WR_ADVCLK : std_logic := '0';
	signal internal_WR_ENA : std_logic := '0';
	signal internal_WR_ADDRCLR : std_logic := '0';
	
	--ASIC DIGITIZATION CONTROL
	signal internal_DIG_STARTDIG : std_logic := '0';
	signal internal_DIG_IDLE_status : std_logic := '0';
	signal internal_DIG_RD_ENA : std_logic := '0';
	signal internal_DIG_CLR : std_logic := '0';
	signal internal_DIG_RD_ROWSEL_S : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
	signal internal_DIG_RD_COLSEL_S : STD_LOGIC_VECTOR(5 downto 0) := (others => '0');
	signal internal_DIG_START : STD_LOGIC := '0';
	signal internal_DIG_RAMP : STD_LOGIC := '0';
	
	--ASIC SERIAL READOUT
	signal internal_SROUT_START : std_logic := '0';
	signal internal_SROUT_IDLE_status : std_logic := '0';
	signal internal_SROUT_SAMP_DONE : std_logic := '0';
	signal internal_SROUT_SR_CLR : std_logic := '0';
	signal internal_SROUT_SR_CLK : std_logic := '0';
	signal internal_SROUT_SR_SEL : std_logic := '0';
	signal internal_SROUT_SAMPLESEL : std_logic_vector(4 downto 0) := (others => '0');
	signal internal_SROUT_SAMPLESEL_ANY : std_logic := '0';
	signal internal_SROUT_FIFO_WR_CLK       : std_logic;
	signal internal_SROUT_FIFO_WR_EN       : std_logic;
	signal internal_SROUT_FIFO_DATA_OUT       : std_logic_vector(31 downto 0);
	
	--WAVEFORM DATA FIFO
	signal internal_WAVEFORM_FIFO_RST : std_logic := '0';
	signal internal_EVTBUILD_MAKE_READY : std_logic := '0';
	
	-- MPPC DAC
	signal i_dac_number : std_logic_vector(3 downto 0);
	signal i_dac_addr   : std_logic_vector(3 downto 0);
	signal i_dac_value  : std_logic_vector(7 downto 0);
	signal i_dac_update : std_logic;
	signal i_dac_update_extended : std_logic;

	signal i_hv_sck_dac : std_logic;
	signal i_hv_din_dac : std_logic;

	
	--Waveform FIFO component
	COMPONENT waveform_fifo_wr32_rd32
	PORT (
		rst : IN STD_LOGIC;
		wr_clk : IN STD_LOGIC;
		rd_clk : IN STD_LOGIC;
		din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		wr_en : IN STD_LOGIC;
		rd_en : IN STD_LOGIC;
		dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		full : OUT STD_LOGIC;
		empty : OUT STD_LOGIC;
		valid : OUT STD_LOGIC
	);

	
	
END COMPONENT;
	
begin

	--Overall Signal Routing
   EX_TRIGGER <= internal_TRIGGER_ALL;

   internal_TRIGGER_ALL <= TDC1_TRG_16 OR TDC1_TRG(0) OR TDC1_TRG(1) OR TDC1_TRG(2) OR TDC1_TRG(3);
	
	--Clock generation
	map_clock_generation : entity work.clock_generation
	port map ( 
		--Raw boad clock input
		BOARD_CLOCKP      => BOARD_CLOCKP,
		BOARD_CLOCKN      => BOARD_CLOCKN,
		--FTSW inputs
		RJ45_ACK_P        => RJ45_ACK_P,
		RJ45_ACK_N        => RJ45_ACK_N,			  
		RJ45_TRG_P        => RJ45_TRG_P,
		RJ45_TRG_N        => RJ45_TRG_N,			  			  
		RJ45_RSV_P        => RJ45_RSV_P,
		RJ45_RSV_N        => RJ45_RSV_N,
		RJ45_CLK_P        => RJ45_CLK_P,
		RJ45_CLK_N        => RJ45_CLK_N,
		--Trigger outputs from FTSW
		FTSW_TRIGGER      => open,
		--Select signal between the two
		USE_LOCAL_CLOCK   => MONITOR_INPUT(0),
		--General output clocks
		CLOCK_50MHz_BUFG  => internal_CLOCK_50MHz_BUFG,
		CLOCK_4MHz_BUFG   => internal_CLOCK_4MHz_BUFG,
		--ASIC control clocks
		CLOCK_SSTx4_BUFG  => internal_CLOCK_4xSST_BUFG,
		CLOCK_SST_BUFG    => internal_CLOCK_SST_BUFG,
		--ASIC output clocks
		ASIC_SST          => open,
		ASIC_SSP          => open,
		ASIC_WR_STRB      => open,
		ASIC_WR_ADDR_LSB  => open,
		ASIC_WR_ADDR_LSB_RAW => open,
		--Output clock enable for I2C things
		I2C_CLOCK_ENABLE  => internal_CLOCK_ENABLE_I2C
	);  

	--Interface to the DAQ devices
	map_readout_interfaces : entity work.readout_interface
	port map ( 
		CLOCK                        => internal_CLOCK_50MHz_BUFG,

		OUTPUT_REGISTERS             => internal_OUTPUT_REGISTERS,
		INPUT_REGISTERS              => internal_INPUT_REGISTERS,
		REGISTER_UPDATED             => i_register_update,
	
		--NOT original implementation - SciFi specific
		WAVEFORM_FIFO_DATA_IN        => internal_EVTBUILD_DATA_OUT,
		WAVEFORM_FIFO_EMPTY          => internal_EVTBUILD_EMPTY,
		WAVEFORM_FIFO_DATA_VALID     => internal_EVTBUILD_DATA_VALID,
		WAVEFORM_FIFO_READ_CLOCK     => internal_EVTBUILD_READ_CLOCK,
		WAVEFORM_FIFO_READ_ENABLE    => internal_EVTBUILD_READ_ENABLE,
		WAVEFORM_PACKET_BUILDER_BUSY => internal_EVTBUILD_PACKET_BUILDER_BUSY,
		WAVEFORM_PACKET_BUILDER_VETO => internal_EVTBUILD_PACKET_BUILDER_VETO,
		
		--WAVEFORM ROI readout disable for now (SciFi implementation)
		--WAVEFORM_FIFO_DATA_IN        => (others=>'0'),
		--WAVEFORM_FIFO_EMPTY          => '1',
		--WAVEFORM_FIFO_DATA_VALID     => '0',
		--WAVEFORM_FIFO_READ_CLOCK     => open,
		--WAVEFORM_FIFO_READ_ENABLE    => open,
		--WAVEFORM_PACKET_BUILDER_BUSY => '0',
		--WAVEFORM_PACKET_BUILDER_VETO => open,

		FIBER_0_RXP                  => FIBER_0_RXP,
		FIBER_0_RXN                  => FIBER_0_RXN,
		FIBER_1_RXP                  => FIBER_1_RXP,
		FIBER_1_RXN                  => FIBER_1_RXN,
		FIBER_0_TXP                  => FIBER_0_TXP,
		FIBER_0_TXN                  => FIBER_0_TXN,
		FIBER_1_TXP                  => FIBER_1_TXP,
		FIBER_1_TXN                  => FIBER_1_TXN,
		FIBER_REFCLKP                => FIBER_REFCLKP,
		FIBER_REFCLKN                => FIBER_REFCLKN,
		FIBER_0_DISABLE_TRANSCEIVER  => FIBER_0_DISABLE_TRANSCEIVER,
		FIBER_1_DISABLE_TRANSCEIVER  => FIBER_1_DISABLE_TRANSCEIVER,
		FIBER_0_LINK_UP              => FIBER_0_LINK_UP,
		FIBER_1_LINK_UP              => FIBER_1_LINK_UP,
		FIBER_0_LINK_ERR             => FIBER_0_LINK_ERR,
		FIBER_1_LINK_ERR             => FIBER_1_LINK_ERR,

		USB_IFCLK                    => USB_IFCLK,
		USB_CTL0                     => USB_CTL0,
		USB_CTL1                     => USB_CTL1,
		USB_CTL2                     => USB_CTL2,
		USB_FDD                      => USB_FDD,
		USB_PA0                      => USB_PA0,
		USB_PA1                      => USB_PA1,
		USB_PA2                      => USB_PA2,
		USB_PA3                      => USB_PA3,
		USB_PA4                      => USB_PA4,
		USB_PA5                      => USB_PA5,
		USB_PA6                      => USB_PA6,
		USB_PA7                      => USB_PA7,
		USB_RDY0                     => USB_RDY0,
		USB_RDY1                     => USB_RDY1,
		USB_WAKEUP                   => USB_WAKEUP,
		USB_CLKOUT		              => USB_CLKOUT
	);

	--------------------------------------------------
	-------General registers interfaced to DAQ -------
	--------------------------------------------------

	--LEDS
	LEDS <= internal_OUTPUT_REGISTERS(0);
	--LEDS <= "0000000" & internal_SMP_MAIN_CNT;
	
	--DAC CONTROL SIGNALS
	internal_DAC_CONTROL_UPDATE <= internal_OUTPUT_REGISTERS(1)(0);
	internal_DAC_CONTROL_REG_DATA <= internal_OUTPUT_REGISTERS(2)(5 downto 0) 
												& internal_OUTPUT_REGISTERS(3)(11 downto 0);
   internal_DAC_CONTROL_TDCNUM <= internal_OUTPUT_REGISTERS(4)(9 downto 0);
	internal_DAC_CONTROL_LOAD_PERIOD <= internal_OUTPUT_REGISTERS(5)(15 downto 0);
	internal_DAC_CONTROL_LATCH_PERIOD <= internal_OUTPUT_REGISTERS(6)(15 downto 0);
	
	--Sampling Signals
	internal_CMDREG_SMP_STOP <= internal_OUTPUT_REGISTERS(10)(0);

	--Digitization Signals
   internal_CMDREG_DIG_STARTDIG <= internal_OUTPUT_REGISTERS(20)(0);
   internal_CMDREG_DIG_RD_ROWSEL_S <= internal_OUTPUT_REGISTERS(21)(8 downto 6);
	internal_CMDREG_DIG_RD_COLSEL_S <= internal_OUTPUT_REGISTERS(21)(5 downto 0);
	
	--Serial Readout Signals
	internal_CMDREG_SROUT_START <=  internal_OUTPUT_REGISTERS(30)(0);
	
	--Event builder signals
	internal_CMDREG_WAVEFORM_FIFO_RST <= internal_OUTPUT_REGISTERS(40)(0);
	internal_CMDREG_EVTBUILD_START_BUILDING_EVENT <= internal_OUTPUT_REGISTERS(44)(0);
	internal_CMDREG_EVTBUILD_MAKE_READY <= internal_OUTPUT_REGISTERS(45)(0);
	internal_CMDREG_EVTBUILD_PACKET_BUILDER_BUSY <= internal_OUTPUT_REGISTERS(46)(0);
	
	--Readout control signals
	internal_CMDREG_SOFTWARE_trigger <= internal_OUTPUT_REGISTERS(50)(0);
	internal_CMDREG_SOFTWARE_TRIGGER_VETO <= internal_OUTPUT_REGISTERS(51)(0);
	internal_CMDREG_HARDWARE_TRIGGER_VETO <= internal_OUTPUT_REGISTERS(52)(0);
	internal_CMDREG_READCTRL_trig_delay <= internal_OUTPUT_REGISTERS(53)(11 downto 0);
	internal_CMDREG_READCTRL_readout_reset <= internal_OUTPUT_REGISTERS(54)(0);
	
	-- HV dac signals
	i_dac_number <= internal_OUTPUT_REGISTERS(60)(15 downto 12);
	i_dac_addr   <= internal_OUTPUT_REGISTERS(60)(11 downto 8);
	i_dac_value  <= internal_OUTPUT_REGISTERS(60)(7 downto 0);
	i_dac_update <= i_register_update(60);
	HV_DISABLE   <= not internal_OUTPUT_REGISTERS(61)(0);
	TDC_AMUX_S   <= internal_OUTPUT_REGISTERS(62)(3 downto 0);
	TOP_AMUX_S   <= internal_OUTPUT_REGISTERS(62)(7 downto 4);

	--------Input register mapping--------------------
	--Map the first N_GPR output registers to the first set of read registers
	gen_OUTREG_to_INREG: for i in 0 to N_GPR-1 generate
		gen_BIT: for j in 0 to 15 generate
			map_BUF_RR : BUF 
			port map( 
				I => internal_OUTPUT_REGISTERS(i)(j), 
				O => internal_INPUT_REGISTERS(i)(j) 
			);
		end generate;
	end generate;
	--- The register numbers must be updated for the following if N_GPR is changed.
	internal_INPUT_REGISTERS(N_GPR + 0 ) <= "0000000" & internal_SMP_MAIN_CNT(8 downto 0 );
	internal_INPUT_REGISTERS(N_GPR + 1 ) <= internal_WAVEFORM_FIFO_DATA_OUT(15 downto 0);
	internal_INPUT_REGISTERS(N_GPR + 2 ) <= "000000000000000" & internal_WAVEFORM_FIFO_EMPTY;
	internal_INPUT_REGISTERS(N_GPR + 3 ) <= "000000000000000" & internal_WAVEFORM_FIFO_DATA_VALID;
	internal_INPUT_REGISTERS(N_GPR + 10 ) <= std_logic_vector(INTERNAL_COUNTER(15 downto 0));
	internal_INPUT_REGISTERS(N_GPR + 11) <= std_logic_vector(internal_numTriggers);
	internal_INPUT_REGISTERS(N_GPR + 20) <= x"002c"; -- ID of the board

   --ASIC control processes
	
	--TARGET6 DAC Control
	u_TARGET6_DAC_CONTROL: entity work.TARGET6_DAC_CONTROL PORT MAP(
			CLK => internal_CLOCK_50MHz_BUFG,
			LOAD_PERIOD => internal_DAC_CONTROL_LOAD_PERIOD,
			LATCH_PERIOD => internal_DAC_CONTROL_LATCH_PERIOD,
			UPDATE => internal_DAC_CONTROL_UPDATE,
			REG_DATA => internal_DAC_CONTROL_REG_DATA,
			SIN => internal_DAC_CONTROL_SIN,
			SCLK => internal_DAC_CONTROL_SCLK,
			PCLK => internal_DAC_CONTROL_PCLK
   );
	--end generate;
	BUSA_REGCLR <= '0';
	BUSB_REGCLR <= '0';
	BUSA_SCLK <= internal_DAC_CONTROL_SCLK;
	BUSB_SCLK <= internal_DAC_CONTROL_SCLK;
	--Only specified DC gets serial data signals, uses bit mask
	gen_DAC_CONTROL: for i in 0 to 9 generate
		SIN(i) <= internal_DAC_CONTROL_SIN and internal_DAC_CONTROL_TDCNUM(i);
		PCLK(i) <= internal_DAC_CONTROL_PCLK and internal_DAC_CONTROL_TDCNUM(i);
	end generate;
	
	--Control the sampling, digitization and serial resout processes following trigger
	u_ReadoutControl: entity work.ReadoutControl PORT MAP(
		clk => internal_CLOCK_50MHz_BUFG,
		trigger => internal_READCTRL_trigger,
		trig_delay => internal_READCTRL_trig_delay,
		SMP_MAIN_CNT => internal_SMP_MAIN_CNT,
		SMP_IDLE_status => internal_SMP_IDLE_STATUS,
		DIG_IDLE_status => internal_DIG_IDLE_status,
		SROUT_IDLE_status => internal_SROUT_IDLE_status,
		fifo_empty => internal_WAVEFORM_FIFO_EMPTY,
		EVTBUILD_DONE_SENDING_EVENT => internal_EVTBUILD_DONE_SENDING_EVENT,
		READOUT_RESET => internal_READCTRL_readout_reset,
		smp_stop => internal_READCTRL_smp_stop,
		dig_start => internal_READCTRL_dig_start,
		srout_start => internal_READCTRL_srout_start,
		EVTBUILD_start => internal_READCTRL_evtbuild_start,
		EVTBUILD_MAKE_READY => internal_READCTRL_evtbuild_make_ready
	);
	internal_SOFTWARE_TRIGGER_VETO <= internal_CMDREG_SOFTWARE_TRIGGER_VETO;
	internal_HARDWARE_TRIGGER_VETO <= internal_CMDREG_HARDWARE_TRIGGER_VETO;
	internal_SOFTWARE_TRIGGER <= internal_CMDREG_SOFTWARE_trigger AND NOT internal_SOFTWARE_TRIGGER_VETO;
	internal_HARDWARE_TRIGGER <= internal_TRIGGER_ALL AND NOT internal_HARDWARE_TRIGGER_VETO;
	internal_READCTRL_trigger <= internal_SOFTWARE_TRIGGER OR internal_HARDWARE_TRIGGER;
	internal_READCTRL_trig_delay <= internal_CMDREG_READCTRL_trig_delay;
	internal_READCTRL_readout_reset <= internal_CMDREG_READCTRL_readout_reset;
	
	--sampling logic - specifically SSPIN/SSTIN + write address control
	u_SamplingLgc : entity work.SamplingLgc
   Port map (
		--clk => internal_CLOCK_150MHz_BUFG,
		clk => internal_CLOCK_50MHz_BUFG,
		stop => internal_SMP_STOP,
		IDLE_status => internal_SMP_IDLE_STATUS,
		MAIN_CNT_out => internal_SMP_MAIN_CNT,
		sspin_out => internal_SSPIN,
		sstin_out => internal_SSTIN,
		wr_advclk_out => internal_WR_ADVCLK,
		wr_addrclr_out => internal_WR_ADDRCLR,
		wr_strb_out => internal_WR_STRB,
		wr_ena_out => internal_WR_ENA
	);
	--internal_SMP_STOP <= internal_READCTRL_smp_stop OR internal_CMDREG_SMP_STOP;
	internal_SMP_STOP <= internal_CMDREG_SMP_STOP;
	SSPIN <= internal_SSPIN;
	SSTIN <= internal_SSTIN;
	WR_ADVCLK <= internal_WR_ADVCLK;
	BUSA_WR_ADDRCLR <= internal_WR_ADDRCLR;
	BUSB_WR_ADDRCLR <= internal_WR_ADDRCLR;
	WR_STRB <= internal_WR_STRB;
	WR_ENA <= internal_WR_ENA;
	
	--digitizing logic
	u_DigitizingLgc: entity work.DigitizingLgc PORT MAP(
		clk => internal_CLOCK_50MHz_BUFG,
		IDLE_status => internal_DIG_IDLE_status,
		StartDig => internal_DIG_STARTDIG,
		ramp_length => X"400",
		rd_ena => internal_DIG_RD_ENA,
		clr => internal_DIG_CLR,
		startramp => internal_DIG_RAMP
	);
	--internal_DIG_STARTDIG <= internal_READCTRL_dig_start OR internal_CMDREG_DIG_STARTDIG;
	internal_DIG_STARTDIG <= internal_CMDREG_DIG_STARTDIG;
	BUSA_RD_ENA	<= internal_DIG_RD_ENA;
	BUSA_RD_ROWSEL_S <= internal_DIG_RD_ROWSEL_S;
	BUSA_RD_COLSEL_S <= internal_DIG_RD_COLSEL_S;
	BUSA_CLR <= internal_DIG_CLR;
	BUSA_START <= internal_DIG_RAMP;
	BUSA_RAMP <= internal_DIG_RAMP;
	BUSB_RD_ENA	<= internal_DIG_RD_ENA;
	BUSB_RD_ROWSEL_S <= internal_CMDREG_DIG_RD_ROWSEL_S;
	BUSB_RD_COLSEL_S <= internal_CMDREG_DIG_RD_COLSEL_S;
	BUSB_CLR <= internal_DIG_CLR;
	BUSB_START <= internal_DIG_RAMP;
	BUSB_RAMP <= internal_DIG_RAMP;
	
	u_SerialDataRout: entity work.SerialDataRout PORT MAP(
		clk => internal_CLOCK_50MHz_BUFG,
		start => internal_SROUT_START,
		IDLE_status => internal_SROUT_IDLE_status,
		busy => open,
		samp_done => open,
		dout => BUSA_DO, --NEED to ACCOMODATE BOTH BUSSES
		--dout => x"ABCD", --NEED to ACCOMODATE BOTH BUSSES
		sr_clr => internal_SROUT_SR_CLR,
		sr_clk => internal_SROUT_SR_CLK,
		sr_sel => internal_SROUT_SR_SEL,
		samplesel => internal_SROUT_SAMPLESEL,
		smplsi_any => internal_SROUT_SAMPLESEL_ANY,
		fifo_wr_en => internal_SROUT_FIFO_WR_EN,
		fifo_wr_clk => internal_SROUT_FIFO_WR_CLK,
		fifo_wr_din => internal_SROUT_FIFO_DATA_OUT
	);
	--internal_SROUT_START <= internal_READCTRL_srout_start OR internal_CMDREG_SROUT_START;
	internal_SROUT_START <= internal_CMDREG_SROUT_START;
	BUSA_SAMPLESEL_S <= internal_SROUT_SAMPLESEL;
	BUSA_SR_CLEAR <= internal_SROUT_SR_CLR;
	BUSA_SR_SEL	<= internal_SROUT_SR_SEL;
	SR_CLOCK	<= internal_SROUT_SR_CLK;
	SAMPLESEL_ANY <= internal_SROUT_SAMPLESEL_ANY;
	BUSB_SAMPLESEL_S <= (others=>'0');
	BUSB_SR_CLEAR <=  '0';
	BUSB_SR_SEL	<= '0';
	
   u_waveform_fifo_wr32_rd32 : waveform_fifo_wr32_rd32
   PORT MAP (
		rst => internal_WAVEFORM_FIFO_RST,
		wr_clk => internal_SROUT_FIFO_WR_CLK,
		--wr_clk => internal_CLOCK_50MHz_BUFG,
		rd_clk => internal_WAVEFORM_FIFO_READ_CLOCK,
		din => internal_SROUT_FIFO_DATA_OUT,
		wr_en => internal_SROUT_FIFO_WR_EN,
		rd_en => internal_WAVEFORM_FIFO_READ_ENABLE,
		dout => internal_WAVEFORM_FIFO_DATA_OUT,
		full => open,
		empty => internal_WAVEFORM_FIFO_EMPTY,
		valid => internal_WAVEFORM_FIFO_DATA_VALID
   );
	
	--Event builder provides ordered waveform data to readout_interfaces module
	map_event_builder: entity work.event_builder PORT MAP(
		READ_CLOCK => internal_EVTBUILD_READ_CLOCK,
		SCROD_REV_AND_ID_WORD => x"00000000",
		EVENT_NUMBER_WORD => x"00000001",
		EVENT_TYPE_WORD => x"00000001",
		EVENT_FLAG_WORD => x"00000000",
		NUMBER_OF_WAVEFORM_PACKETS_WORD => x"00000001",
		START_BUILDING_EVENT => internal_EVTBUILD_START_BUILDING_EVENT,
		DONE_SENDING_EVENT => internal_EVTBUILD_DONE_SENDING_EVENT,
		MAKE_READY => internal_EVTBUILD_MAKE_READY,
		WAVEFORM_FIFO_DATA => internal_WAVEFORM_FIFO_DATA_OUT,
		WAVEFORM_FIFO_DATA_VALID => internal_WAVEFORM_FIFO_DATA_VALID,
		WAVEFORM_FIFO_EMPTY => internal_WAVEFORM_FIFO_EMPTY,
		WAVEFORM_FIFO_READ_ENABLE => internal_WAVEFORM_FIFO_READ_ENABLE,
		WAVEFORM_FIFO_READ_CLOCK => internal_WAVEFORM_FIFO_READ_CLOCK,
		FIFO_DATA_OUT => internal_EVTBUILD_DATA_OUT,
		FIFO_DATA_VALID => internal_EVTBUILD_DATA_VALID,
		FIFO_EMPTY => internal_EVTBUILD_EMPTY,
		FIFO_READ_ENABLE => internal_EVTBUILD_READ_ENABLE
	);
	--internal_EVTBUILD_START_BUILDING_EVENT <= internal_READCTRL_evtbuild_start OR internal_CMDREG_EVTBUILD_START_BUILDING_EVENT;
	--internal_EVTBUILD_MAKE_READY <= internal_READCTRL_evtbuild_make_ready OR internal_CMDREG_EVTBUILD_MAKE_READY;
	internal_EVTBUILD_START_BUILDING_EVENT <= internal_CMDREG_EVTBUILD_START_BUILDING_EVENT;
	internal_EVTBUILD_MAKE_READY <= internal_CMDREG_EVTBUILD_MAKE_READY;
	
   --counter process
   process (internal_CLOCK_50MHz_BUFG) begin
		if (rising_edge(internal_CLOCK_50MHz_BUFG)) then
			INTERNAL_COUNTER <= INTERNAL_COUNTER + 1;
      end if;
   end process;
	
	--trigger counter
	process (INTERNAL_COUNTER, internal_TRIGGER_ALL) begin
		if (INTERNAL_COUNTER = x"0000000") then
			internal_numTriggers <= internal_triggerCounter;
			internal_triggerCounter <= x"0000";
		else
			if( rising_edge(internal_TRIGGER_ALL) ) then
				internal_triggerCounter <= internal_triggerCounter  + 1;
			end if;
      end if;
   end process;
	
	--Event builder
	
	--------------
	-- MPPC DACs
	--------------
	inst_mpps_dacs : entity work.mppc_dacs
	Port map(
		------------CLOCK-----------------
		CLOCK			 => internal_CLOCK_4MHz_BUFG,
		------------DAC PARAMETERS--------
		DAC_NUMBER   => i_dac_number,
		DAC_ADDR     => i_dac_addr,
		DAC_VALUE    => i_dac_value,
		WRITE_STROBE => i_dac_update_extended,
		------------HW INTERFACE----------
		SCK_DAC		 => i_hv_sck_dac,
		DIN_DAC		 => i_hv_din_dac,
		CS_DAC       => TDC_CS_DAC
	);

	BUSA_SCK_DAC <= i_hv_sck_dac;
	BUSB_SCK_DAC <= i_hv_sck_dac;
	BUSA_DIN_DAC <= i_hv_din_dac;
	BUSB_DIN_DAC <= i_hv_din_dac;

	inst_pulse_extent : entity work.pulse_transition
	Generic map(
		CLOCK_RATIO  => 20
	)
	Port map(
		CLOCK_IN     => internal_CLOCK_50MHz_BUFG,
		D_IN         => i_dac_update,
		CLOCK_OUT    => internal_CLOCK_4MHz_BUFG,
		D_OUT        => i_dac_update_extended
	);

end Behavioral;