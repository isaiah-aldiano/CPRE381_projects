-------------------------------------------------------------------------
-- Sam Burns
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- RpplCryNBit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a definition and description of an 
-- N-bit Ripple Carry Adder using generation and FullAdder.vhd
--              
-- created 13:50 on 1/30/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RpplCryNBit is 
   generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
   port(i_cIN : in std_logic;
        i_A : in std_logic_vector(N-1 downto 0);
        i_B : in std_logic_vector(N-1 downto 0);
        o_cOUT : out std_logic_vector(N-1 downto 0);
        o_S : out std_logic_vector(N-1 downto 0));
end RpplCryNBit;

architecture structure of RpplCryNBit is 
   --define FullAdder circuit to be used in generation
   component FullAdder is 
      port(i_cIN : in std_logic;
           i_A : in std_logic;
           i_B : in std_logic;
           o_cOUT : out std_logic;
           o_S : out std_logic);
   end component;


 -- make a carry signal, this allows me to feed carry out from one FA
 -- into the carry in of the following FA, it also allows the indexing seen below
signal carry : std_logic_vector(N downto 0);

   begin
      carry(0) <= i_cIN;
      G_RpplCryNBit : for i in 0 to N-1 generate
    	x1 : FullAdder 
            port map(i_cIN => carry(i),
                     i_A => i_A(i),
                     i_B => i_B(i),
                     o_cOUT => carry(i+1),
                     o_S => o_S(i));
      end generate G_RpplCryNBit;
      o_cOUT <= carry(N downto 1);
      
end structure;


                  
   
