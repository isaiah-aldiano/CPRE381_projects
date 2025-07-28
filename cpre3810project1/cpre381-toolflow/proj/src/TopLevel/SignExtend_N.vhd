-----------------------------------------------------------------------
-- Copy of SignExtend.vhd that allows for varrying bit sign/zero extensions
-----------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SignExtend_N is
	generic(
		DATA_IN : integer := 16; -- Size data coming in
		EXTEND_TO : integer := 32 -- SIze of data going out
	);
    port(data : in std_logic_vector(DATA_IN-1 downto 0);
         extend_sel : in std_logic;
         extended_out : out std_logic_vector(EXTEND_TO-1 downto 0)
	);
end SignExtend_N;

architecture mixed of SignExtend_N is
    begin

    extended_out(DATA_IN-1 downto 0) <=  data;

    G_extended : for i in DATA_IN to EXTEND_TO-1 generate 
        extended_out(i) <= data(DATA_IN-1) and extend_sel;
    end generate G_extended;

end mixed;