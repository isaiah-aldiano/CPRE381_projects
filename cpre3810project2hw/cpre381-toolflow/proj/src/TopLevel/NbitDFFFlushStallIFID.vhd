-------------------------------------------------------------------------
-- Sam Burns 
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- NbitDFFFlushStall.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file will create N 32-Bit DFF's with flush and stall capabilities
--
--
-- NOTES:
-- created 19:15 4/19/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.MIPS_types.all;

entity NbitDFFFlushStallIFID is
    generic (N : integer := 32); --32 bit default bus size
    port(i_CLK : in std_logic;
         i_RST : in std_logic;
         i_FLUSH : in std_logic;
         i_STALL : in std_logic;
         i_FLUSH_DATA : in std_logic_vector(N-1 downto 0);
         i_D : in std_logic_vector (N-1 downto 0);
         o_Q : out std_logic_vector(N-1 downto 0));
end NbitDFFFlushStallIFID;

architecture mixed of NbitDFFFlushStallIFID is
    component DFFFlushStallIFID is

        port(i_CLK        : in std_logic;     -- Clock input
             i_RST        : in std_logic;     -- Reset input
             i_FLUSH      : in std_logic;     -- Flush input
             i_STALL      : in std_logic;     -- Stall input
             i_FLUSH_DATA : in std_logic;     -- Flush data input
             i_D          : in std_logic;     -- Data value input
             o_Q          : out std_logic);   -- Data value output
    end component;

    begin 

    G_NDFFS : for i in 0 to N-1 generate 
        DFFFlushStalli : DFFFlushStallIFID
            port map(i_CLK => i_CLK,
                     i_RST => i_RST,
                     i_FLUSH => i_FLUSH,
                     i_STALL => i_STALL,
                     i_FLUSH_DATA => i_FLUSH_DATA(i),
                     i_D => i_D(i),
                     o_Q => o_Q(i));

    end generate G_NDFFS;

    end mixed;