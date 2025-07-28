-- Isaiah Aldiano
-------------------------------------------------------------------------
-- forwarding_unit.vhd 
-------------------------------------------------------------------------
-- DESCRIPTION: Contains logic for data forwarding unit
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.MIPS_types.all;


entity forwarding_unit is 
    generic(
        EXMEM_CTRL : integer := 9;
        MEMWB_CTRL : integer := 8;
        OPCODE : integer := 6;
        FUNCT : integer := 6;
        REG : integer := 5
    );
	port(
        i_INSTR_IF : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_INSTR_ID : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_INSTR_EX : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_INSTR_MEM : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_INSTR_WB : in std_logic_vector(DATA_WIDTH-1 downto 0);

        -- Taking the so_ at the beginning of stage
        i_EXMEM_CTRL : in std_logic_vector(EXMEM_CTRL-1 downto 0);
        -- bits 0-5 correspond to Halt, LoadW, Load HU, Load H, Load B, and JumpAL 
        -- bits 6 & 7 & 8 correspond to RegWr and DmemWR and MemtoReg respectively
        i_MEMWB_CTRL : in std_logic_vector(MEMWB_CTRL-1 downto 0);
        -- bits 0-5 correspond to Halt, LoadW, Load HU, Load H, Load B, and JumpAL
        -- bits 6 and 7 corresponds RegWr to MemtoReg

        o_ALUSEL_A : out std_logic_vector(1 downto 0);
        o_ALUSEL_B : out std_logic_vector(1 downto 0);
        o_DMEM_DATA : out std_logic_vector(1 downto 0);
        o_SHAMT : out std_logic_vector(1 downto 0);
        o_JR_SEL : out std_logic
    );
end forwarding_unit;


architecture behavioral of forwarding_unit is

    signal s_IF_opcode : std_logic_vector(OPCODE -1 downto 0);
    signal s_ID_opcode : std_logic_vector(OPCODE -1 downto 0);
    signal s_EX_opcode : std_logic_vector(OPCODE -1 downto 0);
    signal s_MEM_opcode : std_logic_vector(OPCODE -1 downto 0);
    signal s_WB_opcode : std_logic_vector(OPCODE -1 downto 0);

    signal s_IF_funct : std_logic_vector(FUNCT -1 downto 0);
    signal s_ID_funct : std_logic_vector(FUNCT -1 downto 0);
    signal s_EX_funct : std_logic_vector(FUNCT -1 downto 0);
    signal s_MEM_funct : std_logic_vector(FUNCT -1 downto 0);
    signal s_WB_funct : std_logic_vector(FUNCT -1 downto 0);

    signal s_IF_RS : std_logic_vector(REG-1 downto 0);
    signal s_IF_RT : std_logic_vector(REG-1 downto 0);
    signal s_IF_RD : std_logic_vector(REG-1 downto 0);

    signal s_ID_RS : std_logic_vector(REG-1 downto 0);
    signal s_ID_RT : std_logic_vector(REG-1 downto 0);
    signal s_ID_RD : std_logic_vector(REG-1 downto 0);

    signal s_EX_RS : std_logic_vector(REG-1 downto 0);
    signal s_EX_RT : std_logic_vector(REG-1 downto 0);
    signal s_EX_RD : std_logic_vector(REG-1 downto 0);

    signal s_MEM_RS : std_logic_vector(REG-1 downto 0);
    signal s_MEM_RT : std_logic_vector(REG-1 downto 0);
    signal s_MEM_RD : std_logic_vector(REG-1 downto 0);

    signal s_WB_RS : std_logic_vector(REG-1 downto 0);
    signal s_WB_RT : std_logic_vector(REG-1 downto 0);
    signal s_WB_RD : std_logic_vector(REG-1 downto 0);

    signal s_MEM_REG_WRITE : std_logic;
    signal s_WB_REG_WRITE : std_logic;
begin
    
		s_MEM_REG_WRITE <= i_EXMEM_CTRL(6);
        s_WB_REG_WRITE <= i_MEMWB_CTRL(6);

        s_IF_opcode <= i_INSTR_IF(31 downto 26);
        s_ID_opcode <= i_INSTR_ID(31 downto 26);
        s_EX_opcode <= i_INSTR_EX(31 downto 26);
        s_WB_opcode <= i_INSTR_WB(31 downto 26);
        s_MEM_opcode <= i_INSTR_MEM(31 downto 26);

        s_IF_funct <= i_INSTR_IF(5 downto 0);
        s_ID_funct <= i_INSTR_ID(5 downto 0);
        s_EX_funct <= i_INSTR_EX(5 downto 0);
        s_MEM_funct <= i_INSTR_MEM(5 downto 0);
        s_WB_funct <= i_INSTR_WB(5 downto 0);
        

        s_IF_RS <= i_INSTR_IF(25 downto 21);
        s_IF_RT <= i_INSTR_IF(20 downto 16);
        s_IF_RD <= i_INSTR_IF(15 downto 11);

        s_ID_RS <= i_INSTR_ID(25 downto 21);
        s_ID_RT <= i_INSTR_ID(20 downto 16);
        s_ID_RD <= i_INSTR_ID(15 downto 11);

        s_EX_RS <= i_INSTR_EX(25 downto 21);
        s_EX_RT <= i_INSTR_EX(20 downto 16);
        s_EX_RD <= i_INSTR_EX(15 downto 11);

        s_MEM_RS <= i_INSTR_MEM(25 downto 21);
        s_MEM_RT <= i_INSTR_MEM(20 downto 16);
		s_MEM_RD <= i_INSTR_MEM(15 downto 11);

        s_WB_RS <= i_INSTR_WB(25 downto 21);
        s_WB_RT <= i_INSTR_WB(20 downto 16);
		s_WB_RD <= i_INSTR_WB(15 downto 11);
	
        process(o_ALUSEL_B, s_MEM_REG_WRITE,s_WB_REG_WRITE,s_EX_opcode,s_IF_opcode,s_WB_opcode,s_MEM_opcode,s_ID_opcode,s_IF_funct,s_ID_funct,s_EX_funct,s_MEM_funct,s_WB_funct,s_EX_RS,s_EX_RT,s_EX_RD,s_MEM_RS,s_MEM_RT,s_WB_RS,s_WB_RT, s_MEM_RD, s_WB_RD, s_ID_RS, s_ID_RT, s_ID_RD, s_IF_RS, s_IF_RT, s_IF_RD)
        begin
            o_ALUSEL_A <= "00";
            o_ALUSEL_B <= "00";
            o_SHAMT <= "00";
            o_DMEM_DATA <= "00";
            o_JR_SEL <= '0';
    
            if (s_MEM_REG_WRITE ='1') and (s_MEM_RT /= "00000") and (s_MEM_RT = s_EX_RS) and (s_EX_funct = "001000") then
                o_JR_SEL <= '1';
            end if;
        
            if (s_MEM_REG_WRITE = '1') and (s_MEM_RT = s_EX_RS) and (s_EX_funct = "000100" or s_EX_funct = "000110" or s_EX_funct = "000111") then -- SHIFT VARIABLE depends on MEM IMMEDIATE
                o_SHAMT <= "10";
            end if;
            
            if (s_WB_REG_WRITE = '1') and (s_WB_RD = s_EX_RT or s_WB_RT = s_EX_RT) and (s_EX_opcode = "101011") then
                o_DMEM_DATA <= "01";
            elsif (s_MEM_REG_WRITE = '1') and (s_MEM_RD = s_EX_RT or (s_MEM_RT = s_EX_RT)) and (s_EX_opcode = "101011") then   
                o_DMEM_DATA <= "10";
            end if;
    
            if (s_WB_REG_WRITE = '1') and (s_WB_RD /= "00000") and not ((s_MEM_REG_WRITE = '1') and (s_MEM_RD /= "00000") and (s_MEM_RD = s_EX_RS)) and (s_WB_RD = s_EX_RS)  then 
                o_ALUSEL_A <= "01";
            elsif (s_WB_REG_WRITE = '1') and (s_WB_RT /= "00000") and not ((s_MEM_REG_WRITE = '1') and (s_MEM_RT /= "00000") and (s_MEM_RT = s_EX_RS)) and (s_WB_RT = s_EX_RS) then
                o_ALUSEL_A <= "01";
            end if;

            if(s_MEM_REG_WRITE = '1') and (s_MEM_RT /= "00000") and (s_MEM_RT = s_EX_RS) and (s_MEM_funct /= "00000" and s_EX_funct /= "100100")then
                o_ALUSEL_A <= "10";
            elsif (s_MEM_REG_WRITE = '1') and (s_MEM_RD /= "00000") and (s_MEM_RD = s_EX_RS) and (s_WB_opcode /= "001111") and (s_MEM_funct /= "000000" and s_EX_funct /= "100100") then
                o_ALUSEL_A <= "10";
            elsif (s_MEM_REG_WRITE = '1') and (s_MEM_RD /= "00000") and (s_MEM_RD = s_EX_RS) and (s_MEM_funct = "000000" or s_MEM_funct = "000010" or s_MEM_funct = "000011" or s_MEM_funct = "000100" or s_MEM_funct = "000110" or s_MEM_funct = "000111") then 
                o_ALUSEL_A <= "10"; -- mem SHIFT RD = RS in EX                                                                                                         -- and
            elsif(s_MEM_REG_WRITE = '1') and (s_MEM_RD = s_EX_RS) and (s_MEM_opcode = s_EX_opcode) and (s_MEM_funct = s_EX_funct) and (s_MEM_funct = "100000" or s_MEM_funct = "100100") then -- Consecutive ands/adds where MEM RD = EX RS 
                o_ALUSEL_A <= "10";
            elsif (s_MEM_REG_WRITE = '1') and (s_MEM_RT /= "00000") and (s_MEM_RD = s_EX_RS) and (s_WB_RT = s_EX_RS) and (s_WB_opcode = "001111")then
                o_ALUSEL_A <= "10";
            end if;
            
                                                                                                                                                                                    -- sw                       -- lw                           -- lui 
            if (s_WB_REG_WRITE = '1') and (s_WB_RD /= "00000") and not ((s_MEM_REG_WRITE = '1') and (s_MEM_RD /= "00000") and (s_MEM_RD = s_EX_RT)) and (s_WB_RD = s_EX_RT) and (s_EX_opcode /= "101011") and (s_EX_opcode /= "100011") and (s_EX_opcode /= "001111") and (s_WB_opcode /= "001000")then 
                o_ALUSEL_B <= "01";                                                                     -- lui                      -- sw
            elsif (s_WB_REG_WRITE = '1') and (s_MEM_REG_WRITE = '0')  and (s_WB_RT = s_EX_RT) and  (s_EX_opcode /= "001111") and (s_EX_opcode /= "101011") then 
                o_ALUSEL_B <= "01";                                             -- beq  
            elsif (s_WB_REG_WRITE = '1') and (s_MEM_REG_WRITE = '1') and (s_EX_opcode = "000100")  and (s_WB_RT = s_EX_RT) then 
                o_ALUSEL_B <= "01";                                         -- Shifting funct                                                                                                                                     -- shifting op                -- ...
            elsif (s_WB_REG_WRITE = '1') and (s_WB_RT = s_EX_RT) and (((s_EX_funct = "000000" or s_EX_funct = "000010" or s_EX_funct = "000011" or s_EX_funct = "000100" or s_EX_funct = "000110" or s_EX_funct = "000111") and (s_EX_opcode = "000000")) or (s_EX_funct = "100001"))then
                o_ALUSEL_B <= "01"; -- Shifting in EX
            elsif (s_WB_REG_WRITE = '1') and (s_WB_RT = s_EX_RT) and (s_MEM_RT = s_EX_RT) and (s_EX_funct = "101010") and (s_WB_funct /= s_MEM_funct) then 
                o_ALUSEL_B <= "01"; 
            end if;
            
            if (s_MEM_REG_WRITE = '1') and (s_MEM_RT /= "00000") and (s_MEM_RT = s_EX_RT) and (s_MEM_RT /= s_EX_RS) and (s_EX_opcode /= "001111") and (s_EX_opcode /= "101011") and (s_EX_opcode /= "001101") and (s_WB_funct /= "000010")  then --and (s_WB_RT /= s_EX_RT and s_EX_opcode /= "101010") 
                o_ALUSEL_B <= "10";
            elsif (s_MEM_REG_WRITE = '1') and (s_MEM_RD /= "00000") and (s_MEM_RD = s_EX_RT) and (s_WB_opcode /= "001111" and s_WB_opcode /= "001000") and (s_EX_opcode /= "001001" and s_EX_opcode /= "101011" and s_EX_opcode /= "001111") then
                o_ALUSEL_B <= "10";
            elsif (s_MEM_REG_WRITE = '1') and (s_MEM_RD /= "00000") and (s_MEM_RD = s_EX_RT or s_MEM_RT = s_EX_RS) and (s_EX_funct = "000000" or s_EX_funct = "000010" or s_EX_funct = "000011") and (s_EX_opcode = "000000")then
                o_ALUSEL_B <= "10"; -- Shifting in EX needs RD or RT from MEM
            
            end if;

            
        

            
            

        
        end process;
    

    

end behavioral; 