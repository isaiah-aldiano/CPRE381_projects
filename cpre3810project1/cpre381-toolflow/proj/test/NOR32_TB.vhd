-- Sam Burns
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- NOR32_TB.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the ALU
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


entity NOR32_TB is 
	generic(JUMP_INSTR: integer := 26;
		gCLK_HPER   : time := 10 ns); --generic for half the clock cycle period
end NOR32_TB;

architecture structure of NOR32_TB is

-- Define component to be tested
component norNBit is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_A         : in std_logic_vector(N-1 downto 0);
       i_B         : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));
end component;


--describe usefule signals for testing
signal si_A : std_logic_vector(31 downto 0) := x"00000000";
signal si_B : std_logic_vector(31 downto 0) := x"00000000";
signal so_O : std_logic_vector(31 downto 0);

begin 

NOR_TEST : norNBit
generic map( N => 32)
port map(i_A => si_A,
	 i_B => si_B,
	 o_O => so_O);



-- Start test cases here 
P_TEST_CASES: process
    begin

	wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges

	--TEST CASE 1:
	si_A <= x"00000000";
	si_B <= x"00000000";
	wait for gCLK_HPER;
    	wait for gCLK_HPER;
	--Expected output for ALU_OUT should be x"FFFFFFFF"

	--TEST CASE 2:
	si_A <= x"FFFFFFFF";
	si_B <= x"FFFFFFFF";
	wait for gCLK_HPER;
    	wait for gCLK_HPER;
	--Expected output for ALU_OUT should be x"00000000"

	--TEST CASE 3:
 	si_A <= x"FFFFFFFF";
	si_B <= x"00000000";
	wait for gCLK_HPER;
    	wait for gCLK_HPER;
	--Expected output for ALU_OUT should be x"00000000"

	--TEST CASE 4:
 	si_A <= x"00000000";
	si_B <= x"FFFFFFFF";
	wait for gCLK_HPER;
    	wait for gCLK_HPER;
	--Expected output for ALU_OUT should be x"00000000"





end process;
end structure;
