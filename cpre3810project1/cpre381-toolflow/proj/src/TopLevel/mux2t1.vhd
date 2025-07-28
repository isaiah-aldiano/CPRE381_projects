-------------------------------------------------------------------------
-- Sam Burns
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- mux2t1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an structural implementation 
-- of a 2-to-1 multiplexer using org2.vhd, andg2.vhd, and invg.vhd
--
--
-- NOTES:
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity mux2t1 is 
   Port(i_D0 : in std_logic;
	i_D1 : in std_logic;
	i_S : in std_logic;
	o_O : out std_logic);
end mux2t1;

architecture structure of mux2t1 is
 -- Describe the component entities as defined in org2.vhd, andg2.vhd,
 -- and and invg.vhd

   --- OR gate------------------------------------------------------------
   component org2 is 
      Port(i_A          : in std_logic;
           i_B          : in std_logic;
           o_F          : out std_logic);
   end component;

   --- AND gate-----------------------------------------------------------
   component andg2 is
      Port(i_A          : in std_logic;
           i_B          : in std_logic;
           o_F          : out std_logic);
   end component;

   --- NOT gate-----------------------------------------------------------
   component invg is
      Port(i_A          : in std_logic;
           o_F          : out std_logic);
   end component;

   -- Intermediate signal declarations
   signal p1_out,p2_out,p3_out : std_logic;

   begin
   x1: invg Port MAP (i_A => i_S,
		      o_F => p1_out);

   x2: andg2 Port MAP (i_A => i_D0,
		       i_B => p1_out,
		       o_F => p2_out);

   x3: andg2 Port MAP (i_A => i_S,
   		       i_B => i_D1,
 		       o_F => p3_out);

   x4: org2 Port MAP (i_A => p2_out,
		      i_B => p3_out,
      		      o_F => o_O);
end structure;
