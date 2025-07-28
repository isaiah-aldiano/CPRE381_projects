-------------------------------------------------------------------------
-- Sam Burns
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- xorNBit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide XOR gate
-- using structural VHDL, generics, and generate statements.
--
--
-- NOTES:
-- created 3/26/25 at 17:00
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity xorNBit is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_A         : in std_logic_vector(N-1 downto 0);
       i_B         : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));

end xorNBit;

architecture structural of xorNBit is

  component xorg2 is
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         o_F          : out std_logic);
  end component;

begin

  -- Instantiate N mux instances.
  G_NBit_XOR: for i in 0 to N-1 generate
    XORI: xorg2 port map(
              i_A     => i_A(i),  -- ith instance's data 0 input hooked up to ith data 0 input.
              i_B     => i_B(i),  -- ith instance's data 1 input hooked up to ith data 1 input.
              o_F      => o_O(i));  -- ith instance's data output hooked up to ith data output.
  end generate G_NBit_XOR;
  
end structural;