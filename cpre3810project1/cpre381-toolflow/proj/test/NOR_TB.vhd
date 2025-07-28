-- Sam Burns
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- NOR_TB.vhd
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


entity NOR_TB is 
	generic(JUMP_INSTR: integer := 26;
		gCLK_HPER   : time := 10 ns); --generic for half the clock cycle period
end NOR_TB;

architecture structure of NOR_TB is

-- Define component to be tested
component norg2 is
  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_O          : out std_logic); 
end component;


--describe usefule signals for testing
signal si_A : std_logic := '0';
signal si_B : std_logic := '0';
signal so_O : std_logic;

begin 

NOR_TEST : norg2
port map(i_A => si_A,
	 i_B => si_B,
	 o_O => so_O);



-- Start test cases here 
P_TEST_CASES: process
    begin

	wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges

	--TEST CASE 1:
	si_A <= '0';
	si_B <= '0';
	wait for gCLK_HPER;
    	wait for gCLK_HPER;
	--Expected output for ALU_OUT should be 1

	--TEST CASE 2:
	si_A <= '1';
	si_B <= '1';
	wait for gCLK_HPER;
    	wait for gCLK_HPER;
	--Expected output for ALU_OUT should be 0

	--TEST CASE 3:
 	si_A <= '0';
	si_B <= '1';
	wait for gCLK_HPER;
    	wait for gCLK_HPER;
	--Expected output for ALU_OUT should be 0

	--TEST CASE 4:
 	si_A <= '1';
	si_B <= '0';
	wait for gCLK_HPER;
    	wait for gCLK_HPER;
	--Expected output for ALU_OUT should be 0





end process;
end structure;

