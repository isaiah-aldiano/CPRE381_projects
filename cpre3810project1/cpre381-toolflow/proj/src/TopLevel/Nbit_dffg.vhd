-------------------------------------------------------------------------
-- Sam Burns 
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- dffg.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit edge-triggered
-- flip-flop with parallel access and reset using dffg.vhd
--
--
-- NOTES:
-- created 17:15 2/5/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Nbit_dffg is
    generic(N : integer := 32); --32 bit default bus size
    port(i_CLK : in std_logic;     -- Clock input
         i_RST : in std_logic;     -- Reset input
         i_WE : in std_logic;     -- Write enable input
         i_D : in std_logic_vector(N-1 downto 0);     -- Data value input
        o_Q : out std_logic_vector(N-1 downto 0));   -- Data value output
end Nbit_dffg;

architecture structure of Nbit_dffg is 
    component dffg is 
        port(i_CLK : in std_logic;     -- Clock input
            i_RST : in std_logic;     -- Reset input
            i_WE : in std_logic;     -- Write enable input
            i_D : in std_logic;     -- Data value input
            o_Q : out std_logic);   -- Data value output
    end component;

    begin 

    G_NBit_DFF : for i in 0 to N-1 generate
        DFFI : dffg port map(
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => i_WE,
            i_D => i_D(i),
            o_Q => o_Q(i));

end generate G_NBit_DFF;

end structure;

