-------------------------------------------------------------------------
-- Sam Burns
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- StallFlushDFF.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for N-bit behavioral DFF
--             
-- created 17:30 on 2/05/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

entity tb_StallFlushDFF is
    generic(gCLK_HPER   : time := 10 ns; --generic for half the clock cycle period
            DATA_WIDTH  : integer := 32); 
end tb_StallFlushDFF;


architecture mixed of tb_StallFlushDFF is 
-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;

component NbitDFFFlushStall is
  generic (N : integer := 32); --32 bit default bus size
  port(i_CLK : in std_logic;
       i_RST : in std_logic;
       i_FLUSH : in std_logic;
       i_STALL : in std_logic;
       i_FLUSH_DATA : in std_logic_vector(N-1 downto 0);
       i_STALL_DATA : in std_logic_vector(N-1 downto 0);
       i_D : in std_logic_vector (N-1 downto 0);
       o_Q : out std_logic_vector(N-1 downto 0));
end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero
    signal CLK, reset : std_logic := '0';
--define signals to be used for testing (both input and outputs)
    signal si_D : std_logic_vector(DATA_WIDTH-1 downto 0) := x"00000000";
    signal so_Q0, so_Q1, so_Q2, so_Q3 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal flush0, flush1, flush2, flush3 : std_logic := '0';
    signal flush_VAL : std_logic_vector(DATA_WIDTH-1 downto 0) := x"77777777"; --This value is used to flush the DFFs, in the actual processor it needs to be the value of a NOP
    signal stall_VAL : std_logic_vector(DATA_WIDTH-1 downto 0) := x"55555555"; --This value is used to stall the DFFs, in the actual processor it needs to be the value of a NOP
    signal stall0, stall1, stall2, stall3 : std_logic := '0';

    begin 

    DUT0 : NbitDFFFlushStall
      port map (i_CLK => CLK,
                i_RST => reset,
                i_FLUSH => flush0,
                i_STALL => stall0,
                i_FLUSH_DATA => flush_VAL,
                i_STALL_DATA => stall_VAL,
                i_D => si_D,
                o_Q => so_Q0);

    DUT1 : NbitDFFFlushStall
      port map (i_CLK => CLK,
                i_RST => reset,
                i_FLUSH => flush1,
                i_STALL => stall1,
                i_FLUSH_DATA => flush_VAL,
                i_STALL_DATA => stall_VAL,
                i_D => so_Q0,
                o_Q => so_Q1);

    DUT2 : NbitDFFFlushStall
      port map (i_CLK => CLK,
                i_RST => reset,
                i_FLUSH => flush2,
                i_STALL => stall2,
                i_FLUSH_DATA => flush_VAL,
                i_STALL_DATA => stall_VAL,
                i_D => so_Q1,
                o_Q => so_Q2);

    DUT3 : NbitDFFFlushStall
      port map (i_CLK => CLK,
                i_RST => reset,
                i_FLUSH => flush3,
                i_STALL => stall3,
                i_FLUSH_DATA => flush_VAL,
                i_STALL_DATA => stall_VAL,
                i_D => so_Q2,
                o_Q => so_Q3);

    

 

    
    --This first process is to setup the clock for the test bench
  P_CLK: process
    begin
    CLK <= '1';         -- clock starts at 1
    wait for gCLK_HPER; -- after half a cycle
    CLK <= '0';         -- clock becomes a 0 (negative edge)
    wait for gCLK_HPER; -- after half a cycle, process begins evaluation again
  end process;
                

  
-- Start test cases here 
  P_TEST_CASES: process
    begin

    wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges

    -- Reset the FF
    reset  <= '1';
    flush0 <= '0';
    flush1 <= '0';
    flush2 <= '0';
    flush3 <= '0';
    stall0 <= '0';
    stall1 <= '0';
    stall2 <= '0';
    stall3 <= '0';
    si_D   <= x"00000000";
    wait for cCLK_PER;

    -- Store 'FFFFFFFF'
    reset  <= '0';
    flush0 <= '0';
    flush1 <= '0';
    flush2 <= '0';
    flush3 <= '0';
    stall0 <= '0';
    stall1 <= '0';
    stall2 <= '0';
    stall3 <= '0';
    si_D   <= x"FFFFFFFF";
    wait for cCLK_PER;

    -- Let 'FFFFFFFF' propagate through the chain
    reset  <= '0';
    flush0 <= '0';
    flush1 <= '0';
    flush2 <= '0';
    flush3 <= '0';
    stall0 <= '0';
    stall1 <= '0';
    stall2 <= '0';
    stall3 <= '0';
    si_D   <= x"00000000"; --not super necessary but helps show functionality
    wait for cCLK_PER;
    wait for cCLK_PER;
    wait for cCLK_PER;


    -- Stall DFF0 "FFFFFFFF"
    reset <= '0';
    flush0 <= '0';
    flush1 <= '0';
    flush2 <= '0';
    flush3 <= '0';
    stall0 <= '0';
    stall1 <= '0';
    stall2 <= '0';
    stall3 <= '0';
    si_D   <= x"FFFFFFFF"; --not super necessary but helps show functionality
    wait for cCLK_PER;

    reset  <= '0';
    flush0 <= '0';
    flush1 <= '0';
    flush2 <= '0';
    flush3 <= '0';
    stall0 <= '1';
    stall1 <= '0';
    stall2 <= '0';
    stall3 <= '0';
    si_D   <= x"00000000"; --not super necessary but helps show functionality
    wait for cCLK_PER;
    wait for cCLK_PER;
    wait for cCLK_PER;

  -- load DFF1 with "111111111"
    reset  <= '0';
    flush0 <= '0';
    flush1 <= '0';
    flush2 <= '0';
    flush3 <= '0';
    stall0 <= '0';
    stall1 <= '0';
    stall2 <= '0';
    stall3 <= '0';
    si_D   <= x"11111111";
    wait for cCLK_PER;

    -- Stall DFF1  -- THEREFORE DFF0 should be also be stalled to not loose data i.e "11111111"
    reset  <= '0';
    flush0 <= '0';
    flush1 <= '0';
    flush2 <= '0';
    flush3 <= '0';
    stall0 <= '1';
    stall1 <= '1';
    stall2 <= '0';
    stall3 <= '0';
    si_D   <= x"00000000"; --not super necessary but helps show functionality
    wait for cCLK_PER;


    --Stall DFF2 
    reset  <= '0';
    flush0 <= '0';
    flush1 <= '0';
    flush2 <= '0';
    flush3 <= '0';
    stall0 <= '1';
    stall1 <= '1';
    stall2 <= '1';
    stall3 <= '0';
    si_D   <= x"00000000"; --not super necessary but helps show functionality
    wait for cCLK_PER;
    
    -- Stall DFF3
    reset  <= '0';
    flush0 <= '0';
    flush1 <= '0';
    flush2 <= '0';
    flush3 <= '0';
    stall0 <= '1';
    stall1 <= '1';
    stall2 <= '1';
    stall3 <= '1';
    si_D   <= x"00000000"; --not super necessary but helps show functionality
    wait for cCLK_PER;
    wait for cCLK_PER;


    -- Flush register 0
    reset  <= '0';
    flush0 <= '1';
    flush1 <= '0';
    flush2 <= '0';
    flush3 <= '0';
    stall0 <= '0';
    stall1 <= '0';
    stall2 <= '0';
    stall3 <= '0';
    si_D   <= x"FFFFFFFF"; --not super necessary but helps show functionality  
    wait for cCLK_PER;


    -- Flush register 1
    reset  <= '0';
    flush0 <= '0';
    flush1 <= '1';
    flush2 <= '0';
    flush3 <= '0';
    stall0 <= '0';
    stall1 <= '0';
    stall2 <= '0';
    stall3 <= '0';
    si_D   <= x"FFFFFFFF"; --not super necessary but helps show functionality
    wait for cCLK_PER;


    -- Flush register 2
    reset  <= '0';
    flush0 <= '0';
    flush1 <= '0';
    flush2 <= '1';
    flush3 <= '0';
    stall0 <= '0';
    stall1 <= '0';
    stall2 <= '0';
    stall3 <= '0';
    si_D   <= x"FFFFFFFF"; --not super necessary but helps show functionality
    wait for cCLK_PER;

    -- Flush register 3
    reset  <= '0';
    flush0 <= '0';
    flush1 <= '0';
    flush2 <= '0';
    flush3 <= '1';
    stall0 <= '0';
    stall1 <= '0';
    stall2 <= '0';
    stall3 <= '0';
    si_D   <= x"FFFFFFFF"; --not super necessary but helps show functionality
    wait for cCLK_PER;







    end process;

end mixed;