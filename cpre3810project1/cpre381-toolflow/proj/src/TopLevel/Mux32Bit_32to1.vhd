-- Sam Burns 
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- Mux32Bit_32to1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of 32 bit, 32to1
--multiplexer that uses package mux_package.vhd
--
--
-- NOTES:
-- created 20:00 2/6/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.MIPS_types.all;

entity Mux32Bit_32to1 is 
   port(data : in t_bus_32x32;
  	sel : in std_logic_vector(4 downto 0);
  	mux_out : out std_logic_vector(31 downto 0));
end Mux32Bit_32to1;

architecture dataflow of Mux32Bit_32to1 is
   begin
   process(data,sel)
      begin 
      mux_out <= data(to_integer(unsigned(sel)));
   end process;
end dataflow;



