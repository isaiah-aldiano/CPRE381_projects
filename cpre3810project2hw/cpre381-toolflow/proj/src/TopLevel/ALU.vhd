-------------------------------------------------------------------------
-- Sam Burns
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- ALU.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a structural design to implement the ALU
-- This module will be continually updated to support more complex instructions
-- The module will start by first implementing addi
--              
-- created 19:00 on 1/30/2025
-------------------------------------------------------------------------

-------------------------------------------------------------------------
-----------------------------------TODO----------------------------------
-------------------------------------------------------------------------
-- TODO: create testbench of alu with only add/sub module and test -- DONE
-- TODO: create full datapath to support addi and run instrction test on 
-- it using the project testing framework.                         -- DONE
-- TODO: add functionality for zero signal -- STILL NEEDS TESTED
-- TODO: add bitwise functions -- STILL NEEDS TESTED
-- TODO: make inputs 33 bits (sign extended at 32nd bit) in order to easily implement overflow and slt - STILL NEEDS TESTED
-- TODO: add barrel shifter 
-- TODO: implement overflow -- NEEDS TESTED 
-- TODO: ADD SUPPORT FOR SLT INSTRUCTION -- NEEDS TESTED
-------------------------------------------------------------------------
-----------------------------------TODO----------------------------------
-------------------------------------------------------------------------


use work.MIPS_types.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is 
port(i_Overflow : in std_logic;
     i_ALUOp : in std_logic_vector(3 downto 0);
     i_Shamt : in std_logic_vector(4 downto 0);
     i_INA : in std_logic_vector(31 downto 0);
     i_INB : in std_logic_vector(31 downto 0);
     o_Overflow : out std_logic;
     o_Zero : out std_logic;
     o_ALUResult : out std_logic_vector(31 downto 0));
end ALU;

architecture structure of ALU is
	 component AddSub_NBit is 
      generic(ADDSUB_BUS : integer := 32); --default value of 32
      port(nAdd_Sub : in std_logic;
           i_A : in std_logic_vector(ADDSUB_BUS-1 downto 0);
        i_B : in std_logic_vector(ADDSUB_BUS-1 downto 0);
        o_cOUT : out std_logic_vector(ADDSUB_BUS-1 downto 0);
        o_O : out std_logic_vector(ADDSUB_BUS-1 downto 0));
     end component;

     component ALUControl is
          port(i_ALUControl : in std_logic_vector(3 downto 0);
               o_ALUControl : out std_logic_vector(3 downto 0));
     end component;

     component mux2t1 is 
     Port(i_D0 : in std_logic;
       i_D1 : in std_logic;
       i_S : in std_logic;
       o_O : out std_logic);
     end component;

     component mux2t1_N is 
          generic(N : integer := 16); -- Generic of type integer for input/output data width. Default value is 32.
          port(i_S          : in std_logic;
               i_D0         : in std_logic_vector(N-1 downto 0);
               i_D1         : in std_logic_vector(N-1 downto 0);
               o_O          : out std_logic_vector(N-1 downto 0));	
     end component;

     component orNBit is
          generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
          port(i_A         : in std_logic_vector(N-1 downto 0);
               i_B         : in std_logic_vector(N-1 downto 0);
               o_O          : out std_logic_vector(N-1 downto 0));
     end component;

     component xorNBit is
          generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
          port(i_A         : in std_logic_vector(N-1 downto 0);
               i_B         : in std_logic_vector(N-1 downto 0);
               o_O          : out std_logic_vector(N-1 downto 0));
     end component;

     component norNBit is
          generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
          port(i_A         : in std_logic_vector(N-1 downto 0);
               i_B         : in std_logic_vector(N-1 downto 0);
               o_O          : out std_logic_vector(N-1 downto 0));
     end component;

     component andNBit is
          generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
          port(i_A         : in std_logic_vector(N-1 downto 0);
               i_B         : in std_logic_vector(N-1 downto 0);
               o_O          : out std_logic_vector(N-1 downto 0));
     end component;

     component LUI is 
     generic(DATA_WIDTH : integer := 32);
     port (i_A : in std_logic_vector(DATA_WIDTH -1 downto 0);
           o_O : out std_logic_vector(DATA_WIDTH -1 downto 0));
     end component;

--     component barrel_shifter is
--          generic(
--               SH_AMT : integer := 5;
--               ALU_SIG : integer := 4
--          );
--          port(
--               i_data 		: in std_logic_vector(DATA_WIDTH-1 downto 0);
--               i_shamt 	: in std_logic_vector(SH_AMT-1 downto 0); -- 5 bit shift value from instr or register
--               i_alusig 	: in std_logic_vector(ALU_SIG-1 downto 0); -- 4 bit ALUSig
--               o_data 		: out std_logic_vector(DATA_WIDTH-1 downto 0)
--          );
--     end component;

	 component barrel_shifterv3 is
	 	port(
			i_data 		: in std_logic_vector(31 downto 0);
			i_shamt 	     : in std_logic_vector(4 downto 0); -- 5 bit shift value from instr or register
			i_alusig 	     : in std_logic_vector(3 downto 0); -- 4 bit ALUSig
			o_data 		: out std_logic_vector(31 downto 0)
		);
	 end component;
	

     component ZeroFlag is
          port(i_A          : in std_logic_vector(31 downto 0);
               o_O          : out std_logic);
     end component;

     --TODO: DEFINE NECESSARY INTERNAL SIGNALS HERE
     
     --------------------------------------------------------------------
     --SIGNALS FOR TESTING, PLEASE ADD/REMOVE as needed LATER
     signal s1 : std_logic; -- first set of muxes select signal
     signal s2 : std_logic; -- middle layer of muxes select signal
     signal s3 : std_logic; -- final mux select signal
     signal s_ADDorSUB : std_logic;
     signal s_OVFSEL : std_logic;
     signal so_Overflow : std_logic;
     signal s_ALUControl : std_logic_vector(3 downto 0);
     signal s_ADDSUBOUT32 : std_logic_vector(31 downto 0);
     signal s_ANDOUT : std_logic_vector(31 downto 0);
     signal s_OROUT : std_logic_vector(31 downto 0);
     signal s_XOROUT : std_logic_vector(31 downto 0);
     signal s_NOROUT : std_logic_vector(31 downto 0);
     signal s_LUIOUT : std_logic_vector(31 downto 0);
     signal s_SHIFTEROUT : std_logic_vector(31 downto 0);
     signal s_SLT : std_logic_vector(31 downto 0);
     signal s_ADDINA : std_logic_vector(32 downto 0);
     signal s_ADDINB : std_logic_vector(32 downto 0);
     signal s_DUMMYCOUT : std_logic_vector(32 downto 0);
     signal s_ADDSUBOUT33 : std_logic_vector(32 downto 0);


     --MUX OUTPUTS
     signal s_MUX_1_1_Out : std_logic_vector(31 downto 0); -- 1_1 denotes that it is the top mux in the first row of muxes and continues as such
     signal s_MUX_1_2_Out : std_logic_vector(31 downto 0); -- 1_1 denotes that it is the second mux from the top in the first row of muxes 
     signal s_MUX_1_3_Out : std_logic_vector(31 downto 0); -- the rest keep following this pattern
     signal s_MUX_1_4_Out : std_logic_vector(31 downto 0);
     signal s_MUX_2_1_Out : std_logic_vector(31 downto 0);
     signal s_MUX_2_2_Out : std_logic_vector(31 downto 0);
     signal s_MUX_3_1_Out : std_logic_vector(31 downto 0);
     --------------------------------------------------------------------
 
     begin 
     
     s_ADDINA <= i_INA(31) & i_INA(31 downto 0); --FEED these into 33 bit adder subtractor to make SLT and overflow calculations very easy. 
     s_ADDINB <= i_INB(31) & i_INB(31 downto 0); --THESE two lines of code simply sign extends the MSB of the input to make a 33 bit input to our add sub

     ADDNSUB : AddSub_NBit
          generic map( ADDSUB_BUS => 33)
          port map(nAdd_Sub => s_ADDorSUB,
          i_A => s_ADDINA,
          i_B => s_ADDINB,
          o_cOUT => s_DUMMYCOUT,
          o_O => s_ADDSUBOUT33);

     s_ADDSUBOUT32 <= s_ADDSUBOUT33(31 downto 0); -- 33rd bit will only be used for slt and overflow
     so_Overflow <= s_DUMMYCOUT(31) xor s_DUMMYCOUT(30);
     s_SLT <= b"0000000000000000000000000000000" & s_ADDSUBOUT33(32); 


     ControlALU : ALUControl
          port map(i_ALUControl => i_ALUOp,
                    o_ALUControl => s_ALUControl);
     
     s_ADDorSUB <= s_ALUControl(3);
     s3 <= s_ALUControl(2);
     s2 <= s_ALUControl(1);
     s1 <= s_ALUControl(0);

     ORG : orNBit
          generic map(N => DATA_WIDTH)
          port map(i_A => i_INA,
                   i_B => i_INB,
                   o_O => s_OROUT);

     ANDG : andNBit
     generic map(N => DATA_WIDTH)
     port map(i_A => i_INA,
               i_B => i_INB,
               o_O => s_ANDOUT);

     XORG : xorNBit
     generic map(N => DATA_WIDTH)
     port map(i_A => i_INA,
               i_B => i_INB,
               o_O => s_XOROUT);

     NORG : norNBit
     generic map(N => DATA_WIDTH)
     port map(i_A => i_INA,
               i_B => i_INB,
               o_O => s_NOROUT);

     LUIMOD : LUI 
     generic map (DATA_WIDTH => DATA_WIDTH)
     port map(i_A => i_INB,
           o_O => s_LUIOUT);


     BARREL : barrel_shifterv3
     port map(i_data => i_INB,
              i_shamt => i_Shamt,
              i_alusig => i_ALUOp,
              o_data => s_SHIFTEROUT);

     MUX_1_1 : mux2t1_N
     generic map(N => DATA_WIDTH) 
     port map(i_S => s1,
               i_D0 => s_ADDSUBOUT32,
               i_D1 => s_OROUT,
               o_O => s_MUX_1_1_Out);

     MUX_1_2 : mux2t1_N
     generic map(N => DATA_WIDTH) 
     port map(i_S => s1,
               i_D0 => s_ANDOUT,
               i_D1 => s_XOROUT,
               o_O => s_MUX_1_2_Out);
     
     MUX_1_3 : mux2t1_N
     generic map(N => DATA_WIDTH) 
     port map(i_S => s1,
               i_D0 => s_NOROUT,
               i_D1 => s_LUIOUT,
               o_O => s_MUX_1_3_Out);

     MUX_1_4 : mux2t1_N
     generic map(N => DATA_WIDTH) 
     port map(i_S => s1,
               i_D0 => s_SHIFTEROUT, 
               i_D1 => s_SLT, 
               o_O => s_MUX_1_4_Out);

     MUX_2_1 : mux2t1_N
     generic map(N => DATA_WIDTH) 
     port map(i_S => s2,
               i_D0 => s_MUX_1_1_Out,
               i_D1 => s_MUX_1_2_Out, 
               o_O => s_MUX_2_1_Out);

     MUX_2_2 : mux2t1_N
     generic map(N => DATA_WIDTH)
     port map(i_S => s2,
               i_D0 => s_MUX_1_3_Out,
               i_D1 => s_MUX_1_4_Out, 
               o_O => s_MUX_2_2_Out);

     MUX_3_1 : mux2t1_N
          generic map(N => DATA_WIDTH) 
          port map(i_S => s3,
                   i_D0 => s_MUX_2_1_Out,
                   i_D1 => s_MUX_2_2_Out,
                   o_O => s_MUX_3_1_Out);

     o_ALUResult <= s_MUX_3_1_Out;

     ZF : ZeroFlag
     port map(i_A => s_ADDSUBOUT32,
              o_O => o_Zero);



     s_OVFSEL <= '1' when (i_ALUOp = b"0010" and i_Overflow = '1') else --USED TO MAKE SURE THAT OVERFLOW SIGNAL CAN ONLY BE SET WHEN USING add/sub with overflow
                 '1' when (i_ALUOp = b"0100" and i_Overflow = '1') else --USED TO MAKE SURE THAT OVERFLOW SIGNAL CAN ONLY BE SET WHEN USING add/sub with overflow
                 '0'; -- if this needs to be fixed further do condition of when (aluop = sub/add and overflow = '1') which will definitely work
     
     MUXOVF : mux2t1
     port map(i_S => s_OVFSEL,
               i_D0 => '0',
               i_D1 => so_Overflow,
               o_O => o_Overflow);
end structure;


