-------------------------------------------------------------------------
-- Sam Burns
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- LUI.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of LUI module that uses 
-- concatonation
--
--
-- NOTES:
-- created 3/26/25 at 16:55
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity LUI is 
generic(DATA_WIDTH : integer := 32);
port (i_A : in std_logic_vector(DATA_WIDTH -1 downto 0);
      o_O : out std_logic_vector(DATA_WIDTH -1 downto 0));
end LUI;

architecture df of LUI is 
    begin 
    o_O <= i_A(15 downto 0) & (15 downto 0 => '0');
end df;
