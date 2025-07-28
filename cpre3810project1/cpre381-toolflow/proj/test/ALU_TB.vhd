-- Sam Burns
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- ALU_TB.vhd
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


entity ALU_TB is 
	generic(JUMP_INSTR: integer := 26;
			 gCLK_HPER   : time := 10 ns); --generic for half the clock cycle period
end ALU_TB;

architecture structure of ALU_TB is

-- Define component to be tested
component ALU is 
port(i_Overflow : in std_logic;
     i_ALUOp : in std_logic_vector(3 downto 0);
     i_Shamt : in std_logic_vector(4 downto 0);
     i_INA : in std_logic_vector(31 downto 0);
     i_INB : in std_logic_vector(31 downto 0);
     o_Overflow : out std_logic;
     o_Zero : out std_logic;
     o_ALUResult : out std_logic_vector(31 downto 0));
end component;


--describe usefule signals for testing
signal si_Overflow : std_logic := '0';
signal si_ALUOp : std_logic_vector(3 downto 0) := x"0";
signal si_Shamt : std_logic_vector(4 downto 0) := b"00000";
signal si_INA : std_logic_vector(31 downto 0) := x"00000000";
signal si_INB : std_logic_vector(31 downto 0) := x"00000000";
signal so_Overflow : std_logic;
signal so_Zero : std_logic;
signal o_ALUResult : std_logic_vector(31 downto 0);

begin 

ALU_TEST : ALU 
  port map(i_Overflow => si_Overflow,
           i_ALUOp => si_ALUOp,
           i_Shamt => si_Shamt, --TODO: WILL NEED TO ASSIGN THIS ONCE BARREL SHIFTER IS ADDED
           i_INA => si_INA,
           i_INB => si_INB,
           o_Overflow => so_Overflow,
           o_Zero => so_Zero,
           o_ALUResult => o_ALUResult);



-- Start test cases here 
P_TEST_CASES: process
    begin

	wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges

	--TEST CASE 1: add (overflow is not yet implemented so it will be zero for now as will shift amount)
	si_Overflow <= '0';
	si_ALUOp <= b"0010";
	si_Shamt <= b"00000";
	si_INA <= x"00000001";
	si_INB <= x"00000002";
	wait for gCLK_HPER;
    	wait for gCLK_HPER;
	--Expected output for ALU_OUT should be x"00000003"

	--TEST CASE 2: sub (overflow is not yet implemented so it will be zero for now as will shift amount)
	si_Overflow <= '1';
	si_ALUOp <= b"0100";
	si_Shamt <= b"00000";
	si_INA <= x"00000001";
	si_INB <= x"00000002";
	wait for gCLK_HPER;
    	wait for gCLK_HPER;
	--Expected output for ALU_OUT should be x"FFFFFFFF"

	--TEST CASE 3: LUI (overflow is not yet implemented so it will be zero for now as will shift amount)
	si_Overflow <= '0';
	si_ALUOp <= b"1010";
	si_Shamt <= b"00000";
	si_INA <= x"00000000"; --Does not matter here
	si_INB <= x"00001001";
	wait for gCLK_HPER;
    	wait for gCLK_HPER;
	--Expected output for ALU_OUT should be x"10010000"


	--TEST CASE 4: add (overflow is implemented so it should be 1
	si_Overflow <= '0';
	si_ALUOp <= b"1010";
	si_Shamt <= b"00000";
	si_INA <= x"7FFFFFFF"; --Does not matter here
	si_INB <= x"7FFFFFFF";
	wait for gCLK_HPER;
    	wait for gCLK_HPER;
	--Expected output for ALU_OUT should be x"10010000"


	--TEST CASE 5: XOR
	si_Overflow <= '0';
	si_ALUOp <= b"1000";
	si_Shamt <= b"00000";
	si_INA <= x"FFFFFFFF"; --Does not matter here
	si_INB <= x"FFFFFFFF";
	wait for gCLK_HPER;
    	wait for gCLK_HPER;
	--Expected output for ALU_OUT should be x"00000000"

	--TEST CASE 6: XOR
	si_Overflow <= '0';
	si_ALUOp <= b"1000";
	si_Shamt <= b"00000";
	si_INA <= x"00000000"; --Does not matter here
	si_INB <= x"FFFFFFFF";
	wait for gCLK_HPER;
    	wait for gCLK_HPER;
	--Expected output for ALU_OUT should be x"FFFFFFFF"

	--TEST CASE 7: SLT
	si_Overflow <= '0';
	si_ALUOp <= b"0111";
	si_Shamt <= b"00000";
	si_INA <= x"00000001"; --Does not matter here
	si_INB <= x"00000000";
	wait for gCLK_HPER;
    	wait for gCLK_HPER;
	--Expected output for ALU_OUT should be x"00000001"

	--TEST CASE 8: SLT
	si_Overflow <= '0';
	si_ALUOp <= b"0111";
	si_Shamt <= b"00000";
	si_INA <= x"00000000"; --Does not matter here
	si_INB <= x"00000001";
	wait for gCLK_HPER;
    	wait for gCLK_HPER;
	--Expected output for ALU_OUT should be x"00000001"

	--TEST CASE 8: SLL
	si_Overflow <= '0';
	si_ALUOp <= b"1111";
	si_Shamt <= b"00001";
	si_INA <= x"00000000"; --Does not matter here
	si_INB <= x"00000001";
	wait for gCLK_HPER;
    	wait for gCLK_HPER;
	--Expected output for ALU_OUT should be x"00000002"






end process;
end structure;

