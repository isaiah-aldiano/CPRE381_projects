-------------------------------------------------------------------------
-- Sam Burns
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- norg2.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 2-input NOR 
-- gate.
--
--
-- NOTES:
-- created 3/30/25 at 16:45
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ZeroFlag is
  port(i_A          : in std_logic_vector(31 downto 0);
       o_O          : out std_logic);
end ZeroFlag;

architecture dataflow of ZeroFlag is
begin
  o_O <= '1' when (i_A = x"00000000") else 
         '0';
end dataflow;