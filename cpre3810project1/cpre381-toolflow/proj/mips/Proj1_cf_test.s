.globl main
#J, JR, JAL
#BEQ, BNE

	li $sp, 0x7fffeffc
main:
	
	addi $sp, $sp, 0x7fffeffc
	add $t0, $zero, $zero
	addi $t1, $zero, 1
	addi $t2, $zero, 1
	jal branchNE
	
	sw $zero, ($sp)
	beq $t0, $t2, toexit

should_never_happen_1:
	addi $t4, $zero, 0x7FFFFFFF

toexit:
	j exit
	
branchNE: 

	bne $t0, $t1, stack1

stack1:
	#add $sp, $sp, $zero
	addi $sp, $sp, -4
	sw $ra, ($sp)

	jal stack2

	sw $zero, ($sp)
	addi $sp, $sp, 4
	lw $ra, ($sp)
	jr $ra
	
stack2:

	addi $sp, $sp, -4
	sw $ra, ($sp)

	jal stack3

	sw $zero, ($sp)
	addi $sp, $sp, 4
	lw $ra, ($sp)
	jr $ra

stack3:

	addi $sp, $sp, -4
	sw $ra, ($sp)

	jal stack4

	sw $zero, ($sp)
	addi $sp, $sp, 4
	lw $ra, ($sp)
	jr $ra

stack4:
	addi $sp, $sp, -4
	sw $ra, ($sp)

	jal stack5

	sw $zero, ($sp)
	addi $sp, $sp, 4
	lw $ra, ($sp)
	jr $ra

stack5:
	#addi $sp, $sp, -4
	#sw $ra, ($sp)

	add $t2, $zero, $zero

	sw $zero, ($sp)
	addi $sp, $sp, 4
	jr $ra

should_never_happen_2:
	addi $t5, $zero, 0x7FFFFFFF

exit:
	addi $t3, $zero, 0xFFFFFFFF
	halt
