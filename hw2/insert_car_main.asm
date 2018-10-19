.include "data.asm"
.include "hw2.asm"

.data
nl: .asciiz "\n"
insert_car_output: .asciiz  "insert_car output: "
test_vin: .asciiz "AAAAABBBBBBBBBBCC"
test_car: .word test_vin
.word make_A
.word model_D
.byte 255, 255
.byte 12, 0

.align 2
expected_all_cars: 
.word vin_00
.word make_A
.word model_A
.byte 110, 7
.byte 8
.byte 0

.word vin_01
.word make_D
.word model_B
.byte 115, 7
.byte 8
.byte 0

.word vin_02
.word make_A
.word model_C
.byte 225, 7
.byte 12
.byte 0

.word test_vin
.word make_A
.word model_D
.byte 255, 255
.byte 12, 0

.word vin_03
.word make_E
.word model_D
.byte 175, 7
.byte 10
.byte 0

.word vin_04
.word make_A
.word model_E
.byte 122, 7
.byte 5
.byte 0

.word vin_05
.word make_C
.word model_F
.byte 150, 7
.byte 10
.byte 0

.text
.globl main

main:
la $a0, insert_car_output
li $v0, 4
syscall
la $a0, all_cars
li $a1, 6
la $a2, test_car
li $a3, 2
jal insert_car
move $a0, $v0
li $v0, 1
syscall
la $a0, nl
li $v0, 4
syscall	
# li $v0, 10
# syscall

# testing the given test case with 6,3 with strcmp
# la $a0, all_cars
# la $a1, expected_all_cars
# jal strcmp
# move $a0, $v0
# li $v0, 1
# syscall

# testing the given test case with 6,3 with strcmp
la $a0, all_cars
la $a1, expected_all_cars
li $a2, 112
jal compare_car_arrays
move $a0, $v0
li $v0, 1
syscall

### test to print the car array ###
la $a0, nl
li $v0, 4
syscall

# la $a0, test_car
# jal print_a_car

# PRINTING ARRAYS 
la $a0, expected_all_cars
li $a1, 7
jal print_car_array

la $a0, nl
li $v0, 4
syscall
la $a0, all_cars
li $a1, 7
jal print_car_array


# maybe have something to see each of the arrays
# pesuedo code
#li $t0, 0 # counter
#la $t3, all_cars
#la $t4, expected_all_cars
#
#la $a0, nl
#li $v0, 4
#syscall	
#
#loop_test1:
#	beq $t0, 112, loop_test2_start
#	lbu $t1, ($t3)
#	move $a0, $t1
#	li $v0, 1
#	syscall
#	addi $t3, $t3, 1
#	addi $t0, $t0, 1	
#	j loop_test1
#	
#loop_test2_start: 
#	la $a0, nl
#	li $v0, 4
#	syscall	
#	li $t0, 0
#	j loop_test2
#
#loop_test2:
#	beq $t0, 112, end_this_loop
#	lbu $t2, ($t4)
#	move $a0, $t2
#	li $v0, 1
#	syscall
#	addi $t4, $t4, 1
#	addi $t0, $t0, 1
#	j loop_test2
#	
#end_this_loop:
#	la $a0, nl
#	li $v0, 4
#	syscall	
#	li $t0, 0
#	la $t3, all_cars
#	la $t4, expected_all_cars
#	
#check_same:	
#	beq $t0, 112, end_check
#	lbu $t1, ($t3)
#	lbu $t2, ($t4)
#	beq $t1, $t2, yes
#	bne $t1, $t2, no
#keep_checking:
#	addi $t3, $t3, 1
#	addi $t4, $t4, 1
#	addi $t0, $t0, 1	
#	j check_same
#yes:
#	li $a0, 'Y'
#	li $v0, 11
#	syscall
#	j keep_checking
#no:
#	li $a0, 'N'
#	li $v0, 11
#	syscall
#	j keep_checking
#
#end_check:

li $v0, 10
syscall
