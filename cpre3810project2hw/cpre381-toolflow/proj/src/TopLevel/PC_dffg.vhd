-------------------------------------------------------------------------
-- Isaiah Aldiano
-------------------------------------------------------------------------
-- PC_dffg.vhd 
-------------------------------------------------------------------------
-- DESCRIPTION: Contains implementation of the dffg used to implement the PC
-------------------------------------------------------------------------

use work.MIPS_types.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PC_dffg is -- Always writable
	port(i_Clk 		: in std_logic;
		i_WE 		: in std_logic; 
		i_Rst 		: in std_logic;
		i_Rst_init 	: in std_logic;
		i_D 		: in std_logic;
		o_Q 		: out std_logic
	);
end PC_dffg;

architecture mixed of PC_dffg is

	signal s_Q : std_logic; -- Output of FF
	signal s_D : std_logic; 
	
begin

	o_Q <= s_Q; -- singal output binded to output of FF

	with i_WE select 
		s_D <= i_D when '1',
				s_Q when others;

	process(i_Clk, i_Rst)
	begin 
		if(i_RST = '1') then
			s_Q <= i_Rst_init; -- on reset initalize to i_Rst_init value
		elsif(rising_edge(i_Clk)) then
			s_Q <= s_D; -- Else assign next PC value
		end if;
	end process;

end mixed;
	