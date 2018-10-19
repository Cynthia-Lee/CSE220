# Cynthia Lee
# cyllee
# 111737790

.data
# Command-line arguments
num_args: .word 0
addr_arg0: .word 0
addr_arg1: .word 0
addr_arg2: .word 0
addr_arg3: .word 0
no_args: .asciiz "You must provide at least one command-line argument.\n"

# Error messages
invalid_operation_error: .asciiz "INVALID_OPERATION\n"
invalid_args_error: .asciiz "INVALID_ARGS\n"

# Output strings
zero_str: .asciiz "Zero\n"
neg_infinity_str: .asciiz "-Inf\n"
pos_infinity_str: .asciiz "+Inf\n"
NaN_str: .asciiz "NaN\n"
floating_point_str: .asciiz "_2*2^"

# Miscellaneous strings
nl: .asciiz "\n"

# Put your additional .data declarations here, if any.
neg_float_sign: .asciiz "-1."
pos_float_sign: .asciiz "1."
b_str: .space 32

# Main program starts here
.text
.globl main
main:
    # Do not modify any of the code before the label named "start_coding_here"
    # Begin: save command-line arguments to main memory
    sw $a0, num_args
    beq $a0, 0, zero_args
    beq $a0, 1, one_arg
    beq $a0, 2, two_args
    beq $a0, 3, three_args
four_args:
    lw $t0, 12($a1)
    sw $t0, addr_arg3
three_args:
    lw $t0, 8($a1)
    sw $t0, addr_arg2
two_args:
    lw $t0, 4($a1)
    sw $t0, addr_arg1
one_arg:
    lw $t0, 0($a1)
    sw $t0, addr_arg0
    j start_coding_here
zero_args:
    la $a0, no_args
    li $v0, 4
    syscall
    j exit
    # End: save command-line arguments to main memory
    
start_coding_here:
    # Start the assignment by writing your code here
    li $t0, 0 # $t0 = the starting address of input 
    li $t1, 0
    li $s2, 2 # setting a number to 2 for binary conversion
    # $a0 = number of arguments passed to program
    # $a1 = the starting address of an array of strings 

    # first argument, string of length 1 (from one_arg: j)
    lw $t0, addr_arg0 # load word into $t0
    lbu $t1, 0($t0) # $t1 has contents from address

    # if argument is a letter, must be uppercase
    beq $t1, 'F', F_first # must be : F, C or 2
    beq $t1, 'C', C_first
    beq $t1, '2', Two_first
    la $a0, invalid_operation_error #if not then print invalid_operation_error and exit the program (system call 10)
    li $v0, 4
    syscall
    j exit
    
# FLOATING POINT, PART 3
F_first: 
    beq $a0, 2, floating_point # need to have 2 arg in total
    la $a0, invalid_args_error
    li $v0, 4
    syscall
    j exit
floating_point:
    li $s1, 0 # 00000000000000000000000000000000 the entire binary number
    li $s0, 0 # length of arg 
    li $s7, 8 # max length of arg
    li $t3, 0 # char we are looking at
    lw $t2, addr_arg1     
while1: # need to read each char
    lbu $t3, ($t2)
    beqz $t3, conv_floating_point # if string char hits a null, stops reading chars 
    blt $t3, '0', iae_end
    bgt $t3, 'F', iae_end
    ble $t3, '9', hex_num
    bge $t3, 'A', hex_letter
    j iae_end
    
hex_bin_conv: 
    # STORE THE VALUE INTO A REGISTER WHICH WILL HAVE IT IN BINARY FORM (at $t3), COMBINING THEM TO 1 REGISTER
    sll $s1, $s1, 4 # shift 4
    add $s1, $s1, $t3 # store the value
    addi $s0, $s0, 1 # increase length of arg
    addi $t2, $t2, 1 # go to next char
    j while1
    
hex_num: 
    addi $t3, $t3, -48 # change string char into number
    j hex_bin_conv    
hex_letter: # A is 65, so subtract 55
    addi $t3, $t3, -55 # change string char into number
    j hex_bin_conv

conv_floating_point:
    li $t6, 0 # temp that will hold number to compare with Zero and +/- Inf
    # s1 holds the binary number from the argument
    bne $s0, 8, iae_end
    li $t6, 2147483648 # arg is 80000000, which is equal to 0
    beqz $s1, print_zero # print out Zero
    beq $s1, $t6, print_zero # print out Zero
    li $t6, 4286578688 # -Inf
    beq $s1, $t6, print_negInf
    li $t6, 2139095040
    beq $s1, $t6, print_posInf
    li $t6, 2139095041 # Nan range a
    li $t7, 2147483647 #Nan range b
    li $t4, 4286578689 # Nan range x
    li $t5, 4294967295 # Nan range y
    bltu $s1, $t6, ok_range
    bleu $s1, $t7, print_nan
    bgtu $s1, $t5, ok_range
    bgeu $s1, $t4, print_nan
    bgtu $s1, $t7, ok_range
 
ok_range:    
    li $s3, 0 # the 1st bit
    li $s4, 0 # the next 8 bits
    li $s5, 0 # the last 23 bits
    
    li $t7, 0 # s4 has number, so have to print each digit individually
    li $t8, 0 # counter for reading in the 23 digits for the fraction
    li $t4, 0x00400000 # getting first digit on the mantissa @9
    li $t5, 22 # shift for the specific digit on the mantissa 
    
    # mask to get the first bit is 0x80000000
    andi $s3, $s1, 0x80000000
    srl $s3, $s3, 31
    # mask to get the 8 bits is 0x7F800000
    andi $s4, $s1, 0x7F800000
    srl $s4, $s4, 23
    # mask to get the last 23 bits is 0x007FFFFF
    andi $s5, $s1, 0x007FFFFF
    beq $s3, 1, neg_fp
    beq $s3, 0, pos_fp		
    
neg_fp: # print -1.
    la $a0, neg_float_sign
    li $v0, 4
    syscall
    j print_fraction_fp
    
pos_fp: # print 1.
    la $a0, pos_float_sign
    li $v0, 4
    syscall
    j print_fraction_fp
    
print_fraction_fp: # will use bit wise and to print each digit individually
    bgt $t8, 22, print_exp

    and $t7, $s5, $t4 # mask to get bit on the 23
    
    addi $t8, $t8, 1 # increase 23 bit counter
    # shift the value of $t7 to turn it into a number Ex. 1000... (rn) to 0000...1
    srlv $t7, $t7, $t5
    move $a0, $t7 # print out this digit
    li $v0, 1
    syscall
    srl $t4, $t4, 1 # change the mask to look at the next digit
    addi $t5, $t5, -1
    j print_fraction_fp
    
print_exp:
    la $a0, floating_point_str
    li $v0, 4
    syscall
    # exponent binary is in s4
    addi $s4, $s4, -127
    move $a0, $s4
    li $v0, 1
    syscall
    la $a0, nl
    li $v0, 4
    syscall
    j exit
    
print_zero:
    la $a0, zero_str
    li $v0, 4
    syscall
    j exit

print_negInf:
    la $a0, neg_infinity_str
    li $v0, 4
    syscall
    j exit

print_posInf:
    la $a0, pos_infinity_str
    li $v0, 4
    syscall
    j exit
    
print_nan:
    la $a0, NaN_str
    li $v0, 4
    syscall
    j exit

# TWOS COMPLEMENT, PART 2
Two_first:   # need to have 2 arg in total
    li $s1, 0 # decimal number value
    beq $a0, 2, twos_complement
    la $a0, invalid_args_error
    li $v0, 4
    syscall
    j exit
   
twos_complement: # read arg 2 to see if valid: most 32 length, string of 0 and 1s
    li $t2, 0
    lw $t2, addr_arg1 # address for next arg
    li $s0, 0  # $s0 = length (length of string)
    li $s7, 32 # max length of arg 2
    li $s4, 0 # flag as pos number, flag = if pos or neg
    li $t3, 0
     
    lbu $t3, 0($t2) # $t3 has contents from address
    # if starts with 1, flip bits and calc binary to dec
    beq $t3, '1', flip_bin # also need to print neg sign  
    # if starts with 0, calc binary to dec, regular conversion
while: # read each char in 2nd argument
    bgt $s0, $s7, iae_end # length > 32
    lbu $t3, ($t2) # $t3 has contents from address
    beqz $t3, print_twos_comp # when hits a null, end
    beq $t3, '0', bin_num0 # 48
    beq $t3, '1', bin_num1 # 49 
    j iae_end
 
bin_num0:
    #if neg
    beq $s4, 1, neg_bin0
    # if pos
    addi $t3, $t3, -48 # change string char into number
    j bin_conv
   
bin_num1: 
    #if neg
    beq $s4, 1, neg_bin1
    # if pos
    addi $t3, $t3, -48 # change string char into number
    j bin_conv
    
neg_bin0: #treat 0s as 1s, and 1s as 0s
    addi $t3, $t3, -47 # change string char into number, changes to 1
    j bin_conv

neg_bin1: #treat 0s as 1s, and 1s as 0s
    addi $t3, $t3, -49 # change string char into number, changes to 1
    j bin_conv
     	
bin_conv:
    addi $s0, $s0, 1 # increase length 
    #addi $t3, $t3, -48 # change string char into number
    addi $t2, $t2, 1  # move position to next char
    #lbu $t5, ($t2) # $t5 = next num
    # num * 2 + next num = num
    mul $s1, $s1, $s2
    addu $s1, $s1, $t3 
    j while
    
flip_bin: # change the string contents to be flipped
    li $s4, 1 # set s4 to 1, indicating that the binary number starts with 1, and to flag as neg number
    j while
             
print_twos_comp: 
    # need to print '\n' at the end
    # move a0 to print number
    #if neg
    beq $s4, 1, printneg_twos_comp
    #if pos
    move $a0, $s1
    li $v0, 1
    syscall
    la $a0, nl
    li $v0, 4
    syscall
    j exit
    
printneg_twos_comp:
    # change to neg, then add 1
    # * -1, +1
    li $t4, -1
    move $a0, $s1
    mul $a0, $a0, $t4
    addi $a0, $a0, -1
    li $v0, 1
    syscall
    la $a0, nl
    li $v0, 4
    syscall
    j exit

# BASE TO DECIMAL CONVERSION, PART 4
C_first:
    # need to have 4 arg in total
    beq $a0, 4, convert_base
    la $a0, invalid_args_error
    li $v0, 4
    syscall
    j exit
   
convert_base:
    li $t2, 0
    li $t3, 0
    li $s1, 0
    li $s3, 0
    li $s4, 0
    li $s5, 0 # decimal value 
    li $t7, 0
    li $t5, 0 # counter to end the stack
    la $t6, b_str # the result string to print
    li $s6, 0 # save arg 2
    li $s7, 0 # save arg 3
    li $t4, 0 # arg 2
    li $t8, 0 # arg 3
    
    lw $t3, addr_arg1
    lbu $s1, ($t3) # arg 1
    lw $t4, addr_arg2 
    # lbu $s3, ($t2) # arg 2
    lw $t8, addr_arg3 
    # lbu $s4, ($t2) # arg 3
    # convert string of ASCII digit characters into a decimal integer (for arg 2,3)
    move $a0, $t4
    li $v0, 84 # arg 2 in v2
    syscall
    move $s6, $v0 # store value in s6
    
    move $a0, $t8
    li $v0, 84 # arg 3 in v3
    syscall
    move $s7, $v0 # store value in s7
    
loop_digits: # t3 has the position number
    lbu $s1, ($t3) # $s1 has contents from address, the byte of the string, $t3 points to the string
    beqz $s1, check_z # when hits a null, end
    addi $s1, $s1, -48 # get the char's number value
    bgeu $s1, $s6, iae_end
    
to_decimal:
    addi $t3, $t3, 1 # to the next char
    mul $s5, $s5, $s6 # num * base = num
    addu $s5, $s5, $s1 # now s5 is s1 string decimal form
    j loop_digits

check_z:            
    beq $s5, 0, z_with_base            
dec_to_base_stack: # store each number on the stack so that the remainder can be reveresed and read normally
    beq $s5, 0, save_base
    div $s5, $s7 # change decimal form into the base we want
    mflo $s5, # quotient
    mfhi $t7 # remainder, deal with it on the stack, store each number on the stack  
    addi $sp, $sp, -4 # make room to store on stack
    sw $t7, ($sp) # PUSH the $t7 register
    addi $t5, $t5, 1 # increase counter to track how many things pushed to stack
    # move the pointer next character, is at to_decimal
    j dec_to_base_stack
    
save_base:
    lw $t7,($sp) # POP a value from the stack
    beq $t5, 0, print_base
    addi $t5, $t5, -1
    addi $sp, $sp, 4 # end adjust the pointer

    # sb $t7, ($t6) # store in string, $t6 is the addr to string
    move $a0, $t7
    li $v0, 1
    syscall
    # addi $t6, $t6, 1 # move pointer one character
    j save_base
     
z_with_base:
    move $a0, $s5
    li $v0, 1
    syscall
print_base:
    # move $a0, $t6
    # li $v0, 4
    # syscall
    la $a0, nl
    li $v0, 4
    syscall
    j exit

iae_end:
    la $a0, invalid_args_error
    li $v0, 4
    syscall
    j exit

exit:
    li $v0, 10   # terminate program
    syscall
