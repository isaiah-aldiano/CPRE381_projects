-------------------------------------------------------------------------
-- Isaiah Aldiano
-------------------------------------------------------------------------
-- tb_control.vhd 
-------------------------------------------------------------------------
-- DESCRIPTION: Test benches of control unit
-------------------------------------------------------------------------
use work.MIPS_types.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_control is 
	generic(
		opcode : integer := 5;
		funct : integer := 5;
		cntrl_sig : integer := 16;
		alu_sig : integer := 3
	);
end tb_control;

architecture mixed of tb_control is 

	component Control
		port(
			i_OpCode : in std_logic_vector(opcode downto 0);
			i_Function : in std_logic_vector(funct downto 0);
			o_ControlSig : out std_logic_vector(cntrl_sig downto 0);
			o_ALUSig : out std_logic_vector(alu_sig downto 0)
		);
	end component;

	constant clk_100 : time := 100 ns;
	--constant clk_50 : time := 50 ns;

	signal s_opcode 	: std_logic_vector(opcode downto 0);
	signal s_funct 		: std_logic_vector(funct downto 0);
	signal s_cntrl_sig	: std_logic_vector(cntrl_sig downto 0);
	signal s_alu_sig 	: std_logic_vector(alu_sig downto 0);
	
begin
	
	TB_CNTRL : Control
		port map(
			i_Opcode => s_opcode,
			i_Function => s_funct,
			o_ControlSig => s_cntrl_sig,
			o_ALUSig => s_alu_sig
		);
	
	TB_CONTROL_SIG_ASSIGNMENTS : process
	-- Testbench signals declaration
	begin

	    -- Test the ADDI instruction
	    s_opcode <= "001000";  -- ADDI
	    s_funct <= (others => 'X');  -- Don't care for ADDI
	    wait for clk_100;
	
	    -- Test the ADD instruction
	    s_opcode <= "000000";  -- ADD
	    s_funct <= "100000";  -- Function code for ADD
	    wait for clk_100;
	
	    -- Test the ADDIU instruction
	    s_opcode <= "001001";  -- ADDIU
	    s_funct <= (others => 'X');  -- Don't care for ADDIU
	    wait for clk_100;
	
	    -- Test the ADDU instruction
	    s_opcode <= "000000";  -- ADDU
	    s_funct <= "100001";  -- Function code for ADDU
	    wait for clk_100;
	
	    -- Test the AND instruction
	    s_opcode <= "000000";  -- AND
	    s_funct <= "100100";  -- Function code for AND
	    wait for clk_100;
	
	    -- Test the ANDI instruction
	    s_opcode <= "001100";  -- ANDI
	    s_funct <= (others => 'X');  -- Don't care for ANDI
	    wait for clk_100;
	
	    -- Test the LUI instruction
	    s_opcode <= "001111";  -- LUI
	    s_funct <= (others => 'X');  -- Don't care for LUI
	    wait for clk_100;
	
	    -- Test the LW instruction
	    s_opcode <= "100011";  -- LW
	    s_funct <= (others => 'X');  -- Don't care for LW
	    wait for clk_100;
	
	    -- Test the NOR instruction
	    s_opcode <= "000000";  -- NOR
	    s_funct <= "100111";  -- Function code for NOR
	    wait for clk_100;
	
	    -- Test the XOR instruction
	    s_opcode <= "000000";  -- XOR
	    s_funct <= "100110";  -- Function code for XOR
	    wait for clk_100;
	
	    -- Test the XORI instruction
	    s_opcode <= "001110";  -- XORI
	    s_funct <= (others => 'X');  -- Don't care for XORI
	    wait for clk_100;
	
	    -- Test the OR instruction
	    s_opcode <= "000000";  -- OR
	    s_funct <= "100101";  -- Function code for OR
	    wait for clk_100;
	
	    -- Test the ORI instruction
	    s_opcode <= "001101";  -- ORI
	    s_funct <= (others => 'X');  -- Don't care for ORI
	    wait for clk_100;
	
	    -- Test the SLT instruction
	    s_opcode <= "000000";  -- SLT
	    s_funct <= "101010";  -- Function code for SLT
	    wait for clk_100;
	
	    -- Test the SLTI instruction
	    s_opcode <= "001010";  -- SLTI
	    s_funct <= (others => 'X');  -- Don't care for SLTI
	    wait for clk_100;
	
	    -- Test the SLL instruction
	    s_opcode <= "000000";  -- SLL
	    s_funct <= "000000";  -- Function code for SLL
	    wait for clk_100;
	
	    -- Test the SRL instruction
	    s_opcode <= "000000";  -- SRL
	    s_funct <= "000010";  -- Function code for SRL
	    wait for clk_100;
	
	    -- Test the SRA instruction
	    s_opcode <= "000000";  -- SRA
	    s_funct <= "000011";  -- Function code for SRA
	    wait for clk_100;
	
	    -- Test the SW instruction
	    s_opcode <= "101011";  -- SW
	    s_funct <= (others => 'X');  -- Don't care for SW
	    wait for clk_100;
	
	    -- Test the SUB instruction
	    s_opcode <= "000000";  -- SUB
	    s_funct <= "100010";  -- Function code for SUB
	    wait for clk_100;
	
	    -- Test the SUBU instruction
	    s_opcode <= "000000";  -- SUBU
	    s_funct <= "100011";  -- Function code for SUBU
	    wait for clk_100;
	
	    -- Test the BEQ instruction
	    s_opcode <= "000100";  -- BEQ
	    s_funct <= (others => 'X');  -- Don't care for BEQ
	    wait for clk_100;
	
	    -- Test the BNE instruction
	    s_opcode <= "000101";  -- BNE
	    s_funct <= (others => 'X');  -- Don't care for BNE
	    wait for clk_100;
	
	    -- Test the J instruction
	    s_opcode <= "000010";  -- J
	    s_funct <= (others => 'X');  -- Don't care for J
	    wait for clk_100;
	
	    -- Test the JAL instruction
	    s_opcode <= "000011";  -- JAL
	    s_funct <= (others => 'X');  -- Don't care for JAL
	    wait for clk_100;
	
	    -- Test the JR instruction
	    s_opcode <= "000000";  -- JR
	    s_funct <= "001000";  -- Function code for JR
	    wait for clk_100;
	
	    -- Test the LB instruction
	    s_opcode <= "100000";  -- LB
	    s_funct <= (others => 'X');  -- Don't care for LB
	    wait for clk_100;
	
	    -- Test the LH instruction
	    s_opcode <= "100001";  -- LH
	    s_funct <= (others => 'X');  -- Don't care for LH
	    wait for clk_100;
	
	    -- Test the LBU instruction
	    s_opcode <= "100100";  -- LBU
	    s_funct <= (others => 'X');  -- Don't care for LBU
	    wait for clk_100;
	
	    -- Test the LHU instruction
	    s_opcode <= "100101";  -- LHU
	    s_funct <= (others => 'X');  -- Don't care for LHU
	    wait for clk_100;
	
	    -- Test the SLLV instruction
	    s_opcode <= "000000";  -- SLLV
	    s_funct <= "000100";  -- Function code for SLLV
	    wait for clk_100;
	
	    -- Test the SRLV instruction
	    s_opcode <= "000000";  -- SRLV
	    s_funct <= "000110";  -- Function code for SRLV
	    wait for clk_100;
	
	    -- Test the SRAV instruction
	    s_opcode <= "000000";  -- SRAV
	    s_funct <= "000111";  -- Function code for SRAV
	    wait for clk_100;
	
	    -- Test the HALT instruction
	    s_opcode <= "010100";  -- HALT
	    s_funct <= (others => 'X');  -- Don't care for HALT
	    wait for clk_100;

	end process;


end mixed; 