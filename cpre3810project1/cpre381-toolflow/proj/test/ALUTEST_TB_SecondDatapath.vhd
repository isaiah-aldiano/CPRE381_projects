-------------------------------------------------------------------------
-- Sam Burns
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- ALUTEST_TB_SecondDatapath.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for SecondDatapath.vhd
--             
-- created 22:30 on 2/16/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O
use work.mux_package.all;

entity ALUTEST_TB_SecondDatapath is 
   generic(gCLK_HPER : time := 10ns); --generic for half the clock cycle period
end ALUTEST_TB_SecondDatapath;

architecture structure of ALUTEST_TB_SecondDatapath is 

constant cCLK_PER  : time := gCLK_HPER * 2;

--Define FirstDatapath component to be tested 
   component SecondDatapath is 
        port(CLK : in std_logic;
        reset : in std_logic;
        ALUSrc : in std_logic;
        nADD_SUB : in std_logic;
        wrte_EN : in std_logic;
        sw : in std_logic;
        lw : in std_logic;
        extender_control : in std_logic;
        wrte_ADDR : in std_logic_vector(4 downto 0);
        rd_REG1 : in std_logic_vector(4 downto 0);
        rd_REG2 : in std_logic_vector(4 downto 0);
        immediate : in std_logic_vector(15 downto 0);
        o_ALU : out std_logic_vector(31 downto 0));
   end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero
    signal CLK, reset : std_logic := '0';
--define signals to be used for testing (both input and outputs)
    signal si_ALUSrc : std_logic := '0';
    signal si_nADD_SUB : std_logic := '0';
    signal si_WRITE_EN : std_logic := '0';  
    signal si_sw : std_logic := '0';
    signal si_lw : std_logic := '0';
    signal si_extender_control : std_logic := '0';
    signal si_WRITE_ADDR: std_logic_vector(4 downto 0) := b"00000";
    signal si_READ1 : std_logic_vector(4 downto 0) := b"00000";
    signal si_READ2 : std_logic_vector(4 downto 0) := b"00000";
    signal si_immediate : std_logic_vector(15 downto 0) := x"0000";
    signal so_ALU : std_logic_vector(31 downto 0);
    
   begin 
   
   DUT0 : SecondDatapath 
      port map(CLK => CLK,
		reset => reset,
		ALUSrc => si_ALUSrc,
		nADD_SUB => si_nADD_SUB,
		wrte_EN => si_WRITE_EN,
        sw => si_sw,
        lw => si_lw,
        extender_control => si_extender_control, 
		wrte_ADDR => si_WRITE_ADDR,
		rd_REG1 => si_READ1,
		rd_REG2 => si_READ2,
		immediate => si_immediate,
		o_ALU => so_ALU);

--This first process is to setup the clock for the test bench
P_CLK: process
  begin
  CLK <= '1';         -- clock starts at 1
  wait for gCLK_HPER; -- after half a cycle
  CLK <= '0';         -- clock becomes a 0 (negative edge)
  wait for gCLK_HPER; -- after half a cycle, process begins evaluation again
end process;
              
-- This process resets the sequential components of the design.
-- It is held to be 1 across both the negative and positive edges of the clock
-- so it works regardless of whether the design uses synchronous (pos or neg edge)
-- or asynchronous resets.
P_RST: process
  begin
    reset <= '0';   
  wait for gCLK_HPER/2;
  reset <= '1';
  wait for gCLK_HPER*2;
  reset <= '0';
  wait;
end process;

-- Start test cases here 
P_TEST_CASES: process
   begin
   wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges
   
   --Test 0: reset the component
   reset <= '1';
   si_ALUSrc <= '0';
   si_nADD_SUB <= '0';
   si_WRITE_EN <= '0';
   si_sw <= '0';
   si_lw <= '0';
   si_extender_control <= '0';
   si_WRITE_ADDR <= b"00000";
   si_READ1 <= b"00000";
   si_READ2 <= b"00000";
   si_immediate <= x"0000";
   wait for cCLK_PER;
   --Expect output to be x"00000000"

   --Test 1: load &A into $25 (addi $25, $0, 0)
   reset <= '0';
   si_ALUSrc <= '1';
   si_nADD_SUB <= '0';
   si_WRITE_EN <= '1';
   si_sw <= '0';
   si_lw <= '0';
   si_extender_control <= '0';
   si_WRITE_ADDR <= b"11001"; --$25
   si_READ1 <= b"00000";
   si_READ2 <= b"00000"; --Value not used since immediate is being loaded
   si_immediate <= x"0000";
   wait for cCLK_PER;
   --Expect output to be x"00000000" and expect value of $25 to be 0 on next positive clock edge

   --Test 2: load &B into $26 (addi $26, $0, 256)
   reset <= '0';
   si_ALUSrc <= '1';
   si_nADD_SUB <= '0';
   si_WRITE_EN <= '1';
   si_sw <= '0';
   si_lw <= '0';
   si_extender_control <= '1';
   si_WRITE_ADDR <= b"11010"; --$26
   si_READ1 <= b"00000";
   si_READ2 <= b"00000"; --Value not used since immediate is being loaded
   si_immediate <= x"0100"; -- immediate 
   wait for cCLK_PER;
   --Expect output to be x"00000100" and expect value of $26 to be 256 on next positive clock edge


   --Test 3: Perform lw $1, 0($25) (load memory value located at address value of $25 (0) with immediate offset of zero and store to $1)
   reset <= '0';
   si_ALUSrc <= '1';
   si_nADD_SUB <= '0';
   si_WRITE_EN <= '1';
   si_sw <= '0';
   si_lw <= '1';
   si_extender_control <= '1';
   si_WRITE_ADDR <= b"00001"; --$25
   si_READ1 <= b"11001";
   si_READ2 <= b"00000"; --Value not used since immediate is being loaded
   si_immediate <= x"0000"; -- immediate
   wait for cCLK_PER;
   --Expect output to be "FFFFFFFF" and expect value of $1 to be x"FFFFFFFF" on next positive clock edge

   --Test 4: Perform lw $2, 4($25) (load memory value located at address value of $25 (0) with immediate offset of 4 and store to $2)
   reset <= '0';
   si_ALUSrc <= '1';
   si_nADD_SUB <= '0';
   si_WRITE_EN <= '1';
   si_sw <= '0';
   si_lw <= '1';
   si_extender_control <= '1';
   si_WRITE_ADDR <= b"00010"; --$2
   si_READ1 <= b"11001"; --$25
   si_READ2 <= b"00000"; --Value not used since immediate is being loaded
   si_immediate <= x"0004"; -- immediate
   wait for cCLK_PER;
   --Expect ALU output to be x"00000004" and expect value of $2 to be x"00000005" on next positive clock edge

   --Test 5: Perform add $1, $1, $2 (add contents of $1 and $2 and store result in $1)
   reset <= '0';
   si_ALUSrc <= '0'; --not loading an immediate
   si_nADD_SUB <= '0'; 
   si_WRITE_EN <= '1'; -- writing to a register 
   si_sw <= '0'; -- not sw operation 
   si_lw <= '0'; -- writing ALU output back to registers
   si_extender_control <= '1';
   si_WRITE_ADDR <= b"00001"; --$1
   si_READ1 <= b"00001"; --$1
   si_READ2 <= b"00010"; --$2
   si_immediate <= x"0000"; -- value not used because two registers are being added
   wait for cCLK_PER;
   --Expect output of ALU to be x"00000004" and expect value of $1 to be x"00000004" on next positive clock edge

   --Test 6: Perform sw $1, 0($26) (store contents of $1 into B[0]
   reset <= '0';
   si_ALUSrc <= '1'; --loading an immediate
   si_nADD_SUB <= '0'; 
   si_WRITE_EN <= '0'; -- not writing to a register 
   si_sw <= '1'; -- sw operation 
   si_lw <= '0'; -- not being used so value does not matter
   si_extender_control <= '1';
   si_WRITE_ADDR <= b"00000"; -- Not writing to any register so use $0
   si_READ1 <= b"11010"; --$26
   si_READ2 <= b"00001"; --$1 (data from here goes to input data of mem)
   si_immediate <= x"0000"; -- offset of 0
   wait for cCLK_PER;
   --Expect output of ALU to be x"00000100" and expect value of 0x100 in mem to be x"00000004" on next positive clock edge

   --Test 7: Perform lw $2, 8($25) (load memory value located at address value of $25 (0) with immediate offset of 8 and store to $2)
   reset <= '0';
   si_ALUSrc <= '1';
   si_nADD_SUB <= '0';
   si_WRITE_EN <= '1';
   si_sw <= '0'; -- not writing to memory
   si_lw <= '1'; -- loading value from memory
   si_extender_control <= '1';
   si_WRITE_ADDR <= b"00010"; --$2
   si_READ1 <= b"11001";
   si_READ2 <= b"00000"; --Value not used since immediate is being loaded
   si_immediate <= x"0008"; -- immediate
   wait for cCLK_PER;
   --Expect output to be x"00000008" and expect value of $2 to be x"00000009" on next positive clock edge

   --Test 8: Perform add $1, $1, $2 (add contents of $1 and $2 and store result in $1)
   reset <= '0';
   si_ALUSrc <= '0'; --not loading an immediate
   si_nADD_SUB <= '0'; 
   si_WRITE_EN <= '1'; -- writing to a register 
   si_sw <= '0'; -- not sw operation 
   si_lw <= '0'; -- writing ALU output back to registers
   si_extender_control <= '0'; -- Not loading an intermediate value so not needed
   si_WRITE_ADDR <= b"00001"; --$1
   si_READ1 <= b"00001"; --$1
   si_READ2 <= b"00010"; --$2
   si_immediate <= x"0000"; -- value not used because two registers are being added
   wait for cCLK_PER;
   --Expect output of ALU to be x"0000000D" and expect value of $1 to be x"0000000D" on next positive clock edge

   --Test 9: Perform sw $1, 4($26) (store contents of $1 into B[1]
   reset <= '0';
   si_ALUSrc <= '1'; --loading an immediate
   si_nADD_SUB <= '0'; 
   si_WRITE_EN <= '0'; -- not writing to a register 
   si_sw <= '1'; -- sw operation 
   si_lw <= '0'; -- not being used so value does not matter
   si_extender_control <= '1';
   si_WRITE_ADDR <= b"00000"; -- Not writing to any register so use $0
   si_READ1 <= b"11010"; --$26
   si_READ2 <= b"00001"; --$1 (data from here goes to input data of mem)
   si_immediate <= x"0004"; -- offset of 0
   wait for cCLK_PER;
   --Expect output of ALU to be x"00000104" and expect value of 0x104 in mem to be x"0000000D" on next positive clock edge


   --Test 10: Perform lw $2, 12($25) (load memory value located at address value of $25 (0) with immediate offset of 12 and store to $2)
   reset <= '0';
   si_ALUSrc <= '1';
   si_nADD_SUB <= '0';
   si_WRITE_EN <= '1';
   si_sw <= '0'; -- not writing to memory
   si_lw <= '1'; -- loading value from memory
   si_extender_control <= '1';
   si_WRITE_ADDR <= b"00010"; --$2
   si_READ1 <= b"11001"; --$25
   si_READ2 <= b"00000"; --Value not used since immediate is being loaded
   si_immediate <= x"000C"; -- immediate
   wait for cCLK_PER;
   --Expect output to be x"0000000C" and expect value of $2 to be x"0000FFFF" on next positive clock edge

   --Test 11: Perform add $1, $1, $2 (add contents of $1 and $2 and store result in $1)
   reset <= '0';
   si_ALUSrc <= '0'; --not loading an immediate
   si_nADD_SUB <= '0'; 
   si_WRITE_EN <= '1'; -- writing to a register 
   si_sw <= '0'; -- not sw operation 
   si_lw <= '0'; -- writing ALU output back to registers
   si_extender_control <= '1';
   si_WRITE_ADDR <= b"00001"; --$1
   si_READ1 <= b"00001"; --$1
   si_READ2 <= b"00010"; --$2
   si_immediate <= x"0000"; -- value not used because two registers are being added
   wait for cCLK_PER;
   --Expect output of ALU to be x"0001000C" and expect value of $1 to be x"0001000C" on next positive clock edge

   --Test 12: Perform sw $1, 8($26) (store contents of $1 into B[2]
   reset <= '0';
   si_ALUSrc <= '1'; --loading an immediate
   si_nADD_SUB <= '0'; 
   si_WRITE_EN <= '0'; -- not writing to a register 
   si_sw <= '1'; -- sw operation 
   si_lw <= '0'; -- not being used so value does not matter
   si_extender_control <= '1';
   si_WRITE_ADDR <= b"00000"; -- Not writing to any register so use $0
   si_READ1 <= b"11010"; --$26
   si_READ2 <= b"00001"; --$1 (data from here goes to input data of mem)
   si_immediate <= x"0008"; -- offset of 0
   wait for cCLK_PER;
   --Expect output of ALU to be x"00000108" and expect value of 0x108 in mem to be x"0001000C" on next positive clock edge


   --Test 13: Perform lw $2, 16($25) (load memory value located at address value of $25 (0) with immediate offset of 16 and store to $2)
   reset <= '0';
   si_ALUSrc <= '1';
   si_nADD_SUB <= '0';
   si_WRITE_EN <= '1';
   si_sw <= '0'; -- not writing to memory
   si_lw <= '1'; -- loading value from memory
   si_extender_control <= '1';
   si_WRITE_ADDR <= b"00010"; --$2
   si_READ1 <= b"11001"; --$25
   si_READ2 <= b"00000"; --Value not used since immediate is being loaded
   si_immediate <= x"0010"; -- immediate
   wait for cCLK_PER;
   --Expect output to be x"00000010" and expect value of $2 to be x"00000001" on next positive clock edge


   --Test 14: Perform add $1, $1, $2 (add contents of $1 and $2 and store result in $1)
   reset <= '0';
   si_ALUSrc <= '0'; --not loading an immediate
   si_nADD_SUB <= '0'; 
   si_WRITE_EN <= '1'; -- writing to a register 
   si_sw <= '0'; -- not sw operation 
   si_lw <= '0'; -- writing ALU output back to registers
   si_extender_control <= '1';
   si_WRITE_ADDR <= b"00001"; --$1
   si_READ1 <= b"00001"; --$1
   si_READ2 <= b"00010"; --$2
   si_immediate <= x"0000"; -- value not used because two registers are being added
   wait for cCLK_PER;
   --Expect output of ALU to be x"0001000D" and expect value of $1 to be x"0001000D" on next positive clock edge

   --Test 15: Perform sw $1, 12($26) (store contents of $1 into B[3]
   reset <= '0';
   si_ALUSrc <= '1'; --loading an immediate
   si_nADD_SUB <= '0'; 
   si_WRITE_EN <= '0'; -- not writing to a register 
   si_sw <= '1'; -- sw operation 
   si_lw <= '0'; -- not being used so value does not matter
   si_extender_control <= '1';
   si_WRITE_ADDR <= b"00000"; -- Not writing to any register so use $0
   si_READ1 <= b"11010"; --$26
   si_READ2 <= b"00001"; --$1 (data from here goes to input data of mem)
   si_immediate <= x"000C"; -- offset of 0
   wait for cCLK_PER;
   --Expect output of ALU to be x"0000010C" and expect value of 0x10C in mem to be x"0001000D" on next positive clock edge

   --Test 16: Perform lw $2, 20($25) (load memory value located at address value of $25 (0) with immediate offset of 20 and store to $2)
   reset <= '0';
   si_ALUSrc <= '1';
   si_nADD_SUB <= '0';
   si_WRITE_EN <= '1';
   si_sw <= '0'; -- not writing to memory
   si_lw <= '1'; -- loading value from memory
   si_extender_control <= '1';
   si_WRITE_ADDR <= b"00010"; --$2
   si_READ1 <= b"11001"; --$25
   si_READ2 <= b"00000"; --Value not used since immediate is being loaded
   si_immediate <= x"0014"; -- immediate
   wait for cCLK_PER;
   --Expect output to be x"FFFEFFF4" and expect value of $2 to be x"FFFEFFF4" on next positive clock edge

   --Test 17: Perform add $1, $1, $2 (add contents of $1 and $2 and store result in $1)
   reset <= '0';
   si_ALUSrc <= '0'; --not loading an immediate
   si_nADD_SUB <= '0'; 
   si_WRITE_EN <= '1'; -- writing to a register 
   si_sw <= '0'; -- not sw operation 
   si_lw <= '0'; -- writing ALU output back to registers
   si_extender_control <= '1';
   si_WRITE_ADDR <= b"00001"; --$1
   si_READ1 <= b"00001"; --$1
   si_READ2 <= b"00010"; --$2
   si_immediate <= x"0000"; -- value not used because two registers are being added
   wait for cCLK_PER;
   --Expect output of ALU to be x"000000001 and expect value of $1 to be x"00000001" on next positive clock edge

   --Test 18: Perform sw $1, 16($26) (store contents of $1 into B[4]
   reset <= '0';
   si_ALUSrc <= '1'; --loading an immediate
   si_nADD_SUB <= '0'; 
   si_WRITE_EN <= '0'; -- not writing to a register 
   si_sw <= '1'; -- sw operation 
   si_lw <= '0'; -- not being used so value does not matter
   si_extender_control <= '1';
   si_WRITE_ADDR <= b"00000"; -- Not writing to any register so use $0
   si_READ1 <= b"11010"; --$26
   si_READ2 <= b"00001"; --$1 (data from here goes to input data of mem)
   si_immediate <= x"0010"; -- offset of 0
   wait for cCLK_PER;
   --Expect output of ALU to be x"00000110" and expect value of 0x110 in mem to be x"00000001" on next positive clock edge

   --Test 19: Perform lw $2, 24($25) (load memory value located at address value of $25 (0) with immediate offset of 24 and store to $2)
   reset <= '0';
   si_ALUSrc <= '1';
   si_nADD_SUB <= '0';
   si_WRITE_EN <= '1';
   si_sw <= '0'; -- not writing to memory
   si_lw <= '1'; -- loading value from memory
   si_extender_control <= '1';
   si_WRITE_ADDR <= b"00010"; --$2
   si_READ1 <= b"11001"; --$25
   si_READ2 <= b"00000"; --Value not used since immediate is being loaded
   si_immediate <= x"0018"; -- immediate
   wait for cCLK_PER;
   --Expect output to be x"FFFFFFFF" and expect value of $2 to be x"FFFFFFFF" on next positive clock edge

   --Test 20: Perform add $1, $1, $2 (add contents of $1 and $2 and store result in $1)
   reset <= '0';
   si_ALUSrc <= '0'; --not loading an immediate
   si_nADD_SUB <= '0'; 
   si_WRITE_EN <= '1'; -- writing to a register 
   si_sw <= '0'; -- not sw operation 
   si_lw <= '0'; -- writing ALU output back to registers
   si_extender_control <= '1';
   si_WRITE_ADDR <= b"00001"; --$1
   si_READ1 <= b"00001"; --$1
   si_READ2 <= b"00010"; --$2
   si_immediate <= x"0000"; -- value not used because two registers are being added
   wait for cCLK_PER;
   --Expect output of ALU to be x"000000000 and expect value of $1 to be x"00000000" on next positive clock edge

   --Test 21: load &B[64] into $27 (addi $27, $0, 512)
   reset <= '0';
   si_ALUSrc <= '1';
   si_nADD_SUB <= '0';
   si_WRITE_EN <= '1';
   si_sw <= '0';
   si_lw <= '0';
   si_extender_control <= '1';
   si_WRITE_ADDR <= b"11011"; --$27
   si_READ1 <= b"00000";
   si_READ2 <= b"00000"; --Value not used since immediate is being loaded
   si_immediate <= x"0200"; -- immediate 
   wait for cCLK_PER;
   --Expect output to be x"00000200" and expect value of $27 to be x"00000200 on next positive clock edge

   --Test 22: Perform sw $1, -4($26) (store contents of $1 into B[63]
   reset <= '0';
   si_ALUSrc <= '1'; --loading an immediate
   si_nADD_SUB <= '0'; 
   si_WRITE_EN <= '0'; -- not writing to a register 
   si_sw <= '1'; -- sw operation 
   si_lw <= '0'; -- not being used so value does not matter
   si_extender_control <= '1';
   si_WRITE_ADDR <= b"00000"; -- Not writing to any register so use $0
   si_READ1 <= b"11011"; --$26
   si_READ2 <= b"00001"; --$1 (data from here goes to input data of mem)
   si_immediate <= x"FFFC"; -- offset of 0
   wait for cCLK_PER;
   --Expect output of ALU to be x"000001FC" and expect value of 0x1FC in mem to be x"00000000" on next positive clock edge

   wait;
   end process;
end structure;


