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

  component Nbit_dffg is
    generic(N : integer := 32); --32 bit default bus size
    port(i_CLK : in std_logic;     -- Clock input
         i_RST : in std_logic;     -- Reset input
         i_WE : in std_logic;     -- Write enable input
         i_D : in std_logic_vector(N-1 downto 0);     -- Data value input
        o_Q : out std_logic_vector(N-1 downto 0));   -- Data value output
  end component;

--ALL DFF SIGNALS GO HERE--
  signal si_DFFIDEX_CTRL : std_logic_vector(17 downto 0);
  signal so_DFFIDEX_CTRL : std_logic_vector(17 downto 0);
  signal so_DFFIFID_INST : std_logic_vector(DATA_WIDTH-1 downto 0); 
  signal so_DFFIDEX_SHAMT : std_logic_vector(4 downto 0);
  signal so_DFFIDEX_RTIMM : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal so_DFFIDEX_RS : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal so_DFFIDEX_WRADDR : std_logic_vector(4 downto 0); --
  signal so_DFFIDEX_RT : std_logic_vector(DATA_WIDTH-1 downto 0); --
  signal so_DFFEXM_RTIMM : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal so_DFFEXM_ALUOUT : std_logic_vector(DATA_WIDTH-1 downto 0);

  signal so_DFFEXM_WRADDR : std_logic_vector(4 downto 0); --
  signal si_DFFEXM_CTRL : std_logic_vector(8 downto 0);
  signal so_DFFEXM_CTRL : std_logic_vector(8 downto 0);

  signal so_DFFMWB_DMEM : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal so_DFFMWB_ALUOUT : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal so_DFFMWB_WRADDR : std_logic_vector(4 downto 0); --
  signal si_DFFMWB_CTRL : std_logic_vector(7 downto 0);
  signal so_DFFMWB_CTRL : std_logic_vector(7 downto 0);
--END DFF SIGNALS--

	component fetch_tuah is -- Entire fetch block
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
        signal s_PCP4D0 : std_logic_vector(DATA_WIDTH-1 downto 0);
        signal s_PCP4D1 : std_logic_vector(DATA_WIDTH-1 downto 0);
        signal s_PCP4D2 : std_logic_vector(DATA_WIDTH-1 downto 0);
        signal s_PCP4WB : std_logic_vector(DATA_WIDTH-1 downto 0);


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
	        o_DATA2 : out std_logic_vector(31 downto 0);
          o_regdata : out t_bus_32x32);
	end component;

  --REGFILES SIGNALS 
  signal s_RSValue : std_logic_vector(31 downto 0);
  signal s_RTValue : std_logic_vector(31 downto 0);
  signal s_WBRegWr : std_logic;
  signal DEBUG_REGDATA: t_bus_32x32;


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
  signal s_ALUres : std_logic_vector(DATA_WIDTH-1 downto 0);
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
	signal s_WBJAL : std_logic;

	
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
             addr => s_DMemAddr(11 downto 2), --changed to take alu out from EX/M DFF
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);
	

  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100) IN WB STAGE 
  -- TODO: Ensure that s_Ovfl is connected to the overflow output of your ALU in EX stage

  -- TODO: Implement the rest of your processor below this comment! 


 --START IF/FD DFF-- 
  DFF1 : Nbit_dffg
  port map(i_CLK => iCLK,
          i_RST => iRST,
          i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
          i_D => s_Inst,
          o_Q => so_DFFIFID_INST);


---------------------------------------------

        -- signal s_PCPlus4 : std_logic_vector(DATA_WIDTH-1 downto 0);     
        -- signal s_PCP4D0 : std_logic_vector(DATA_WIDTH-1 downto 0);
        -- signal s_PCP4D1 : std_logic_vector(DATA_WIDTH-1 downto 0);
        -- signal s_PCP4D2 : std_logic_vector(DATA_WIDTH-1 downto 0);
        -- signal s_PCP4WB : std_logic_vector(DATA_WIDTH-1 downto 0);
        DFF2 : Nbit_dffg
        port map(i_CLK => iCLK,
                i_RST => iRST,
                i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
                i_D => s_PCPlus4,
                o_Q => s_PCP4D0);
        DFF3 : Nbit_dffg
        port map(i_CLK => iCLK,
                i_RST => iRST,
                i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
                i_D => s_PCP4D0,
                o_Q => s_PCP4D1);

        DFF4 : Nbit_dffg
        port map(i_CLK => iCLK,
                i_RST => iRST,
                i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
                i_D => s_PCP4D1,
                o_Q => s_PCP4D2);

        -- DFF5 : Nbit_dffg
        -- port map(i_CLK => iCLK,
        --         i_RST => iRST,
        --         i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
        --         i_D => s_PCP4D2,
        --         o_Q => s_PCP4WB);
---------------------------------------------
  --END IF/ID DFF--

	CNTRL : Control
		port map(
		i_OpCode => so_DFFIFID_INST(31 downto 26),
      		i_Function => so_DFFIFID_INST(5 downto 0),
      		o_ControlSig => s_ControlSig,
      		o_ALUSig => s_ALUSig);
  
  s_RegWr <= s_WBRegWr;--s_ControlSig(13); --Assign required signal to corresponding control bit for write enable on RegFile

	
	FTCH : fetch_tuah
		generic map(JUMP_INSTR => JUMP_INST) -- TODO: Internal pipelining, double check current connections align with this during testing
    port map(
              i_clk => iCLK,
              i_rst => iRST,
              i_branch => so_DFFIDEX_CTRL(14), --TODO: ADD ID/EX pipelined branch signal
              i_jump => so_DFFIDEX_CTRL(12), --TODO: ADD ID/EX pipelined jump signal
              i_jr => so_DFFIDEX_CTRL(11), --TODO: ADD ID/EX pipelined jr signal
              i_jumpreg => so_DFFIDEX_RS, --TODO: ADD ID/EX pipelined RS signal 
              i_jumpinstr => so_DFFIFID_INST(25 downto 0),  
              i_bne => so_DFFIDEX_CTRL(13), --TODO: ADD ID/EX pipelined bne signal
              i_zero => s_Zero,
              i_sign_ext_imm => s_SignExtOut,
              o_pc4 => s_PCPlus4,
              o_next_addr => s_NextInstAddr);


  MUXRorItype : Mux2t1_N -- Mux between I and R instructions
  generic map(N => 5)
  port map(i_S => s_ControlSig(12),
           i_D0 => so_DFFIFID_INST(20 downto 16),
           i_D1 => so_DFFIFID_INST(15 downto 11), --25 downto 21
           o_O => s_InstrRegWr); 

-------------------------------------------------------------------------------------------------------- WB

  MUXRegWrAddr : Mux2t1_N -- Mux between instruction reg and $ra (31) 
  generic map(N => 5)
  port map(i_S => s_WBJAL,--s_ControlSig(6), TODO change to JAL signal from WB stage
		   i_D0 => so_DFFMWB_WRADDR,-- s_InstrRegWr, --TODO change this to signal from WB stage
		   i_D1 => "11111",
		   o_O => s_RegWrAddr);
		  
  MUXRegWrData : Mux2t1_N -- Mux between DMEM Data and PC+4
  generic map(N => 32)
  port map(i_S => s_WBJAL,--s_ControlSig(6), TODO change to JAL signal from WB stage
	i_D0 => s_DataMemtoReg,
	i_D1 => s_PCP4D2,--s_PCPlus4,-- -- This does not need to be pipelined, taken care of by internal pipelining of fetch
	o_O => s_RegWrData);
-------------------------------------------------------------------------------------------------------- WB


  RGFL : RegFile
  port map(i_CLK => iCLK,
            i_RST => iRST,
            wrte_EN =>  s_RegWr, -- TODO this signal must be part of write back stage 
            wrte_ADDR => s_RegWrAddr,
            reg_READ1 => so_DFFIFID_INST(25 downto 21),
            reg_READ2 => so_DFFIFID_INST(20 downto 16),
            i_DATA => s_RegWrData,
            o_DATA1 => s_RSValue,
            o_DATA2 => s_RTValue,
            o_regdata => DEBUG_REGDATA);


  SIGNEXT : SignExtend 
  port map(data => so_DFFIFID_INST(15 downto 0),
           extend_sel => s_ControlSig(11),
           extended_out => s_SignExtOut);


  MUXALUIN : Mux2t1_N 
  generic map(N => DATA_WIDTH)
  port map(i_S => s_ControlSig(16),
           i_D0 => s_RTValue,
           i_D1 => s_SignExtOut,
           o_O => s_MUXALUIn); 

                                      
  MUXShift : Mux2t1_N
  generic map(N => 5)
  port map(i_S => so_DFFIFID_INST(2), -- Function bit 2
		   i_D0 => so_DFFIFID_INST(10 downto 6), -- Shift value from instr (Immediate shifts)
		   i_D1 => s_RSValue(4 downto 0), -- Read Data 1 (Variable shifts)
		   o_O => s_ShamttoAlu); 

--START ID/EX DFFS--
DFF21 : Nbit_dffg
generic map(N=>5)
port map(i_CLK => iCLK,
        i_RST => iRST,
        i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
        i_D => s_ShamttoAlu,
        o_Q => so_DFFIDEX_SHAMT);

DFF22 : Nbit_dffg
port map(i_CLK => iCLK,
        i_RST => iRST,
        i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
        i_D => s_MUXALUIn,
        o_Q => so_DFFIDEX_RTIMM);    
        
DFF23 : Nbit_dffg
port map(i_CLK => iCLK,
        i_RST => iRST,
        i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
        i_D => s_RSValue,
        o_Q => so_DFFIDEX_RS); 


DFF25 : Nbit_dffg
generic map (N => 5)
port map(i_CLK => iCLK,
        i_RST => iRST,
        i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
        i_D => s_InstrRegWr, -- Instr [10:6] 
        o_Q => so_DFFIDEX_WRADDR);

DFF26 : Nbit_dffg 
port map(i_CLK => iCLK,
        i_RST => iRST,
        i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
        i_D => s_RTValue,  
        o_Q => so_DFFIDEX_RT);

si_DFFIDEX_CTRL <= s_ControlSig(15 downto 13) & s_ControlSig(10 downto 6) & s_ControlSig(5 downto 0) & s_ALUSig;
-- from control sig bits 0-3 correspond to ALU signal
-- bits 4-9 correspond to  Overflow, Halt, LoadW, Load HU, Load H, Load B respectively 
-- bits 10-14 correspond to jumpAL, jump reg, jump, branch NE, and branch respectively 
-- bits 15 & 16 & 17 correspond to RegWr, DmemWR, Memtoreg respectively


DFF24 : Nbit_dffg
generic map( N => 18)
port map(i_CLK => iCLK,
        i_RST => iRST,
        i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
        i_D => si_DFFIDEX_CTRL,
        o_Q => so_DFFIDEX_CTRL); 

--END ID/EX DFFS--
  

  ALU1 : ALU 
  port map(i_Overflow => so_DFFIDEX_CTRL(4), --TODO: Make sure this is correct
           i_ALUOp => so_DFFIDEX_CTRL(3 downto 0), --TODO: Make sure this is correct
           i_Shamt => so_DFFIDEX_SHAMT,
           i_INA => so_DFFIDEX_RS,
           i_INB => so_DFFIDEX_RTIMM,
           o_Overflow => s_Ovfl,
           o_Zero => s_Zero,
           o_ALUResult => s_ALUres);

  oALUOut <= s_ALUres; -- ASSIGN value of ALU output 

  --START EX/M DFFs--
  DFF31 : Nbit_dffg  
  port map(i_CLK => iCLK,
          i_RST => iRST,
          i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
          i_D => so_DFFIDEX_RT , 
          o_Q => so_DFFEXM_RTIMM);

  DFF32 : Nbit_dffg
  port map(i_CLK => iCLK,
          i_RST => iRST,
          i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
          i_D => s_ALUres,
          o_Q => so_DFFEXM_ALUOUT);


  DFF34 : Nbit_dffg 
  generic map (N => 5)
  port map(i_CLK => iCLK,
        i_RST => iRST,
        i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
        i_D => so_DFFIDEX_WRADDR,
        o_Q => so_DFFEXM_WRADDR);
        

  si_DFFEXM_CTRL <= so_DFFIDEX_CTRL(17 downto 15) & so_DFFIDEX_CTRL(10 downto 5); -- TODO: make sure this is correct 
  -- bits 0-5 correspond to Halt, LoadW, Load HU, Load H, Load B, and JumpAL 
  -- bits 6 & 7 & 8 correspond to RegWr and DmemWR and MemtoReg respectively

   
  DFF33 : Nbit_dffg
  generic map(N => 9)
  port map(i_CLK => iCLK,
          i_RST => iRST,
          i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
          i_D => si_DFFEXM_CTRL,
          o_Q => so_DFFEXM_CTRL);

  --TODO NEED TO MAKE SURE HALT IS SET CORRECTLY WITH GLOBAL SIGNAL AND MAKE SURE SIGNALS ARE BEING ASSIGNED CORRECTLY
  --END EX/M DFFs--
  s_ALUResLB <= so_DFFEXM_ALUOUT(1 downto 0); 
  s_ALUResLH <= so_DFFEXM_ALUOUT(1);
  s_DMemAddr <= so_DFFEXM_ALUOUT;
  s_DMemData <= so_DFFEXM_RTIMM; --ASSIGN Data in of DMEM to RT from RegFile
  s_DMemWr <= so_DFFEXM_CTRL(7); --ASSIGN Write Enable of DMEM

  
  --START OF M/WB DFFs--
  DFF41 : Nbit_dffg
  port map(i_CLK => iCLK,
          i_RST => iRST,
          i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
          i_D => s_DMemOut,
          o_Q => so_DFFMWB_DMEM);

  DFF42 : Nbit_dffg
  port map(i_CLK => iCLK,
          i_RST => iRST,
          i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
          i_D => so_DFFEXM_ALUOUT,
          o_Q => so_DFFMWB_ALUOUT);

  DFF44 : Nbit_dffg 
  generic map (N => 5)
  port map(i_CLK => iCLK,
          i_RST => iRST,
          i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
          i_D => so_DFFEXM_WRADDR,
          o_Q => so_DFFMWB_WRADDR);


  si_DFFMWB_CTRL <= so_DFFEXM_CTRL(8) & so_DFFEXM_CTRL(6) & so_DFFEXM_CTRL(5 downto 0);
  -- bits 0-5 correspond to Halt, LoadW, Load HU, Load H, Load B, and JumpAL
  -- bits 6 and 7 corresponds RegWr to MemtoReg 


  DFF43 : Nbit_dffg
  generic map(N => 8)
  port map(i_CLK => iCLK,
          i_RST => iRST,
          i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
          i_D => si_DFFMWB_CTRL,
          o_Q => so_DFFMWB_CTRL);

  --END OF M/WB DFFS--

s_Halt <= so_DFFMWB_CTRL(0); --TODO: ASSIGN HALT SIGNAL
s_WBJAL <= so_DFFMWB_CTRL(5); -- JAL
s_WBRegWr <= so_DFFMWB_CTRL(6); -- RegWR


  LOADING1 : loading
  port map(i_DMEM => so_DFFMWB_DMEM,
		   i_RESULT_LB => s_ALUResLB, -- Result[1:0]
		   i_RESULT_LH => s_ALUResLH, -- Result[1]
		   i_LB => so_DFFMWB_CTRL(4), -- LB
		   i_LH => so_DFFMWB_CTRL(3), -- LH
		   i_LHU => so_DFFMWB_CTRL(2), -- LHU
		   i_LW => so_DFFMWB_CTRL(1), -- LW
		   o_DMEM => s_DMemLoad
		   );
		   
  MUXDMEMOUT : Mux2t1_N
  generic map(N => DATA_WIDTH)
  port map(i_S => so_DFFMWB_CTRL(7), 
           i_D0 => so_DFFMWB_ALUOUT,
           i_D1 => s_DMemLoad,
           o_O => s_DataMemtoReg --s_RegWrData --TODO: THIS SIGNAL WILL NOT BE DIRECTLY ASSIGNED WHEN IMPLEMENTING OTHER INSTRUCTIONS (IE R-TYPE) use s_DataMemtoReg instead
           ); 
end structure;

