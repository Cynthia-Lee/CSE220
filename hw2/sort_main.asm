.include "sort_data.asm"
.include "hw2.asm"

.data
nl: .asciiz "\n"
sort_output: .asciiz  "sort output: "

.text
.globl main
main:
# all_cars array before being sorted
# la $a0, all_cars
# li $a1, 12
# jal print_car_array
# la $a0, nl
# li $v0, 4
# syscall

la $a0, sorted_all_cars
li $a1, 12
jal print_car_array
la $a0, nl
li $v0, 4
syscall


la $a0, sort_output
li $v0, 4
syscall
la $a0, all_cars
li $a1, 12
jal sort
move $a0, $v0
li $v0, 1
syscall
la $a0, nl
li $v0, 4
syscall

# sorted_all_cars, car array gets messed up here

# printing out the array to check
la $a0, all_cars
li $a1, 12
jal print_car_array

#la $a0, nl
#li $v0, 4
#syscall

#la $a0, sorted_all_cars
#li $a1, 12
#jal print_car_array

la $a0, nl
li $v0, 4
syscall

la $a0, all_cars
la $a1, sorted_all_cars
li $a2, 192
jal compare_car_arrays
move $a0, $v0
li $v0, 1
syscall

#la $a0, all_cars
#la $a1, sorted_all_cars
#li $a2, 16
#jal compare_car_arrays
#move $a0, $v0
#li $v0, 1
#syscall

#la $a0, nl
#li $v0, 4
#syscall
#la $a0, sorted_all_cars
#la $a1, sorted_all_cars
#li $a2, 16
#jal compare_car_arrays
#move $a0, $v0
#li $v0, 1
#syscall

#la $a0, all_cars
#li $a1, 12
#jal print_car_array

li $v0, 10
syscall
