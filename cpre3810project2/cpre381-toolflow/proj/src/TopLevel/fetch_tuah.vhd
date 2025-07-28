
library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.MIPS_types.all;

entity fetch_tuah is 
	generic(JUMP_INSTR: integer := 26);
	port(
		i_clk 			: 			in std_logic; -- Clock signal\
		i_rst 			: 			in std_logic; -- Set PC to 0x0040_0000
		i_branch 		:  			in std_logic; -- Branch (1) or PC+4 (0)
		i_jump 			: 			in std_logic; -- Jump (1) or BranchMux result (0)
		i_jr 			: 			in std_logic; -- Jump Reg (1) or JumpMux result (0)
		i_jumpreg 		:	 		in std_logic_vector(DATA_WIDTH-1 downto 0); -- Jump value from register
		i_jumpinstr		:			in std_logic_vector(JUMP_INSTR-1 downto 0); -- Jump value from J-Type
		i_bne 			: 			in std_logic; -- Swithes branch mux for BEQ and BNE
		i_zero 			: 			in std_logic; -- Carries 0/1 from ALU output
		i_sign_ext_imm 	: 			in std_logic_vector(DATA_WIDTH-1 downto 0); -- Sign extended input to be SL2
		--i_instr 		: 			in std_logic_vector(DATA_WIDTH-1 downto 0); -- Instruction determined from fetch logic
		o_pc4			: 			out std_logic_vector(DATA_WIDTH-1 downto 0); -- ouput PC+4 for JAL instructions
		o_next_addr 	: 			out std_logic_vector(DATA_WIDTH-1 downto 0) -- Output of next given instruction
	);
end fetch_tuah;


architecture mixed of fetch_tuah is 
	
	component PC is 
		port(i_Clk : std_logic;
			i_Rst : in std_logic;
			i_D : in std_logic_vector(DATA_WIDTH-1 downto 0);
			o_Addr : out std_logic_vector(DATA_WIDTH-1 downto 0)
		);
	end component;

	component AddSub_NBit is -- Adders for PC + 4 and Branch (PC + 4 + offset)
		generic(ADDSUB_BUS : integer := DATA_WIDTH);
		port(nAdd_Sub 	: in std_logic;
			i_A 		: in std_logic_vector(ADDSUB_BUS-1 downto 0);
			i_B 		: in std_logic_vector(ADDSUB_BUS-1 downto 0);
			o_cOut 		: out std_logic_vector(ADDSUB_BUS-1 downto 0);
			o_O 		: out std_logic_vector(ADDSUB_BUS-1 downto 0)
		);
	end component;

	component mux2t1_N -- 32 bit 2 to 1 mux. Branch, Jump, JR
		generic(N : integer := DATA_WIDTH);
		port(i_S : in std_logic;
			i_D0 : in std_logic_vector(N-1 downto 0);
			i_D1 : in std_logic_vector(N-1 downto 0);
			o_O : out std_logic_vector(N-1 downto 0)
		);
	end component;
	
	component andg2 -- BranchCtrl and Zero for branch mux
		port(i_A :in std_logic;
			i_B : in std_logic;
			o_F : out std_logic
		);
	end component;

	component mux2t1 -- Mux to select BEQ or BNE
		port(i_D0 : in std_logic;
			i_D1 : in std_logic;
			i_S : in std_logic;
			o_O : out std_logic
		);
	end component;
	
	component invg -- !0 for BNE
		port(i_A : in std_logic;
			o_F : out std_logic
		);
    end component;

    component org2 is
        port(i_A          : in std_logic;
             i_B          : in std_logic;
             o_F          : out std_logic);
	end component;

    component Nbit_dffg is
        generic(N : integer := 32); --32 bit default bus size
        port(i_CLK : in std_logic;     -- Clock input
             i_RST : in std_logic;     -- Reset input
             i_WE : in std_logic;     -- Write enable input
             i_D : in std_logic_vector(N-1 downto 0);     -- Data value input
            o_Q : out std_logic_vector(N-1 downto 0));   -- Data value output
    end component;

	--SIGNALS FROM ORIGINAL FETCH--
	signal s_jump_address 	: std_logic_vector(DATA_WIDTH-1 downto 0); -- (PC+4)[31:28] + i_jumpinstr + 00
	signal s_Current_PC 	: std_logic_vector(DATA_WIDTH-1 downto 0); -- Signal binded to Fetch output  
	signal s_PC_Plus_Four 	: std_logic_vector(DATA_WIDTH-1 downto 0); -- PC + 4 adder signal
	signal s_Sign_Ext_Imm 	: std_logic_vector(DATA_WIDTH-1 downto 0); -- SEI[29:0] + 00 into Add1
	signal s_Branch_Address : std_logic_vector(DATA_WIDTH-1 downto 0); -- (PC+4)

	signal s_Inv_Zero 		: std_logic; -- Invert Zero flag
	signal s_BNE_Mux_Res 	: std_logic; -- BNE0 result
	signal s_Branch_Mux_sel : std_logic; -- BR_AND 

	signal s_Branch_Mux_Res : std_logic_vector(DATA_WIDTH-1 downto 0); -- Result of BR_MUX
	signal s_Jump_Mux_Res 	: std_logic_vector(DATA_WIDTH-1 downto 0); -- Result of J_MUX
	signal s_Pc_Next_Res 	: std_logic_vector(DATA_WIDTH-1 downto 0); -- Result of PC_MUX
    --END ORIGINAL SIGNALS--

    --NEW SIGNALS ADDED FOR SOFWARE PIPELINE--
    signal s_OutOR1 : std_logic; -- OR two control signals together and then or result with another control signal
    signal s_PCMMuxS : std_logic; --Output from the second OR gate (according to software scheduled pipeline schematic) will be control bit of new PC mux
    signal s_OutJrandBrLogic : std_logic_vector(DATA_WIDTH-1 downto 0); -- Output of what was previously called the PC_Mux in the single cycle design
    signal s_DFF1_PC_Plus_Four : std_logic_vector(DATA_WIDTH-1 downto 0); --Output of first DFF only used for delaying PC+4 (the first time)
    signal s_DFF2_PC_Plus_Four : std_logic_vector(DATA_WIDTH-1 downto 0); --Output of second DFF only used for delaying PC+4 (the second time)
    signal s_DFF3_PC_Jump_Address : std_logic_vector(DATA_WIDTH-1 downto 0); --Output of second DFF set only used for jump address
    signal s_DFF4_PC_Branch_Address : std_logic_vector(DATA_WIDTH-1 downto 0); --Output of second DFF set only used for delaying branch address
	
begin

	MIPS_PC : PC -- PC implemenmted with PC_dffg
		port map(
			i_Clk 	=> i_clk,
			i_Rst 	=> i_rst, -- 1 = reset to 0x0040_0000
			i_D 	=> s_Pc_Next_Res,  
			o_Addr 	=> s_Current_PC
		);
	
	o_next_addr <= s_Current_PC; -- Bind current pc value to output

	ADD0 : AddSub_NBit -- Increment to next PC value
		port map(
			nAdd_Sub => '0', -- Add 4 to PC
			i_A => s_Current_PC,
			i_B => x"00000004",
			o_cOUT => open,
			o_O => s_PC_Plus_Four
		);
	

    --START STRUCTURAL CHANGES MADE FOR SOFTWARE PIPELINE--
    -- note: other signal assignment changes from the original module will occur outside of this section, but major strucutural changes
    -- i.e. addition of new modules will be found here 
    -- all structural changes are made in accordance with the schematic as of 4/9/2025

    OR1 : org2  
    port map(i_A => i_jump,
             i_B => i_branch,
             o_F => s_OutOR1); --First OR gate used to OR two control bits together

    OR2 : org2
    port map(i_A => i_jr,
            i_B => s_OutOR1,
            o_F => s_PCMMuxS); --Second OR gate used to OR output of first gate and third control signal to control new PC mux (according to schematic)


    PC_MUX : mux2t1_N
    port map(i_S => s_PCMMuxS,
        i_D0 => s_PC_Plus_Four,
        i_D1 => s_OutJrandBrLogic,
        o_O => s_Pc_Next_Res
    );
    
    DFF1 : Nbit_dffg
        port map(i_CLK => i_clk,
                i_RST => i_rst,
                i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
                i_D => s_PC_Plus_Four,
                o_Q => s_DFF1_PC_Plus_Four);

    o_pc4 <= s_DFF1_PC_Plus_Four; -- PC + 4 for JAL instructions


	s_Jump_Address <= s_DFF1_PC_Plus_Four(31 downto 28) & i_jumpinstr & "00"; -- Sl and Slice jump address together

	s_Sign_Ext_Imm <= i_sign_ext_imm(29 downto 0) & "00"; -- Sl and slice sign ext immediate 

	ADD1 : AddSub_NBit 
		port map(
			nAdd_Sub => '0', -- (PC+4) + Sign Extended Immediate
			i_A => s_PC_Plus_Four,
			i_B => s_Sign_Ext_Imm,
			o_cOut => open,
			o_O => s_Branch_Address -- 1 of Branch Mux
		);

    DFF2 : Nbit_dffg
    port map(i_CLK => i_clk,
            i_RST => i_rst,
            i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
            i_D => s_DFF1_PC_Plus_Four,
            o_Q => s_DFF2_PC_Plus_Four);  

    DFF3 : Nbit_dffg
    port map(i_CLK => i_clk,
            i_RST => i_rst,
            i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
            i_D => s_Jump_Address,
            o_Q => s_DFF3_PC_Jump_Address);  

    DFF4 : Nbit_dffg
    port map(i_CLK => i_clk,
            i_RST => i_rst,
            i_WE => '1', --WE of DFFs will be 1 for software scheduled pipeline
            i_D => s_Branch_Address,
            o_Q => s_DFF4_PC_Branch_Address);  


    --END STRUCTURAL CHANGES OF NEW MODULE--

	INV_ZERO : invg -- Invert 0 for and gate
		port map(
			i_A => i_zero,  
			o_F => s_Inv_Zero
		);
	
	BNE0 : mux2t1 -- BNE = 1, BEQ = 0
		port map(
			i_D0 => i_zero,
			i_D1 => s_Inv_Zero, 
			i_S => i_bne,
			o_O => s_BNE_Mux_Res
		);

	BR_AND : andg2 -- Branch && BNE
		port map(
			i_A => i_branch,
			i_B => s_BNE_Mux_Res,
			o_F => s_Branch_Mux_Sel
		);

	BR_MUX : mux2t1_N -- 0 = PC + 4, 1 = Branch Address
		port map(
			i_S => s_Branch_Mux_Sel,
			i_D0 => s_DFF2_PC_Plus_Four,
			i_D1 => s_DFF4_PC_Branch_Address,
			o_O => s_Branch_Mux_Res
		);
	
	J_MUX : mux2t1_N -- 0 = Branch mux result, 1 = Jump instruction Address	
        port map(
                i_S => i_jump,
                i_D0 => s_Branch_Mux_Res,
                i_D1 => s_DFF3_PC_Jump_Address,
                o_O => s_Jump_Mux_Res
            );
		
	OUT_MUX : mux2t1_N -- 0 = Jump mux result, 1 = Jump register
		port map(
			i_S => i_jr,
			i_D0 => s_Jump_Mux_Res,
			i_D1 => i_jumpreg,
			o_O => s_OutJrandBrLogic
		);
		
end mixed;