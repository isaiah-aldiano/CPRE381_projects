-------------------------------------------------------------------------
-- Sam Burns
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- dffg.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an edge-triggered
-- flip-flop with muxes for flush and stall capabilities. 
--
--
-- NOTES:
-- 8/19/16 by JAZ::Design created.
-- 11/25/19 by H3:Changed name to avoid name conflict with Quartus
--          primitives.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity DFFFlushStallIDEX is

  port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_FLUSH      : in std_logic;     -- Flush input
       i_STALL      : in std_logic;     -- Stall input
       i_FLUSH_DATA : in std_logic;     -- Flush data input
       i_D          : in std_logic;     -- Data value input
       o_Q          : out std_logic);   -- Data value output

end DFFFlushStallIDEX;

architecture mixed of DFFFlushStallIDEX is

    component dffg is
        port(i_CLK        : in std_logic;     -- Clock input
             i_RST        : in std_logic;     -- Reset input
             i_WE         : in std_logic;     -- Write enable input
             i_D          : in std_logic;     -- Data value input
             o_Q          : out std_logic);   -- Data value output
    end component;

    component mux2t1 is 
    Port(i_D0 : in std_logic;
     i_D1 : in std_logic;
     i_S : in std_logic;
     o_O : out std_logic);
    end component;

    component org2 is

        port(i_A          : in std_logic;
             i_B          : in std_logic;
             o_F          : out std_logic);
        end component;


    -- Intermediate signal declarations
  signal s_D    : std_logic;    -- Multiplexed input to the FF
  signal s_Q    : std_logic;    -- Output of the FF
  signal s_Sel : std_logic; -- Stall signal

begin

    OR1 : org2
    Port MAP (i_A => i_FLUSH,
              i_B => i_STALL,
              o_F => s_Sel);

    -- Instantiate the 2-to-1 multiplexer
    MUX1: mux2t1 
    Port MAP (i_D0 => i_D,
              i_D1 => i_FLUSH_DATA,
              i_S   => s_Sel,
              o_O   => s_D);

    -- Instantiate the D flip-flop

    DFF1: dffg 
    Port MAP (i_CLK => i_CLK,
              i_RST        => i_RST,
              i_WE         => '1',
              i_D          => s_D,
              o_Q          => s_Q);
    
o_Q <= s_Q; 

end mixed;