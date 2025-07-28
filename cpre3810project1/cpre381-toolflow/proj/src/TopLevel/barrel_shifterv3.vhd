
-------------------------------------------------------------------------
-- Isaiah Aldiano
-------------------------------------------------------------------------
-- barrel_shifter.vhd 
-------------------------------------------------------------------------
-- DESCRIPTION: Implementation of a barrel shifter for ALU operations
-------------------------------------------------------------------------

use work.MIPS_types.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity barrel_shifterv3 is
	port(
		i_data 		: in std_logic_vector(31 downto 0);
		i_shamt 	: in std_logic_vector(4 downto 0); -- 5 bit shift value from instr or register
		i_alusig 	: in std_logic_vector(3 downto 0); -- 4 bit ALUSig
		o_data 		: out std_logic_vector(31 downto 0)
	);
end barrel_shifterv3;
	

architecture mixed of barrel_shifterv3 is 
	
	signal s_Data_Out : std_logic_vector(DATA_WIDTH-1 downto 0) := x"00000000";
	--signal s_sll : std_logic_vector(DATA_WIDTH-1 downto 0);
	--signal s_sllv : std_logic_vector(DATA_WIDTH-1 downto 0);
	--signal s_srl : std_logic_vector(DATA_WIDTH-1 downto 0);
	--signal s_srlv : std_logic_vector(DATA_WIDTH-1 downto 0);
	--signal s_sra : std_logic_vector(DATA_WIDTH-1 downto 0);
	--signal s_srav : std_logic_vector(DATA_WIDTH-1 downto 0);

	signal s_alusig0 : std_logic;
	signal s_alusig1 : std_logic;
	signal s_alusig2 : std_logic;
	signal s_alusig3 : std_logic;

begin 

	process(i_alusig, i_shamt, i_data) 
	begin

		s_alusig0 <= i_alusig(0);
		s_alusig1 <= i_alusig(1);
		s_alusig2 <= i_alusig(2);
		s_alusig3 <= i_alusig(3);

		if i_alusig(0) = '1' and i_alusig(1) = '1' and i_alusig(2) = '1' and i_alusig(3) = '1' then
			s_Data_Out <= std_logic_vector(shift_left(unsigned(i_data), to_integer(unsigned(i_shamt))));
		elsif i_alusig(0) = '0' and i_alusig(1) = '1' and i_alusig(2) = '1' and i_alusig(3) = '1' then
			s_Data_Out <= std_logic_vector(shift_right(unsigned(i_data), to_integer(unsigned(i_shamt))));
		elsif i_alusig(0) = '1' and i_alusig(1) = '0' and i_alusig(2) = '0' and i_alusig(3) = '1' then
			s_Data_Out <= std_logic_vector(shift_right(signed(i_data), to_integer(unsigned(i_shamt))));
		else
			s_Data_Out <= i_data;
		end if;
	end process;	
	
	o_data <= s_Data_Out;
end mixed;