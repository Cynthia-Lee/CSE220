# Cynthia Lee
# cyllee
# 111737790

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################

.text

### Part I ###
index_of_car:
	li $v0, -200
	li $v1, -200
	# $a0 = array base address
	# $a2 = start index, i = start
	# $a1 = length of the array (upper bound)
	# $a3 = year
	li $t7, 0
	li $v0, -1
	move $t7, $a2 # i = start
	# conditions for v0 = -1
		bleu $a1, 0, end_yloop
		bltu $a2, 0, end_yloop
		bleu $a1, $a2, end_yloop
		bltu $a3, 1885, end_yloop
	year_loop:
		beq $t7, $a1, end_yloop # repeat until i = length, valid for i < length
		# addr = base_addr + i * elem_size_in_bytes 
		sll $t0, $t7, 4 # $t0 = i * 16
		add $t0, $t0, $a0
		lhu $t1, 12($t0) # $t1 = array[i], this contains the CAR STRUCT at the index
		# we want to shift the offset by 12 to reach the section containing the year in the car struct
		beq $t1, $a3, year_found # if the car at the index = year we want, end
		addi $t7, $t7, 1
		j year_loop
	
	year_found:
		move $v0, $t7
		j end_yloop
		
	end_yloop:
		jr $ra
	

### Part II ###
strcmp:
	li $v0, -200
	li $v1, -200
	li $t1, 0 # str 1 length
	li $t2, 0 # str 2 length
	li $t3, -1
	move $t4, $a0 # temp when counting the s1 string
	move $t5, $a1  # temp with counting the s2 string
	# $t6 is char at s1
	# t7 is char at s2
	
	s1_len:
		lbu $t6, ($t4)
		beqz $t6, s2_len # go to s2 to count length
		addi $t1, $t1, 1 # inc len s1
		addi $t4, $t4, 1 # next char
		j s1_len
		
	s2_len:
		lbu $t7, ($t5)
		beqz $t7, check_string_nulls
		addi $t2, $t2, 1 # inc len s2
		addi $t5, $t5, 1 
		j s2_len
	
	check_string_nulls:	
		beqz $t1, str1_null
		beqz $t2, str2_null
	loop_compare_strings:
		lbu $t6, ($a0)
		beqz $t6, s1_shorter # s1 is a substring of s2
		addi $a0, $a0, 1 # next char in s1
		lbu $t7, ($a1)
		beqz $t7, s2_shorter # s2 is a substring of s1
		addi $a1, $a1, 1 # next char in s2
		# compare the two characters if different
		bne $t6, $t7, strings_diff
		j loop_compare_strings
		
	s1_shorter: # s1 is substring of s2
		lbu $t7, ($a1) # s2 string. char after the substring
		mul $t7, $t7, $t3
		move $v0, $t7
		j end_sc
	
	s2_shorter: # s2 is substring of s1
		# s1 string. char after the substring
		move $v0, $t6
		j end_sc
		
	strings_diff:
		mul $t7, $t7, $t3 # s2 * -1
		add $v0, $t6, $t7
		j end_sc
	
	str1_null:
		beqz $t2, return_zero # s1 len = 0, s2 len = 0 both nulls are the same
		# so now s2 len != 0
		mul $t2, $t2, $t3 # t2 len is neg
		move $v0, $t2
		j end_sc
	
	str2_null:
		# so now s1 len != 0
		move $v0, $t1
		j end_sc
	
	return_zero:
		li $v0, 0
		j end_sc

	end_sc:
		jr $ra


### Part III ###
memcpy:
	li $v0, -200
	li $v1, -200
	li $t0, 0 # counter
	ble $a2, 0, copy_error 
	li $t0, 0 # char from src
	
	loop_to_copy:
		beq $t0, $a2, end_copy # until counter reaches n
		lbu $t1, ($a0) # get char from src
		# put it in the same index into dest
		sb $t1, ($a1)
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		addi $t0, $t0, 1 # inc counter
		j loop_to_copy
	
	copy_error:
		li $v0, -1
		jr $ra
	
	end_copy:
		li $v0, 0
		jr $ra


### Part IV ###
insert_car:
	li $v0, -200
	li $v1, -200
	# $a0 = array of cars
	# $a1 = length of array
	# $a2 = new car 
	# $a3 = index
	# $t7 = i 
	
	# return -1 conditions first
	bltz  $a1, insert_error
	bltz $a3, insert_error
	bltu $a1, $a3, insert_error
	
	li $t7, 0
	addi $t7, $a1, -1 # starting at the last index
	
	# save to the stack so we can call the original values
	addi $sp, $sp, -20 # make space on the stack to store one register
	sw $ra, 0($sp)
	sw $s0, 4($sp) # save $s0 on the satck
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	li $t0, 0
	li $t2, 0
	li $t3, 0
	
	shift_car_loop: # should do the copy first
		blt $t7, $s3, end_shift # repeat until i = length, valid for i < length
		# addr = base_addr + i * elem_size_in_bytes 
		sll $t0, $t7, 4 # $t0 = i * 16
		add $t0, $t0, $s0 # $t0 has the addr
		# starting at the last index
		# shift the car second to last into the last
		# we will move the car 16 bytes over with memcpy
		
		move $a0, $t0 # src addr
		# addr "to"
		addi $t2, $t7, 1
		sll $t3, $t2, 4
		add $t3, $t3, $s0
		move $a1, $t3 # 16 bytes over, dest addr
		li $a2, 16 
		jal memcpy
		addi $t7, $t7, -1
		j shift_car_loop
	
	insert_error:
		li $v0, -1
		jr $ra
	
	end_shift:
		# want to load ogriginal values of $a from $s registers from the stack
		
		# now to insert the car we wanted
		# a3 = index, a2 = new car
		
		# addr = base_addr + i * elem_size_in_bytes 
		sll $t0, $s3, 4 # $t0 = i * 16
		add $t0, $t0, $s0
		
		move $a0, $s2 # the new car
		# get address "to"
		move $a1, $t0
		# la $a1, ($t1) # to dest which is t1
		li $a2, 16 
		
		jal memcpy
		
		lw $s3, 16($sp)
		lw $s2, 12($sp)
		lw $s1, 8($sp)
		lw $s0, 4($sp)
		lw $ra, 0($sp) # get $ra	
		addi $sp, $sp, 20
		
		li $v0, 0
		jr $ra # return to the first jr ra
	
# PRINTING A CAR
print_a_car:
	# $a0 will have address to the car
	lw $t0, 0($a0)
	lw $t1, 4($a0)
	lw $t2, 8($a0)
	lhu $t3, 12($a0)
	lbu $t4, 14($a0)
	lbu $t5, 15($a0)
	move $a0, $t0
	li $v0, 4
	syscall
	li $a0, '_'
	li $v0, 11
	syscall
	move $a0, $t1
	li $v0, 4
	syscall
	li $a0, '_'
	li $v0, 11
	syscall
	move $a0, $t2
	li $v0, 4
	syscall
	li $a0, '_'
	li $v0, 11
	syscall
	move $a0, $t3
	li $v0, 1
	syscall
	li $a0, '_'
	li $v0, 11
	syscall	
	move $a0, $t4
	li $v0, 1
	syscall
	jr $ra

# PRINTING AN ARRAY OF CARS
print_car_array:
	# $a0 will be the address to the array of the car
	# $a1 will be the length of the arr
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp) # counter & index
	sw $s1, 8($sp)
	sw $s4, 12($sp) # address 
	sw $s3, 16($sp) 
	
	li $s0, 0 # counter & index
	li $s4, 0, # address
	move $s1, $a1 # t0 is the length
	move $s3, $a0
	
	print_loop_array:
		beq $s0, $s1, end_print_array 
		# addr = base_addr + i * elem_size_in_bytes
		sll $s4, $s0, 4
		add $s4, $s4, $s3
		
		move $a0, $s4
		jal print_a_car
		
		li $a0, '.' 
		li $v0, 11
		syscall
		li $a0, ' '
		li $v0, 11
		syscall	
		addi $s0, $s0, 1
		j print_loop_array
		
	end_print_array:
		# lw $ra, 0($sp)
		# addi $sp, $sp, 4
		lw $ra, 0($sp)
		lw $s0, 4($sp) # counter & index
		lw $s1, 8($sp)
		lw $s4, 12($sp) # address 
		lw $s3, 16($sp) 
		addi $sp, $sp, 16
		jr $ra
		
# COMPARING ARRAY OF CARS with strcmp
compare_car_arrays:
	# a0 = str1, a1 = str2, a2 = number of bytes (doing this to include the nulls)
	# 7 * 16 = 112, 7 cars, 16 bytes each
	# will return $v0, -1 if not the same, 0 if the same
	li $v0, -200
	li $v1, -200
	# li $t1, 0 # str 1 length
	# li $t2, 0 # str 2 length
	# li $t3, -1
	li $t1, 0 # counter for the bytes
	move $t4, $a0 # temp when counting the s1 string
	move $t5, $a1  # temp with counting the s2 string
	# $t6 is char at s1
	# t7 is char at s2
	
	loop_compare_car_arr:
		beq $t1, $a2, end_compare_car_arr
		lbu $t6, ($a0)
		# beqz $t6, s1_shorter # s1 is a substring of s2
		addi $a0, $a0, 1 # next char in s1
		lbu $t7, ($a1)
		# beqz $t7, s2_shorter # s2 is a substring of s1
		addi $a1, $a1, 1 # next char in s2
		# compare the two characters if different
		bne $t6, $t7, cars_diff
		addi $t1, $t1, 1
		j loop_compare_car_arr
	
	end_compare_car_arr:
		li $v0, 0
		j end_ca

	cars_diff:
		li $v0, -1
		j end_ca
	
	end_ca:
		jr $ra
	

### Part V ###
most_damaged:
	# check -1 conditions
	ble $a2, 0, most_damaged_error
	ble $a3, 0, most_damaged_error
	
	li $v0, 0
	li $v1, 0
	li $t0, 0
	li $t1, 0
	li $t2, 0 
	li $t3, 12 # ele size of repair struct
	li $t4, 0 # counter for car array/index
	li $t5, 0 # counter for repair array/index
	li $t6, 0 # will hold the max value of the cost
	li $t7, 0 
	
	loop_car_array: # $t4 is the index
		beq $t4, $a2, end_repair_max
		li $t5, 0
		# addr = base_addr + i * element_size_in_bytes
		sll $t0, $t4, 4 # $t0 = i*16
		add $t0, $t0, $a0 # $t0 = addr of car
		j loop_repair_cost
		
	loop_repair_cost: # $t5 is the index
		beq $t5, $a3, next_car
		# $t0 has address of car, have to compare that address with the repair array's car pointer address
		# get address of the repair struct, then the car pointer
		mul $t1, $t5, $t3 # $t1 = i * 12
		add $t1, $t1, $a1 # $t1 = addr of repair struct
		lw $t2, ($t1) # $t2 = car addr from car_ptr
		beq $t2, $t0, calc_repair # if the same car addr, calculate
	cont_loop_repair_cost:
		addi $t5, $t5, 1
		j loop_repair_cost
	
	calc_repair:
		# add cost from repair struct to cost
		# can reuse the $t0,$t3 register? 
		# $t6 = total repair cost of the current car
		lhu $t7, 8($t1) # getting the cost from repair struct
		add $t6, $t7, $t6
		j cont_loop_repair_cost
		
	next_car:
		# check the max 
		# $t0 = current car's total cost
		# $t6 = the max value of the cost
		# $t7 = the index of the max value
		bgtu $t6, $v1, change_max
	cont_next_car:
		li $t6, 0
		addi $t4, $t4, 1
		j loop_car_array
	
	change_max:
		move $v0, $t4 # index
		move $v1, $t6 # cost
		j cont_next_car
	
	end_repair_max:
		jr $ra

	most_damaged_error:
		li $v1, -1
		li $v0, -1
		jr $ra
		
		
### Part VI ###
sort:
	# check -1 conditions
	blez $a1, error_sort
 	
	li $v0, 0
	li $t1, 1 # = i
	li $t2, 0 # year at [i]
	# start index for odd loop = 1
	# start index for even loop = 0
	li $t3, 0 # i+1 addr
	li $t4, 0 # year at [i+1]
	li $t5, 0 # car[i] addr
	li $t6, 0 # car[i+1] addr
	
	# need to keep the [i] and [i+1] index after calling memcpy
	# things to reserve before memcpy
	addi $sp, $sp, -24
	sw $ra, 0($sp)
	sw $s0, 4($sp) # car array addr
	sw $s1, 8($sp) # car array length
	sw $s2, 12($sp) # keep [i]
	sw $s3, 16($sp) # cap/stop for the for loop
	sw $s4, 20($sp) # sorted flag
	
	li $t0, 0 # sorted flag, 0 = false, 1 = true
	move $s0, $a0 
	move $s1, $a1
	move $s2, $t1 # i
	li $s3, 0
	addi $s3, $s1, -1 # $s3 = stop for loop, len - 1
	li $s4, 0 # sorted flag
	
	# sorted = false
	loop_sorted: # while sorted = false
		beq $s4, 1, end_loop_sorted
		li $s4, 1 # sorted = true
		li $s2, 1 # set the index to 1 again
		loop_odd: # i = t1, start at 1
			bge $s2, $s3, end_loop_odd
			# addr = base_addr + i * elem_size_in_bytes
			# get addr of car at [i], $t1
			sll $t5, $s2, 4
			add $t5, $t5, $s0 # $t5 = car[i] addr
			lhu $t2, 12($t5) # $t2 = year at car[i]
			# get addr of car at [i+1], $t1 + 1 = $t3
			addi $t3, $s2, 1
			sll $t6, $t3, 4 
			add $t6, $t6, $s0 # $t6 = car[i+1] addr
			lhu $t4, 12($t6) # $t4 = year at car[i+1]
			bgt $t2, $t4, swap_cars_odd
		cont_loop_odd:
			addi $s2, $s2, 2
			j loop_odd
		
		swap_cars_odd:
			addi $sp, $sp, -16
			# $a0 = src
			# $a1 = dest
			# $a2 = n
			move $a0, $t5 # t5 = car[i] addr
			move $a1, $sp
			li $a2, 16
			jal memcpy # copy cars[i] onto the stack
			move $a0, $t6 
			move $a1, $t5
			li $a2, 16
			jal memcpy # copy cars[i+1] to cars[i]
			# copy the temp car on the stack to cars[i+1]
			move $a0, $sp
			move $a1, $t6
			li $a2, 16
			jal memcpy
			addi $sp, $sp, 16
			
			li $s4, 0 # sorted = false
			j cont_loop_odd
		
		end_loop_odd:
			# reset values here t1, t3, t5, t6, t2, t4
			li $s2, 0 # = i
			li $t3, 0 # = i + 1
			li $t5, 0 # = car[i] addr
			li $t6, 0 # = car[i+1] addr
			li $t2, 0 # = year[i]
			li $t4, 0 # = year[i+1]
			j loop_even
					
		loop_even: # i = t1, start at 0
			bge $s2, $s3, loop_sorted
			# addr = base_addr + i * elem_size_in_bytes
			# get addr of car at [i], $t1
			sll $t5, $s2, 4
			add $t5, $t5, $s0 # $t5 = car[i] addr
			lhu $t2, 12($t5) # $t2 = year at car[i]
			# get addr of car at [i+1], $t1 + 1 = $t3
			addi $t3, $s2, 1
			sll $t6, $t3, 4 
			add $t6, $t6, $s0 # $t6 = car[i+1] addr
			lhu $t4, 12($t6) # $t4 = year at car[i+1]
			bgt $t2, $t4, swap_cars_even
		cont_loop_even:
			addi $s2, $s2, 2
			j loop_even
			
		swap_cars_even:
			addi $sp, $sp, -16
			# $a0 = src
			# $a1 = dest
			# $a2 = n
			move $a0, $t5
			move $a1, $sp
			li $a2, 16
			jal memcpy # copy cars[i] onto the stack
			move $a0, $t6 
			move $a1, $t5
			li $a2, 16
			jal memcpy # copy cars[i+1] to cars[i]
			# copy the temp car on the stack to cars[i+1]
			move $a0, $sp
			move $a1, $t6
			li $a2, 16
			jal memcpy
			addi $sp, $sp, 16
			
			li $s4, 0 # sorted = false
			j cont_loop_even
	
	end_loop_sorted:
		lw $ra, 0($sp)
		lw $s0, 4($sp) # car array addr
		lw $s1, 8($sp) # car array length
		lw $s2, 12($sp) # keep [i]
		lw $s3, 16($sp) # cap/stop for the for loop
		lw $s4, 20($sp) # sorted flag
		addi $sp, $sp, 24
		jr $ra
		
	error_sort:
		li $v0, -1
		jr $ra


### Part VII ###
most_popular_feature:
	blez $a1, error_most_popu
	blt $a2, 1, error_most_popu
	bgt $a2, 15, error_most_popu
	
	li $v0, 0
	li $t7, 0 # counter
	li $t3, 0 # count GPS at bit 3
	li $t2, 0 # count TINT at bit 2
	li $t1, 0 # count HYBRIDS at bit 1
	li $t0, 0 # count CONV at bit 0
	
	# $a2 = check to see which features we want to count for
	# go through car array, for loop
	loop_car_arr_features:
		beq $t7, $a1, find_max
		# get address of car at index
		# addr = base_addr + i * elem_size_in_bytes
		# get addr of car at [i], $t1
		sll $t5, $t7, 4 # i * 16
		add $t5, $t5, $a0 # $t5 = car[i] addr
		# need to get the features part
		lbu $t6, 14($t5) # $t6 = feature at car[i]
		andi $t4, $t6, 0x00000008 # at bit 3
		bnez $t4, inc_GPS # can be [1,15] just can't be 0
	return_cf1:
		andi $t4, $t6, 0x00000004 # at bit 2
		bnez $t4, inc_tint
	return_cf2:
		andi $t4, $t6, 0x00000002 # at bit 1
		bnez $t4, inc_hybrid
	return_cf3:
		andi $t4, $t6, 0x00000001 # at bit 0
		bnez $t4, inc_convertables
	return_cf4:
		addi $t7, $t7, 1
		j loop_car_arr_features
	
	# should only increase the count if the feature is being considered	
	inc_GPS: # t3
		# lbu $t9, ($a2)
		andi $t5, $a2, 0x00000008 # at bit 3
		beq $t5, 0, return_cf1 # not being considered
		addi $t3, $t3, 1 # being considered
		j return_cf1
		
	inc_tint: # t2
		# lbu $t9, ($a2)
		andi $t5, $a2, 0x00000004 # at bit 3
		beq $t5, 0, return_cf2 # not being considered
		addi $t2, $t2, 1
		j return_cf2
			
	inc_hybrid: # t1
		# lbu $t9, ($a2)
		andi $t5, $a2, 0x00000002 # at bit 3
		beq $t5, 0, return_cf3 # not being considered
		addi $t1, $t1, 1
		j return_cf3
		
	inc_convertables: # t0
		# lbu $t9, ($a2)
		andi $t5, $a2, 0x00000001 # at bit 3
		beq $t5, 0, return_cf4 # not being considered
		addi $t0, $t0, 1
		j return_cf4
			 
	# check the max. return the highest valued bit number with the greatest
	find_max:
		li $t9, 0 # can reuse $t9, $t9 = max
		ble $t3, $t9, skip_max1
		move $t9, $t3 # if t3 > max, t3 = max, v0 = 8
		li $v0, 8
	skip_max1:
		ble $t2, $t9, skip_max2
		move $t9, $t2 # if t2 > max, t2 = max, v0 = 4
		li $v0, 4	
	skip_max2:
		ble $t1, $t9, skip_max3
		move $t9, $t1 # if t2 > max, t2 = max, v0 = 4
		li $v0, 2
	skip_max3:
		ble $t0, $t9, end_popu
		move $t9, $t0 # if t2 > max, t2 = max, v0 = 4
		li $v0, 1
	end_popu:
		beq $t9, 0, error_most_popu # error when there is no favorite because the count is 0 for all features											
		jr $ra
	
	error_most_popu:
		li $v0, -1
		jr $ra

### Optional function: not required for the assignment ###
transliterate:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $v0, -200
	li $v1, -200
	# a0 = char
	# a1 = string
	# returning value in v0
	jal index_of
	li $t1, 10
	move $t0, $v0
	div $v0, $t1
	mfhi $v0 # hi is mod
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra


### Optional function: not required for the assignment ###
char_at:
	li $v0, -200
	li $v1, -200
	# returns char at the index
	# a0 = index
	# a1 = string to use
	# v0 = char
	# for loop to go through the string until the char is found
	li $t0, 0 # counter/index
	move $t1, $a1
	loop_get_char_at_i:
		lbu $t3, ($t1) # char at that address
		beq $t0, $a0, end_index
		addi $t1, $t1, 1
		addi $t0, $t0, 1
		j loop_get_char_at_i

	end_index: 
		move $v0, $t3 # char at the index
		jr $ra


### Optional function: not required for the assignment ###
index_of:
	# returns index of in $v0
	# will not pass bad arguments for this method/branch?
	li $v0, -200
	li $v1, -200
	# a0 = char
	# a1 = string to take in
	# prioritizes index that comes first
	# for loop through each char in the string until it finds it 
	li $t0, 0 # counter/index
	li $t1, 0
	move $t1, $a1 # string
	li $t2, 0
	loop_index_of:
		lbu $t2, ($t1) # gets char at that index
		beqz $t2, exit_loop_i # if it hits a null 
		beq $t2, $a0, index_found
		addi $t1, $t1, 1
		addi $t0, $t0, 1
		j loop_index_of
	
	exit_loop_i: 
		jr $ra
	
	index_found:	
		move $v0, $t0	
		jr $ra


### Part VIII ###
compute_check_digit:
	li $v0, -200
	li $v1, -200
	# a0 = vin
	# a1 = map
	# a2 = weights
	# a3 = transliterate_str
	# save to the stack
	addi $sp, $sp, -32
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	li $s4, 0 # sum = 0 KEEP
	li $s5, 0 # counter/i KEEP
	li $s6, 0
	
	for_loop_vin: # t1 = i
		beq $s5, 17, end_loop_vin
		
		# transliterate(vin.charAt(i), transliterate_str)
		move $a0, $s5 # a0 = i
		move $a1, $s0 # a1 = string, in this case will be VIN
		jal char_at
		move $t2, $v0 # t2 = vin.charAt(i)
		# transliterate (t2, transliterate_str)
		move $a0, $t2
		move $a1, $s3
		jal transliterate
		move $s6, $v0 # NEED TO KEEP THIS
		# map.index_of(weights.char_at(i))
		# t4 = weights.char_at(i)
		move $a0, $s5
		move $a1, $s2
		jal char_at
		move $t4, $v0
		# map.index_of(t4)
		move $a0, $t4 # a0 = t4
		move $a1, $s1 # a1 = map
		jal index_of
		move $t5, $v0 # t5 = map.index_of(t4)
		# sum = sum + s6 * t5
		# t6 = t3 * t5
		mul $t6, $s6, $t5
		add $s4, $s4, $t6
		
		addi $s5, $s5, 1
		j for_loop_vin
	
	end_loop_vin:
		li $t9, 11
		# return map.char_at(sum % 11)
		div $s4, $t9
		# t7 = sum % 11
		mfhi $t7
		move $a0, $t7 # a0 = (sum % 11)
		move $a1, $s1 # a1 = map
		jal char_at
		# v0 is the value
		
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		addi $sp, $sp, 32
		jr $ra	

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################
