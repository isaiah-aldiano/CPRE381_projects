-- Sam Burns 
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- mux_package.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This is a package file used for a 32bit 32-1 mux 
--
--
-- NOTES:
-- created 19:45 2/6/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package mux_package is 
   constant five_bit_zero : std_logic_vector := "00000";
   type t_bus_32x32 is array (0 to 31) of std_logic_vector(31 downto 0);
end package mux_package;
