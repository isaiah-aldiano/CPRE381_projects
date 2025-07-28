
-------------------------------------------------------------------------
-- Isaiah Aldiano
-------------------------------------------------------------------------
-- tb_barrel_shifter.vhd 
-------------------------------------------------------------------------
-- DESCRIPTION: RAHHHHHHHHHHH testing barrel shifter
-------------------------------------------------------------------------


use work.MIPS_types.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity tb_barrel_shifter is
	generic(
		SH_AMT : integer := 5;
		ALU_SIG : integer := 4
	);
end tb_barrel_shifter;


architecture mixed of tb_barrel_shifter is

	constant clk_100 : time := 100 ns;

	component barrel_shifterv3 is
		port(
			i_data 		: in std_logic_vector(31 downto 0);
			i_shamt 	: in std_logic_vector(4 downto 0); -- 5 bit shift value from instr or register
			i_alusig 	: in std_logic_vector(3 downto 0); -- 4 bit ALUSig
			o_data 		: out std_logic_vector(31 downto 0)
		);
	end component;
	
	signal s_data 	: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal s_shamt 	: std_logic_vector(SH_AMT-1 downto 0);
	signal s_alusig : std_logic_vector(ALU_SIG-1 downto 0);
	signal so_D 	: std_logic_vector(DATA_WIDTH-1 downto 0) := x"00000000";
begin

	DUT : barrel_shifterv3 
		port map(
			i_data => s_data,
			i_shamt => s_shamt,
			i_alusig => s_alusig,
			o_data => so_D
		);

	tb_barrel_shifter : process
	begin
		-- shamt is muxed outside the ALU so shift amount source in the barrel shifter is ambiguous
		
		-- Test for SLL/SLLV instructions
		-- 0x0000_0001 -> 0x8000_0000
		s_data <= x"00000001"; 	-- 1 in LSB
		s_shamt <= "11111"; 	-- 31 bits 
		s_alusig <= "1111"; 	-- SLL/SLLV
		wait for clk_100;

		-- Test for SLL/SLLV instructions
		-- 0x0000_0001 -> 0x0000_8000
		s_data <= x"00000001"; -- 1 in LSB
		s_shamt <= "01111"; -- 15 bits 
 		s_alusig <= "1111"; -- SLL/SLLV
		wait for clk_100;

		-- Test for SLL/SLLV instructions
		-- 0x1234_5678 -> 0x5678_0000
		s_data <= x"12345678"; -- 1 in LSB
		s_shamt <= "10000"; -- 16 bits 
 		s_alusig <= "1111"; -- SLL/SLLV
		wait for clk_100;


		-- Test for SRL/SRLV instructions
		-- 0x8000_0000 -> 0x0000_0001
		s_data <= x"80000000"; -- 1 in MSB
		s_shamt <= "11111"; -- 31 bits
		s_alusig <= "1110"; -- SRL/SRLV
		wait for clk_100;

		-- Test for SRL/SRLV instructions
		-- 0x1234_5678 -> 0x0000_1234
		s_data <= x"12345678"; -- 0 in MSB
		s_shamt <= "10000"; -- 16 bits 
 		s_alusig <= "1110"; -- SRL/SRLV
		wait for clk_100;
		
		-- Test for SRA/SRAV instructions
		-- 0x8000_0000 -> 0xFFFF_FFFF
		s_data <= x"80000000"; -- 1 in MSB
		s_shamt <= "11111"; -- 31 bits
		s_alusig <= "1001"; -- SRA/SRAV
		wait for clk_100;

		-- Test for SRA/SRAV instructions
		-- 0x8234_5678 -> 0xFFFF_8234
		s_data <= x"82345678"; -- 1 in MSB
		s_shamt <= "10000"; -- 16 bits 
 		s_alusig <= "1001"; -- SRA/SRAV
		wait for clk_100;
	
		-- Test for SRA/SRAV instructions
		-- 0x1234_5678 -> 0x0000_1234
		s_data <= x"12345678"; -- 0 in LSB
		s_shamt <= "10000"; -- 16 bits 
 		s_alusig <= "1001"; -- SRA/SRAV
		wait for clk_100;

		-- Test for SRA/SRAV instructions
		-- 0x4000_0000 -> 0x0000_0001
		s_data <= x"40000000"; -- 0 in MSB
		s_shamt <= "11110"; -- 30 bits
		s_alusig <= "1001";
		wait for clk_100;

		-- Test for SRA/SRAV instructions
		-- 0x4000_0000 -> 0x0001_0000
		s_data <= x"40000000"; -- 0 in MSB
		s_shamt <= "01110"; -- 14 bits
		s_alusig <= "1001"; -- SRA/SRAV
		wait for clk_100;

		-- Test for SRA/SRAV instructions
		-- 0x8000_0000 -> 0xFFFF_0000
		s_data <= x"80000000"; -- 0 in MSB
		s_shamt <= "01111"; -- 15 bits
		s_alusig <= "1001"; -- SRA/SRAV
		wait for clk_100;
		
	end process;
		
end mixed;

