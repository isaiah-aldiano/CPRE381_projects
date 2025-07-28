-------------------------------------------------------------------------
-- Isaiah Aldiano
-------------------------------------------------------------------------
-- tb_loading.vhd 
-------------------------------------------------------------------------
-- DESCRIPTION: Test benches for loading module for load b/bu/h/hu/w
-------------------------------------------------------------------------


use work.MIPS_types.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_loading is 
	generic(
		LB_WIDTH : integer := 8
	);
end tb_loading;

architecture mixed of tb_loading is

	constant clk_100 : time := 100 ns;

	component loading is
		port(
			i_DMEM 		: 	in std_logic_vector(DATA_WIDTH-1 downto 0);
			i_RESULT_LB : 	in std_logic_vector(1 downto 0);
			i_RESULT_LH : 	in std_logic;
			i_LB 		: 	in std_logic;
			i_LHU 		: 	in std_logic;
			i_LH 		: 	in std_logic;
			i_LW 		: 	in std_logic;
			o_DMEM		:   out std_logic_vector(DATA_WIDTH-1 downto 0)
		);
	end component;

	signal s_DMEM : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal s_RESULT_LB : std_logic_vector(1 downto 0);
	signal s_RESULT_LH : std_logic;
	signal s_LB 		: 	std_logic;
	signal s_LHU 		: 	std_logic;
	signal s_LH 		:   std_logic;
	signal s_LW 		: 	std_logic;
	signal so_DMEM		:   std_logic_vector(DATA_WIDTH-1 downto 0);
begin

	LOADING_COMP: loading
		port map(
			i_DMEM 		=> s_DMEM,
			i_RESULT_LB => s_RESULT_LB,
			i_RESULT_LH => s_RESULT_LH,
			i_LB 		=> s_LB,
			i_LHU 		=> s_LHU,
			i_LH 		=> s_LH,
			i_LW 		=> s_LW,
			o_DMEM		=> so_DMEM
		);

	TB_LOADING : process
	begin
		s_DMEM <= x"000000FF"; -- expected: 0x000000FF
		s_RESULT_LB <= "00"; -- [7:0]
		s_LB <= '0'; -- 0 extend
		s_LH <= '0'; -- LB 
		s_LW <= '1'; -- LB/LH
		wait for clk_100; 

		s_DMEM <= x"000000FF"; -- expected: 0xFFFFFFFF
		s_RESULT_LB <= "00"; -- [7:0]
		s_LB <= '1'; -- sign extend
		s_LH <= '0'; -- LB 
		s_LW <= '1'; -- LB/LH
		wait for clk_100;

		s_DMEM <= x"00FF0000"; -- expected: 0x000000FF
		s_RESULT_LB <= "10"; -- [23:16]
		s_LB <= '0'; -- 0 extend
		s_LH <= '0'; -- LB 
		s_LW <= '1'; -- LB/LH
		wait for clk_100;

		s_DMEM <= x"00FF0000"; -- expected: 0xFFFFFFFF
		s_RESULT_LB <= "10"; -- [23:16]
		s_LB <= '1'; -- sign extend
		s_LH <= '0'; -- LB 
		s_LW <= '1'; -- LB/LH
		wait for clk_100;

		s_DMEM <= x"82340000"; -- expected: 0x00008234
		s_RESULT_LH <= '1'; -- [32:16]
		s_LH <= '1'; -- (LH xor LHU) = zero extend 
		s_LHU <= '1'; 
		s_LW <= '1'; -- LB/LH
		wait for clk_100;

		s_DMEM <= x"82340000"; -- expected: 0xFFFF8234
		s_RESULT_LH <= '1'; -- [32:16]
		s_LH <= '1'; -- (LH xor LHU) = sign extend 
		s_LHU <= '0'; 
		s_LW <= '1'; -- LB/LH
		wait for clk_100;

		s_DMEM <= x"12345678"; -- expected: 0x1234678
		s_LW <= '0'; -- LW
		wait for clk_100;
	end process;

end mixed;