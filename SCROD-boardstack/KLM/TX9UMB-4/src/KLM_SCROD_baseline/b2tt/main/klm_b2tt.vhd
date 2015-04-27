------------------------------------------------------------------------
--
-- klm_b2tt.vhd --- B2TT receiver test with KLM Data Concentrator
--
-- Mikihiko Nakao, KEK IPNS
--
-- 20140611 0.01  based on ml605_b2tt 0.13
-- 20140722 0.02  b2tt 0.27
-- 20140724 0.03  b2tt 0.18 - single idelay version
-- 20140724 0.04  b2tt 0.27 again
-- 20140808 0.05  b2tt 0.29
-- 20140917 0.06  b2tt 0.31
-- 20150105 0.07  b2tt 0.33
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.ALL;
--library work;
--use work.mytypes.all;

------------------------------------------------------------------------
-- entity
------------------------------------------------------------------------
entity klm_b2tt is
  generic (
    VERSION : integer := 7;
    ID : std_logic_vector (31 downto 0) := x"4b4c4d54";  -- "KLMT"
    USE_CHIPSCOPE : std_logic := '1' );

  port (
    ack_n      : out   std_logic;
    ack_p      : out   std_logic;
    trg_n      : in    std_logic;
    trg_p      : in    std_logic;
    rsv_n      : out   std_logic;
    rsv_p      : out   std_logic;
    clk_n      : in    std_logic;
    clk_p      : in    std_logic;

 -- clkout_n   : out   std_logic;  -- to measure jitter
 -- clkout_p   : out   std_logic;
 -- ext_n      : out   std_logic_vector (2 downto 0);
 -- ext_p      : out   std_logic_vector (2 downto 0);

    oscen      : out   std_logic;
    cbufen     : out   std_logic;
    
    led_b      : out   std_logic_vector (1 downto 0) );
 -- sma_gpio_p : out   std_logic;
 -- sma_gpio_n : out   std_logic;

 -- header     : out   std_logic_vector (3 downto 0);
 -- pushsw     : in    std_logic_vector (3 downto 1);
 -- dipsw      : in    std_logic_vector (2 downto 0) );

end klm_b2tt;

------------------------------------------------------------------------
-- architecture
------------------------------------------------------------------------
architecture implementation of klm_b2tt is

  constant XVERSION : std_logic_vector (31 downto 0)
    := std_logic_vector(to_unsigned(VERSION, 32));

  signal sig_led       : std_logic_vector (3 downto 0) := (others => '0');

  signal sig_blink     : std_logic := '0';
  signal cnt_127       : std_logic_vector (26 downto 0) := (others => '0');

  signal sig_raw127    : std_logic := '0';
  signal clk_127       : std_logic := '0';
  
  signal sig_clkup     : std_logic := '0';
  signal sig_ttup      : std_logic := '0';
  signal sig_trg       : std_logic := '0';

  signal sig_revo      : std_logic := '0';

  signal sig_trgtag    : std_logic_vector (31 downto 0) := (others => '0');

  signal sig_test      : std_logic := '0';

  signal reg_dbg       : std_logic_vector (7  downto 0) := (others => '0');
  signal cnt_delay     : std_logic_vector (6  downto 0) := (others => '0');
  signal sig_delay     : std_logic := '0';
  -- 65ms (2^23 * 7.8ns) to avoid chattering
  signal cnt_pushsw    : std_logic_vector (23 downto 0) := (others => '0');
  signal seq_pushsw    : std_logic_vector (1  downto 0) := "00";
  signal cnt_pushsw2   : std_logic_vector (23 downto 0) := (others => '0');
  signal seq_pushsw2   : std_logic_vector (1  downto 0) := "00";
  signal sig_caldelay  : std_logic := '0';
  
  signal open_utime    : std_logic_vector (31 downto 0) := (others => '0');
  signal open_ctime    : std_logic_vector (26 downto 0) := (others => '0');
  signal open_divclk1  : std_logic_vector (1  downto 0) := (others => '0');
  signal open_divclk2  : std_logic_vector (1  downto 0) := (others => '0');
  signal open_exprun   : std_logic_vector (31 downto 0) := (others => '0');
  signal open_runreset : std_logic := '0';
  signal open_feereset : std_logic := '0';
  signal open_gtpreset : std_logic := '0';
  signal open_trgtyp   : std_logic_vector (3  downto 0) := (others => '0');
  signal open_revo9    : std_logic := '0';
  signal open_revoclk  : std_logic_vector (10 downto 0) := (others => '0');
  signal open_revogap  : std_logic := '0';
  signal open_injveto  : std_logic_vector (1  downto 0) := (others => '0');
  signal open_fifordy  : std_logic := '0';
  signal open_fifodata : std_logic_vector (95 downto 0) := (others => '0');
  signal open_octet    : std_logic_vector (7  downto 0) := (others => '0');
  signal open_isk      : std_logic := '0';
  signal open_cntbit2  : std_logic_vector (2  downto 0) := (others => '0');
  signal open_sigbit2  : std_logic_vector (1  downto 0) := (others => '0');
  signal sig_dbg       : std_logic_vector (95 downto 0) := (others => '0');

  signal pushsw        : std_logic_vector (3  downto 1) := (others => '0');
  signal dipsw         : std_logic_vector (2  downto 0) := (others => '0');

  -- for chipscope
  signal sig_ilacontrol : std_logic_vector (35 downto 0) := (others => '0');

begin
  ----------------------------------------------------------------------
  -- clock and LED (lclk, jclk)
  ----------------------------------------------------------------------
  ---_ods: obufds port map ( i => sig_test, o => clkout_p, ob => clkout_n );

  --led(7 downto 4) <= sig_dbg(3 downto 0);

  cbufen <= '1';
  oscen  <= '1';
  
  proc_test: process (clk_127)
  begin
    if clk_127'event and clk_127 = '1' then
      if cnt_127 = (127216000/2)-1 then
        cnt_127 <= (others => '0');
        sig_blink <= not sig_blink;
      else
        cnt_127 <= cnt_127 + 1;
      end if;
    end if;
  end process;

  led_b(0) <= sig_blink;
  led_b(1) <= '0';
  
  reg_dbg(0) <= dipsw(0);      -- manual delay control for debug
  reg_dbg(1) <= dipsw(1);      -- bitslip
  reg_dbg(2) <= sig_delay;     -- incdelay from pushsw(2)
  reg_dbg(3) <= pushsw(1);     -- clrdelay
  reg_dbg(4) <= sig_caldelay;  -- caldelay from pushsw(3)
  reg_dbg(5) <= dipsw(2);      -- decdelay (decrement instead of increment)

  proc_clk: process (clk_127)
  begin
    if clk_127'event and clk_127 = '1' then

      -- SW5: pushsw(2) for "inc"
      if seq_pushsw(0) = pushsw(2) then
        cnt_pushsw <= (others => '0');
      else
        if cnt_pushsw(cnt_pushsw'left) = '0' then
          cnt_pushsw <= cnt_pushsw + 1;
        else
          seq_pushsw(0) <= pushsw(2);
        end if;
      end if;
      seq_pushsw(1) <= seq_pushsw(0);
      sig_delay     <= seq_pushsw(0) and (not seq_pushsw(1));

      -- SW8: pushsw(3) for "cal"
      if seq_pushsw2(0) = pushsw(3) then
        cnt_pushsw2 <= (others => '0');
      else
        if cnt_pushsw2(cnt_pushsw2'left) = '0' then
          cnt_pushsw2 <= cnt_pushsw2 + 1;
        else
          seq_pushsw2(0) <= pushsw(3);
        end if;
      end if;
      sig_caldelay <= seq_pushsw2(0) and (not seq_pushsw2(1));
      
      if pushsw(1) = '1' then
        cnt_delay <= (others => '0');
      elsif sig_delay = '1' then
        cnt_delay <= cnt_delay + 1;
      end if;
    end if;
  end process;
  
  ----------------------------------------------------------------------
  -- test input / output
  ----------------------------------------------------------------------
  map_b2tt: entity work.b2tt
    generic map (
      FLIPACK  => '0',
      USEICTRL => '1',
      USEPLL   => '1',
      USEFIFO  => '0' )
    port map (
      -- RJ-45
      clkp     => clk_p,
      clkn     => clk_n,
      trgp     => trg_p,
      trgn     => trg_n,
      ackp     => ack_p,
      ackn     => ack_n,
      rsvp     => rsv_p,
      rsvn     => rsv_n,

      -- alternative external clock source
      extclk    => '0',
      extclkinv => '0',
      extclkdbl => '0',
      extdblinv => '0',
      extclklck => '0',

      -- board id
      id       => (others => '0'),
      
      -- link status
      b2clkup  => sig_clkup,
      b2ttup   => sig_ttup,

      -- system clock and time
      sysclk   => clk_127,
      rawclk   => sig_raw127,
      --raw509   => sig_raw509,
      utime    => open_utime,
      ctime    => open_ctime,

      -- divided clock
      divclk1  => open_divclk1,
      divclk2  => open_divclk2,

      -- run reset
      exprun   => open_exprun,
      runreset => open_runreset,
      feereset => open_feereset,
      gtpreset => open_gtpreset,

      -- trigger
      trgout   => sig_trg,
      trgtyp   => open_trgtyp,
      trgtag   => sig_trgtag,
      
      -- revolution
      revo     => sig_revo,
      revo9    => open_revo9,
      revoclk  => open_revoclk,
      revogap  => open_revogap,
      injveto  => open_injveto,

      -- busy and status return
      busy     => '0',
      err      => '0',

      -- Belle2link status
      b2plllk  => '1', -- dummy
      b2linkup => '1', -- dummy
      b2linkwe => '0',
      b2lclk   => clk_127,

      -- SEU status (from virtex5_seu_controller)
      seuinit  => '0',
      seubusy  => '0',
      seuactiv => '0',
      seuscan  => '0',
      seudet   => '0',
      seucrc   => '0',
      seumbe   => '0',

      -- data for Belle2link header
      fifordy  => open_fifordy,
      fifodata => open_fifodata,
      fifonext => '0',

      -- b2tt-link status
      regdbg   => reg_dbg,
      octet    => open_octet,
      isk      => open_isk,
      cntbit2  => open_cntbit2,
      sigbit2  => open_sigbit2,
      dbglink  => sig_dbg,
      dbgerr   => open );
      --dbgerr   => sig_dbg,
      --dbglink  => open );
  
  ----------------------------------------------------------------------
  -- chipscope
  ----------------------------------------------------------------------
  gen_cs: if USE_CHIPSCOPE = '1' generate
    map_icon: entity work.b2tt_icon port map ( control0 => sig_ilacontrol );
    map_ila:  entity work.b2tt_ila
      port map (
        control => sig_ilacontrol,
        clk     => clk_127,
        trig0   => sig_dbg );

  end generate;

end implementation;
