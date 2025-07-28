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

    li $t1, 396 # array size - 1 in bits
    li $t2, 0 # i
    li $t4, 0 # int temp_value 
    la $s0, some_array # reference start of array
    sub $t7, $t1, $t2 # store somearray size - i - 1
    add $t7, $s0, $t7 # end of somearray address 
    

outer_loop:
    
    li $t6, 0 # boolean swapped set to 0
    la $s0, some_array # reference start of array

    jal inner_loop
    addi $t2, $t2, 4 # increment i

    beq $t6, $zero, exit # if no swap then break loop

    j outer_loop

inner_loop:
    
    addi $t0, $s0, 4 # address of j + 1
    lw $t5, 0($t0) # some_array[j + 1] value
    lw $t3, 0($s0) # some_array[j] value
    slt $t8, $t5, $t3 # $t8 = $t5 < $t3 ====> $t8 = some_array[j+1] < some_array[j]
    bne $t8, $zero, swap_indicies # if 1 swap values

return_to_inner_loop:
    
    addi $s0, $s0, 4 # increment j
    slt $t8, $s0, $t7 # $t8 = J < somearray size - i - 1
    bne $t8, $zero, inner_loop 

    jr $ra
    

swap_indicies:

    sw $t5, 0($s0) # some_array[j] = some_array[j + 1]
    sw $t3, 0($t0) # some_array[j + 1] = some_array[j]
    addi $t6, $t6, 1 # swapped = true

    j return_to_inner_loop

exit:
   halt
