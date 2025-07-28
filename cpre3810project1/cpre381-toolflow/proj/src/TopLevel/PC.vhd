-------------------------------------------------------------------------
-- Isaiah Aldiano
-------------------------------------------------------------------------
-- PC.vhd 
-------------------------------------------------------------------------
-- DESCRIPTION: Contains implementation of the MIPS PC used in instr fetch logic
-------------------------------------------------------------------------

use work.MIPS_types.all;
Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PC is 
	port(i_Clk : in std_logic;
		i_Rst : in std_logic; -- 1 resets to 0x00400000
		i_D : in std_logic_vector(DATA_WIDTH-1 downto 0);
		o_Addr : out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end PC;

architecture mixed of PC is

	constant RESET_VALUE : std_logic_vector := x"00400000";
	
	component PC_dffg -- Always writable
		port(i_Clk : in std_logic;
			i_Rst : in std_logic;
			i_Rst_init : in std_logic; -- 1 bit of RESET_VALUE
			i_D : in std_logic;
			o_Q : out std_logic
		);
	end component;
	
	signal s_RESET_VALUE : std_logic_vector(DATA_WIDTH-1 downto 0); -- Reset

begin 

	 
	s_RESET_VALUE <= RESET_VALUE;

	G_Nbit_PC_dffg: for i in 0 to DATA_WIDTH-1 generate
		PC_REG : PC_dffg
			port map(i_Clk => i_clk,
				i_RST => i_rst, -- 1 resets PC value to 0x00400000
				i_Rst_init => s_RESET_VALUE(i),  
				i_D => i_d(i),
				o_Q => o_Addr(i)
			);
	end generate G_Nbit_PC_dffg;
end mixed;