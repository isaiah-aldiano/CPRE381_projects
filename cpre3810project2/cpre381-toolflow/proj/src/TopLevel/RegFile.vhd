-------------------------------------------------------------------------
-- Sam Burns 
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- RegFile.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file containst a structural implementation of a Register
-- File using Decoder5to32.vhd, mux_package.vhd, Mux32Bit_32to1.vhd, and
-- 
--
--
-- NOTES:
--Use NRegs32bit for 32 registers, feed output of 5to32 decoder to i_WE input 
--Use readred1 signal as input to i_sel of 1 mux and use readreg2 for the other
--Use of intermediate signals will be big here, it will allow to set the i_WE(0) to zero so the value of 
-- Reg 0 cannot be changed, as well, set 0_Q val of Reg to zero to create zero register
--clk signal needed 
-- reset signal needed 
--TODO: Create testbench for this file and NRegs32Bit
--TODO: Figure out where to set zero register to zero
-- created 17:15 2/5/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.MIPS_types.all;

entity RegFile is
    port(i_CLK : in std_logic;
         i_RST : in std_logic;
	 	 wrte_EN : in std_logic;
         wrte_ADDR : in std_logic_vector(4 downto 0);
         reg_READ1 : in std_logic_vector(4 downto 0);
         reg_READ2 : in std_logic_vector(4 downto 0);
         i_DATA : in std_logic_vector(31 downto 0);
         o_DATA1 : out std_logic_vector(31 downto 0);
         o_DATA2 : out std_logic_vector(31 downto 0);
         o_regdata : out t_bus_32x32);
end RegFile;

architecture structure of RegFile is

--Define components to be used in design
    component Decoder5to32 is 
    port(sel : in std_logic_vector(4 downto 0);
	write_en : in std_logic;
   	out_sel : out std_logic_vector(31 downto 0));
    end component;

    component NRegs32Bit is
        port(i_CLK : in std_logic;
         i_RST : in std_logic;
         i_WE : in std_logic_vector(31 downto 0);
         i_D : in std_logic_vector (31 downto 0);
         o_Q : out t_bus_32x32);
    end component;

    component Mux32Bit_32to1 is 
        port(data : in t_bus_32x32;
        sel : in std_logic_vector(4 downto 0);
        mux_out : out std_logic_vector(31 downto 0));
    end component;

--Define intermediate signals used to connect components 
    signal so_Decoder : std_logic_vector(31 downto 0);
    signal so_interDecoder : std_logic_vector(31 downto 0);
    signal so_Reg : t_bus_32x32;
    signal so_interReg : t_bus_32x32;

    --Begin describing components being used
    begin
    -- TWO LINES BELOW COMMENTED OUT TO SEE IF IT HELPS WITH SYNTHESIS
    --so_Decoder(0) <= '0'; --Set write enable of register zero to always be zero (constant register)
    --so_Reg(0) <= x"00000000"; --Set output value of register zero to always be zero (constant register)

    Decoder : Decoder5to32 
        port map(sel => wrte_ADDR,
		 write_en => wrte_EN,
                 out_sel => so_interDecoder);

    --LINE ADDED TO SEE IF IT WORKS FOR SYNTHESIS
    so_Decoder <= so_interDecoder(31 downto 1) & '0';
    
    Regs : NRegs32Bit
        port map(i_CLK => i_CLK,
                 i_RST => i_RST,
                 i_WE => so_Decoder,
                 i_D => i_DATA,
                 o_Q => so_interReg);

    o_regdata <= so_interReg;

    --LINE ADDED TO SEE IF IT WORKS FOR SYNTHESIS
    so_Reg <= x"00000000" & so_interReg(1 to 31);
    

    Mux1 : Mux32Bit_32to1 
        port map(data => so_Reg,
                 sel => reg_READ1,
                 mux_out => o_DATA1);

    Mux2 : Mux32Bit_32to1 
    port map(data => so_Reg,
            sel => reg_READ2,
            mux_out => o_DATA2);               
    


end structure ; 