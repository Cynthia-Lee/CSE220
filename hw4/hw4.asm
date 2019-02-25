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
init_game:
	li $v0, -200
	li $v1, -200
	# STACK
	addi $sp, $sp, -32
	sw $ra, 0($sp)
	sw $s0, 4($sp) # map_filename
	sw $s1, 8($sp) # map ptr (addr)
	sw $s2, 12($sp) # player ptr (addr)
	sw $s3, 16($sp) # file descriptor
	sw $s4, 20($sp) # row num
	sw $s5, 24($sp) # col num
	sw $s6, 28($sp) # health num
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	
	# three flag values: 0 = read only, 1 = write only, 9 = write only with create and append
	# OPEN FILE, v0 = 13
	li $v0, 13 # system call for open file
	move $a0, $s0 # a0 = address of null terminated file-name string (map_filename)
	li $a1, 0 # a1 = flags (0 for read)
	li $a2, 0 # a2 = mode (0, mode is ignored)
	syscall
	
	bltz $v0, file_open_error
	
	move $s3, $v0 # save the file descriptor
	# method v0 = 0 when file successfully open, -1 if error
	# if v0 or s3 = -1
	
	# READ FILE, v0 = 14
	# FIRST CHAR (number)
	li $v0, 14 
	move $a0, $s3 # a0 = file descriptor
	move $a1, $s1 # a1 = address of input buffer
	li $a2, 1 # a2 = maximum # characters to read
	syscall
	# first char, line 1
	lbu $t0, ($s1) # char
	li $t1, '0'
	sub $s4, $t0, $t1 # char - '0'
	li $t1, 10
	mul $s4, $s4, $t1 # ten's place * 10
	# SECOND CHAR (number)
	li $v0, 14 
	move $a0, $s3 # a0 = file descriptor
	move $a1, $s1 # a1 = address of input buffer
	li $a2, 1 # a2 = maximum # characters to read
	syscall
	# second char, line 1
	lbu $t0, ($s1) # char
	li $t1, '0'
	li $t2, 0
	sub $t2, $t0, $t1 # char - '0'
	add $s4, $s4, $t2 # one's place + ten's
	# row number is stored
	# THIRD CHAR (new line char)
	li $v0, 14 
	move $a0, $s3 # a0 = file descriptor
	move $a1, $s1 # a1 = address of input buffer
	li $a2, 1 # a2 = maximum # characters to read
	syscall
	# ignored the new line
	# FOURTH CHAR (number)
	li $v0, 14 
	move $a0, $s3 # a0 = file descriptor
	move $a1, $s1 # a1 = address of input buffer
	li $a2, 1 # a2 = maximum # characters to read
	syscall
	# fourth char, line 2
	lbu $t0, ($s1) # char
	li $t1, '0'
	sub $s5, $t0, $t1 # char - '0'
	li $t1, 10
	mul $s5, $s5, $t1
	# FIFTH CHAR (number)
	li $v0, 14 
	move $a0, $s3 # a0 = file descriptor
	move $a1, $s1 # a1 = address of input buffer
	li $a2, 1 # a2 = maximum # characters to read
	syscall
	# fifth char, line 2
	lbu $t0, ($s1) # char
	li $t1, '0'
	li $t2, 0
	sub $t2, $t0, $t1 # char - '0'
	add $s5, $s5, $t2 # one's place + ten's
	# col number is stored
	
	# map_ptr is s1
	# map_ptr[0] = # rows
	sb $s4, ($s1)
	addi $s1, $s1, 1
	# map_ptr[1] = # cols
	sb $s5, ($s1)
	addi $s1, $s1, 1
	
	# READING THE MAP FROM THE FILE
	# one char at at time
	li $t9, 0 # t9 = counter
	# exit when counter > row * col + row
	li $t8, 0
	mul $t8, $s4, $s5
	add $t8, $t8, $s4
	read_map_loop: 
		# row * col + row = reading the map from the file including the new lines
		# exit when counter > row * col + row
		bgt $t9, $t8, end_read_map
		li $v0, 14 
		move $a0, $s3 # a0 = file descriptor
		move $a1, $s1 # a1 = address of input buffer
		li $a2, 1 # a2 = maximum # characters to read
		syscall
		# char that is read is in t0
		lbu $t0, ($s1) # char
		# don't save the new lines
		beq $t0, 10, skip_saving_map
		beq $t0, '@', player_pos # check if the char is '@' (check for player)
	cont_read_map:	
		# convert char to have hidden flag in hex
		# s7 as binary, t0
		li $t2, 0
		ori $t2, $t0, 0x80 #(10000000) # with hidden flag
		# map bytes #2 through #num_rows*num_cols+1
		# store char in the map ptr
		sb $t2, ($s1)
	
		addi $s1, $s1, 1 # inc map ptr
	skip_saving_map:
		addi $t9, $t9, 1
		j read_map_loop
	
	player_pos:
		# player_ptr = s2
		li $t2, 0
		li $t5, 0
		# s5 = total col
		addi $t5, $s5, 1 # col + 1
		# t9 = counter
		
		# CURRENT ROW # current row = counter / (total col + 1) (index)
		divu $t9, $t5 # cont / col+1(t5)
		mflo $t6 # current row = t6 # quotient, drop decimals
		# store row into player_ptr byte #0
		sb $t6, 0($s2)
		
		# CURRENT COL # current col = [counter % (total col + 1)] -1  (index)
		# t5 = col + 1
		# divu $t9, $t5 # cont / col+1 (t5)
		mfhi $t7 # current col = t7 # mod, remainder
		addi $t7, $t7, -1 # t7 - 1
		# store row into player_ptr byte #1
		sb $t7, 1($s2)
		j cont_read_map
	
	end_read_map:
		# AFTER READING MAP, PLAYER HEALTH
		# reading the last two chars and convert to number
		# HEALTH FIRST CHAR (number)
		li $v0, 14 
		move $a0, $s3 # a0 = file descriptor
		move $a1, $s1 # a1 = address of input buffer
		li $a2, 1 # a2 = maximum # characters to read
		syscall
		# first char, health
		li $t1, '0'
		li $t2, 0
		lbu $t0, ($s1) # char
		sub $t2, $t0, $t1 # char - '0'
		li $t1, 10
		mul $t2, $t2, $t1 # ten's place * 10
		# HEALTH SECOND CHAR (number)
		li $v0, 14 
		move $a0, $s3 # a0 = file descriptor
		move $a1, $s1 # a1 = address of input buffer
		li $a2, 1 # a2 = maximum # characters to read
		syscall
		# second char, health
		li $t1, '0'
		li $t3, 0
		lbu $t0, ($s1) # char
		sub $t3, $t0, $t1 # char - '0'
		add $t3, $t3, $t2
		# player health num = t3
		sb $t3, 2($s2) # store health to player_ptr

		# CLOSE FILE, v0 = 16
		li $v0, 16
		move $a0, $s3
		syscall	
		
		li $t0, 0
		sb $t0, 3($s2) #store coins to player_ptr
		li $v0, 0 # method will have v0 = 0, success
done_init_game:
	# FIX STACK
	lw $ra, 0($sp)
	lw $s0, 4($sp) # map_filename
	lw $s1, 8($sp) # map ptr (addr)
	lw $s2, 12($sp) # player ptr (addr)
	lw $s3, 16($sp) # file descriptor
	lw $s4, 20($sp) # row num
	lw $s5, 24($sp) # col num
	lw $s6, 28($sp) # health num
	lw $s7, 32($sp) # input buffer
	addi $sp, $sp, 36
	jr $ra
file_open_error:
	li $v0, -1
	j done_init_game


# Part II
is_valid_cell:
	li $v0, -200
	li $v1, -200
	li $v0, 0 # valid
	# a0 = map_ptr addr
	# a1 = int row
	# a2 = int col
	li $t0, 0 # map_ptr.num_rows
	lbu $t0, 0($a0)
	li $t1, 0 # map_ptr.num_cols
	lbu $t1, 1($a0)
	bltz $a1, not_valid_cell
	bge $a1, $t0, not_valid_cell
	bltz $a2, not_valid_cell
	bge $a2, $t1, not_valid_cell
	j exit_valid_cell
not_valid_cell:
	li $v0, -1
exit_valid_cell:
	jr $ra


# Part III
get_cell:
	li $v0, -200
	li $v1, -200
	# STACK
	# caller method
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp) # map_ptr
	sw $s1, 8($sp) # int row
	sw $s2, 12($sp) # int col
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	# check error cases, a0, a1, a2
	jal is_valid_cell
	beq $v0, -1, exit_get_cell
	
	# valid so v0 = map_ptr.cells[row][col]
	# 2D array, row major order
	# address = base_addr + elem_size_in_bytes * (i * num_col + j)
	# i = row = s1
	# j = col = s2
	li $t1, 0
	lbu $t1, 1($s0) # total num_col = t1
	# (i * num_col + j) = t0
	li $t0, 0 
	mul $t0, $s1, $t1 # (i * num_col) = t0
	add $t0, $t0, $s2 # (i * num_col + j) = t0
	
	addi $s0, $s0, 2 # 2($s0)
	add $t0, $t0, $s0 # base addr + t0
	# elem_size_in_bytes = 1
	lbu $v0, ($t0)
exit_get_cell:
	# FIX STACK
	lw $ra, 0($sp)
	lw $s0, 4($sp) # map_ptr
	lw $s1, 8($sp) # int row
	lw $s2, 12($sp) # int col
	addi $sp, $sp, 16
	jr $ra


# Part IV
set_cell:
	li $v0, -200
	li $v1, -200
	# STACK
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp) # map_ptr addr
	sw $s1, 8($sp) # row
	sw $s2, 12($sp) # col
	sw $s3, 16($sp) # ch
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	# error cases, a0, a1, a2
	jal is_valid_cell
	beq $v0, -1, exit_set_cell
	
	# changes byte stored at map pos (row,col) to ch
	# map_ptr.cells[row][col] = ch

	# 2D array, row major order
	# address = base_addr + elem_size_in_bytes * (i * num_col + j)
	# i = row = s1
	# j = col = s2
	li $t1, 0
	lbu $t1, 1($s0) # total num_col = t1
	# (i * num_col + j) = t0
	li $t0, 0 
	mul $t0, $s1, $t1 # (i * num_col) = t0
	add $t0, $t0, $s2 # (i * num_col + j) = t0
	
	addi $s0, $s0, 2 # 2($s0)
	add $t0, $t0, $s0 # base addr + t0
	# elem_size_in_bytes = 1
	
	# t0 = address
	sb $s3, ($t0)

	li $v0, 0 # success
exit_set_cell:	
	# FIX STACK
	lw $ra, 0($sp)
	lw $s0, 4($sp) # map_ptr addr
	lw $s1, 8($sp) # row
	lw $s2, 12($sp) # col
	lw $s3, 16($sp) # ch
	addi $sp, $sp, 20
	jr $ra


# Part V
reveal_area:
	li $v0, -200
	li $v1, -200
	# STACK
	addi $sp, $sp, -24
	sw $ra, 0($sp)
	sw $s0, 4($sp) # map_ptr addr
	sw $s1, 8($sp) # row 
	sw $s2, 12($sp) # col
	sw $s3, 16($sp) # row counter
	sw $s4, 20($sp) # col counter
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	li $s3, 0
	li $s4, 0
	addi $s3, $s1, -1 # starting position, row = r-1 # s3 = row count
	addi $s4, $s2, -1 # starting position, col = c-1 # s4 = col count
	addi $s1, $s1, 1 # ending position, row = r+1
	addi $s2, $s2, 1 # ending position, col = c+1
	reveal_loop:
		# row loop
		bgt $s3, $s1, exit_reveal_loop
		# col loop
		rev_loop_col: # s3 = current row, s4 = current col
			bgt $s4, $s2, cont_rev_loop
			# check if cell at [row][col] is valid
			move $a0, $s0 # a0 = map_ptr
			move $a1, $s3 # a1 = row
			move $a2, $s4 # a2 = col
			jal is_valid_cell
			beq $v0, -1, next_reveal # if valid, reveal. if not, skip
			# reveal valid
			# get_cell (returns byte inside that cell)
			move $a0, $s0 # a0 = map_ptr
			move $a1, $s3 # a1 = row
			move $a2, $s4 # a2 = col
			jal get_cell
			li $t9, 0
			move $t9, $v0 # v0 = byte = t9
			# bitwise, change bit 7 of the cell to 0
			andi $t9, $t9, 0x7F #(01111111)
			# set_cell (changes byte at that position to the char)
			move $a0, $s0 # a0 = map_ptr
			move $a1, $s3 # a1 = row
			move $a2, $s4 # a2 = col
			move $a3, $t9 # a3 = ch
			jal set_cell
			
		next_reveal:	
			addi $s4, $s4, 1
			j rev_loop_col
	cont_rev_loop:
		li $t2, 0
		addi $t2, $s2, -2 # original start position = ending position col - 2
		move $s4, $t2 # reset the col counter to original col
		addi $s3, $s3, 1 # inc row
		j reveal_loop
	
exit_reveal_loop:
	# FIX STACK
	lw $ra, 0($sp)
	lw $s0, 4($sp) # map_ptr addr
	lw $s1, 8($sp) # row 
	lw $s2, 12($sp) # col
	lw $s3, 16($sp) # row counter
	lw $s4, 20($sp) # col counter
	addi $sp, $sp, 24	
	jr $ra


# Part VI
get_attack_target:
	li $v0, -200
	li $v1, -200
	# a0 = map_ptr
	# a1 = player_ptr
	# a2 = char direction
	# STACK
	addi $sp, $sp, -24
	sw $ra, 0($sp)
	sw $s0, 4($sp) # map_ptr
	sw $s1, 8($sp) # player_ptr
	sw $s2, 12($sp) # char direction
	sw $s3, 16($sp) # row (index) adj
	sw $s4, 20($sp) # col (index) adj
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	li $s3, 0
	li $s4, 0
	# calculate row and col of target
	# s3 = row
	# s4 = col
	lb $s3, 0($s1)
	lb $s4, 1($s1)
	# READ CHAR DIRECTION (check the direction char)
	beq $s2, 'U', U_direct
	beq $s2, 'D', D_direct
	beq $s2, 'L', L_direct
	beq $s2, 'R', R_direct
	# if none of thos char, then invalid
	error_get_attack_target:
		li $v0, -1
		j exit_get_att_targ

	U_direct:
		addi $s3, $s3, -1 # row - 1
		# col
		j cont_get_att_targ
	
	D_direct:
		addi $s3, $s3, 1 # row + 1
		# col
		j cont_get_att_targ
	
	L_direct:
		# row
		addi $s4, $s4, -1 # col - 1
		j cont_get_att_targ
	
	R_direct:
		# row
		addi $s4, $s4, 1 # col + 1
		j cont_get_att_targ
	
	cont_get_att_targ:
		# check if row and col is valid
		# is_valid_cell
		move $a0, $s0 # a0 = map_ptr
		move $a1, $s3 # a1 = row
		move $a2, $s4 # a2 = col
		jal is_valid_cell
		beq $v0, -1, error_get_attack_target
		# otherwise valid index
		# GET CELL
		move $a0, $s0 # a0 = map_ptr
		move $a1, $s3 # a1 = row
		move $a2, $s4 # a2 = col
		jal get_cell
		li $t0, 0
		move $t0, $v0 # t0 has char (byte)
		# check if char in cell is 'm','B', or'/'
		beq $t0, 'm', valid_att_char
		beq $t0, 'B', valid_att_char
		beq $t0, '/', valid_att_char
		# not valid att char
		j error_get_attack_target
		
		valid_att_char:
			# v0 = char
exit_get_att_targ:
	# FIX STACK
	lw $ra, 0($sp)
	lw $s0, 4($sp) # map_ptr
	lw $s1, 8($sp) # player_ptr
	lw $s2, 12($sp) # char direction
	lw $s3, 16($sp) # row (index) adj
	lw $s4, 20($sp) # col (index) adj
	addi $sp, $sp, 24
	jr $ra


# Part VII
complete_attack:
	li $v0, -200
	li $v1, -200
	# a0 = map_ptr
	# a1 = player_ptr
	# a2 = target_row
	# a3 = target_col
	# STACK
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp) # map_ptr
	sw $s1, 8($sp) # player_ptr
	sw $s2, 12($sp) # target_row
	sw $s3, 16($sp) # target_col
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	# call get_cell to get the target value
	move $a0, $s0 # a0 = map_ptr
	move $a1, $s2 # a1 = row
	move $a2, $s3 # a2 = col
	jal get_cell
	# v0 has char
	beq $v0, 'm', m_complete_att
	beq $v0, 'B', B_complete_att
	beq $v0, '/', d_complete_att
	m_complete_att:
		# player health addr = 2($s1)
		li $t0, 0
		lb $t0, 2($s1) # t0 = player health num
		addi $t0, $t0, -1
		sb $t0, 2($s1) # player health -1
		# m replaced with $
		# set cell
		move $a0, $s0 # a0 = map_ptr
		move $a1, $s2 # a1 = row
		move $a2, $s3 # a2 = col
		li $a3, '$' # a3 = char
		jal set_cell
		# v0 = 0, success
		j exit_complete_attack
	B_complete_att:
		# player health addr = 2($s1)
		li $t0, 0
		lb $t0, 2($s1) # t0 = player health num
		addi $t0, $t0, -2
		sb $t0, 2($s1) # player health -2
		# B replaced with *
		# set cell
		move $a0, $s0 # a0 = map_ptr
		move $a1, $s2 # a1 = row
		move $a2, $s3 # a2 = col
		li $a3, '*' # a3 = char
		jal set_cell
		# v0 = 0, success
		j exit_complete_attack
	d_complete_att:
		# / replaced with .
		# set cell
		move $a0, $s0 # a0 = map_ptr
		move $a1, $s2 # a1 = row
		move $a2, $s3 # a2 = col
		li $a3, '.' # a3 = char
		jal set_cell
		# v0 = 0, success
		j exit_complete_attack

exit_complete_attack:
	# after player attack monster
	# CHECK PLAYER'S HEALTH IF DEAD
	# if player health <= 0, replace @ with X
	
	# player health addr = 2($s1)
	li $t0, 0
	lb $t0, 2($s1) # t0 = player health num
	blez $t0, player_died
	j exit_ca
	player_died:
		# replace '@' with X
		# get player position
		li $t1, 0
		li $t2, 0
		sb $t1, 0($s1) # player's row pos
		sb $t2, 1($s1) # player's col pos
		# set cell
		move $a0, $s0 # a0 = map_ptr
		move $a1, $t1 # a1 = row
		move $a2, $t2 # a2 = col
		li $a3, 'X' # a3 = ch
		j exit_ca
exit_ca:
	# FIX STACK
	lw $ra, 0($sp)
	lw $s0, 4($sp) # map_ptr
	lw $s1, 8($sp) # player_ptr
	lw $s2, 12($sp) # target_row
	lw $s3, 16($sp) # target_col
	addi $sp, $sp, 20
	jr $ra


# Part VIII
monster_attacks:
	li $v0, -200
	li $v1, -200
	# a0 = map_ptr
	# a1 = player_ptr
	# STACK
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp) # map_ptr
	sw $s1, 8($sp) # player_ptr
	sw $s2, 12($sp) # result, total # damage from monster attacks
	move $s0, $a0
	move $s1, $a1
	li $s2, 0
	
	# BOT POSITION (R-1, C)
	li $t0, 0 # row
	li $t1, 0 # col
	lbu $t0, 0($s1)
	addi $t0, $t0, -1 # R-1
	lbu $t1, 1($s1)
	# get cell
	move $a0, $s0 # a0 = map_ptr
	move $a1, $t0 # a1 = row
	move $a2, $t1 # a2 = col
	jal get_cell
	# check if m or B
	beq $v0, 'm', m_ma_bot
	beq $v0, 'B', B_ma_bot
	j up_pos_ma # if not m or B, check next pos
	m_ma_bot:
		addi $s2, $s2, 1
		j up_pos_ma
	B_ma_bot:
		addi $s2, $s2, 2
		j up_pos_ma
	
	up_pos_ma:
		# TOP POSITION, (R+1, C)
		li $t0, 0 # row
		li $t1, 0 # col
		lbu $t0, 0($s1)
		addi $t0, $t0, 1 # R+1
		lbu $t1, 1($s1)
		# get cell
		move $a0, $s0 # a0 = map_ptr
		move $a1, $t0 # a1 = row
		move $a2, $t1 # a2 = col
		jal get_cell
		# check if m or B
		beq $v0, 'm', m_ma_up
		beq $v0, 'B', B_ma_up
		j left_pos_ma # if not m or B, check next pos
		m_ma_up:
			addi $s2, $s2, 1
			j left_pos_ma
		B_ma_up:
			addi $s2, $s2, 2
			j left_pos_ma
	
	left_pos_ma:
		# LEFT POSITION, (R,C-1)
		li $t0, 0 # row
		li $t1, 0 # col
		lbu $t0, 0($s1)
		lbu $t1, 1($s1)
		addi $t1, $t1, -1 # C-1
		# get cell
		move $a0, $s0 # a0 = map_ptr
		move $a1, $t0 # a1 = row
		move $a2, $t1 # a2 = col
		jal get_cell
		# check if m or B
		beq $v0, 'm', m_ma_left
		beq $v0, 'B', B_ma_left
		j right_pos_ma # if not m or B, check next pos
		m_ma_left:
			addi $s2, $s2, 1
			j right_pos_ma
		B_ma_left:
			addi $s2, $s2, 2
			j right_pos_ma
	
	right_pos_ma:
		# RIGHT POSITION (R,C+1)
		li $t0, 0 # row
		li $t1, 0 # col
		lbu $t0, 0($s1)
		lbu $t1, 1($s1)
		addi $t1, $t1, 1 # C+1
		# get cell
		move $a0, $s0 # a0 = map_ptr
		move $a1, $t0 # a1 = row
		move $a2, $t1 # a2 = col
		jal get_cell
		# check if m or B
		beq $v0, 'm', m_ma_right
		beq $v0, 'B', B_ma_right
		j exit_ma # if not m or B, check next pos
		m_ma_right:
			addi $s2, $s2, 1
			j exit_ma
		B_ma_right:
			addi $s2, $s2, 2
			j exit_ma
exit_ma:	
	move $v0, $s2
	# FIX STACK
	lw $ra, 0($sp)
	lw $s0, 4($sp) # map_ptr
	lw $s1, 8($sp) # player_ptr
	lw $s2, 12($sp) # result, total # damage from monster attacks
	addi $sp, $sp, 16
	jr $ra


# Part IX
player_move:
	li $v0, -200
	li $v1, -200
	# STACK
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp) # a0 = map_ptr
	sw $s1, 8($sp) # a1 = player_ptr
	sw $s2, 12($sp) # a2 = target_row
	sw $s3, 16($sp) # a3 = target_col
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	# before attempting to move the player, call monster_attacks
	move $a0, $s0 # a0 = map_ptr
	move $a1, $s1 # a1 = player_ptr
	jal monster_attacks
	# v0 = number, subtract it from the player's health
	li $t0, 0
	# player's health at 2($s1)
	lb $t0, 2($s1)
	sub $t0, $t0, $v0 # t0 = t0-v0
	sb $t0, 2($s1)
	
	# possible outcomes of calling this function:
	# NEARBY MONSTERS KILLED THE PLAYER (player health <=0)
	blez $t0, move_player_killed
	# check what the targeted cell is
	# s2 = targ row, s3 = targ col
	# get cell
	move $a0, $s0 # a0 = map_ptr
	move $a1, $s2 # a1 = row
	move $a2, $s3 # a2 = col
	jal get_cell
	# v0 = byte/data inside the cell
	li $t9, 0
	move $t9, $v0
	
	## WILL CHANGE PLAYER WITH TARGET ##
	# for . $ * >
	# '@' at player's position replaced with '.'
	li $t1, 0 # player's row
	li $t2, 0 # player's col
	lbu $t1, 0($s1)
	lbu $t2, 1($s1)
	# set cell
	move $a0, $s0 # a0 = map_ptr
	move $a1, $t1 # a1 = row
	move $a2, $t2 # a2 = col
	li $a3, '.' # a3 = char
	jal set_cell
	
	# 'thing' at targeted cell replaced with '@'
	# s2 = targ row, s3 = targ col
	# set cell
	move $a0, $s0 # a0 = map_ptr
	move $a1, $s2 # a1 = row
	move $a2, $s3 # a2 = col
	li $a3, '@' # a3 = char
	jal set_cell
	
	# the Player's struct's position is updated accordingly
	# s2 = targ row, s3 = targ col
	sb $s2, 0($s1)
	sb $s3, 1($s1)
	
	# TARGETED CELL IS '.' 
	beq $t9, '.', move_player_floor
	# TARGETED CELL IS '$'
	beq $t9, '$', move_player_coin
	# TARGETED CELL IS '*'
	beq $t9, '*', move_player_gem
	# TARGED CELL IS '>'
	beq $t9, '>', move_player_dungeon_exit
	
	move_player_dungeon_exit:
		# '@' at the player's position in the game world is replaced with '.'
		# '>' at the targed cell in the game world is replaced with '@'
		# player struct's position is updated
		
		# return -1
		li $v0, -1
		j exit_player_move
	
	move_player_gem:
		# '@' at the player's position in the game world is replaced with '.'
		# '*' at the targeted cell in the game is replaced with '@'
		# player's struct position is updated
		
		# player's struct's coins inc by 5
		# player coins at 3($s1)
		li $t1, 0
		lbu $t1, 3($s1)
		addi $t1, $t1, 5
		sb $t1, 3($s1)
		# return 0
		li $v0, 0
		j exit_player_move
	
	move_player_coin:
		# '@' at player's position is replaced with '.'
		# '$' at the targeted cell is replaced with '@'
		# player struct's position is updated
		
		# player struct's coins inc by 1
		# player coins at 3($s1)
		li $t1, 0
		lbu $t1, 3($s1)
		addi $t1, $t1, 1
		sb $t1, 3($s1)
		# return 0
		li $v0, 0
		j exit_player_move
	
	move_player_floor:
		# '@' at player's position replaced with '.'
		# '.' at targeted cell replaced with '@'	
		# player struct position updated
		
		# return 0
		li $v0, 0
		j exit_player_move
	
	move_player_killed:
		# '@' at player's position is replaced with X
		li $t1, 0 # player's row
		li $t2, 0 # player's col
		lbu $t1, 0($s1)
		lbu $t2, 1($s1)
		# set cell
		move $a0, $s0 # a0 = map_ptr
		move $a1, $t1 # a1 = row
		move $a2, $t2 # a2 = col
		li $a3, 'X' # a3 = char
		jal set_cell # assume valid (can move here)
		# function returns 0
		li $v0, 0
		j exit_player_move
	
exit_player_move:
	# FIX STACK
	lw $ra, 0($sp)
	lw $s0, 4($sp) # a0 = map_ptr
	lw $s1, 8($sp) # a1 = player_ptr
	lw $s2, 12($sp) # a2 = target_row
	lw $s3, 16($sp) # a3 = target_col
	addi $sp, $sp, 20
	jr $ra


# Part X
player_turn:
	li $v0, -200
	li $v1, -200
	# a0 = map_ptr
	# a1 = player_ptr
	# a2 = char (direction: U,D,L,R)
	# STACK
	addi $sp, $sp, -24
	sw $ra, 0($sp)
	sw $s0, 4($sp) # map_ptr
	sw $s1, 8($sp) # player_ptr
	sw $s2, 12($sp) # char
	sw $s3, 16($sp) # row (target)
	sw $s4, 20($sp) # col (target)
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	li $s3, 0
	li $s4, 0
	# player row = 0($s1) = s3
	# player col = 1($s1) = s4
	lbu $s3, 0($s1)
	lbu $s4, 1($s1)
	
	# 1. check direction
	beq $s2, 'U', valid_dir_U
	beq $s2, 'D', valid_dir_D
	beq $s2, 'L', valid_dir_L
	beq $s2, 'R', valid_dir_R
	# if not, return -1
	li $v0, -1
	j exit_p_move_not_att

	valid_dir_U: # 'U' = (R-1,C)
		# row = R-1
		addi $s3, $s3, -1
		# col
		j cont_p_turn_2
	valid_dir_D: # 'D' = (R+1,C)
		# row = R-1
		addi $s3, $s3, 1
		# col
		j cont_p_turn_2
	valid_dir_L: # 'L' = (R,C-1)
		# row
		# col = C-1
		addi $s4, $s4, -1
		j cont_p_turn_2
	valid_dir_R: # 'R' = (R,C+1)
		# row
		# col = C+1
		addi $s4, $s4, 1
		j cont_p_turn_2
	
	cont_p_turn_2:
	# 2. check if the targeted cell is at a valid index, if not, return 0 (exit)
		# is_valid_cell
#		move $a0, $s0 # a0 = map_ptr
#		move $a1, $s3 # a1 = row
#		move $s2, $s4 # a2 = col
#		jal is_valid_cell
		# v0 = 0 = valid
		# v0 = -1 = not valid
#		beq $v0, -1, exit_p_turn
	
	# 3. call get_cell to check where the player is attempting to move or attack
		# get cell
		move $a0, $a0 # a0 = map_ptr
		move $a1, $s3 # a1 = row
		move $a2, $s4 # a2 = col
		jal get_cell
		# v0 = data/byte inside that cell
		# if target cell is '#', return 0, (exit)
		beq $v0, '#', exit_p_turn
	
	# 4. assuming the target is a valid index to move or attack, call get_attack_target
	# to see if the target cell is attackable
		# get_attack_target
		move $a0, $s0 # a0 = map_ptr
		move $a1, $s1 # a1 = player_ptr
		move $a2, $s2 # a2 = char direction
		jal get_attack_target
		# v0 = -1 if invalid
		# otherwise, v0 = character at targeted cell
		# if target cell is attackable, call complete_attack and return 0		
		bne $v0, -1, p_move_complete_att
		# else (v0 = -1, invalid)
		j p_move_not_att
		
		p_move_complete_att:
			# complete_attack
			move $a0, $s0 # a0 = map_ptr
			move $a1, $s1 # a1 = player_ptr
			move $a2, $s3 # a2 = row target
			move $a3, $s4 # a3 = col target
			jal complete_attack
			j exit_p_turn
			
		# otherwise, call player_move and return that fuction's return value as the return value of player_turn
		p_move_not_att:
			# player_move
			move $a0, $s0 # a0 = map_ptr
			move $a1, $s1 # a1 = player_ptr
			move $a2, $s3 # a2 = row target
			move $a3, $s4 # a3 = col target
			jal player_move
			# return that fuction's return value as the return value of player_turn
			# v0 = the value
			j exit_p_move_not_att

exit_p_turn:
	li $v0, 0
exit_p_move_not_att:
	# FIX STACK
	lw $ra, 0($sp)
	lw $s0, 4($sp) # map_ptr
	lw $s1, 8($sp) # player_ptr
	lw $s2, 12($sp) # char
	lw $s3, 16($sp) # row (target)
	lw $s4, 20($sp) # col (target)
	addi $sp, $sp, 24
	jr $ra


# Part XI
flood_fill_reveal:
li $v0, -200
li $v1, -200
jr $ra

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################
