-------------------------------------------------------------------------
-- Sam Burns
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- AddSub_NBit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a structural design to implement a
-- N-Bit adder/subtractor circuit using RpplCryNBit.vhd, OnesComp.vhd,
-- and mux2t1_N.vhd 
--              
-- created 19:00 on 1/30/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


--define the AddSub_NBit module
entity AddSub_NBit is 
   generic(ADDSUB_BUS : integer := 32); --default value of 32
   port(nAdd_Sub : in std_logic;
        i_A : in std_logic_vector(ADDSUB_BUS-1 downto 0);
	i_B : in std_logic_vector(ADDSUB_BUS-1 downto 0);
	o_cOUT : out std_logic_vector(ADDSUB_BUS-1 downto 0);
	o_O : out std_logic_vector(ADDSUB_BUS-1 downto 0));
end AddSub_NBit;

architecture structure of AddSub_NBit is 
--define the pplCryNBit.vhd, OnesComp.vhd, and mux2t1_N.vhd modules

   component RpplCryNBit is 
   generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
   port(i_cIN : in std_logic;
        i_A : in std_logic_vector(N-1 downto 0);
        i_B : in std_logic_vector(N-1 downto 0);
        o_cOUT : out std_logic_vector(N-1 downto 0);
        o_S : out std_logic_vector(N-1 downto 0));
   end component;

   component OnesComp is 
       generic(N: integer := 16); --Generic of type integer for input/output data width. Default value is 16
       port (i_A : in std_logic_vector(N-1 downto 0);
             o_O : out std_logic_vector(N-1 downto 0));
   end component;

   component mux2t1_N is
      generic(N : integer := 16); -- Generic of type integer for input/output data width. Default value is 32.
      port(i_S          : in std_logic;
           i_D0         : in std_logic_vector(N-1 downto 0);
           i_D1         : in std_logic_vector(N-1 downto 0);
           o_O          : out std_logic_vector(N-1 downto 0));

   end component;


 --decribe intermediate signals to carry ouput of OnesComp and Mux2t1 modules
   signal p1_out : std_logic_vector(ADDSUB_BUS-1 downto 0);
   signal p2_out : std_logic_vector(ADDSUB_BUS-1 downto 0);

begin 
   x1: OnesComp
      generic map(N => ADDSUB_BUS)
      port map(i_A => i_B,
    	       o_O => p1_out);

   x2: mux2t1_N  
      generic map(N => ADDSUB_BUS)
      port map (i_S => nAdd_Sub,
	   	i_D0 => i_B, --CHANGED FROM i_A WHICH FIXED ISSUE IN FIRST DATAPATH
                             -- MAKE SURE TO NOW CREATE TESTBENCHES WITH DIFFERING INPUT VALUES 
			     -- AND ALSO ENSURE THAT INPUTS ARE ASSIGNED CORRECTLY COMPARED TO INTERNAL SIGNALS
  	 	i_D1 => p1_out,
 		o_O => p2_out);

   x3: RpplCryNBit
      generic map(N => ADDSUB_BUS)
      port map (i_cIN => nAdd_Sub,
		i_A => i_A,
		i_B => p2_out,
		o_cOUT => o_cOUT,
		o_S => o_O);

end structure;


