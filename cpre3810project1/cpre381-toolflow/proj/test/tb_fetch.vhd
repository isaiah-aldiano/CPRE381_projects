-- Sam Burns
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_fetch.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the fetch logic
--             
-- created 22:30 on 3/09/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O
use work.MIPS_types.all;


entity tb_fetch is 
	generic(JUMP_INSTR: integer := 26;
			 gCLK_HPER   : time := 10 ns); --generic for half the clock cycle period
end tb_fetch;

architecture structure of tb_fetch is

-- Define component to be tested
component fetch is 
	generic(JUMP_INSTR: integer := 26);
	port(
		i_clk 			: 			in std_logic; -- Clock signal\
		i_rst 			: 			in std_logic; -- Set PC to 0x0040_0000
		i_branch 		:  			in std_logic; -- Branch (1) or PC+4 (0)
		i_jump 			: 			in std_logic; -- Jump (1) or BranchMux result (0)
		i_jr 			: 			in std_logic; -- Jump Reg (1) or JumpMux result (0)
		i_jumpreg 		:	 		in std_logic_vector(DATA_WIDTH-1 downto 0); -- Jump value from register
		i_jumpinstr		:			in std_logic_vector(JUMP_INSTR-1 downto 0); -- Jump value from J-Type
		i_bne 			: 			in std_logic; -- Swithes branch mux for BEQ and BNE
		i_zero 			: 			in std_logic; -- Carries 0/1 from ALU output
		i_sign_ext_imm 	: 			in std_logic_vector(DATA_WIDTH-1 downto 0); -- Sign extended input to be SL2
		--i_instr 		: 			in std_logic_vector(DATA_WIDTH-1 downto 0); -- Instruction determined from fetch logic
		o_next_addr 	: 			out std_logic_vector(DATA_WIDTH-1 downto 0) -- Output of next given instruction
	);
end component;

-- Instantiate signals 
	signal si_clk : std_logic := '0';
	signal si_rst : std_logic := '0';
	signal si_branch : std_logic := '0';
	signal si_jump : std_logic := '0';
	signal si_jr : std_logic := '0';
	signal si_jumpreg : std_logic_vector(DATA_WIDTH-1 downto 0) := x"00000000";
	signal si_jumpinstr : std_logic_vector(JUMP_INSTR-1 downto 0) := b"00000000000000000000000000";
	signal si_bne : std_logic := '0';
	signal si_zero : std_logic := '0';
	signal si_sign_ext_imm : std_logic_vector(DATA_WIDTH-1 downto 0) := x"00000000";
	signal so_next_addr : std_logic_vector(DATA_WIDTH-1 downto 0) := x"00000000";


begin 

--Describe compoent to be tested
	DUT0 : fetch
	generic map(JUMP_INSTR => JUMP_INSTR)
	port map(i_clk => si_clk,
		i_rst => si_rst,
		i_branch => si_branch,
		i_jump => si_jump,
		i_jr => si_jr,
		i_jumpreg => si_jumpreg,
		i_jumpinstr => si_jumpinstr,
		i_bne => si_bne,
		i_zero => si_zero,
		i_sign_ext_imm => si_sign_ext_imm,
		o_next_addr => so_next_addr);

--This first process is to setup the clock for the test bench
  P_CLK: process
  begin
  si_clk <= '1';         -- clock starts at 1
  wait for gCLK_HPER; -- after half a cycle
  si_clk <= '0';         -- clock becomes a 0 (negative edge)
  wait for gCLK_HPER; -- after half a cycle, process begins evaluation again
end process;
              
-- This process resets the sequential components of the design.
-- It is held to be 1 across both the negative and positive edges of the clock
-- so it works regardless of whether the design uses synchronous (pos or neg edge)
-- or asynchronous resets.
P_RST: process
  begin
	si_rst <= '0';   
  wait for gCLK_HPER/2;
  si_rst <= '1';
  wait for gCLK_HPER*2;
  si_rst <= '0';
  wait;
end process;

-- Start test cases here 
P_TEST_CASES: process
    begin

	wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges

	--TEST CASE 1: RESET THE MODULE
	-- ALL signals besides si_rst set to zero, expect output of next instruction to be defualt value of 0xPC of 0x0040_0000
	si_rst <= '1';
	si_branch <= '0';
	si_jump <= '0';
	si_jr <= '0';
	si_jumpreg <= x"00000000";
	si_jumpinstr <= b"00000000000000000000000000";
	si_bne <= '0';
	si_zero <= '0';
	si_sign_ext_imm <= x"00000000";
	wait for gCLK_HPER;
    wait for gCLK_HPER;


	--TEST CASE 2: Increment THE MODULE
	-- ALL signals set to zero, expect output of next instruction to be value of 0xPC of 0x0040_0004
	si_rst <= '0';
	si_branch <= '0';
	si_jump <= '0';
	si_jr <= '0';
	si_jumpreg <= x"00000000";
	si_jumpinstr <= b"00000000000000000000000000";
	si_bne <= '0';
	si_zero <= '0';
	si_sign_ext_imm <= x"00000000";
	wait for gCLK_HPER;
    wait for gCLK_HPER;

	--TEST CASE 3: Test Branch when values are not equal
	--Expect output of next instruction to be value of 0xPC of 0x0040_0008
	si_rst <= '0';
	si_branch <= '1';
	si_jump <= '0';
	si_jr <= '0';
	si_jumpreg <= x"00000000";
	si_jumpinstr <= b"00000000000000000000000000";
	si_bne <= '0';
	si_zero <= '0';
	si_sign_ext_imm <= x"00000000";
	wait for gCLK_HPER;
    wait for gCLK_HPER;

	
	--TEST CASE 4: Test Branch when values are equal
	--Expect output of next instruction to be value of 0xPC of 0x0050_0000<<2 + (PC+4)
	si_rst <= '0';
	si_branch <= '1';
	si_jump <= '0';
	si_jr <= '0';
	si_jumpreg <= x"00000000";
	si_jumpinstr <= b"00000000000000000000000000";
	si_bne <= '0';
	si_zero <= '1';
	si_sign_ext_imm <= x"00500000";
	wait for gCLK_HPER;
    wait for gCLK_HPER;

	--TEST CASE 5: Test Branch Not Equal when values are equal
	--Expect output of next instruction to be value of 0xPC of 0x0050_0000<<2 + (PC+4) + 4
	si_rst <= '0';
	si_branch <= '1';
	si_jump <= '0';
	si_jr <= '0';
	si_jumpreg <= x"00000000";
	si_jumpinstr <= b"00000000000000000000000000";
	si_bne <= '1';
	si_zero <= '1';
	si_sign_ext_imm <= x"00000000";
	wait for gCLK_HPER;
    wait for gCLK_HPER;

	--TEST CASE 6: Test Branch Not Equal when values are not equal
	--Expect output of next instruction to be value of 0xPC of 0x0100_0000<<2 + (PC +4)
	si_rst <= '0';
	si_branch <= '1';
	si_jump <= '0';
	si_jr <= '0';
	si_jumpreg <= x"00000000";
	si_jumpinstr <= b"00000000000000000000000000";
	si_bne <= '1';
	si_zero <= '0';
	si_sign_ext_imm <= x"01000000";
	wait for gCLK_HPER;
    wait for gCLK_HPER;

	--TEST CASE 7: Test Jump Resgister
	--Expect output of next instruction to be value of 0xPC of 0x1111_1111
	si_rst <= '0';
	si_branch <= '0';
	si_jump <= '0';
	si_jr <= '1';
	si_jumpreg <= x"11111111";
	si_jumpinstr <= b"00000000000000000000000000";
	si_bne <= '0';
	si_zero <= '0';
	si_sign_ext_imm <= x"00000000";
	wait for gCLK_HPER;
    wait for gCLK_HPER;


	--TEST CASE 8: Test Jump
	--Expect output of next instruction to be value of 0xPC of 0x1000_0000
	si_rst <= '0';
	si_branch <= '0';
	si_jump <= '1';
	si_jr <= '0';
	si_jumpreg <= x"11111111";
	si_jumpinstr <= b"00000000000000000000000000";
	si_bne <= '0';
	si_zero <= '0';
	si_sign_ext_imm <= x"00000000";
	wait for gCLK_HPER;
    wait for gCLK_HPER;


    wait;
    end process;
end structure; 
