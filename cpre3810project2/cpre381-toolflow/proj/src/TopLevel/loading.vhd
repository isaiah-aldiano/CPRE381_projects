-------------------------------------------------------------------------
-- Isaiah Aldiano
-------------------------------------------------------------------------
-- loading.vhd 
-------------------------------------------------------------------------
-- DESCRIPTION: Contains logic for loading a byte, word, half word to MUXDMEMOUT
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.MIPS_types.all;

entity loading is 
	generic(
		LB_WIDTH : integer := 8
		);
	port(
		i_DMEM 		: 	in std_logic_vector(DATA_WIDTH-1 downto 0);
		i_RESULT_LB : 	in std_logic_vector(1 downto 0);
		i_RESULT_LH : 	in std_logic;
		i_LB 		: 	in std_logic;
		i_LH 		: 	in std_logic;
		i_LHU 		: 	in std_logic;
		i_LW 		: 	in std_logic;
		o_DMEM		:   out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end loading;

architecture structure of loading is

	component mux2t1_N is
		generic(N : integer := 32);
		port(
			i_S 	: in std_logic;
			i_D0	: in std_logic_vector(N - 1 downto 0);
			i_D1 	: in std_logic_vector(N - 1 downto 0);
			o_O 	: out std_logic_vector(N - 1 downto 0)
		);
	end component;

	component mux4t1_N is
		 generic(
				N : integer := 8;
		  		BYTE : integer := 2); 
		port(
			i_S          : in std_logic_vector(BYTE-1 downto 0); -- result[1:0]
       		i_D0         : in std_logic_vector(N-1 downto 0); -- [7:0]
       		i_D1         : in std_logic_vector(N-1 downto 0); -- [15:8]
	   		i_D2         : in std_logic_vector(N-1 downto 0); -- [23:16]
	   		i_D3         : in std_logic_vector(N-1 downto 0); -- [31:24]
       		o_O          : out std_logic_vector(N-1 downto 0)
		);
	end component;

--	component SignExtend is 
--		port(
--			data 			: in std_logic_vector(15 downto 0);
--			extend_sel 		: in std_logic;
--			extended_out 	: out std_logic_vector(31 downto 0)
--		);
--	end component;

	component SignExtend_N is
		generic(
			DATA_IN : integer := 16;
			EXTEND_TO : integer := 32
		);
    	port(
			data : in std_logic_vector(DATA_IN-1 downto 0);
        	extend_sel : in std_logic;
        	extended_out : out std_logic_vector(EXTEND_TO-1 downto 0)
		);
	end component;

	component xorg2 is
		port(
			i_A : in std_logic;
			i_B : in std_logic;
			o_F : out std_logic
		);
	end component;

	signal s_LBMUX_RES 		: std_logic_vector(LB_WIDTH-1 downto 0);
	signal s_LBMUX_TEMP 	: std_logic_vector(DATA_WIDTH/2-1 downto 0);
	signal s_LB_EXT 		: std_logic_vector(DATA_WIDTH-1 downto 0);

	signal s_LHMUX0_RES 	: std_logic_vector(DATA_WIDTH/2 - 1 downto 0);
	signal s_LHMUX_TEMP 	: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal s_LH_XOR 		: std_logic;

	signal s_LHMUX1_RES : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

	LB_MUX : mux4t1_N -- determines the byte to load
		port map(
			i_S => i_RESULT_LB,
			i_D0 => i_DMEM(7 downto 0),
			i_D1 => i_DMEM(15 downto 8),
			i_D2 => i_DMEM(23 downto 16),
			i_D3 => i_DMEM(31 downto 24),
			o_O => s_LBMUX_RES
		);

	
	--s_LBMUX_TEMP <= (7 downto 0 => '0') & s_LBMUX_RES; -- fills zeros just to send to sign/zero extend
	
	LB_SIGN_EXT : SignExtend_N -- sign extends the byte value to 32 bits
	
	--TODO: probably just create new sign extender that extends 8 to 32 bits 
		generic map(
			DATA_IN => 8,
			EXTEND_TO => 32
		)
		port map(
			data => s_LBMUX_RES,
			extend_sel => i_LB,
			extended_out => s_LB_EXT
		);
			
	LH_MUX0 : mux2t1_N -- determines the half word to load
		generic map (N => 16)
		port map(
			i_S => 	i_RESULT_LH,
			i_D0 => i_DMEM(15 downto 0),
			i_D1 => i_DMEM(31 downto 16),
			o_O => s_LHMUX0_RES
		);

	LH_XOR : xorg2 -- xors LH and LHU for sign or zero extend
		port map(
			i_A => i_LH,
			i_B => i_LHU,
			o_F => s_LH_XOR
		);

	LH_SIGN_EXT : SignExtend_N -- sign or zero extends half word
		generic map(
			DATA_IN => 16,
			EXTEND_TO => 32
		)
		port map(
			data => s_LHMUX0_RES,
			extend_sel => S_LH_XOR,
			extended_out => s_LHMUX_TEMP
		);
	
	LH_MUX1 : mux2t1_N -- muxes between lb and lh values
		generic map (N => 32)
		port map(
			i_S => i_LH,
			i_D0 => s_LB_EXT,
			i_D1 => s_LHMUX_TEMP,
			o_O => s_LHMUX1_RES
		);
	
	LW_MUX : mux2t1_N -- muxes between lw and lb/lh value
		port map(
			i_S => i_LW,
			i_D0 => s_LHMUX1_RES,
			i_D1 => i_DMEM,
			o_O => o_DMEM
		);
		
end structure;