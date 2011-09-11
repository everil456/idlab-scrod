----------------------------------------------------------------------------------
-- Clocking and FTSW Interface
-- Description:
--   This module produces all the clocks to be used by the board stack firmware,
--   except for the "USER_CLOCK" generated by Aurora.  The following clocks
--   are produced:
--        CLOCK_127MHz      127 MHz     (explicitly on a BUFG)
--        CLOCK_SST          21 MHz     (explicitly on a BUFG)
--        CLOCK_SSP          21 MHz     
--        CLOCK_WRITE_STROBE 42 MHz 
--        CLOCK_4xSST        84 MHz     (explicitly on a BUFG)
--        CLOCK_83kHz        83 kHz 
--        CLOCK_80Hz         80 Hz
--   These clocks are generated either from FTSW or from the 250 MHz on-board
--   oscillator.  The "USE_FTSW_CLOCK" signal decides which to use.
-- Change log:
-- 2011-09-10 - Created by Kurtis
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity clocking_and_ftsw_interface is
    Port ( 
				BOARD_CLOCK_250MHz_P : in STD_LOGIC;
				BOARD_CLOCK_250MHz_N : in STD_LOGIC;
				---FTSW I/Os (from RJ45)
				RJ45_ACK_P			: out std_logic;
				RJ45_ACK_N			: out std_logic;			  
				RJ45_TRG_P			: in std_logic;
				RJ45_TRG_N			: in std_logic;			  			  
				RJ45_RSV_P			: out std_logic;
				RJ45_RSV_N			: out std_logic;
				RJ45_CLK_P			: in std_logic;
				RJ45_CLK_N			: in std_logic;
				--Inputs from the user/board
				USE_FTSW_CLOCK		: in std_logic;
				--Status outputs
				FTSW_INTERFACE_READY : out std_logic;
				SAMPLING_CLOCKS_READY : out std_logic;
				--Clock outputs 
				CLOCK_127MHz		: out std_logic; --This clock is on a BUFG
				CLOCK_SST			: out std_logic; --This clock is on a BUFG
				CLOCK_SSP			: out std_logic; --NOT explicitly on a BUFG
				CLOCK_WRITE_STROBE : out std_logic;--NOT explicitly on a BUFG
				CLOCK_4xSST			: out std_logic; --NOT explicitly on a BUFG
				CLOCK_83kHz			: out std_logic; --This clock is on a BUFG
				CLOCK_80Hz			: out std_logic
			);
end clocking_and_ftsw_interface;

architecture Behavioral of clocking_and_ftsw_interface is

	--------SIGNAL DEFINITIONS-------------------------------
	signal internal_BOARD_CLOCK_250MHz		: std_logic;
	signal internal_BOARD_CLOCK_127MHz		: std_logic;
	signal internal_BOARD_CLOCK_21MHz		: std_logic;	
	signal internal_BOARD_CLOCK_DCM_LOCKED : std_logic;

	signal internal_FTSW_INTERFACE_READY	: std_logic;
	signal internal_FTSW_CLOCK_127MHz		: std_logic;
	signal internal_FTSW_CLOCK_21MHz			: std_logic;
	signal internal_FTSW_TRIGGER127			: std_logic;
	signal internal_FTSW_TRIGGER21			: std_logic;

	signal internal_USE_FTSW_CLOCK			: std_logic;

	signal internal_CLOCK_127MHz				: std_logic;
	signal internal_CLOCK_21Mhz				: std_logic;
	signal internal_CLOCK_83kHz				: std_logic;
	signal internal_CLOCK_80Hz					: std_logic;
	
	signal internal_RESET_SAMPLING_CLOCK_GEN : std_logic;
	signal internal_SAMPLING_CLOCKS_READY	  : std_logic;

	signal internal_CLOCK_SSP 				: std_logic;
	signal internal_CLOCK_SST 				: std_logic;	
	signal internal_CLOCK_WRITE_STROBE	: std_logic;
	signal internal_CLOCK_4xSST			: std_logic;
   ---------------------------------------------------------	

begin
	-----Map inputs/outputs to the appropriate internal signals------
	CLOCK_127MHz <= internal_CLOCK_127MHz;
	CLOCK_SST	 <= internal_CLOCK_SST;
	CLOCK_SSP 	 <= internal_CLOCK_SSP;
	CLOCK_WRITE_STROBE <= internal_CLOCK_WRITE_STROBE;
	CLOCK_4xSST  <= internal_CLOCK_4xSST;
	CLOCK_83kHz  <= internal_CLOCK_83kHz;
	CLOCK_80Hz   <= internal_CLOCK_80Hz;
	FTSW_INTERFACE_READY <= internal_FTSW_INTERFACE_READY;
	SAMPLING_CLOCKS_READY <= internal_SAMPLING_CLOCKS_READY;
   -----------------------------------------------------------------
	internal_CLOCK_SST <= internal_CLOCK_21MHz;	
   ----Map out the interface signals--------------------------------
	map_FTSW_interface: entity work.bpid
    port map (
      ack_p  => RJ45_ACK_P,
      ack_n  => RJ45_ACK_N,
      trg_p  => RJ45_TRG_P,
      trg_n  => RJ45_TRG_N,
		rsv_p  => RJ45_RSV_P,
		rsv_n  => RJ45_RSV_N,
		clk_p  => RJ45_CLK_P,
		clk_n  => RJ45_CLK_N,
		clk127 => internal_FTSW_CLOCK_127MHz,
		clk21  => internal_FTSW_CLOCK_21MHz,
		trg127 => internal_FTSW_TRIGGER127,
		trg21  => internal_FTSW_TRIGGER21,
		ready  => internal_FTSW_INTERFACE_READY,
		monitor => open);
   ----------------------------------------------------------------
	map_ibufgds_250MHz : IBUFGDS
      port map (O  => internal_BOARD_CLOCK_250MHz,
                I  => BOARD_CLOCK_250MHz_P,
                IB => BOARD_CLOCK_250MHz_N); 
	---------------------------------------------------------
	map_primary_ibufgmux : BUFGMUX
		port map (I0 => internal_BOARD_CLOCK_127MHz,
					 I1 => internal_FTSW_CLOCK_127MHz,
					 O  => internal_CLOCK_127MHz,
					 S  => internal_USE_FTSW_CLOCK);
	---------------------------------------------------------
	map_board_derived_clockgen : entity work.board_derived_clockgen
		port map (	-- Clock in ports
						CLK_IN1 => internal_BOARD_CLOCK_250MHz,
						-- Clock out ports
						CLK_OUT1 => internal_BOARD_CLOCK_127MHz,
						CLK_OUT2 => internal_BOARD_CLOCK_21MHz,
						-- Status and control signals
						RESET  => internal_USE_FTSW_CLOCK,
						LOCKED => internal_BOARD_CLOCK_DCM_LOCKED);
	---------------------------------------------------------
	map_sst_ibufgmux : BUFGMUX
		port map (I0 => internal_BOARD_CLOCK_21MHz,
					 I1 => internal_FTSW_CLOCK_21MHz,
					 O  => internal_CLOCK_21MHz,
					 S  => internal_USE_FTSW_CLOCK);
	---------------------------------------------------------
	map_sampling_clock_gen : entity work.sampling_clock_gen
		port map (	CLK_IN1  => internal_CLOCK_SST,
						CLK_OUT1 => internal_CLOCK_SSP,
						CLK_OUT2 => internal_CLOCK_WRITE_STROBE,
						CLK_OUT3 => internal_CLOCK_4xSST,
						RESET 	=> internal_RESET_SAMPLING_CLOCK_GEN,
						LOCKED	=> internal_SAMPLING_CLOCKS_READY);
	---------------------------------------------------------
	-----------Process to control the reset logic to the PLLs
	process (internal_USE_FTSW_CLOCK, internal_BOARD_CLOCK_DCM_LOCKED, internal_FTSW_INTERFACE_READY) begin
		if (internal_USE_FTSW_CLOCK = '1') then
			internal_RESET_SAMPLING_CLOCK_GEN <= not(internal_FTSW_INTERFACE_READY);
		else
			internal_RESET_SAMPLING_CLOCK_GEN <= not(internal_BOARD_CLOCK_DCM_LOCKED);
		end if;
	end process;	
	-----------Two processes to control the slower clocks----
	process (internal_CLOCK_21MHz) 
		variable counter : integer := 0;
		constant target  : integer := 128;
	begin
		if rising_edge(internal_CLOCK_21MHz) then
			if (counter = target) then
				internal_CLOCK_83kHz <= not(internal_CLOCK_83kHz);
				counter := 0;
			else 
				counter := counter + 1;
			end if;
		end if;
	end process;
	----------------------
	process (internal_CLOCK_83kHz)
		variable counter : integer := 0;
		constant target  : integer := 512;
	begin
		if rising_edge(internal_CLOCK_83kHz) then
			if (counter = target) then
				internal_CLOCK_80Hz <= not(internal_CLOCK_80Hz);
				counter := 0;
			else
				counter := counter + 1;
			end if;
		end if;
	end process;
	---------------------------------------------------------

	

end Behavioral;

