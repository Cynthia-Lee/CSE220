.include "hw2.asm"

.data
nl: .asciiz "\n"
memcpy_output: .asciiz "memcpy output: "
# src: .asciiz "ABCD"
# dest: .asciiz "**********"
src: .asciiz "ABCDEFGHIJ"
dest: .asciiz "XXXXXXX"

.text
.globl main
main:
la $a0, memcpy_output
li $v0, 4
syscall
la $a0, src
la $a1, dest
# li $a2, 4
li $a2, 6
jal memcpy
move $a0, $v0
li $v0, 1
syscall
li $a0, ' '
li $v0, 11
syscall
la $a0, dest
li $v0, 4
syscall
la $a0, nl
li $v0, 4
syscall
li $v0, 10
syscall
