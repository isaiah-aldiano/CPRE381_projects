-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- MIPS_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a MIPS_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.MIPS_types.all;

entity MIPS_Processor is
  generic(N : integer := DATA_WIDTH);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  MIPS_Processor;


architecture structure of MIPS_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic;  -- TODO: this signal indicates an overflow exception would have been initiated

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;

  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment

	component fetch is -- Entire fetch block
		generic(JUMP_INSTR: integer := 26);
		port(
			i_clk 			    : 	in std_logic;
			i_rst 			    : 	in std_logic;
			i_branch 		    : 	in std_logic;
			i_jump 			    : 	in std_logic;
			i_jr 			    : 	in std_logic; -- Jump Reg (1) or JumpMux result (0)
			i_jumpreg 	    	:	in std_logic_vector(DATA_WIDTH-1 downto 0); -- Jump value from register
			i_jumpinstr	    	:	in std_logic_vector(JUMP_INSTR-1 downto 0); -- Jump value from J-Type
			i_bne 			    : 	in std_logic; -- Swithes branch mux for BEQ and BNE
			i_zero 			    : 	in std_logic; -- Carries 0/1 from ALU output
			i_sign_ext_imm 		: 	in std_logic_vector(DATA_WIDTH-1 downto 0); -- Sign extended input to be SL2
			o_pc4 				: 	out std_logic_vector(DATA_WIDTH-1 downto 0); -- PC +4 for JAL instructions	
			o_next_addr 	  : 	out std_logic_vector(DATA_WIDTH-1 downto 0) -- Output of next given instruction
		);
	end component;

	signal s_PCPlus4 : std_logic_vector(DATA_WIDTH-1 downto 0);

	component Control is -- CONTROL MODULE
		port(
			i_OpCode : in std_logic_vector(5 downto 0);
     		i_Function : in std_logic_vector(5 downto 0);
     		o_ControlSig : out std_logic_vector(16 downto 0);
     		o_ALUSig : out std_logic_vector(3 downto 0));
	end component;
  
  --CONTROL MODULE SIGNALS
  signal s_ControlSig : std_logic_vector(16 downto 0);
  signal s_ALUSig : std_logic_vector(3 downto 0);


  --ADD SIGNALS ASSOCIATED WITH EACH MODULE BELOW THE MODULE

	component RegFile is -- CENTRAL REGISTER FILE
		port(
			i_CLK : in std_logic;
	        i_RST : in std_logic;
		 	wrte_EN : in std_logic;
	        wrte_ADDR : in std_logic_vector(4 downto 0);
	        reg_READ1 : in std_logic_vector(4 downto 0);
	        reg_READ2 : in std_logic_vector(4 downto 0);
	        i_DATA : in std_logic_vector(31 downto 0);
	        o_DATA1 : out std_logic_vector(31 downto 0);
	        o_DATA2 : out std_logic_vector(31 downto 0));
	end component;

  --REGFILES SIGNALS 
  signal s_RSValue : std_logic_vector(31 downto 0);
  signal s_RTValue : std_logic_vector(31 downto 0);


  component SignExtend is
    port(data : in std_logic_vector(15 downto 0);
         extend_sel : in std_logic;
         extended_out : out std_logic_vector(31 downto 0));
  end component; 

  --SIGN EXTENDER SIGNALS
  signal s_SignExtOut : std_logic_vector(31 downto 0);


  component mux2t1_N is
    generic(N : integer := 16); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_S          : in std_logic;
         i_D0         : in std_logic_vector(N-1 downto 0);
         i_D1         : in std_logic_vector(N-1 downto 0);
         o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  --MUX SIGNALS FOR WHOLE DESIGN
  signal s_MUXALUIn : std_logic_vector(31 downto 0);
  signal s_DataMemtoReg : std_logic_vector(31 downto 0);
  signal s_InstrRegWr : std_logic_vector(4 downto 0); 
  signal s_ShamttoAlu : std_logic_vector(4 downto 0);

  --TODO: ADD SIGNALS FOR MUXES FOR LOAD(W,H,B,HU,BU) AND JAL INSTRUCTIONS
  

	component ALU is -- ALU
		port(
			i_Overflow : in std_logic;
			i_ALUOp : in std_logic_vector(3 downto 0);
			i_Shamt : in std_logic_vector(4 downto 0);
			i_INA : in std_logic_vector(31 downto 0);
			i_INB : in std_logic_vector(31 downto 0);
	        o_Overflow : out std_logic;
	        o_Zero : out std_logic;
	        o_ALUResult : out std_logic_vector(31 downto 0));
	end component;

  --ALU SIGNALS 
  signal s_Zero : std_logic;
  signal s_ALUResLB : std_logic_vector(1 downto 0); -- muxing loading byte
  signal s_ALUResLH : std_logic; -- muxing loading halfword 

 	component loading is
		port(
			i_DMEM 		: 	in std_logic_vector(DATA_WIDTH-1 downto 0);
			i_RESULT_LB : 	in std_logic_vector(1 downto 0);
			i_RESULT_LH : 	in std_logic;
			i_LB 		: 	in std_logic;
			i_LH 		: 	in std_logic;
			i_LHU 		: 	in std_logic;
			i_LW 		: 	in std_logic;
			o_DMEM		:   out std_logic_vector(DATA_WIDTH-1 downto 0)
		);
	end component;

	-- DMEM SIGNALS
	signal s_DMemLoad : std_logic_vector(DATA_WIDTH-1 downto 0); -- Output of loading module contain some loaded value from DMEM

	
begin

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;


  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

	

  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)
  -- TODO: Ensure that s_Ovfl is connected to the overflow output of your ALU

  -- TODO: Implement the rest of your processor below this comment! 

	CNTRL : Control
		port map(
			i_OpCode => s_Inst(31 downto 26),
      		i_Function => s_Inst(5 downto 0),
      		o_ControlSig => s_ControlSig,
      		o_ALUSig => s_ALUSig);

    		s_Halt <= s_ControlSig(1);  --ASSIGN HALT SIGNAL
    		s_DMemWr <= s_ControlSig(14); --ASSIGN Write Enable of DMEM

  			s_RegWr <= s_ControlSig(13); --Assign required signal to corresponding control bit for write enable on RegFile
	
	FTCH : fetch
		generic map(JUMP_INSTR => JUMP_INST)
    port map(
			i_clk => iCLK,
			i_rst => iRST,
	      	i_branch => s_ControlSig(10), 
	      	i_jump => s_ControlSig(8),
	      	i_jr => s_ControlSig(7),
	      	i_jumpreg => s_RSValue, 
	      	i_jumpinstr => s_Inst(25 downto 0), -- TODO: DOUBLE CHECK THAT THIS IS CORRECT 
			i_bne => s_ControlSig(9),
	      	i_zero => s_Zero,
	      	i_sign_ext_imm => s_SignExtOut,
			o_pc4 => s_PCPlus4,
	      	o_next_addr => s_NextInstAddr);

  --TODO: MUXES WILL NEED TO BE ADDED HERE TO SUPPORT BOTH I AND R TYPE INSTRUCTIONS 
  -- AS WELL AS JAL, BUT FOR NOW JUST CONNEC NECESSARY BITS TO WRITE DATA AND WRITE REG TO REG FILE

  MUXRorItype : Mux2t1_N -- Mux between I and R instructions
  generic map(N => 5)
  port map(i_S => s_ControlSig(12),
           i_D0 => s_Inst(20 downto 16),
           i_D1 => s_Inst(15 downto 11), --25 downto 21
           o_O => s_InstrRegWr); 

  MUXRegWrAddr : Mux2t1_N -- Mux between instruction reg and $ra (31) 
  generic map(N => 5)
  port map(i_S => s_ControlSig(6),
		   i_D0 => s_InstrRegWr,
		   i_D1 => "11111",
		   o_O => s_RegWrAddr);
		  
  MUXRegWrData : Mux2t1_N -- Mux between DMEM Data and PC+4
  generic map(N => 32)
  port map(i_S => s_ControlSig(6),
		   i_D0 => s_DataMemtoReg,
		   i_D1 => s_PCPlus4,
		   o_O => s_RegWrData);

  RGFL : RegFile
  port map(i_CLK => iCLK,
            i_RST => iRST,
            wrte_EN => s_RegWr,
            wrte_ADDR => s_RegWrAddr,
            reg_READ1 => s_Inst(25 downto 21),
            reg_READ2 => s_Inst(20 downto 16),
            i_DATA => s_RegWrData,
            o_DATA1 => s_RSValue,
            o_DATA2 => s_RTValue);

  s_DMemData <= s_RTValue; --ASSIGN Data in of DMEM to RT from RegFile


  SIGNEXT : SignExtend 
  port map(data => s_Inst(15 downto 0),
           extend_sel => s_ControlSig(11),
           extended_out => s_SignExtOut);


  MUXALUIN : Mux2t1_N 
  generic map(N => DATA_WIDTH)
  port map(i_S => s_ControlSig(16),
           i_D0 => s_RTValue,
           i_D1 => s_SignExtOut,
           o_O => s_MUXALUIn); 

  --TODO: Will need to add another mux here for shamt input to ALU when shift instructions are added
  MUXShift : Mux2t1_N
  generic map(N => 5)
  port map(i_S => s_Inst(2), -- Function bit 2
		   i_D0 => s_Inst(10 downto 6), -- Shift value from instr (Immediate shifts)
		   i_D1 => s_RSValue(4 downto 0), -- Read Data 1 (Variable shifts)
		   o_O => s_ShamttoAlu); 

  ALU1 : ALU 
  port map(i_Overflow => s_ControlSig(0),
           i_ALUOp => s_ALUSig,
           i_Shamt => s_ShamttoAlu, --b"00000", --TODO: WILL NEED TO ASSIGN THIS ONCE BARREL SHIFTER IS ADDED
           i_INA => s_RSValue,
           i_INB => s_MUXALUIn,
           o_Overflow => s_Ovfl,
           o_Zero => s_Zero,
           o_ALUResult => s_DMemAddr);

  oALUOut <= s_DMemAddr; -- ASSIGN value of ALU output 
  s_ALUResLB <= s_DMemAddr(1 downto 0); 
  s_ALUResLH <= s_DMemAddr(1);

  LOADING1 : loading
  port map(i_DMEM => s_DMemOut,
		   i_RESULT_LB => s_ALUResLB, -- Result[1:0]
		   i_RESULT_LH => s_ALUResLH, -- Result[1]
		   i_LB => s_ControlSig(5), -- LB
		   i_LH => s_ControlSig(4), -- LH
		   i_LHU => s_ControlSig(3), -- LHU
		   i_LW => s_ControlSig(2), -- LW
		   o_DMEM => s_DMemLoad
		   );
		   
  MUXDMEMOUT : Mux2t1_N
  generic map(N => DATA_WIDTH)
  port map(i_S => s_ControlSig(15),
           i_D0 => s_DMemAddr,
           i_D1 => s_DMemLoad,
           o_O => s_DataMemtoReg --s_RegWrData --TODO: THIS SIGNAL WILL NOT BE DIRECTLY ASSIGNED WHEN IMPLEMENTING OTHER INSTRUCTIONS (IE R-TYPE) use s_DataMemtoReg instead
           ); 
end structure;

