-------------------------------------------------------------------------
-- Sam Burns 
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- SignExtend.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of sign and zero 
-- extension hardware based on a control signal
--
--
-- NOTES:
-- An extend_sel value of 1 allows for sign extension and 0 ensures zero extension
-- created 19:0 2/16/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SignExtend is
    port(data : in std_logic_vector(15 downto 0);
         extend_sel : in std_logic;
         extended_out : out std_logic_vector(31 downto 0));
end SignExtend;

architecture mixed of SignExtend is
    begin

    extended_out(15 downto 0) <=  data;

    G_extended : for i in 16 to 31 generate 
        extended_out(i) <= data(15) and extend_sel;
    end generate G_extended;

end mixed;
