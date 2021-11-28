-- FIR filter in transposed structure
library IEEE;
use IEEE.std_logic_1164.all;	 
use IEEE.numeric_std.all;	

entity FIR_FILTER is
generic
	(
	XN_WIDTH: 		  positive := 16;  -- width x[n] 
	YN_WIDTH: 		  positive := 16;  -- width y[n]
	COEFF_WIDTH: 	positive := 8;  -- width COEFF a_k
	PROD_WIDTH: 	 positive := 24;  -- full width product COEFF(I) * XN
	TAPS: 			     positive := 129   -- FIR filter order M
	);
port
	(CLK: 	in    std_logic;		        						-- clock
	 RESET_N:in  std_logic;		 	  							 -- asynch reset, active-low
	 FIR_EN: in std_logic;               -- FIR filter operation enable
	 XN: 		in  signed(XN_WIDTH-1 downto 0); -- filter input
	 YN: 		out signed(YN_WIDTH-1 downto 0));-- filter output
end FIR_FILTER;

architecture FIR_TRANSPOSE of FIR_FILTER is
type COEFF_TYPE is array(0 to TAPS-1)  of signed (COEFF_WIDTH-1 downto 0);	 
type PROD_TYPE 	is array(0 to TAPS-1)  of signed (YN_WIDTH-1 downto 0);	
type ADD_TYPE 		is array(0 to TAPS-1)  of signed (YN_WIDTH-1 downto 0);	

signal COEFF: COEFF_TYPE :=(
"00000000",   "00000000",   "00000000",   "00000000",   "00000000",   "00000000",   "00000000",   "00000000",   "00000000",   "00000000",   "00000000",
"00000000",   "00000000",   "00000000",   "00000000",   "00000000",   "00000000",   "00000000",   "00000000",   "11111111",   "00000000",   "11111111",
"00000000",   "11111111",   "00000000",   "11111111",   "00000000",   "11111111",   "00000000",   "11111111",   "00000000",   "11111111",   "00000000",
"11111110",   "00000000",   "11111110",   "00000000",   "11111110",   "00000000",   "11111110",   "00000000",   "11111101",   "00000000",   "11111101",
"00000000",   "11111100",   "00000000",   "11111100",   "00000000",   "11111011",   "00000000",   "11111010",   "00000000",   "11111001",   "00000000",
"11110111",   "00000000",   "11110101",   "00000000",   "11110000",   "00000000",   "11100101",   "00000000",   "10101111",   "00000000",   "01010001",
"00000000",   "00011011",   "00000000",   "00010000",   "00000000",   "00001011",   "00000000",   "00001001",   "00000000",   "00000111",   "00000000",
"00000110",   "00000000",   "00000101",   "00000000",   "00000100",   "00000000",   "00000100",   "00000000",   "00000011",   "00000000",   "00000011",
"00000000",   "00000010",   "00000000",   "00000010",   "00000000",   "00000010",   "00000000",   "00000010",   "00000000",   "00000001",   "00000000",
"00000001",   "00000000",   "00000001",   "00000000",   "00000001",   "00000000",   "00000001",   "00000000",   "00000001",   "00000000",   "00000001", 
"00000000",   "00000000",   "00000000",   "00000000",   "00000000",   "00000000",   "00000000",   "00000000",   "00000000",   "00000000",   "00000000",
"00000000",   "00000000",   "00000000",   "00000000",   "00000000",   "00000000",   "00000000",   "00000000"
);	 -- FIR coefficients
signal ADD: ADD_TYPE; 		   -- accumulated signals in register chain
signal PROD: PROD_TYPE;  		-- COEF*XN rounded to output width (YN_WIDTH)

begin  
ADD_STAGES: process(CLK, RESET_N) 
begin 	
	if CLK='1' and CLK'event then	 		
	   if RESET_N ='0' then	
		   ADD <= (others => (others => '0')) after 3 ns; 
	   else  
	      if FIR_EN='1' then
		      ADD(TAPS-1) <= PROD(TAPS-1) after 3 ns; 
		      for I in (TAPS-2) downto 0  loop		 
		         ADD(I) <= ADD(I+1) + PROD(I) after 3 ns; 
		      end loop;				
		   end if;
	   end if;
	end if;
end process ADD_STAGES;
YN <= signed(ADD(0));


MULT: process(XN,COEFF)
variable PROD_TMP: signed(PROD_WIDTH-1 downto 0);	-- COEF*XN at full width	       
begin
	for I in 0 to (TAPS-1) loop	
		PROD_TMP := signed(XN) * COEFF(I); 
		PROD(I)  <= PROD_TMP(PROD_WIDTH-2 downto PROD_WIDTH-YN_WIDTH-1);
   end loop;
end process MULT;
					
end FIR_TRANSPOSE;