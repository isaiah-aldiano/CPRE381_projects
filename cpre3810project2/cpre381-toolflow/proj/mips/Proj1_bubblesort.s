#Bubble sort = pointless
# O(n^2) the hell
#-------------------------------------------------------------------------
#-- Isaiah Aldiano
#-------------------------------------------------------------------------
#-- bubblesort.s 
#-------------------------------------------------------------------------
#-- DESCRIPTION: MIPS asm file for bubble sort algorithm 
#-------------------------------------------------------------------------

.data
some_array: .word   765, 943, 132, 845, 507, 634, 713, 801, 380, 159, 493, 948, 724, 134, 602, 998, 256, 688, 522, 451, 382, 68, 225, 419, 619, 150, 467, 934, 553, 273, 828, 667, 209, 658, 792, 44, 161, 561, 396, 189, 908, 564, 135, 522, 129, 242, 939, 311, 42, 67, 381, 274, 391, 265, 538, 430, 70, 813, 592, 658, 998, 91, 315, 374, 794, 888, 987, 274, 703, 849, 284, 971, 220, 71, 216, 373, 121, 937, 1000, 820, 262, 234, 426, 453, 359, 141, 744, 239, 915, 825, 13, 376, 270, 221, 889, 275, 99, 79, 100, 859

# some_array: .word   4, 3, 2, 1, 0

.text

            .globl  main
main:

    addiu $s1, $zero, 396 # array size - 1 in bits
    lui $s0, 0x1001  # reference start of array
    nop
    nop
    nop

    add $t7, $s0, $s1 # end of somearray address 
    

outer_loop:
    # add $s0, $zero, $zero  # reference start of array
    # nop
    # nop
    # nop
    # lui $s0, 0x1001  # reference start of array
    
    li $t6, 0 # boolean SWAPPED set to 0
    nop
    nop
    nop

    jal inner_loop

    nop
    nop
    nop

    beq $t6, $zero, exit # if no swap then break loop

    nop
    nop
    nop

    add $s0, $zero, $zero  # reference start of array
    nop
    nop
    nop
    lui $s0, 0x1001  # reference start of array

    j outer_loop

inner_loop:

    nop
    nop
    nop
    nop
    add $t8, $zero, $zero
    addi $t0, $s0, 4 # address of j + 1

    nop
    nop
    
    lw $t3, 0($s0) # some_array[j] value
    lw $t5, 0($t0) # some_array[j + 1] value

    nop
    nop
    nop

    slt $t8, $t5, $t3 # $t8 = $t5 < $t3 ====> $t8 = some_array[j+1] < some_array[j]

    nop
    nop
    nop

    beq $t8, $zero, inner_loop1 # if 1 swap values instead 

    nop
    nop
    nop

    # Swapping
    sw $t5, 0($s0) # some_array[j] = some_array[j + 1]
    sw $t3, 0($t0) # some_array[j + 1] = some_array[j]
    addi $t6, $t6, 1 # SWAPPED = true

inner_loop1:
    
    nop
    nop
    nop
    
    addi $s0, $s0, 4 # increment j
    
    nop
    nop
    nop

    slt $t8, $s0, $t7 # $t8 = J < somearray size - i - 1

    nop
    nop
    nop

    bne $t8, $zero, inner_loop 

    nop
    nop
    nop
    nop

    jr $ra
    
exit:
   nop
   nop
   nop
   nop
   halt
