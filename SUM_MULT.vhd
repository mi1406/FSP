library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SUM_MULT is 
generic (W : integer := 8);
port(
CLK: 	in    std_logic;
SIN : in signed(W - 1 downto 0);
COS : in signed(W - 1 downto 0);
XN : in signed(2*W - 1 downto 0);
X_FILTERED : in signed(2 * W - 1 downto 0);
YN : out std_logic_vector(2 * W - 1 downto 0)
);
end SUM_MULT;

architecture BEHAVIOUR of SUM_MULT is

component MUL is 
generic(W : integer := 8);
port(
CLK: 	in    std_logic;
X: in signed(W - 1 downto 0);
Y : in signed(2*W -1 downto 0);
YN :  out std_logic_vector(2*W - 1 downto 0)
);
end component MUL;
signal PROD_L : std_logic_vector(2*W - 1 downto 0);
signal PROD_R : std_logic_vector(2*W - 1 downto 0);

begin
MUL_LEFT : MUL port map(CLK => CLK, X => COS, Y => XN, YN => PROD_L);
MUL_RIGHT : MUL port map(CLK => CLK, X => SIN, Y => X_FILTERED, YN => PROD_R);

SUM : process(CLK)
variable tmp : signed(2 * W - 1 downto 0) := (others => '0');
begin
if rising_edge(CLK) then
    tmp := signed(PROD_L) + signed(PROD_R);
    --if tmp'length >= W then
	--	report integer'image(tmp'length) severity failure;
    YN <= std_logic_vector(tmp(tmp'length - 1 downto tmp'length - (2 * W)));
  --  else 
 --       YN <= std_logic_vector(tmp);
 --   end if;
end if;
end process;
end BEHAVIOUR;
