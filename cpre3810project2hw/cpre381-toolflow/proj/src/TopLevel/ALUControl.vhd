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

--TODO: ADD STUFF FOR WHEN INPUT IS FOR SLT

entity ALUControl is
	port(i_ALUControl : in std_logic_vector(3 downto 0);
     	o_ALUControl : out std_logic_vector(3 downto 0));
end ALUControl;

-- LOOKUP TABLES:

-- TABLE FOR o_AluControl:
--o_ALUControl[3] corresponds to nAdd_Sub which is zero for all opcodes besides subtract and set less than (maybe??)
--o_ALUControl[2] corresponds to S3, the final mux connected to the mux output 
--o_ALUControl[1] corresponds to S2, the second set of muxes at the ALU output
--o_ALUControl[0] corresponds to s1, the first set of muxes at the ALU output

--END LOOKUP TABLES

architecture df of ALUControl is
    begin

    o_ALUControl <= "0000" when (i_ALUControl = "0010") else -- select ALU ouput when input selects for add -> nAdd_Sub = 0
                    "1000" when (i_ALUControl = "0100") else -- select ALU output when input selects for add -> nAdd_Sub = 1
                    --TOP TWO ARE FOR ADD AND SUB WHICH BOTH USE THE RESULT OF THE ADD/SUB MODULE
                    "0001" when (i_ALUControl = "0001") else -- select OR output when input selects for or
                    "0010" when (i_ALUControl = "0000") else -- select AND output when input selects for and
                    "0011" when (i_ALUControl = "1000") else -- select XOR output when input selects for xor
                    "0100" when (i_ALUControl = "1100") else -- select NOR output when input selects for nor
                    "0101" when (i_ALUControl = "1010") else -- select LUI output when input selects for lui
                    --START OF SHIFTING FUNCTIONS
                    "0110" when (i_ALUControl = "1001") else -- select barrel shifter output when input selects for shift right arthmetic functionality
                    "0110" when (i_ALUControl = "1110") else -- select barrel shifter output when input selects for shift right functionality
                    "0110" when (i_ALUControl = "1111") else -- select barrel shifter output when input selects for shift left functionality
                    --END OF SHIFTING FUNCTIONS

                    --TODO: NEED TO ADD SLT FUNCTIONALITY TO THIS MODULE AS WELL AS THE ALU
                    "1111" when (i_ALUControl = "0111") else -- select slt when input selects for shift left functionality

                    --Default Case
                    "0000";
    
end df;