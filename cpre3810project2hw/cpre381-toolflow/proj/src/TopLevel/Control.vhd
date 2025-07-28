-------------------------------------------------------------------------
-- Sam Burns
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- Control.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a behavioral implementation of our
-- control flow module for our first project
--         	 
-- created 19:00 on 1/30/2025
-------------------------------------------------------------------------

use work.MIPS_types.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CONTROL is
	port(i_OpCode : in std_logic_vector(5 downto 0);
     	i_Function : in std_logic_vector(5 downto 0);
     	o_ControlSig : out std_logic_vector(16 downto 0);
     	o_ALUSig : out std_logic_vector(3 downto 0));
end CONTROL;

-- LOOKUP TABLES:

-- TABLE FOR o_ControlSig:
-- o_ControlSig[16] corresponds to ALUSrc
-- o_ControlSig[15] corresponds to MemtoReg
-- o_ControlSig[14] corresponds to s_DMemWr
-- o_ControlSig[13] corresponds to s_RegWr
-- o_ControlSig[12] corresponds to RegDst
-- o_ControlSig[11] corresponds to Sign Extender
-- o_ControlSig[10] corresponds to Branch
-- o_ControlSig[9] corresponds to BranchNE
-- o_ControlSig[8] corresponds to Jump
-- o_ControlSig[7] corresponds to JumpReg
-- o_ControlSig[6] corresponds to JumpAL
-- o_ControlSig[5] corresponds to LoadB
-- o_ControlSig[4] corresponds to LoadH
-- o_ControlSig[3] corresponds to LoadHU
-- o_ControlSig[2] corresponds to LoadW
-- o_ControlSig[1] corresponds to Halt
-- o_ControlSig[0] corresponds to Overflow

--TABLE FOR o_ALUSig:
-- o_ALUSig = 0000 for AND functionality
-- o_ALUSig = 0001 for OR functionality
-- o_ALUSig = 0010 for add functionality
--NOTE ::::::::::::::::::::::::: I DONT THINK THIS IS USED, BUT NOT 100% Certain o_ALUSig = 0011 for XOR functionality
-- o_ALUSig = 0100 for subtract functionality
-- o_ALUSig = 0111 for set on less than functionality
-- o_ALUSig = 1000 for XOR functionality
-- o_ALUSig = 1001 for shift-right-arithmetic functionality
-- o_ALUSig = 1010 for LUI functionality
-- o_ALUSig = 1100 for NOR functionality

-- o_ALUSig = 1110 for shift-right functionality
-- o_ALUSig = 1111 for shift-left functionality

--END LOOKUP TABLES

--TEMPLATES
-- R-TYPE INSTRUCTION TEMPLATE
	--o_ControlSig <= "0000 0000 0000 0000" when (i_OpCode = "000000" and i_Function = "000000") else;
	--o_ALUSig < "0000" when (i_OpCode = "000000" and i_Function = "000000") else;
--END R-TYPE TEMPLATE
--END TEMPLATES

architecture df of CONTROL is
begin

--ADDI signal assignments
o_ControlSig <= "10010100000000001" when (i_OpCode = "001000") else

--ADD signal assignments
           	"00011000000000001" when (i_OpCode = "000000" and i_Function = "100000") else

--ADDIU signal assignments  
          	"10010100000000000" when (i_OpCode = "001001") else

--ADDU signal assignments
          	"00011000000000000" when (i_OpCode = "000000" and i_Function = "100001") else

--AND signal assignments
          	"00011000000000001" when (i_OpCode = "000000" and i_Function = "100100") else

--ANDI signal assignments
          	"10010000000000001" when (i_OpCode = "001100") else

--LUI signal assignments
        	"10010000000000001" when (i_OpCode = "001111") else

--LW signal assignments
        	"11010100000000101" when (i_OpCode = "100011") else

--NOR signal assignments
        	"00011000000000001" when (i_OpCode = "000000" and i_Function = "100111") else

--XOR signal assignments
        	"00011000000000001" when (i_OpCode = "000000" and i_Function = "100110") else

--XORI signal assignments
        	"10010000000000001" when (i_OpCode = "001110") else

--OR signal assignments
        	"00011000000000001" when (i_OpCode = "000000" and i_Function = "100101") else

--ORI signal assignments
        	"10010000000000001" when (i_OpCode = "001101") else

--SLT signal assignments
        	"00011100000000001" when (i_OpCode = "000000" and i_Function = "101010") else

--SLTI signal assignments
        	"10010100000000001" when (i_OpCode = "001010") else

--SLL signal assignments
        	"00011000000000001" when (i_OpCode = "000000" and i_Function = "000000") else

--SRL signal assignments
        	"00011000000000001" when (i_OpCode = "000000" and i_Function = "000010") else

--SRA signal assignments
        	"00011000000000001" when (i_OpCode = "000000" and i_Function = "000011") else

--SW signal assignments
        	"10100100000000001" when (i_OpCode = "101011") else

--SUB signal assignments
        	"00011000000000001" when (i_OpCode = "000000" and i_Function = "100010") else

--SUBU signbal assignments
        	"00011000000000000" when (i_OpCode = "000000" and i_Function = "100011") else

--BEQ signal assignments
        	"00000110000000000" when (i_OpCode = "000100") else --TODO: both of these were changed to use sign extender, double check this is correct

--BNE signal assignments
        	"00000111000000000" when (i_OpCode = "000101") else

--J signal assignments
        	"00000000100000001" when (i_OpCode = "000010") else

--JAL signal assignments
        	"00010000101000001" when (i_OpCode = "000011") else

--JR signbal assignments
        	"00000000010000001" when (i_OpCode = "000000" and i_Function = "001000") else

--LB signal assignments
        	"11010100000100001" when (i_OpCode = "100000") else

--LH signal assignments
        	"11010100000010001" when (i_OpCode = "100001") else

--LBU signal assignments
        	"11010100000000001" when (i_OpCode = "100100") else

--LHU signal assignments
        	"11010100000011001" when (i_OpCode = "100101") else

--SLLV signal assignments
        	"00011000000000001" when (i_OpCode = "000000" and i_Function = "000100") else

--SRLV signal assignments
        	"00011000000000001" when (i_OpCode = "000000" and i_Function = "000110") else

--SRAV signal assignments
        	"00011000000000001" when (i_OpCode = "000000" and i_Function = "000111") else

--HALT signal assignments
        	"00000000000000010" when (i_OpCode = "010100") else

--Default Case
        	"00000000000000000";



-------------------------------------------------------------------------
----------------------------o_ALUSig Assignments-------------------------
-------------------------------------------------------------------------
--ADDI signal assignments
o_ALUSig <= "0010" when (i_OpCode = "001000") else

--ADD signal assignments
        	"0010" when (i_OpCode = "000000" and i_Function = "100000") else

--ADDIU signal assignments -- CHECK TODO
        	"0010" when (i_OpCode = "001001") else

--ADDU signal assignments
        	"0010" when (i_OpCode = "000000" and i_Function = "100001") else

--AND signal assignments
        	"0000" when (i_OpCode = "000000" and i_Function = "100100") else

--ANDI signal assignments
        	"0000" when (i_OpCode = "001100") else

--LUI signal assignments
        	"1010" when (i_OpCode = "001111") else

--LW signal assignments
        	"0010" when (i_OpCode = "100011") else

--NOR signal assignments
        	"1100" when (i_OpCode = "000000" and i_Function = "100111") else

--XOR signal assignments
        	"1000" when (i_OpCode = "000000" and i_Function = "100110") else

--XORI signal assignments
        	"1000" when (i_OpCode = "001110") else

--OR signal assignments
        	"0001" when (i_OpCode = "000000" and i_Function = "100101") else

--ORI signal assignments
        	"0001" when (i_OpCode = "001101") else

--SLT signal assignments
        	"0111" when (i_OpCode = "000000" and i_Function = "101010") else

--SLTI signal assignments
        	"0111" when (i_OpCode = "001010") else

--SLL signal assignments
        	"1111" when (i_OpCode = "000000" and i_Function = "000000") else

--SRL signal assignments
        	"1110" when (i_OpCode = "000000" and i_Function = "000010") else

--SRA signal assignments
        	"1001" when (i_OpCode = "000000" and i_Function = "000011") else

--SW signal assignments
        	"0010" when (i_OpCode = "101011") else

--SUB signal assignments
        	"0100" when (i_OpCode = "000000" and i_Function = "100010") else

--SUBU signbal assignments
        	"0100" when (i_OpCode = "000000" and i_Function = "100011") else

--BEQ signal assignments
        	"0100" when (i_OpCode = "000100") else

--BNE signal assignments
        	"0100" when (i_OpCode = "000101") else

--J signal assignments
        	"0000" when (i_OpCode = "000010") else

--JAL signal assignments
        	"0000" when (i_OpCode = "000011") else

--JR signbal assignments
        	"0000" when (i_OpCode = "000000" and i_Function = "001000") else

--LB signal assignments
        	"0010" when (i_OpCode = "100000") else

--LH signal assignments
        	"0010" when (i_OpCode = "100001") else

--LBU signal assignments
        	"0010" when (i_OpCode = "100100") else

--LHU signal assignments
        	"0010" when (i_OpCode = "100101") else

--SLLV signal assignments
        	"1111" when (i_OpCode = "000000" and i_Function = "000100") else

--SRLV signal assignments
        	"1110" when (i_OpCode = "000000" and i_Function = "000110") else

--SRAV signal assignments
        	"1001" when (i_OpCode = "000000" and i_Function = "000111") else

--HALT signal assignments
        	"0000" when (i_OpCode = "010100") else

--Default Case
        	"0000";

end df;


