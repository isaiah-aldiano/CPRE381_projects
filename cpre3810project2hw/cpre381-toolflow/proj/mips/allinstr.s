# add, addi, addiu, addu, and, andi, nor, xor, xori, or,
# ori slt, slti, sll, srl, sra, sw,  subu,  beq, bne, sllv, srlv, lb, lh, lbu, lhu, lui, lw, sub,

#  j, jal,
# jr,

lui $sp, 0x7fff
nop
nop
nop
ori $sp, 0xeffc

main:

    addi $t0, $zero, 1
    addi $t1, $zero, 2
    addi $t2, $zero, 3
    addiu $t3, $zero, 0xFFFFFF00
    addiu $t4, $zero, 0xFFFFFFFF
    
    add $t5, $t0, $t1 # = 3
    addu $t6, $t2, $t1 # = 5
    nop
    nop
    and $t7, $t3, $t4 #= 0xFFFFFF00
    andi $t8, $t4, 0x000000FF # = 0x000000FF
    addi $sp, $sp, -4
    
    nop
    nop
    nop
    nor $t5, $t3, $t7 # = 0x000000FF

    xor $t6, $t7, $t8 # = 0x000000FD

    xori $t7, $t3, 0x000000FF # = 0xFFFFFFFF

    or $t8, $t8, $t4 # = 0xFFFFFFFF

    ori $t5, $t5, 0xFFFF 

    nop
    nop
    nop

    lui $t6, 0xFFFF # = 0xFFFF00FD
    sw $t4, 0($sp)

    nop
    nop
    
    slt $t6, $t6, $t7 # = 1
    slti $t7, $t7, 0x1 # = 1
	
    nop
    nop
    nop
    
    sll $t0, $t0, 1 # = 2
    srl $t1, $t1, 2 # = 1

    nop
    nop
    nop 

    sra $t7, $t3, 4 # = 0xFFFFFFF0

    #sw $t3, 0($t3) # at addr 0xFF should be 0xFFFFFF00

    subu $t4, $t0, $t1 # $t4 should be 0xFFFFFFFF with no overflow generated 

    beq $t0, $t1, DEEZ

    nop

DEEZ:

    bne $t0, $t1, NUTS

    nop

NUTS:
 #need to do all jump instrs still and also srav
    
    lb $s0, 0($sp)
    lbu $s1, 0($sp)
    lh $s2, 0($sp)
    lhu $s3, 0($sp)
    lw $s7, 0($sp)

    sllv $s4, $t0, $t1 #= 4
    srlv $s5, $t0, $t1 #= 1
    srav $s6, $t0, $t1 
    
    jal whistling


stop:
    nop
    nop
    nop
    j exit

whistling:
    sub $s0, $s1, $s4
        nop
        nop
    jr $ra


exit:
    halt
