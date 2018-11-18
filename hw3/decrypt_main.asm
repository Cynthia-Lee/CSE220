.data
adfgvx_grid: .asciiz "NA1CEH8TB2OM35WRPD4F6G7I9J0KLQSUVXYZ"
ciphertext: .asciiz "XDDDAAXAV*AXDFXDXFVFDDGFXGVVG*VDDF*"
keyword: .asciiz "KNIGHTS"
plaintext: .ascii "?????????????????"  # result is 16 chars + null-terminator
.asciiz "!!!!!!"

.text
.globl main
main:
la $a0, adfgvx_grid
la $a1, ciphertext
la $a2, keyword
la $a3, plaintext
jal decrypt

la $a0, plaintext
li $v0, 4
syscall
li $a0, '\n'
li $v0, 11
syscall

li $v0, 10
syscall

.include "hw3.asm"
