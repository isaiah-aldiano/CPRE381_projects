-- Sam Burns
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- LUI_TB.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the xor
--             
-- created 11:50 on 3/30/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O
use work.MIPS_types.all;


entity LUI_TB is 
	generic(JUMP_INSTR: integer := 26;
		gCLK_HPER   : time := 10 ns); --generic for half the clock cycle period
end LUI_TB;

architecture structure of LUI_TB is

-- Define component to be tested
component LUI is 
generic(DATA_WIDTH : integer := 32);
port (i_A : in std_logic_vector(DATA_WIDTH -1 downto 0);
      o_O : out std_logic_vector(DATA_WIDTH -1 downto 0));
end component;


--describe usefule signals for testing
signal si_A : std_logic_vector(31 downto 0) := x"00000000";
signal so_O : std_logic_vector(31 downto 0);

begin 

LUI_TEST : LUI
generic map(DATA_WIDTH => 32)
port map(i_A => si_A,
	 o_O => so_O);



-- Start test cases here 
P_TEST_CASES: process
    begin

	wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges

	--TEST CASE 1:
	si_A <= x"00000000";
	wait for gCLK_HPER;
    	wait for gCLK_HPER;
	--Expected output for ALU_OUT should be x"000000000"

	--TEST CASE 2:
	si_A <= x"00000001";
	wait for gCLK_HPER;
    	wait for gCLK_HPER;
	--Expected output for ALU_OUT should be x"000100000"

	--TEST CASE 3:
	si_A <= x"0000FFFF";
	wait for gCLK_HPER;
    	wait for gCLK_HPER;
	--Expected output for ALU_OUT should be x"FFFF0000"

	--TEST CASE 4:
	si_A <= x"00001001";
	wait for gCLK_HPER;
    	wait for gCLK_HPER;
	--Expected output for ALU_OUT should be x"100100000"





end process;
end structure;
