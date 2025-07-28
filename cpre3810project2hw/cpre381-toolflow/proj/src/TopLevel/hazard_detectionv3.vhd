-------------------------------------------------------------------------
-- Sam Burns
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- hazard_detection.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a behavioral implementation of a hazard
-- detection unit for a pipelined MIPS processor with data forwarding.
--              
-- created 19:00 on 1/30/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.MIPS_types.all;


-------------------------------------------------------------------------
-- TODO: THIS IS A NAIVE IMPLEMENTATION OF A HAZARD DETECTION UNIT. 
-- NEEDS TO BE REFINED FOR A FULLY FUNCTIONAL PIPELINED MIPS PROCESSOR.
-- TALK TO TA ABOUT HOW THIS NEEDS TO WORK IN SPECIFIC CASES
-------------------------------------------------------------------------

entity hazard_detection3 is 
    port(
        i_INSTR_IF : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_INSTR_ID : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_INSTR_EX : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_INSTR_MEM : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_INSTR_WB : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_BRNACH_TAKEN : in std_logic;

        i_EX_WE : in std_logic;
        i_MEM_WE : in std_logic;
        i_EX_memread : in std_logic;

        o_FLUSH_ID : out std_logic;
        o_FLUSH_IF: out std_logic;
        o_STALL_IF : out std_logic;
        o_STALL_ID :  out std_logic;
        o_PC_WE : out std_logic
    );
end hazard_detection3;

architecture behavioral of hazard_detection3 is

    -- signal s_ID_RS : std_logic_vector(4 downto 0);
    -- signal s_ID_RT : std_logic_vector(4 downto 0);
    -- signal s_ID_instr

    -- signal s_EX_RD : std_logic_vector(4 downto 0);
    -- signal s_EX_we : std_logic;
    -- signal s_EX_memread : std_logic;
    -- signal s_EX_instr

    -- signal s_MEM_rd : std_logic_vector(4 downto 0);
    -- signal s_MEM_we : std_logic;

    signal id_rs_eq_ex_rdrt: std_logic;
    signal id_rs_eq_mem_rdrt : std_logic;
    signal id_rt_eq_ex_rdrt : std_logic;
    signal id_rt_eq_mem_rdrt : std_logic;

    signal ex_memread : std_logic;

    signal load_use : std_logic;

    signal is_load_ex : std_logic;
    signal is_load_mem : std_logic;

    
begin

    o_FLUSH_IF <= '1' when (i_BRNACH_TAKEN = '1') else
                  '1' when (i_INSTR_EX(31 downto 26) = b"000010") else -- Flush for JUMP
                  '1' when (i_INSTR_EX(31 downto 26) = b"000011") else -- Flush for JAL
                  '1' when (i_INSTR_EX(31 downto 26) = b"000000") and (i_INSTR_EX(5 downto 0) = b"001000") else -- Flush for JUMP REG
                  '0';

    o_FLUSH_ID <= '1' when (i_BRNACH_TAKEN = '1') else
                  '1' when (i_INSTR_EX(31 downto 26) = b"000010") else -- Flush for JUMP
                  '1' when (i_INSTR_EX(31 downto 26) = b"000011") else -- Flush for JAL
                  '1' when (i_INSTR_EX(31 downto 26) = b"000000") and (i_INSTR_EX(5 downto 0) = b"001000") else -- Flush for JUMP REG
                  '0';

    is_load_ex <= '1' when (i_INSTR_EX(31 downto 26) = "100011" or i_INSTR_EX(31 downto 26) = "100000" or i_INSTR_EX(31 downto 26) = "100001" or i_INSTR_EX(31 downto 26) = "100100" or i_INSTR_EX(31 downto 26) = "100101") else '0';
    is_load_mem <= '1' when (i_INSTR_MEM(31 downto 26) = "100011" or i_INSTR_MEM(31 downto 26) = "100000" or i_INSTR_MEM(31 downto 26) = "100001" or i_INSTR_MEM(31 downto 26) = "100100" or i_INSTR_MEM(31 downto 26) = "100101") else '0';


    
    id_rs_eq_ex_rdrt <= '1' when (i_INSTR_ID(25 downto 21) /= "00000") and (i_INSTR_EX(15 downto 11) /= "00000" or (is_load_ex = '1') or (i_INSTR_EX(31 downto 26) /= "000000")) -- If ID RS != 0 and (ID EX RD != 0 or is_load or EX != R Type)
    and (i_INSTR_EX(15 downto 11) = i_INSTR_ID(25 downto 21) or i_INSTR_EX(20 downto 16) = i_INSTR_ID(25 downto 21)) else '0'; -- and (EX RD = ID RS or EX RT = EX RD)

    id_rs_eq_mem_rdrt <= '1' when (i_INSTR_ID(25 downto 21) /= "00000") and (i_INSTR_MEM(15 downto 11) /= "00000" or (is_load_mem = '1') or (i_INSTR_MEM(31 downto 26) /= "000000")) 
    and (i_INSTR_MEM(15 downto 11) = i_INSTR_ID(25 downto 21) or i_INSTR_MEM(20 downto 16) = i_INSTR_ID(25 downto 21)) else '0';


    id_rt_eq_ex_rdrt <= '1' when (i_INSTR_ID(20 downto 16) /= "00000") and (i_INSTR_EX(15 downto 11) /= "00000" or (is_load_ex = '1') or (i_INSTR_EX(31 downto 26) /= "000000")) 
    and (i_INSTR_EX(15 downto 11) = i_INSTR_ID(20 downto 16) or (i_INSTR_EX(20 downto 16) = i_INSTR_ID(20 downto 16))) else '0';

    id_rt_eq_mem_rdrt <= '1' when (i_INSTR_ID(20 downto 16) /= "00000") and (i_INSTR_MEM(15 downto 11) /= "00000" or (is_load_mem = '1') or (i_INSTR_MEM(31 downto 26) /= "000000")) 
    and (i_INSTR_MEM(15 downto 11) = i_INSTR_ID(20 downto 16) or (i_INSTR_MEM(20 downto 16) = i_INSTR_ID(20 downto 16))) else '0';

    

    -- STALLP : process(i_EX_memread, rt_eq_mem_rd, rt_eq_ex_rd, rs_eq_mem_rd, rs_eq_ex_rd)
    -- begin 

    
    load_use <= '1' when ((i_EX_memread = '1') and ((id_rs_eq_ex_rdrt = '1') or (id_rs_eq_mem_rdrt = '1') or id_rt_eq_ex_rdrt = '1' or id_rt_eq_mem_rdrt = '1')) else '0';
    
    o_STALL_IF <= '1' when ((load_use = '1') or 
                ((id_rs_eq_ex_rdrt = '1' or id_rt_eq_ex_rdrt = '1')) or --i_EX_WE = '1' and 
                ((id_rs_eq_mem_rdrt = '1' or id_rt_eq_mem_rdrt = '1'))) and (o_FLUSH_ID /= '1') else '0'; --i_MEM_WE = '1' and 

    o_STALL_ID <= o_STALL_IF;

    o_PC_WE <= not (o_STALL_IF);


        
    -- end process;
end behavioral;