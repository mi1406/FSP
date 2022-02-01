library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity AUDIO_PROCESSING_DUMMY_TB is
end AUDIO_PROCESSING_DUMMY_TB;

architecture SIM of AUDIO_PROCESSING_DUMMY_TB is

--DUT
component AUDIO_PROCESSING_DUMMY is
generic(W : integer := 16; myWidth : integer := 8; lutSize : integer := 48; sizeOfDelay : integer := 67);
	port(
		CLK				: in std_logic;
		SRESETN				: in std_logic;
		AUDIO_IN_L			: in std_logic_vector(W-1 downto 0);
		AUDIO_IN_R			: in std_logic_vector(W-1 downto 0);
		START_L				: in std_logic;
		START_R	          		: in std_logic;
		IOM_SW0				: in std_logic;
		IOM_SW1				: in std_logic;
		IOM_SW2				: in std_logic;
		AUDIO_OUT_L			: out std_logic_vector(W-1 downto 0);
		AUDIO_OUT_R			: out std_logic_vector(W-1 downto 0)
	);
end component AUDIO_PROCESSING_DUMMY;

-- Testbench Internal Signals
file FILE_AUDIO_IN  : text;
file FILE_AUDIO_OUT : text;

constant CLK_PERIOD: time := 10 ns; -- clock period (1/100 MHz)
constant SYSCTL_PERIOD: time := 80 ns; -- bit clock (8/100 MHz)
constant BCK_PERIOD: time := 640 ns; -- bit clock (8*8/100 MHz)
constant LRC_PERIOD: time := 20480 ns; -- LRC period (32*8*8/100MHz = approx 1/48kHz, 20.08333... would be accurate)
constant CDELAY : time :=  2 ns;    -- combinational delay

signal CLK : std_logic :='1';
signal SRESETN 	: std_logic;
signal AUDIO_IN_L : std_logic_vector(16-1 downto 0);
signal AUDIO_IN_R : std_logic_vector(16-1 downto 0);
signal START_L : std_logic;
signal START_R : std_logic;
signal AUDIO_OUT_L : std_logic_vector(16-1 downto 0);
signal AUDIO_OUT_R : std_logic_vector(16 - 1 downto 0);

begin
-- CLK and SRESETN generation by unconditional assignement 
	CLK <= not CLK after CLK_PERIOD / 2 ; -- actually a combinational loop -> oscillator 
	SRESETN <= '0', '1' after 55 ns;      -- non periodic, giving values directly like in force instruction
DUT: AUDIO_PROCESSING_DUMMY port map(CLK, SRESETN, AUDIO_IN_L, AUDIO_IN_R, START_L, START_R, AUDIO_OUT_L, AUDIO_OUT_R);

AUDIO_IN_L <= "0000000000000000", "0000000100000100" after SYSCTL_PERIOD,     "0000000000000000" after SYSCTL_PERIOD * 2,   "0000000001001100" after SYSCTL_PERIOD * 3;
AUDIO_IN_R <= "0000000000000000", "0000000000110100" after SYSCTL_PERIOD * 2, "0000000000000000" after SYSCTL_PERIOD * 3,   "0000000000110001" after SYSCTL_PERIOD * 4;
SRESETN <= '0', '1' after CDELAY;
START_L <= '0', '1' after CDELAY, '0' after CDELAY * 2, '1' after CDELAY * 3;     
START_R <= '0', '1' after CDELAY * 2, '0' after CDELAY * 3, '1' after CDELAY * 4;

end architecture;