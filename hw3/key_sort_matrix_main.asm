.data

#matrix1: .asciiz "DDAXAVFFADXVDVGDVGGXAAGGXAVVGXGDAVDFAVGDDVFGAVFXAVADDDAX"
#key1: .asciiz "KNIGHTS"

matrix1: .asciiz "ABCDEFGHIJKLMNOPQR"
key1: .asciiz "WOLFIE"
matrix2: .asciiz "ABCDEFGHIJKLMNOPQRST"
key2: .word 500, 20, 100, 40, 300

.text
.globl main
main:
la $a0, matrix1
li $a1, 3 #3
li $a2, 6 #6
la $a3, key1
addi $sp, $sp, -4
li $t0, 1
sw $t0, 0($sp)
jal key_sort_matrix
addi $sp, $sp, 4

la $a0, matrix1
li $v0, 4
syscall
li $a0, '\n'
li $v0, 11
syscall

la $a0, matrix2
li $a1, 4
li $a2, 5
la $a3, key2
addi $sp, $sp, -4
li $t0, 4
sw $t0, 0($sp)
jal key_sort_matrix
addi $sp, $sp, 4

la $a0, matrix2
li $v0, 4
syscall
li $a0, '\n'
li $v0, 11
syscall

li $v0, 10
syscall

.include "hw3.asm"
