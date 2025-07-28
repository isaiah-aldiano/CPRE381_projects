.globl main
# SLL, SRL, SRA, SLLV, SRLV, SRAV
# ADD, ADDI, ADDIU, ADDU, SUB, SUBU, SLT, SLTI, 
# AND, ANDI, NOR, XOR, XORI, OR, ORI
main: 

shifting:
    addi $t0, $zero, 1 
    addi $t1, $zero, 0x80000000 
    addi $t2, $zero, 31 # Shift value
    
    sll $t3, $t0, 31 # expected: 0x8000_0000
    srl $t4, $t1, 31 # expected: 0x1
    sra $t5, $t1, 31 # expected: 0xFFFF_FFFF

    sllv $t0, $t0, $t2 # expected: 0x8000_0000
    srlv $t6, $t1, $t2 # expected: 0x1
    srav $t7, $t1, $t2 # expected: 0xFFFF_FFFF

arithmetic: 
    
    add $t0, $zero, $t4
    addi $t1, $zero, 999
    addiu $t1, $t1, 0xF0000000

    addi $t2, $zero, 2147483647 #setting up addu
    addi $t0, $zero, 1 #setting up addu
    #no overflow
    addu $t3, $t2, $t0 # expected: -2147483648 (0x80000000) 
    
    addi $t6, $zero, 100
    sub $t4, $t4, $t6 # expected: -99 (0xFFFFFF9d) 
    # no overflow 
    subu $t5, $t4, $t2 # expected: 2147483550 (0x7FFFFFF9e)
    
    
    slt $t0, $t4, $t5 # expected: 1
    
    slt $t1, $t4, $t3 # expected: 0
    
    slti $t8, $t6, 0x0065 # expected: 1
    
    slti $t9, $t6, 0x0063 # expected: 0
    
logical:

    addi $t0, $zero, 0xAAAAAAAA
    addi $t1, $zero, 0x55555555
    
    and $t3, $t0, $t1 # expected: 0x00000000
    andi $t4, $t0, 0xAAAA # expected: 0x0000AAAA
    
    nor $t5, $t0, $t0 # expected: 0x55555555
    
    xor $t6, $t0, $t1 # expected: 0xffffffff
    
    xori $t7, $t1, 0xAAAA5555 # expected: 0xffff0000
    
    or $t8, $t0, $t1 # expected: 0xffffffff
    
    ori $t9, $t0, 0x00005555 # expected: 0xAAAAFFFF
    
    halt    
   
    
    
    


   
