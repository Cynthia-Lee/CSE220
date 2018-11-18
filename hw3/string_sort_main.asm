.data
# str: .asciiz "STONYBROOKUNIVERSITY"
str: .asciiz "KNIGHTS"

.text
.globl main
main:
la $a0, str
jal string_sort

la $a0, str
li $v0, 4
syscall

li $a0, '\n'
li $v0, 11
syscall

li $v0, 10
syscall

.include "hw3.asm"
