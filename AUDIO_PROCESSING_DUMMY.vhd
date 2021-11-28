--------
-- TOP LEVEL ENTITY DUMMY MODULE
-- LTL, 26.4.2020 
--------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity AUDIO_PROCESSING is
	generic(W : integer := 16; myWidth : integer := 8; lutSize : integer := 48; sizeOfDelay : integer := 63);
	port(
		CLK					: in std_logic;
		SRESETN				: in std_logic;
		AUDIO_IN_L			: in std_logic_vector(W-1 downto 0);
		AUDIO_IN_R			: in std_logic_vector(W-1 downto 0);
		START_L				    : in std_logic;
		START_R	          		  : in std_logic;
		AUDIO_OUT_L			: out std_logic_vector(W-1 downto 0);
		AUDIO_OUT_R			: out std_logic_vector(W-1 downto 0)
	);
end AUDIO_PROCESSING;

architecture BEHAVIOUR of AUDIO_PROCESSING is

component FIR_FILTER is
generic
	(
	XN_WIDTH: 		  positive := 16;  -- width x[n] 
	YN_WIDTH: 		  positive := 16;  -- width y[n]
	COEFF_WIDTH: 	positive := 8;  -- width COEFF a_k
	PROD_WIDTH: 	 positive := 24;  -- full width product COEFF(I) * XN
	TAPS: 			     positive := 129    -- FIR filter order M
	);
port
	(CLK: 	in    std_logic;		        						-- clock
	 RESET_N:in  std_logic;		 	  							 -- asynch reset, active-low
	 FIR_EN: in std_logic;               -- FIR filter operation enable
	 XN: 		in  signed(XN_WIDTH-1 downto 0); -- filter input
	 YN: 		out signed(YN_WIDTH-1 downto 0));-- filter output
end component FIR_FILTER;

component SUM_MULT is
generic(W : integer := 8);
port(
	CLK: 	in    std_logic;
	SIN : in signed(W - 1 downto 0);
	COS : in signed(W - 1 downto 0);
	XN : in signed(2*W - 1 downto 0);
	X_FILTERED : in signed(2 * W - 1 downto 0);
	YN : out std_logic_vector(2 * W - 1 downto 0)
);
end component SUM_MULT;


signal AUDIO_REG_R, AUDIO_REG_MONO, AUDIO_REG_TMP : signed(W-1 downto 0);		
signal AUDIO_REG_L : std_logic_vector(W - 1 downto 0);
type RAM is array(natural range<>) of signed(myWidth - 1 downto 0);
type SHIFT_REGISTER is array(natural range<>) of signed(W - 1 downto 0);
signal FIR_EN : std_logic;
signal sinLUT : RAM(0 to 47) :=(    
b"00000000",   b"00010001",   b"00100001",   b"00110001",   b"01000000",   b"01001110",   b"01011011",   b"01100110",
b"01101111",   b"01110110",   b"01111100",   b"01111111",   b"01111111",   b"01111111",   b"01111100",   b"01110110",
b"01101111",   b"01100110",   b"01011011",   b"01001110",   b"01000000",   b"00110001",   b"00100001",   b"00010001",
b"00000000",   b"11101111",   b"11011111",   b"11001111",   b"11000000",   b"10110010",   b"10100101",   b"10011010",
b"10010001",   b"10001010",   b"10000100",   b"10000001",   b"10000000",   b"10000001",   b"10000100",   b"10001010",
b"10010001",   b"10011010",   b"10100101",   b"10110010",   b"11000000",   b"11001111",   b"11011111",   b"11101111"
); -- element 12 (starting from zero is the first for cos)
signal  DELAY_LINE : SHIFT_REGISTER(0 to sizeOfDelay);-- <= (others => (others => '0')); -- must be (N - 1)/2
signal sum : signed(W - 1 downto 0) := (others => '0');
signal buf : signed(myWidth - 1 downto 0);
signal debug_enter : std_logic;
signal SIN : signed(myWidth - 1 downto 0);
signal COS : signed(myWidth - 1 downto 0);
--signal minusOne : signed( )
begin 

-- 1 process VHDL modeling of register (left channel)
FIR_L :  FIR_FILTER port map(CLK => CLK, RESET_N => SRESETN, FIR_EN => FIR_EN, XN =>AUDIO_REG_MONO, YN => sum);
SUM_M : SUM_MULT port map(CLK => CLK, SIN => SIN, COS => COS, XN => DELAY_LINE(sizeOfDelay), X_FILTERED => sum, YN => AUDIO_REG_L); 
DUMMY_L: process(CLK)
begin 

	if rising_edge(CLK) then
		if SRESETN = '0' then
			AUDIO_REG_L <= (others=>'0');
			AUDIO_REG_R <= (others => '0');AUDIO_REG_MONO <= (others=>'0'); AUDIO_REG_TMP <= (others=>'0');
		else
			if START_L='1' then
				AUDIO_REG_TMP <= signed(AUDIO_IN_L);
 			elsif START_R = '1' then
				AUDIO_REG_MONO <= AUDIO_REG_TMP + signed(AUDIO_IN_R);
				FIR_EN <= '1';
			
			end if;
		end if;
	end if;
end process;

DUMMY_STORE : process(CLK)
begin
if rising_edge(CLK) then
	if SRESETN = '0' then
		for i in DELAY_LINE'range loop
			DELAY_LINE(i) <= (others => '0');
		end loop;
	end if;
		if START_R = '1' then
			for j in sizeOfDelay downto 1 loop
				DELAY_LINE(j) <= DELAY_LINE(j - 1);
			end loop;
			DELAY_LINE(0) <= AUDIO_REG_MONO;
		end if;
	--end if;
end if;
end process;


write_back : process(CLK)
-- asynchronous assignment from register to output
variable counter_sin : integer range 0 to 47 := 24;
variable counter_cos : integer range 0 to 47:= 36;
variable tmp_reg : signed(W -1 downto 0);
variable tmp_reg1 : signed(W -1 downto 0);
begin
	--FIR_EN <= '0';
if rising_edge(CLK) then
	if START_R = '1' then
	--AUDIO_REG_L
	--tmp_reg := resize(sum * sinLUT(counter_sin), 16);
	--tmp_reg1 := resize((DELAY_LINE(sizeOfDelay)* sinLUT(counter_cos)), 16);
	SIN <=  sinLUT(counter_sin);
	COS <= sinLUT(counter_cos);
--	 AUDIO_REG_L<= tmp_reg + tmp_reg1;--resize((sum * sinLUT(counter_sin) + (DELAY_LINE(sizeOfDelay)* sinLUT(counter_cos))), 16); -- delay line index needs to be 63?
--	AUDIO_OUT_R <= std_logic_vector(tmp_reg);--resize((sum * sinLUT(counter_sin) + (DELAY_LINE(sizeOfDelay)* sinLUT(counter_cos))), 16); -- delay line index needs to be 63?
	if counter_sin = 47 then
		counter_sin := 0;
	else 
		counter_sin := counter_sin + 1;
	end if;
	if counter_cos = 47 then
	counter_cos := 0;
	else 
	counter_cos := counter_cos +  1;
	end if;
	end if;
end if;

end process;

latch_out: process(AUDIO_REG_L)
variable tmp_left : std_logic_vector(W - 1 downto 0);
begin
	tmp_left := std_logic_vector(AUDIO_REG_L);
	AUDIO_OUT_L	<=  tmp_left; --after 2 ns;		-- "0000000000100000" after 2 ns;
	AUDIO_OUT_R     <=  tmp_left;-- std_logic_vector(AUDIO_REG_L);-- after 4 ns;      --"0000000010000000" after 4 ns;
end process;
end BEHAVIOUR;
