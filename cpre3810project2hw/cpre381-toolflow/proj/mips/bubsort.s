.data
array: .word   765, 943, 132, 845, 507, 634, 713, 801, 380, 159, 493, 948, 724, 134, 602, 998, 256, 688, 522, 451, 382, 68, 225, 419, 619, 150, 467, 934, 553, 273, 828, 667, 209, 658, 792, 44, 161, 561, 396, 189, 908, 564, 135, 522, 129, 242, 939, 311, 42, 67, 381, 274, 391, 265, 538, 430, 70, 813, 592, 658, 998, 91, 315, 374, 794, 888, 987, 274, 703, 849, 284, 971, 220, 71, 216, 373, 121, 937, 1000, 820, 262, 234, 426, 453, 359, 141, 744, 239, 915, 825, 13, 376, 270, 221, 889, 275, 99, 79, 100, 859

.text
.globl main

main:
    la $t0, array     # $t0 = base address of array
    li $t1, 100        # $t1 = array length (n)
    subi $t1, $t1, 1  # $t1 = n - 1 (outer loop limit)
    move $t2, $zero   # $t2 = i (outer loop counter)

outer_loop:
    beq $t2, $t1, end_sort # if i == n - 1, end sort
    move $t3, $zero   # $t3 = j (inner loop counter)
    sub $t4, $t1, $t2 # $t4 = n - 1 - i (inner loop limit)

inner_loop:
    beq $t3, $t4, next_outer # if j == n - 1 - i, next outer loop
    sll $t5, $t3, 2    # $t5 = j * 4 (offset)
    add $t5, $t5, $t0  # $t5 = address of array[j]
    lw $t6, 0($t5)     # $t6 = array[j]

    addi $t7, $t3, 1   # $t7 = j + 1
    sll $t8, $t7, 2    # $t8 = (j + 1) * 4 (offset)
    add $t8, $t8, $t0  # $t8 = address of array[j + 1]
    lw $t9, 0($t8)     # $t9 = array[j + 1]

    slt $a0, $t9, $t6 # $a0 = 1 if array[j + 1] < array[j], 0 otherwise
    beq $a0, $zero, next_inner # if array[j+1] >= array[j], no swap

    # Swap array[j] and array[j + 1]
    sw $t9, 0($t5)     # array[j] = array[j + 1]
    sw $t6, 0($t8)     # array[j + 1] = array[j]

next_inner:
    addi $t3, $t3, 1   # j++
    j inner_loop

next_outer:
    addi $t2, $t2, 1   # i++
    j outer_loop

end_sort:
    halt

