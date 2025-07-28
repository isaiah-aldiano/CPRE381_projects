library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.MIPS_types.all;

entity tb_hazard_detection is
-- Testbench has no ports
end tb_hazard_detection;

architecture Behavioral of tb_hazard_detection is

    -- Component declaration for the Unit Under Test (UUT)
    component hazard_detection
    port(
        i_INSTR_IF : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_INSTR_ID : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_INSTR_EX : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_INSTR_MEM : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_INSTR_WB : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_BRNACH_TAKEN : in std_logic;

        o_FLUSH_ID : out std_logic;
        o_FLUSH_IF: out std_logic;
        o_STALL_IF : out std_logic;
        o_STALL_ID :  out std_logic;
        o_PC_WE : out std_logic
    );
    end component;

    -- Signals to connect to the UUT
    signal si_INSTR_IF : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal si_INSTR_ID : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal si_INSTR_EX : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal si_INSTR_MEM : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal si_INSTR_WB : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal si_BRNACH_TAKEN : std_logic;

    signal so_FLUSH_ID : std_logic;
    signal so_FLUSH_IF: std_logic;
    signal so_STALL_IF : std_logic;
    signal so_STALL_ID : std_logic;
    signal so_PC_WE : std_logic;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: hazard_detection
        port map (
            i_INSTR_IF => si_INSTR_IF,
            i_INSTR_ID => si_INSTR_ID,
            i_INSTR_EX => si_INSTR_EX,
            i_INSTR_MEM => si_INSTR_MEM,
            i_INSTR_WB => si_INSTR_WB,
            i_BRNACH_TAKEN => si_BRNACH_TAKEN,

            o_FLUSH_ID => so_FLUSH_ID,
            o_FLUSH_IF => so_FLUSH_IF,
            o_STALL_IF => so_STALL_IF,
            o_STALL_ID => so_STALL_ID,
            o_PC_WE => so_PC_WE
        );

    -- Test process
    stim_proc: process
    begin
        -- Test case 1: No Load and Instr in EX is a NOP
        si_INSTR_IF <= x"00000000"; -- No operation
        si_INSTR_ID <= x"11111111"; -- Some other operation
        si_INSTR_EX <= x"00000000"; -- No operation
        si_INSTR_MEM <= x"00000000"; -- No operation
        si_INSTR_WB <= x"00000000"; -- No operation
        si_BRNACH_TAKEN <= '0'; -- No branch taken
        wait for 10 ns;
        -- Stall and Flush outputs should all be zero, PC_WE should be '1'

        -- Test case 2: Branch taken
        si_INSTR_IF <= x"00000000"; -- No operation
        si_INSTR_ID <= x"11111111"; -- Some other operation
        si_INSTR_EX <= x"00000000"; -- No operation
        si_INSTR_MEM <= x"00000000"; -- No operation    
        si_INSTR_WB <= x"00000000"; -- No operation
        si_BRNACH_TAKEN <= '1'; -- Branch taken
        wait for 10 ns;
        -- Flush outputs should be '1', Stall outputs should be '0', PC_WE should be '1'

        --Test Case 3: Jump instruction
        si_INSTR_IF <= x"00000000"; -- No operation
        si_INSTR_ID <= x"11111111"; -- Some other operation
        si_INSTR_EX <= b"00001000000000000000000000000000"; -- JUMP instruction
        si_INSTR_MEM <= x"00000000"; -- No operation
        si_INSTR_WB <= x"00000000"; -- No operation
        si_BRNACH_TAKEN <= '0'; -- No branch taken
        wait for 10 ns;
        -- Flush outputs should be '1', Stall outputs should be '0', PC_WE should be '1'

        --Test Case 4: JAL instruction
        si_INSTR_IF <= x"00000000"; -- No operation
        si_INSTR_ID <= x"11111111"; -- Some other operation
        si_INSTR_EX <= b"00001100000000000000000000000000"; -- JAL instruction
        si_INSTR_MEM <= x"00000000"; -- No operation
        si_INSTR_WB <= x"00000000"; -- No operation
        si_BRNACH_TAKEN <= '0'; -- No branch taken
        wait for 10 ns;
        -- Flush outputs should be '1', Stall outputs should be '0', PC_WE should be '1'

        --Test Case 5: JR instruction
        si_INSTR_IF <= x"00000000"; -- No operation
        si_INSTR_ID <= x"11111111"; -- Some other operation
        si_INSTR_EX <= b"00000000000000000000000000001000"; -- JR instruction
        si_INSTR_MEM <= x"00000000"; -- No operation
        si_INSTR_WB <= x"00000000"; -- No operation
        si_BRNACH_TAKEN <= '0'; -- No branch taken
        wait for 10 ns;
        -- Flush outputs should be '1', Stall outputs should be '0', PC_WE should be '1'



        -- Test case 6: Load detected with hazard in RS (R type)
        si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
        si_INSTR_ID <= b"00000000000001000000000000001000"; -- Some other operation
        si_INSTR_EX <= b"10001100010000000000000000000000"; -- Load instruction (LW)
        si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
        si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
        si_BRNACH_TAKEN <= '0'; -- No branch taken
        wait for 10 ns;
        -- Flush outputs should be '0', Stall outputs should be '1', PC_WE should be '0'

        -- Test case 7: Load detected with hazard in RT (R Type)
        si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
        si_INSTR_ID <= b"00000000000001000000000000001000"; -- Some other operation
        si_INSTR_EX <= b"10001100000001000000000000000000"; -- Load instruction (LW)
        si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
        si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
        si_BRNACH_TAKEN <= '0'; -- No branch taken
        wait for 10 ns;
        -- Flush outputs should be '0', Stall outputs should be '1', PC_WE should be '0'

        -- Test case 8: Load detected with no hazard (R Type)
        si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
        si_INSTR_ID <= b"00000000000001000000000000001000"; -- Some other operation
        si_INSTR_EX <= b"10001100000010000000000000000000"; -- Load instruction (LW)
        si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
        si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
        si_BRNACH_TAKEN <= '0'; -- No branch taken
        wait for 10 ns;
        -- Flush outputs should be '0', Stall outputs should be '0', PC_WE should be '1'

        -- Test case 9: Load detected with hazard in RS (I Type)
        si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
        si_INSTR_ID <= b"10000000000001000000000000001000"; -- Some other operation
        si_INSTR_EX <= b"10001100010000000000000000000000"; -- Load instruction (LW)
        si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
        si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
        si_BRNACH_TAKEN <= '0'; -- No branch taken
        wait for 10 ns;
        -- Flush outputs should be '0', Stall outputs should be '1', PC_WE should be '0'

    -- Test case 10: Load detected with hazard in RT (I Type) (should result in no hazard)
        si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
        si_INSTR_ID <= b"10000000000001000000000000001000"; -- Some other operation
        si_INSTR_EX <= b"10001100000001000000000000000000"; -- Load instruction (LW)
        si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
        si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
        si_BRNACH_TAKEN <= '0'; -- No branch taken
        wait for 10 ns;
        -- Flush outputs should be '0', Stall outputs should be '0', PC_WE should be '1'

    -- Test case 11: Load detected with no hazard (I Type) (should result in no hazard)
        si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
        si_INSTR_ID <= b"10000000000001000000000000001000"; -- Some other operation
        si_INSTR_EX <= b"10001100000010000000000000000000"; -- Load instruction (LW)
        si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
        si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
        si_BRNACH_TAKEN <= '0'; -- No branch taken
        wait for 10 ns;
    -- Flush outputs should be '0', Stall outputs should be '0', PC_WE should be '0'


    -- Test case 12: LB detected with hazard in RS (R type)
    si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
    si_INSTR_ID <= b"00000000000001000000000000001000"; -- Some other operation
    si_INSTR_EX <= b"10000000010000000000000000000000"; -- Load instruction (LW)
    si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
    si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
    si_BRNACH_TAKEN <= '0'; -- No branch taken
    wait for 10 ns;
    -- Flush outputs should be '0', Stall outputs should be '1', PC_WE should be '0' TIMESTAMP 110nS

    -- Test case 13: LB detected with hazard in RT (R Type)
    si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
    si_INSTR_ID <= b"00000000000001000000000000001000"; -- Some other operation
    si_INSTR_EX <= b"10000000000001000000000000000000"; -- Load instruction (LW)
    si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
    si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
    si_BRNACH_TAKEN <= '0'; -- No branch taken
    wait for 10 ns;
    -- Flush outputs should be '0', Stall outputs should be '1', PC_WE should be '0' TIMESTAMP 120nS


    -- Test case 14: LB detected with no hazard (R Type)
    si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
    si_INSTR_ID <= b"00000000000001000000000000001000"; -- Some other operation
    si_INSTR_EX <= b"10000000000010000000000000000000"; -- Load instruction (LW)
    si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
    si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
    si_BRNACH_TAKEN <= '0'; -- No branch taken
    wait for 10 ns;
    -- Flush outputs should be '0', Stall outputs should be '0', PC_WE should be '1' TIMESTAMP 130nS

    -- Test case 15: LB detected with hazard in RS (I Type)
    si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
    si_INSTR_ID <= b"10000000000001000000000000001000"; -- Some other operation
    si_INSTR_EX <= b"10000000010000000000000000000000"; -- Load instruction (LW)
    si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
    si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
    si_BRNACH_TAKEN <= '0'; -- No branch taken
    wait for 10 ns;
    -- Flush outputs should be '0', Stall outputs should be '1', PC_WE should be '0' TIMESTAMP 140nS

    -- Test case 16: LB detected with hazard in RT (I Type) (should result in no hazard)
    si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
    si_INSTR_ID <= b"10000000000001000000000000001000"; -- Some other operation
    si_INSTR_EX <= b"10000000000001000000000000000000"; -- Load instruction (LW)
    si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
    si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
    si_BRNACH_TAKEN <= '0'; -- No branch taken
    wait for 10 ns;
    -- Flush outputs should be '0', Stall outputs should be '0', PC_WE should be '1' TIMESTAMP 150nS

-- Test case 17: LB detected with no hazard (I Type) (should result in no hazard)
    si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
    si_INSTR_ID <= b"10000000000001000000000000001000"; -- Some other operation
    si_INSTR_EX <= b"10000000000010000000000000000000"; -- Load instruction (LW)
    si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
    si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
    si_BRNACH_TAKEN <= '0'; -- No branch taken
    wait for 10 ns;
-- Flush outputs should be '0', Stall outputs should be '0', PC_WE should be '1' TIMESTAMP 160nS



   -- Test case 18: LH detected with hazard in RS (R type)
   si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
   si_INSTR_ID <= b"00000000000001000000000000001000"; -- Some other operation
   si_INSTR_EX <= b"10000100010000000000000000000000"; -- Load instruction (LW)
   si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
   si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
   si_BRNACH_TAKEN <= '0'; -- No branch taken
   wait for 10 ns;
   -- Flush outputs should be '0', Stall outputs should be '1', PC_WE should be '0' TIMESTAMP 170nS

   -- Test case 19: LH detected with hazard in RT (R Type)
   si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
   si_INSTR_ID <= b"00000000000001000000000000001000"; -- Some other operation
   si_INSTR_EX <= b"10000100000001000000000000000000"; -- Load instruction (LW)
   si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
   si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
   si_BRNACH_TAKEN <= '0'; -- No branch taken
   wait for 10 ns;
   -- Flush outputs should be '0', Stall outputs should be '1', PC_WE should be '0' TIMESTAMP 180nS


   -- Test case 20: LH detected with no hazard (R Type)
   si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
   si_INSTR_ID <= b"00000000000001000000000000001000"; -- Some other operation
   si_INSTR_EX <= b"10000100000010000000000000000000"; -- Load instruction (LW)
   si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
   si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
   si_BRNACH_TAKEN <= '0'; -- No branch taken
   wait for 10 ns;
   -- Flush outputs should be '0', Stall outputs should be '0', PC_WE should be '1' TIMESTAMP 190nS

   -- Test case 21: LH detected with hazard in RS (I Type)
   si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
   si_INSTR_ID <= b"10000000000001000000000000001000"; -- Some other operation
   si_INSTR_EX <= b"10000100010000000000000000000000"; -- Load instruction (LW)
   si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
   si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
   si_BRNACH_TAKEN <= '0'; -- No branch taken
   wait for 10 ns;
   -- Flush outputs should be '0', Stall outputs should be '1', PC_WE should be '0' TIMESTAMP 200nS

   -- Test case 22: LH detected with hazard in RT (I Type) (should result in no hazard)
   si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
   si_INSTR_ID <= b"10000000000001000000000000001000"; -- Some other operation
   si_INSTR_EX <= b"10000100000001000000000000000000"; -- Load instruction (LW)
   si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
   si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
   si_BRNACH_TAKEN <= '0'; -- No branch taken
   wait for 10 ns;
   -- Flush outputs should be '0', Stall outputs should be '0', PC_WE should be '1' TIMESTAMP 210nS

-- Test case 23: LH detected with no hazard (I Type) (should result in no hazard)
   si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
   si_INSTR_ID <= b"10000000000001000000000000001000"; -- Some other operation
   si_INSTR_EX <= b"10000100000010000000000000000000"; -- Load instruction (LW)
   si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
   si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
   si_BRNACH_TAKEN <= '0'; -- No branch taken
   wait for 10 ns;
-- Flush outputs should be '0', Stall outputs should be '0', PC_WE should be '1' TIMESTAMP 220nS








 -- Test case 24: LBU detected with hazard in RS (R type)
 si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_ID <= b"00000000000001000000000000001000"; -- Some other operation
 si_INSTR_EX <= b"10010000010000000000000000000000"; -- Load instruction (LW)
 si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
 si_BRNACH_TAKEN <= '0'; -- No branch taken
 wait for 10 ns;
 -- Flush outputs should be '0', Stall outputs should be '1', PC_WE should be '0' TIMESTAMP 230nS

 -- Test case 25: LBU detected with hazard in RT (R Type)
 si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_ID <= b"00000000000001000000000000001000"; -- Some other operation
 si_INSTR_EX <= b"10010000000001000000000000000000"; -- Load instruction (LW)
 si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
 si_BRNACH_TAKEN <= '0'; -- No branch taken
 wait for 10 ns;
 -- Flush outputs should be '0', Stall outputs should be '1', PC_WE should be '0' TIMESTAMP 240nS


 -- Test case 26: LBU detected with no hazard (R Type)
 si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_ID <= b"00000000000001000000000000001000"; -- Some other operation
 si_INSTR_EX <= b"10010000000010000000000000000000"; -- Load instruction (LW)
 si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
 si_BRNACH_TAKEN <= '0'; -- No branch taken
 wait for 10 ns;
 -- Flush outputs should be '0', Stall outputs should be '0', PC_WE should be '1' TIMESTAMP 250nS

 -- Test case 27: LBU detected with hazard in RS (I Type)
 si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_ID <= b"10000000000001000000000000001000"; -- Some other operation
 si_INSTR_EX <= b"10010000010000000000000000000000"; -- Load instruction (LW)
 si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
 si_BRNACH_TAKEN <= '0'; -- No branch taken
 wait for 10 ns;
 -- Flush outputs should be '0', Stall outputs should be '1', PC_WE should be '0' TIMESTAMP 260nS

 -- Test case 28: LBU detected with hazard in RT (I Type) (should result in no hazard)
 si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_ID <= b"10000000000001000000000000001000"; -- Some other operation
 si_INSTR_EX <= b"10010000000001000000000000000000"; -- Load instruction (LW)
 si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
 si_BRNACH_TAKEN <= '0'; -- No branch taken
 wait for 10 ns;
 -- Flush outputs should be '0', Stall outputs should be '0', PC_WE should be '1' TIMESTAMP 270nS

-- Test case 29: LBU detected with no hazard (I Type) (should result in no hazard)
 si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_ID <= b"10000000000001000000000000001000"; -- Some other operation
 si_INSTR_EX <= b"10010000000010000000000000000000"; -- Load instruction (LW)
 si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
 si_BRNACH_TAKEN <= '0'; -- No branch taken
 wait for 10 ns;
-- Flush outputs should be '0', Stall outputs should be '0', PC_WE should be '1' TIMESTAMP 280nS




 -- Test case 30: LHU detected with hazard in RS (R type)
 si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_ID <= b"00000000000001000000000000001000"; -- Some other operation
 si_INSTR_EX <= b"10010100010000000000000000000000"; -- Load instruction (LW)
 si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
 si_BRNACH_TAKEN <= '0'; -- No branch taken
 wait for 10 ns;
 -- Flush outputs should be '0', Stall outputs should be '1', PC_WE should be '0' TIMESTAMP 290nS

 -- Test case 31: LHU detected with hazard in RT (R Type)
 si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_ID <= b"00000000000001000000000000001000"; -- Some other operation
 si_INSTR_EX <= b"10010100000001000000000000000000"; -- Load instruction (LW)
 si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
 si_BRNACH_TAKEN <= '0'; -- No branch taken
 wait for 10 ns;
 -- Flush outputs should be '0', Stall outputs should be '1', PC_WE should be '0' TIMESTAMP 300nS


 -- Test case 32: LHU detected with no hazard (R Type)
 si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_ID <= b"00000000000001000000000000001000"; -- Some other operation
 si_INSTR_EX <= b"10010100000010000000000000000000"; -- Load instruction (LW)
 si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
 si_BRNACH_TAKEN <= '0'; -- No branch taken
 wait for 10 ns;
 -- Flush outputs should be '0', Stall outputs should be '0', PC_WE should be '1' TIMESTAMP 310nS

 -- Test case 33: LHU detected with hazard in RS (I Type)
 si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_ID <= b"10000000000001000000000000001000"; -- Some other operation
 si_INSTR_EX <= b"10010100010000000000000000000000"; -- Load instruction (LW)
 si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
 si_BRNACH_TAKEN <= '0'; -- No branch taken
 wait for 10 ns;
 -- Flush outputs should be '0', Stall outputs should be '1', PC_WE should be '0' TIMESTAMP 320nS

 -- Test case 34: LBU detected with hazard in RT (I Type) (should result in no hazard)
 si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_ID <= b"10000000000001000000000000001000"; -- Some other operation
 si_INSTR_EX <= b"10010100000001000000000000000000"; -- Load instruction (LW)
 si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
 si_BRNACH_TAKEN <= '0'; -- No branch taken
 wait for 10 ns;
 -- Flush outputs should be '0', Stall outputs should be '0', PC_WE should be '1' TIMESTAMP 330nS

-- Test case 35: LHU detected with no hazard (I Type) (should result in no hazard)
 si_INSTR_IF <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_ID <= b"10000000000001000000000000001000"; -- Some other operation
 si_INSTR_EX <= b"10010100000010000000000000000000"; -- Load instruction (LW)
 si_INSTR_MEM <= b"00000000000000000000000000001000"; -- Some other operation
 si_INSTR_WB <= b"00000000000000000000000000001000"; -- Some other operation
 si_BRNACH_TAKEN <= '0'; -- No branch taken
 wait for 10 ns;
-- Flush outputs should be '0', Stall outputs should be '0', PC_WE should be '1' TIMESTAMP 340nS

        -- End simulation
        wait;
    end process;

end Behavioral;