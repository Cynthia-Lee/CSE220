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

# Part I
get_adfgvx_coords:
	li $v0, 0
	li $v1, 0
	# string "ADFGVX" and pick chars based on that index
	# index1 = a0, index2 = a1
	# error cases
	# if index1<0 or index1>5, both v0 = -1, v1 = -1
	blt $a0, 0, coords_error
	bgt $a0, 5, coords_error
	# if index2<0 or index2>5
	blt $a1, 0, coords_error
	bgt $a1, 5, coords_error
	# check index1 first
	beqz $a0, index1_A # if a0 = 0, then A
	beq $a0, 1, index1_D
	beq $a0, 2, index1_F
	beq $a0, 3, index1_G
	beq $a0, 4, index1_V
	beq $a0, 5, index1_X
	index1_A:
		li $v0, 'A'
		j check_index2
	index1_D:
		li $v0, 'D'
		j check_index2
	index1_F:
		li $v0, 'F'
		j check_index2
	index1_G:
		li $v0, 'G'
		j check_index2
	index1_V:
		li $v0, 'V'
		j check_index2
	index1_X:
		li $v0, 'X'
		j check_index2	
	check_index2: # check index2
	beqz $a1, index2_A # if a1 = 0, then A
	beq $a1, 1, index2_D
	beq $a1, 2, index2_F
	beq $a1, 3, index2_G
	beq $a1, 4, index2_V
	beq $a1, 5, index2_X
	index2_A:
		li $v1, 'A'
		j exit_coords
	index2_D:
		li $v1, 'D'
		j exit_coords
	index2_F:
		li $v1, 'F'
		j exit_coords
	index2_G:
		li $v1, 'G'
		j exit_coords
	index2_V:
		li $v1, 'V'
		j exit_coords
	index2_X:
		li $v1, 'X'
		j exit_coords
exit_coords:		
	jr $ra
coords_error:
	li $v0, -1
	li $v1, -1
	jr $ra

# Part II
search_adfgvx_grid:
	li $v0, -200
	li $v1, -200
	li $t1, 0 # counter for row index
	li $t2, 0 # counter for col index
	# a0 = String addr, a1 = char looking for
	move $t3, $a0
	# loop for reading each char one by one in the String (row-major order)
	loop_2D_String:
		lbu $t4, ($t3) # t4 has char
		beq $a1, $t4, end_search_grid # if char is same as a1 char
		addi $t2, $t2, 1 # inc col first
		beq $t2, 6, reset_col_count	
	cont_col:
		addi $t3, $t3, 1
		j loop_2D_String
# check if the char is actually on the grid, will be when row = 6
reset_col_count:
	li $t2, 0
	addi $t1, $t1, 1 # increase the row
	beq $t1, 6, not_found
	j cont_col
not_found:
	li $v0, -1
	li $v1, -1
	jr $ra
end_search_grid:	
	move $v0, $t1
	move $v1, $t2
	jr $ra

# Part III
map_plaintext:
	li $v0, -200
	li $v1, -200
	addi $sp, $sp, -24
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	move $s0, $a0 # grid addr
	move $s1, $a1 # plain text addr
	move $s2, $a2 # middle text addr (buffer)
	li $s3, 0
	li $s4, 0
	li $t3, 0
	move $s3, $s1 # s3 = inc plain text addr
	move $s4, $s2 # s4 = inc buffer addr
	# loop for each char in plain text
	loop_plaintext:
		lbu $t3, ($s3) # t3 = char
		beq $t3, 0, end_plaintext
		move $a0, $s0 # a0 has 2D array grid addr
		move $a1, $t3 # a1 = char
		jal search_adfgvx_grid # v0 = row index, v1 = col index
		move $a0, $v0 # a0 = index1
		move $a1, $v1 # a1 = index2
		jal get_adfgvx_coords # v0 = index1 char, v1 = index2 char
		# now store into the buffer
		sb $v0, ($s4)
		addi $s4, $s4, 1
		sb $v1, ($s4)
		addi $s4, $s4, 1
		addi $s3, $s3, 1 # next char
		j loop_plaintext
end_plaintext:		
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)	
	addi $sp, $sp, 24	
	jr $ra

# Part IV
swap_matrix_columns:
	li $v0, -200
	li $v1, -200
	# a3 = col1, 0($sp) = col2
	# error cases
	lw $t9, 0($sp)
	blez $a1, swap_error
	blez $a2, swap_error
	bltz $a3, swap_error
	bge $a3, $a2, swap_error # col1 >= num_cols
	bltz $t9, swap_error
	bge $t9, $a2, swap_error # col2 >= num_cols
	li $t0, 1 # elem size
	li $t1, 0 # row counter
	li $t2, 0 # col counter
	li $t3, 0 # temp
	li $t4, 0
	li $t5, 0
	# loop through the string, groups of # cols, if 4, 0123
	loop_swap:
		# if col count = col1, then swap letters in that row
		beq $t2, $a3, swap_cols_on_row
	cont_loop_swap:
		addi $t2, $t2, 1 # inc col first
		beq $t2, $a2, reset_col_count_swap
		j loop_swap
swap_cols_on_row:
	# mul $t4, $a2, $t1 # position of col 2 char = col2 + (col_len * row_pos)
	# addi $t4, $t4, $t9
	# lbu $t3, $t4($a0) 
	# --------------------
	# address of [i,j] = base_addr + elem_size_in_bytes * (i * num_col + j)
	# save col2 char in temp
	# col2 char is at i = row counter(t1), j = col2(t9)
	## t4 = COL2 INDEX OF THIS ROW
	mul $t4, $t1, $a2 # t4 = (i*num_col+j)
	add $t4, $t4, $t9
	mul $t5, $t4, $t0 # t5 = elem_size * t4
	add $t4, $a0, $t5 # t4 = base_addr + t5
	## t6 = COL1 INDEX OF THIS ROW
	# col1 char is at i = row counter(t1), j = col1(a3)
	mul $t6, $t1, $a2 # t6 = (i*num_col+j)
	add $t6, $t6, $a3
	mul $t5, $t0, $t6 # t5 = elem_size * t6
	add $t6, $a0, $t5 # t6 = base_addr + t5
	# get char at col2 pos, lbu $t3
	lbu $t3, ($t4) # t3 = temp (char)
	# put col1 char on col2 pos
	lbu $t7, ($t6) # t7 = col1 char
	sb $t7, ($t4) # t7 = col 1 char, t4 = col2 pos
	# put temp on col1 pos
	# t3 = temp char, t6 = col1 pos
	sb $t3, ($t6)
	j cont_loop_swap
reset_col_count_swap:
	li $t2, 0
	addi $t1, $t1, 1 # increase the row
	beq $t1, $a1, end_swap # finished all rows 
	j loop_swap
end_swap:
	li $v0, 0
	jr $ra
swap_error:
	li $v0, -1
	jr $ra

# Part V
key_sort_matrix:
# Assume the array to be sorted is A[] with length n:
# for (int i = 0; i < n; i++)
#	for (int j = 0; j < n - i - 1; j++)
#		if A[j] > A[j+1]:
#			swap A[j] and A[j+1]
	li $v0, -200
	li $v1, -200
	lw $t2, 0($sp)
	# 0($sp) has element size
	addi $sp, $sp, -36
	sw $ra, 0($sp)
	sw $s0, 4($sp) # s0 = matrix arr 
	sw $s1, 8($sp) # s1 = num_rows
	sw $s2, 12($sp) # s2 = num_cols
	sw $s3, 16($sp) # s3 = key addr
	sw $s4, 20($sp) # s4 = elem_size
	sw $s5, 24($sp) # s5 = i
	sw $s6, 28($sp) # s6 = j
	sw $s7, 32($sp) # s7 = n (length)
	li $s5, 0 # s5 = i
	li $s6, 0 # s6 = j (col counter)
	li $s7, 0 # s7 = n, n is the key array length which is same as num_cols
	# using the stack
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	move $s4, $t2 # s4 = elem_size
	move $s7, $a2
# FIRST FOR LOOP		
	for_loop_1: # i will act as row counter, s5 = i
		li $s6, 0 # j = 0
		beq $s5, $s7, exit_for_loop_1 # i < n
		for_loop_2: # col counter j = s6
			li $t2, 0
			addi $t2, $s6, 1 # t2 = j+1
			li $t9, 0
			sub $t9, $s7, $s5 # n - i
			addi $t9, $t9, -1 
			beq $s6, $t9, cont_for_loop_1 # j < n - i - 1
			# if A[j] > A[j+1]
			# address = base_addr + i(s6) * elem_size_in_bytes
			mul $t5, $s6, $s4
			add $t5, $t5, $s3 # address of A[j] = t5
			beq $s4, 1, lb_j
			beq $s4, 4, lw_j
		lb_j:
			lbu $t0, ($t5) # char at A[j] = t0 # DEPENDS ON ELE SIZE
			j cont_j
		lw_j:
			lw $t0, ($t5) # at A[j] = t0 # DEPENDS ON ELE SIZE
		cont_j:
			# address = base_addr + (i(s6)+1) * elem_size_in_bytes
			mul $t6, $t2, $s4
			add $t6, $t6, $s3 # address of A[j+1] = t6
			beq $s4, 1, lb_j1
			beq $s4, 4, lw_j1
		lb_j1:
			lbu $t1, ($t6) # char at A[j+1] = t1 # DEPENDS ON ELE SIZE
			j cont_j1
		lw_j1:
			lw $t1, ($t6) # at A[j+1] = t1 # DEPENDS ON ELE SIZE
		cont_j1:
			bgt $t0, $t1, swap_key
		cont_loop_2:
			addi $s6, $s6, 1 # inc col
			j for_loop_2
		cont_for_loop_1:
			addi $s5, $s5, 1
			j for_loop_1
	swap_key:
		# swap A[j] and A[j+1]
		move $t3, $t1 # save A[j+1] char (t1) in temp
		# temp = t3
		beq $s4, 1, sb_swap_j
		beq $s4, 4, sw_swap_j
	sb_swap_j:
		sb $t0, ($t6) # put A[j](t0) on A[j+1] pos(t6) # DEPENDS ON ELE SIZE
		sb $t3, ($t5) # put temp on A[j] pos(t5) # DEPENDS ON ELE SIZE
		j cont_swap_j
	sw_swap_j:
		sw $t0, ($t6) # put A[j](t0) on A[j+1] pos(t6) # DEPENDS ON ELE SIZE
		sw $t3, ($t5) # put temp on A[j] pos(t5) # DEPENDS ON ELE SIZE
	cont_swap_j:
		# swap the cols, j with j+1
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		move $a3, $s6 # col1 = j
		# addi $sp, $sp, 40 # at 0($sp)
		# move $sp, $t2 # col2 = j+1
		addi $sp, $sp, -4
		sw $t2, 0($sp)
		jal swap_matrix_columns
		addi $sp, $sp, 4
		# addi $sp, $sp, -40
		j cont_loop_2
	exit_for_loop_1:
		# fix the stack
		lw $ra, 0($sp)
		lw $s0, 4($sp) # s0 = matrix arr 
		lw $s1, 8($sp) # s1 = num_rows
		lw $s2, 12($sp) # s2 = num_cols
		lw $s3, 16($sp) # s3 = key addr
		lw $s4, 20($sp) # s4 = elem_size
		lw $s5, 24($sp) # s5 = i
		lw $s6, 28($sp) # s6 = j
		lw $s7, 32($sp) # s7 = n (length)
		addi $sp, $sp, 36
		jr $ra

# Part VI
transpose:
	li $v0, -200
	li $v1, -200
	# error cases
	ble $a2, 0, transp_error
	ble $a3, 0, transp_error
	# a0 = origin matrix
	# a1 = dest matrix
	li $t0, 0 # t0 = i
	li $t1, 0 # t1 = j
	# for loop for i
	for_loop_i:
		li $t1, 0
		beq $t0, $a2, exit_loop_i
		# for loop for j	
		for_loop_j:
			beq $t1, $a3, exit_loop_j
			# read char from src[i][j] = t3
			# address = base_addr + elem_size * (i * num_cols + j)
			# ROW MAJOR ORDER
			li $t4, 0
			mul $t4, $t0, $a3
			add $t4, $t4, $t1
			# mul $t4, $t4, 1 # elem_size = 1 because chars
			add $t4, $t4, $a0 # src
			lbu $t3, ($t4) # t3 = char at src[i][j]
			# store that char (t3) into dest[j][i] position
			# COL MAJOR ORDER
			li $t5, 0
			mul $t5, $t1, $a2 # (j * num_rows + i)
			add $t5, $t5, $t0
			# mul $t5, $t5, 1
			add $t5, $t5, $a1 # dest, base_add + t5
			sb $t3, ($t5) # t5 = dest pos
			addi $t1, $t1, 1 # inc col
			j for_loop_j
	exit_loop_j:
		addi $t0, $t0, 1 # inc row
		j for_loop_i
exit_loop_i:
	li $v0, 0 # success
	jr $ra
transp_error:
	li $v0, -1
	jr $ra

# Part VII
encrypt:
	li $v0, -200
	li $v1, -200
	# STACK
	addi $sp, $sp, -36
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	move $s0, $a0 # grid 2D[][] char
	move $s1, $a1 # plaintext String
	move $s2, $a2 # keyword String
	move $s3, $a3 # ciphertext [] char
	li $s4, 0 # heap-ciphertext-array
	li $s5, 0 # keyword len
	li $s6, 0 # heap-ca len or num bytes
	li $s7, 0 # rows for heap
	li $t0, 0
	li $t1, 0
	move $t2, $a2
	keyword_len: # s5
		lbu $t1, ($t2)
		beq $t1, 0, end_key_len
		addi $t2, $t2, 1
		addi $s5, $s5, 1
		j keyword_len
	end_key_len:
		# calculate plaintext length
		li $t0, 0
		li $t1, 0
		li $t2, 0
		li $t3, 0
		move $t2, $s1
	pt_len: # t0 = plaintext len
		lbu $t1, ($t2)
		beq $t1, 0, end_pt_len
		addi $t2, $t2, 1
		addi $t0, $t0, 1
		j pt_len
	end_pt_len:
		# num bytes for the heap
		# (plaintext_len * 2) + (keyword len -[(plaintext_len * 2) % keyword len]) = t1
		li $t7, 0
		li $t2, 2
		mul $t1, $t0, $t2 # t1 = (pt_len*2)
		div $t1, $s5
		mfhi $t3 # remainder
		beqz $t3, ok_byte_size # plaintext_len * 2 is the size if t3 = 0
		# if mod has a number, calculate
		sub $t7, $s5, $t3 # t7 = what to add to size
		add $s6, $t1, $t7
		j make_heap_cipher
	ok_byte_size:
		addi $s6, $t1, 0
	make_heap_cipher:
		# make heap
		addi $a0, $s6, 0
		li $v0, 9
		syscall
		# v0 = address of new mem buffer = s4
		move $s4, $v0 # s4 has space
		# filling the space with '*'
		li $t3, 0
		move $t3, $s4
		li $t5, '*'
		li $t2, 0 # counter
	fill_ast_arr:
		# lb $t4, ($t3) # chars of s4
		# beqz $t4, end_fill
		# sb $t5, ($t3)
		# addi $t3, $t3, 1
		beq $t2, $s6, end_fill
		sb $t5, ($t3)
		addi $t2, $t2, 1
		addi $t3, $t3, 1
		j fill_ast_arr
	end_fill:
		div $s6, $s5
		mflo $t8 # lo = quotient
		move $s7, $t8 # heap num rows (heap byte len / keyword len)
		# use heap-ca as a2 for map_plaintext
		move $a0, $s0 # a0 = grid [][]
		move $a1, $s1 # a1 = plaintext
		move $a2, $s4 # a2 = buffer = heap-ca (answer stored here)
		jal map_plaintext
		# sort heap-ca
		move $a0, $s4 # a0 = matrix (sorted)
		move $a1, $s7 # a1 = num_rows 
		move $a2, $s5 # a2 = num_cols (keyword length)
		move $a3, $s2 # a3 = key
		addi $sp, $sp, -4
		li $t6, 1
		sw $t6, 0($sp) # 0($sp) = elem_size = 1
		jal key_sort_matrix
		addi $sp, $sp, 4
		# transpose heap-ca
		move $a0, $s4 # a0 = matrix read in
		move $a1, $s3 # a1 = matrix dest
		move $a2, $s7 # a1 = num_rows (heap byte len / keyword len)
		move $a3, $s5 # a2 = num_cols (keyword length)
		jal transpose
		# ciphertext (s3)
		# need to null term ciphertext String
		li $t9, 0
		addu $t9, $s3, $s6
		sb $0, ($t9)	
		# restore the stack
		# STACK
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		lw $s7, 32($sp)
		addi $sp, $sp, 36
		jr $ra

# Part VIII
lookup_char:
	li $v0, -200
	li $v1, -200
	li $t0, -1 # t0 = row_index
	li $t1, -1 # t1 = col_index
	# check index1 first
	beq $a1, 'A', index1_0 # if a1 = A, then 0
	beq $a1, 'D', index1_1
	beq $a1, 'F', index1_2
	beq $a1, 'G', index1_3
	beq $a1, 'V', index1_4
	beq $a1, 'X', index1_5
	# error cases
	beq $t0, -1, lookup_error
	index1_0:
		li $t0, 0
		j check_index2_num
	index1_1:
		li $t0, 1
		j check_index2_num
	index1_2:
		li $t0, 2
		j check_index2_num
	index1_3:
		li $t0, 3
		j check_index2_num
	index1_4:
		li $t0, 4
		j check_index2_num
	index1_5:
		li $t0, 5
		j check_index2_num
	check_index2_num: # check index2
	beq $a2, 'A', index2_0 # if a1 = 0, then A
	beq $a2, 'D', index2_1
	beq $a2, 'F', index2_2
	beq $a2, 'G', index2_3
	beq $a2, 'V', index2_4
	beq $a2, 'X', index2_5
	# error cases
	beq $t1, -1, lookup_error
	index2_0:
		li $t1, 0
		j exit_coords_num
	index2_1:
		li $t1, 1
		j exit_coords_num
	index2_2:
		li $t1, 2
		j exit_coords_num
	index2_3:
		li $t1, 3
		j exit_coords_num
	index2_4:
		li $t1, 4
		j exit_coords_num
	index2_5:
		li $t1, 5
		j exit_coords_num
exit_coords_num:
	# t0 = i, t1 = j	
	li $t2, 0 
	li $t3, 0
	li $t4, 6
	li $t5, 1
	# addr = base_addr + elem_size_in_bytes * (i*num_cols+j)
	mul $t2, $t0, $t4
	add $t2, $t2, $t1 # t2 = (i*num_cols+j)
	mul $t2, $t2, $t5
	add $t2, $t2, $a0
	lbu $v1, ($t2)
	j lookup_success
lookup_error:
	li $v0, -1
	jr $ra
lookup_success:
	li $v0, 0
	jr $ra

# Part IX
string_sort:
	li $v0, -200
	li $v1, -200
	# calculate the string length
	li $t0, 0 # string len counter
	li $t1, 0
	move $t1, $a0
	string_len:
		lbu $t2, ($t1)
		beq $t2, 0, end_string_len
		addi $t0, $t0, 1
		addi $t1, $t1, 1
		j string_len
	end_string_len: # t0 = string len
		li $t1, 0 # i
		li $t2, 0 # j
		li $t4, 0 # A[j} addr
		li $t5, 0 # A[j+1] addr
		li $t6, 0 # A[j] char
		li $t7, 0 # A[j+1] char
		b_sort_loop_1: # t1 = i
			beq $t1, $t0, end_b_loop_1
			# n - i -1 = t3
			li $t3, 0
			sub $t3, $t0, $t1
			addi $t3, $t3, -1
			b_sort_loop_2: # t2 = j
				beq $t2, $t3, b_cont_sort_loop_1
				# address = base_addr + i*elem_size_in_bytes (1 cause char)
				# base_addr + i(t2)
				add $t4, $a0, $t2 # A[j] addr = t4
				# base_addr + i+1(t2+1)
				add $t5, $a0, $t2 
				addi $t5, $t5, 1 # A[j+1] addr = t5
				# if A[j]char > A[j+1]char
				lbu $t6, ($t4) # A[j] char
				lbu $t7, ($t5) # A[j+1] char
				bgt $t6, $t7, swap_sort_string # swap A[j] and A[j+1]
			cont_sort_string:
				addi $t2, $t2, 1
				j b_sort_loop_2
		b_cont_sort_loop_1:
			addi $t1, $t1, 1
			li $t2, 0 # j = 0
			j b_sort_loop_1
	swap_sort_string:
		# put A[j] char into A[j+1] pos
		sb $t6, ($t5)
		# put A[j+1] char into A[j] pos
		sb $t7, ($t4)
		j cont_sort_string
	end_b_loop_1:	
		jr $ra

# Part X
decrypt:
	li $v0, -200
	li $v1, -200
	# STACK
	addi $sp, $sp, -36
	sw $ra, 0($sp)
	sw $s0, 4($sp) # adfgvx_grid char[][]
	sw $s1, 8($sp) # ciphertext String
	sw $s2, 12($sp) # keyword String
	sw $s3, 16($sp) # plaintext String
	sw $s4, 20($sp) # heap_keyword
	sw $s5, 24($sp) # heap_keyword_indicides
	sw $s6, 28($sp) # i 
	# heap_ciphertext_array
	sw $s7, 32($sp) # keyword length
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	li $s4, 0
	li $s5, 0
	li $s6, 0
	li $s7, 0
	li $t0, 0 # keyword length
	li $t1, 0 # keyword addr
	move $t1, $s2
	li $t2, 0
	li $t3, 0
	li $t4, 0
	# keyword length
	keyword_len_decrypt:
		lbu $t3, ($t1)
		beq $t3, 0, end_kw_len
		addi $t0, $t0, 1
		addi $t1, $t1, 1
		j keyword_len_decrypt
	end_kw_len:
		addi $s7, $t0, 0 # s7 = keyword len
		# make heap, store copy of keyword = heap_keyword
		addi $a0, $s7, 0
		li $v0, 9
		syscall
		move $s4, $v0 # heap_keyword = s4
		
		# copy keyword onto heap_keyword
		li $t0, 0
		move $t0, $s2 # keyword addr = t0
		li $t1, 0
		li $t2, 0
		move $t2, $s4
		loop_heap_copy_keyword:
			lbu $t1, ($t0)
			beq $t1, 0, end_copy_key
			sb $t1, ($t2) # store onto the heap
			addi $t2, $t2, 1
			addi $t0, $t0, 1
			j loop_heap_copy_keyword
	end_copy_key:
		# sort heap_keyword by calling string_sort
		move $a0, $s4 # a0 = string address
		jal string_sort
		
		# heap_keyword_indicies
		# word is 4 bytes, it consists of words
		li $t0, 4
		li $t1, 0
		# keyword length * 4
		mul $t1, $s7, $t0 # keyword_len * 4
		addi $a0, $t1, 0 # a0 = t1
		li $v0, 9
		syscall
		move $s5, $v0 # heap_keyword_indicies = s5
		li $t2, 0
		# for loop for heap_keyword_indicies
	for_loop_kw_indicies: # s6 = i
		beq $s6, $s7, end_loop_kw_indicies # i < keyword len
		# addr = base_addr + i * elem_size_in_bytes (char so 1)
		# heap_kw_i[i] = keyword.index_of(heap_keyword[i])
		add $t5, $s4, $s6 # t5 = heap_kwyword[i] addr
		lbu $t4, ($t5) # heap_keyword[i] = t4 (char)
		# keyword.index_of(heap_keyword[i]) = t2
		move $a0, $t4 # a0 = char (heap_keyword[i] = t4)
		move $a1, $s2 # a1 = string (keyword)	
		jal index_of
		
		move $t2, $v0 # t2 = v0, index
		# heap_kw_i[i] addr = t3
		# addr = base_addr + i * elem_size_in_bytes(4)
		li $t0, 4
		mul $t3, $s6, $t0
		add $t3, $s5, $t3
		# t3 = t2, the address at t3 will contain t2
		sw $t2, ($t3)
		addi $s6, $s6, 1
		j for_loop_kw_indicies
	end_loop_kw_indicies:
		# need to save ciphertext len on the stack because want s register
		# don't need s4, heap_keyword
		addi $sp, $sp, -4
		sw $s4, 0($sp)
		li $s4, 0
	
		# transpose the ciphertext array
		# row = keyword len
		li $t7, 0
		li $t8, 0 # address inc
		move $t8, $s1
		li $t6, 0 # char
	loop_cipherlen: # cipherlen = s4
		lbu $t6, ($t8)
		beq $t6, 0, calc_cipherlen
		addi $s4, $s4, 1
		addi $t8, $t8, 1
		j loop_cipherlen
	calc_cipherlen:	
		# REUSING THE s6 REGISTER
		addi $sp, $sp, -4
		sw $s6, 0($sp)
		li $s6, 0
		# make heap
		addi $a0 $s4, 0 # make heap_ciphertext_array, size = s4
		li $v0, 9
		syscall
		# stored into v0
		# making heap_ciphertext_array
		move $s6, $v0
		
		move $a0, $s1 # a0 = 2D[][] array read from (addr) = s1 ciphertext
		move $a1, $s6 # a1 = 2D[][] dest = heap_ciphertext_array [S6]
		move $a2, $s7 # a2 = num_rows = s7
		# num_cols
		# col = cipherlen/keyword len = t6
		div $s4, $s7
		mflo $t6
		move $a3, $t6 # a3 = num_cols = t6
		jal transpose
		# num_cols
		# col = cipherlen/keyword len = t6
		div $s4, $s7
		mflo $t6	
		# call key_sort_matrix
		move $a0, $s6 # a0 = heap_ciphertext_array (array to be sorted)
		move $a1, $t6 # a1 = num_rows = t6 (from being transposed)
		move $a2, $s7 # a2 = num_cols = s7
		move $a3, $s5 # a3 = heap_keyword_indicies (key, array of items being sorted)
		# sp = elem_size = 1
		addi $sp, $sp, -4
		li $t8, 4
		sw $t8, 0($sp) # 0($sp) = elem_size = 4, one element in the key (words)
		jal key_sort_matrix
		addi $sp, $sp, 4
		
		# put back stack for s4, don't need it anymore
		lw $s4, 0($sp)
		addi $sp, $sp, 4
		
		# write a loop that will iterate over heap_ciphertext_array, like 1D of characters
		# heap_ct_array address = s6
		li $t1, 0
		li $t2, 0
		li $t9, 0
		move $t9, $s3 # after last bit of addr = addr + len
	# loop should read out the ADFGVX as (DD, AX, AV, etc.) decode them using lookup_char
	loop_heap_ct_arr:
		lbu $t1, ($s6) # first char
		# also need to check for *, dont want to include extra
		beq $t1, 0, end_loop_heap_ct_arr
		li $t5, '*'
		beq $t1, $t5, end_loop_heap_ct_arr
	
		addi $s6, $s6, 1 # need to go to next after this
		lbu $t2, ($s6) # second char
		
		# lookup_char
		move $a0, $s0 # a0 = 2d[][] adfgvx_grid
		addi $a1, $t1, 0 # a1 = row_char
		addi $a2, $t2, 0 # a2 = col_char
		jal lookup_char
		# v1 = char from grid at those coordinates
		sb $v1, ($s3) # append each character to plaintext, need to be s register
		addi $s6, $s6, 1
		addi $s3, $s3, 1
		j loop_heap_ct_arr
	end_loop_heap_ct_arr:
		# add null-terminator to end of plaintext
		# plaintext (s3)
		sb $0, ($s3)	
	
		# put back the s6
		lw $s6, 0($sp)
		addi $sp, $sp, 4
		
		# restore the stack
		# STACK
		lw $ra, 0($sp)
		lw $s0, 4($sp) # adfgvx_grid char[][]
		lw $s1, 8($sp) # ciphertext String
		lw $s2, 12($sp) # keyword String
		lw $s3, 16($sp) # plaintext String
		lw $s4, 20($sp) # heap_keyword
		lw $s5, 24($sp) # heap_keyword_indicides
		lw $s6, 28($sp) # i 
		# heap_ciphertext_array
		lw $s7, 32($sp) # keyword length
		addi $sp, $sp, 36
		
		jr $ra
	
index_of: # a0 = char,  a1 = string(addr) to take in
	# returns index if found in $v0
	# will not pass bad arguments for this method/branch
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
		beqz $t2, exit_loop_index_of # if it hits a null 
		beq $t2, $a0, index_found
		addi $t1, $t1, 1
		addi $t0, $t0, 1
		j loop_index_of
	exit_loop_index_of: 
		jr $ra
	index_found:	
		move $v0, $t0	
		jr $ra

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################
