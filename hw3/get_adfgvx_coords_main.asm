.text
.globl main
main:
li $a0, 1 #4
li $a1, 0 #5
jal get_adfgvx_coords

beq $v0, -1, print_num
beq $v1, -1, print_num

move $a0, $v0
li $v0, 11
syscall
li $a0, ' '
syscall
move $a0, $v1
syscall
li $a0, '\n'
syscall

li $v0, 10
syscall

print_num:
move $a0, $v0
li $v0, 1
syscall
li $a0, ' '
li $v0, 11
syscall
move $a0, $v1
li $v0, 1
syscall
li $v0, 10
syscall

.include "hw3.asm"
