.include "data.asm"
.include "hw2.asm"

.data
nl: .asciiz "\n"
index_of_car_output: .asciiz  "index_of_car output: "
.text

.globl main
main:
la $a0, index_of_car_output
li $v0, 4
syscall
# la $a0, all_cars
# li $a1, 8
# li $a2, 0
# li $a3, 2017
la $a0, all_cars
li $a1, 6
li $a2, 0
li $a3, 1880
jal index_of_car
move $a0, $v0
li $v0, 1
syscall
la $a0, nl
li $v0, 4
syscall
li $v0, 10
syscall


