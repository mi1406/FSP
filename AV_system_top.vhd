--
--  "AV_system_top" instantiates both audio processing and video processing 
--  with correct timing of HSYNC, VSYNC and pixel coordinates X,Y
--  In the image processing pipeline: 
--  -   moving_sine_disp creates a moving sine from look-up table
--      with changing colors
--  - chess_board_disp overlays a chess board in the backgroud of 
--    the sine
--
--  1.5.2020 LTL
--


library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity AV_system_top is 
port(
    clk	 				: in std_logic;
	sresetn 			: in std_logic;
	-- clock signals (to audio codec)
	SYSCLK, BCK, LRC: out std_logic;
	-- serial data in
	DIN: in std_logic;
	IOM_SW0			: in std_logic;
	IOM_SW1			: in std_logic;
	IOM_SW2			: in std_logic;
	-- serial data out
	DOUT: out std_logic;
	hSync				: out std_logic;
	vSync 				: out std_logic;
	dviClk  			: out std_logic;
	dviDataEn			: out std_logic;
	vgaClk  			: out std_logic;
	vgaNSync, vgaNBlanc : out std_logic;
	pixelRGBData	 	: out unsigned(23 downto 0)
);
end entity; 

architecture structural of AV_system_top is

component video_system_top is 
	port( 	clk	 				: in std_logic;
			sresetn 			: in std_logic;
			hSync				: out std_logic;
			vSync 				: out std_logic;
			dviClk  			: out std_logic;
			dviDataEn			: out std_logic;
			vgaClk  			: out std_logic;
			vgaNSync            : out std_logic;
			vgaNBlanc           : out std_logic;
			pixelRGBData	 	: out unsigned(23 downto 0)
	);
end component video_system_top;

component AUDIO_SYSTEM_TOP is
	generic(W : integer := 16);
	port(
		CLK, SRESETN : in std_logic;
		-- clock signals (to audio codec)
		SYSCLK, BCK, LRC: out std_logic;
		-- serial data in
		DIN: in std_logic;
	IOM_SW0			: in std_logic;
	IOM_SW1			: in std_logic;
	IOM_SW2			: in std_logic;
		-- serial data out
		DOUT: out std_logic
		);
end component AUDIO_SYSTEM_TOP;

begin
audio : AUDIO_SYSTEM_TOP
 port map(CLK    =>  clk,
        SRESETN  =>  sresetn,
        SYSCLK   =>  SYSCLK,
        BCK      =>  BCK,
        LRC      =>  LRC,
        DIN      =>  DIN,
	IOM_SW0 => IOM_SW0,
IOM_SW1 => IOM_SW1,
IOM_SW2 => IOM_SW2,
        DOUT     =>  DOUT);

video : video_system_top
port map(clk	 	  =>      clk,
		sresetn 	  =>      sresetn,
		hSync		  =>      hSync,
		vSync         =>      vSync,
        dviClk        =>      dviClk,
		dviDataEn	  =>      dviDataEn,
		vgaClk  	  =>      vgaClk,
		vgaNSync      =>      vgaNSync, 
        vgaNBlanc     =>      vgaNBlanc,
		pixelRGBData  =>      pixelRGBData
	);

end architecture structural;