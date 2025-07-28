-------------------------------------------------------------------------
-- Sam Burns
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- OnesComp.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a structural design to implement ones
-- complement using the invg.vhd file 
--              
-- created 21:00 on 1/29/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity OnesComp is 
   generic(N: integer := 16); --Generic of type integer for input/output data width. Default value is 16
   port (i_A : in std_logic_vector(N-1 downto 0);
           o_O : out std_logic_vector(N-1 downto 0));
end OnesComp;

architecture structural of OnesComp is 
   --describe inv component to be used in structural design
   component invg is 
      port(i_A : in std_logic;
           o_F : out std_logic);
   end component;

   begin
   
   --define N invg instances through generation
   G_NBit_INV: for i in 0 to N-1 generate
   INVI : invg 
      port map(i_A => i_A(i), 
	       o_F => o_O(i));
   end generate G_NBit_INV;
end structural; 
   

   