-------------------------------------------------------------------------
-- Sam Burns 
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- NRegs32Bit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file will create N 32-Bit DFF's using Nbit_dffg.vhd
--
--
-- NOTES:
-- created 19:15 2/8/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.MIPS_types.all;

entity NRegs32Bit is
    port(i_CLK : in std_logic;
         i_RST : in std_logic;
         i_WE : in std_logic_vector(31 downto 0);
         i_D : in std_logic_vector (31 downto 0);
         o_Q : out t_bus_32x32);
end NRegs32Bit;

architecture mixed of NRegs32Bit is
    component Nbit_dffg is
        generic(N : integer := 32); --32 bit default bus size
        port(i_CLK : in std_logic;     -- Clock input
             i_RST : in std_logic;     -- Reset input
             i_WE : in std_logic;     -- Write enable input
             i_D : in std_logic_vector(N-1 downto 0);     -- Data value input
            o_Q : out std_logic_vector(N-1 downto 0));   -- Data value output
    end component;

    begin 

    G_NDFFS : for i in 0 to 31 generate 
        DFFI : Nbit_dffg
            generic map(N => 32)
            port map(i_CLK => i_CLK,
                     i_RST => i_RST,
                     i_WE => i_WE(i),
                     i_D => i_D,
                     o_Q => o_Q(i));

    end generate G_NDFFS;

    end mixed;



