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
-- created 3/26/25 at 16:45
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity norg2 is
  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_O          : out std_logic);

end norg2;

architecture dataflow of norg2 is
begin
  o_O <= not(i_A or i_B);
end dataflow;
