.include "hw2.asm"

.data
nl: .asciiz "\n"
compute_check_digit_output: .asciiz "compute_check_digit output: "
map: .asciiz "0123456789X"
weights: .asciiz "8765432X098765432"
transliterate_str: .asciiz "0123456789.ABCDEFGH..JKLMN.P.R..STUVWXYZ"
vin_test1: .asciiz "JTDKN3DU0D5614628"
vin_test2: .asciiz "1B4HR28N01F502695"
vin_test3: .asciiz "1HGEM1150YL037618"
vin_test4: .asciiz "1FTDF15N0KNB73611"
vin_test5: .asciiz "1M2P198C0JW002996"

.text
.globl main
main:
la $a0, compute_check_digit_output
li $v0, 4
syscall
la $a0, vin_test5
la $a1, map
la $a2, weights
la $a3, transliterate_str
jal compute_check_digit
move $a0, $v0
li $v0, 11
syscall
la $a0, nl
li $v0, 4
syscall
li $v0, 10
syscall
