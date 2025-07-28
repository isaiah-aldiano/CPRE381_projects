-------------------------------------------------------------------------
-- Isaiah Aldiano
-------------------------------------------------------------------------
-- mux4t1_N.vhd 
-------------------------------------------------------------------------
-- DESCRIPTION: Contains implementation of a 4 to 1 mux. Inside loading module to mux between bytes of DMEM address value
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.MIPS_types.all;

entity mux4t1_N is
  generic(N : integer := 8;
		  BYTE : integer := 2); 
  port(i_S          : in std_logic_vector(BYTE-1 downto 0); -- result[1:0]
       i_D0         : in std_logic_vector(N-1 downto 0); -- [7:0]
       i_D1         : in std_logic_vector(N-1 downto 0); -- [15:8]
	   i_D2         : in std_logic_vector(N-1 downto 0); -- [23:16]
	   i_D3         : in std_logic_vector(N-1 downto 0); -- [31:24]
       o_O          : out std_logic_vector(N-1 downto 0));

end mux4t1_N;

architecture structural of mux4t1_N is

  component mux2t1 is
    port(
         i_D0                 : in std_logic;
         i_D1                 : in std_logic;
		 i_S                  : in std_logic;
         o_O                  : out std_logic);
  end component;

  signal s_lower_bytes_res : std_logic_vector(N-1 downto 0);
  signal s_upper_bytes_res : std_logic_vector(N-1 downto 0);
  signal s_S0 : std_logic;
  signal s_S1 : std_logic;

begin

  LOWER_BYTES: for i in 0 to N-1 generate
    MUX_LOWER: mux2t1 
		port map(
              i_D0     => i_D0(i),  
              i_D1     => i_D1(i),
			  i_S      => i_S(0),  -- bit 0 of the 2 bit select input
              o_O      => s_lower_bytes_res(i));  
  end generate LOWER_BYTES;

  UPPER_BYTES: for i in 0 to N-1 generate
     MUXI_UPPER: mux2t1 port map(
               i_D0     => i_D2(i),  
               i_D1     => i_D3(i), 
			   i_S      => i_S(0),  -- bit 0 of the 2 bit select input
               o_O      => s_upper_bytes_res(i));  
  end generate UPPER_BYTES;

  RESULTS: for i in 0 to N-1 generate
     MUX_RES: mux2t1 port map(
               i_D0     => s_lower_bytes_res(i),  
               i_D1     => s_upper_bytes_res(i), 
			   i_S      => i_S(1), -- bit 1 of the 2 bit select input
               o_O      => o_O(i));  
  end generate RESULTS;
	
  
end structural;