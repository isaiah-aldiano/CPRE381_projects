-------------------------------------------------------------------------
-- Sam Burns
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- FullAdder.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a structural design to implement a full
-- adder using the andg2.vhd and org2.vhd 
--              
-- created 10:52 on 1/30/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FullAdder is 
   port(i_cIN : in std_logic;
	i_A : in std_logic;
	i_B : in std_logic;
	o_cOUT : out std_logic;
	o_S : out std_logic);
end FullAdder;

architecture structure of FullAdder is 

--define XOR gate 
   component xorg2 is 
      port(i_A : in std_logic;
 		   i_B : in std_logic;
		   o_F : out std_logic);
   end component;

--define AND gate
   component andg2 is 
       port(i_A : in std_logic;
	   		i_B : in std_logic;
			o_F : out std_logic);
	end component;

--define OR gate
   component org2 is 
       port(i_A : in std_logic;
	   		i_B : in std_logic;
			o_F : out std_logic);
	end component;

--define intermediate signals 
signal p1_out, p2_out, p3_out : std_logic;

--define instances of gates following circuit schematic

   begin 
   x1 : xorg2 
      port map(i_A => i_A,
   			   i_B => i_B,
			   o_F => p1_out);

   x2 : xorg2
      port map(i_A => p1_out,
	  		   i_B => i_cIN,
			   o_F => o_S);

   x3: andg2
      port map(i_A => p1_out,
	  		   i_B => i_cIN,
			   o_F => p2_out);

   x4 : andg2 
       port map(i_A => i_A,
	            i_B => i_B,
				o_F => p3_out);

   x5: org2
      port map(i_A => p2_out,
	           i_B => p3_out,
			   o_F => o_cOUT);

end structure;
