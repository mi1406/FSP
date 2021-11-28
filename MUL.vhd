library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MUL is generic(W : integer := 8);
port(
CLK	 : in std_logic;
X : in signed(W - 1 downto 0);
Y : in signed(2 * W - 1 downto 0);
YN : out std_logic_vector(2 * W - 1 downto 0)
);
end MUL;

architecture BEHAVIOUR of MUL is

begin
MULT :  process(CLK)
variable TMP : signed(3* W - 1 downto 0);
begin
if rising_edge(CLK) then
    TMP := X * Y;
--	TMP :=  resize(TMP, 16);
    YN <= std_logic_vector(TMP(TMP'length - 1 downto TMP'length - 2 * W));
end if;
end process;
end BEHAVIOUR;

