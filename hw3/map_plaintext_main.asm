.data
adfgvx_grid: .asciiz "IQSP4TONLZJUGACHXVE73WKY5MB126980FRD"
#plaintext: .asciiz "STONYBROOKUNIV"
plaintext: .asciiz "STORMLIGHT"
middletext_buffer: .asciiz "???????????????????????????????"

.text
.globl main
main:
la $a0, adfgvx_grid
la $a1, plaintext
la $a2, middletext_buffer
jal map_plaintext

la $a0, middletext_buffer
li $v0, 4
syscall

li $a0, '\n'
li $v0, 11
syscall

li $v0, 10
syscall

.include "hw3.asm"
