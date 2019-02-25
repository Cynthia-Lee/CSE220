.data
map_filename: .asciiz "map3.txt"
# num words for map: 45 = (num_rows * num_cols + 2) // 4 
# map is random garbage initially
.asciiz "Don't touch this region of memory"
map: .word 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 
.asciiz "Don't touch this"
# player struct is random garbage initially
player: .word 0x2912FECD
.asciiz "Don't touch this either"
# visited[][] bit vector will always be initialized with all zeroes
# num words for visited: 6 = (num_rows * num*cols) // 32 + 1
visited: .word 0 0 0 0 0 0 
.asciiz "Really, please don't mess with this string"

welcome_msg: .asciiz "Welcome to MipsHack! Prepare for adventure!\n"
pos_str: .asciiz "Pos=["
health_str: .asciiz "] Health=["
coins_str: .asciiz "] Coins=["
your_move_str: .asciiz " Your Move: "
you_won_str: .asciiz "Congratulations! You have defeated your enemies and escaped with great riches!\n"
you_died_str: .asciiz "You died!\n"
you_failed_str: .asciiz "You have failed in your quest!\n"

.text
print_map:
la $t0, map  # the function does not need to take arguments
# loop to load each char
#li $t1, 0 # row counter
#li $t2, 0 # col counter
li $t3, 0 # total rows
li $t4, 0 # total cols

lbu $t3, 0($t0)
lbu $t4, 1($t0)
# 2D array at 2($t0)
addi $t0, $t0, 2 # start

# READING THE MAP FROM THE FILE
	# one char at at time
	li $t9, 1 # t9 = counter
	# exit when counter > row * col
	li $t8, 0
	mul $t8, $t3, $t4
	# addi $t8, $t8, 1
	print_map_loop: 
		# row * col = reading the map from the file including the new lines
		# exit when counter > row * col
		bgt $t9, $t8, end_print_map
		
		# char that is read is in t1
		lbu $t1, ($t0) # char
		# check hidden flag
		srl $t7, $t1, 7 # check if bit 7 is 1
		beqz $t7, map_print_char # if 0 (not 1) then no hidden flag
		# else (10000000), print space
		li $a0, ' '
		li $v0, 11  # syscall number for printing character
		syscall
		j cont_print_map
	map_print_char:
		move $a0, $t1 # t1 has char
		li $v0, 11
		syscall
		j cont_print_map
				
	cont_print_map:	
		# add a new line
		# add new line after every num cols
		# ex when counter is 
		# row1: 1-25
		# row2: 26-50
		div $t9, $t4 # div counter with num col
		mfhi $t2
		beqz $t2, print_nl
		j print_map_next_col
	print_nl:
		li $a0, '\n'
		li $v0, 11
		syscall
	print_map_next_col:
		addi $t0, $t0, 1 # inc map ptr
		addi $t9, $t9, 1
		j print_map_loop
end_print_map:
	jr $ra



print_player_info:
# the idea: print something like "Pos=[3,14] Health=[4] Coins=[1]"
la $t0, player
# print pos_str
# row pos
# col pos
# print health_str
# health
# print coins_str
# coins
# print ]

jr $ra


.globl main
main:
la $a0, welcome_msg
li $v0, 4
syscall

## fill in arguments
la $a0, map_filename # a0 = map_filename
la $a1, map # a1 = map * map_ptr
la $a2, player # a2 = player * player_ptr
jal init_game
#move $a0, $v0
#li $v0, 1
#syscall

# PART 2
#la $a0, map # a0 = map struct
#li $a1, -4 # a1 = row test
#li $a2, -3 # a2 = col test
#jal is_valid_cell
#move $a0, $v0
#li $v0, 1
#syscall

# PART 3
#la $a0, map # a0 = map struct
#li $a1, 0 # a1 = row test
#li $a2, 25 # a2 = col test
#jal get_cell
#move $a0, $v0
#li $v0, 1
#syscall

# PART 4
#la $a0, map # a0 = map struct
#li $a1, 1 # a1 = row test
#li $a2, 1 # a2 = col test
#li $a3, 'P'
#jal set_cell
#move $a0, $v0
#li $v0, 1
#syscall

# PART 5
## fill in arguments
la $a0, map # a0 = map_ptr
#li $a1, 1 # a1 = row # player_ptr.row
#li $a2, 7 # a2 = col # player_ptr.col
li $t0, 0
li $t1, 0
li $t2, 0
la $t0, player
lb $t1, 0($t0) # t1 = row
lb $t2, 1($t0) # t2 = col
move $a1, $t1 # a1 = row # player_ptr.row = 0(addr)
move $a2, $t2 # a2 = col # player_ptr.col = 1(addr)
jal reveal_area

# PART 6
#la $a0, map # a0 = map_ptr
#la $a1, player # a1 = player_ptr
#li $a2, 'U' # a2 = char (direction)
#jal get_attack_target
#move $a0, $v0
#li $v0, 1
#syscall

# PART 7
#la $a0, map # a0 = map_ptr
#la $a1, player # a1 = player_ptr
#li $a2, 3 # a2 = target row
#li $a3, 15 # a3 = target col
#jal complete_attack

# PART 8
#la $a0, map # a0 = map_ptr
#la $a1, player # a1 = player_ptr
#jal monster_attacks
#move $a0, $v0
#li $v0, 1
#syscall

# PART 9
#la $a0, map # a0 = map_ptr
#la $a1, player # a1 = player_ptr
#li $a2, 0 # a2 = target_row
#li $a3, 7 # a3 = target_col
#jal player_move
#move $a0, $v0
#li $v0, 1
#syscall

## GAME LOOP ##
li $s0, 0  # move = 0

# move = 0 means keep playing
game_loop:  # while player is not dead and move == 0:

jal print_map # takes no args

jal print_player_info # takes no args

# print prompt
la $a0, your_move_str
li $v0, 4
syscall

li $v0, 12  # read character from keyboard
syscall
move $s1, $v0  # $s1 has character entered
li $s0, 0  # move = 0

li $a0, '\n'
li $v0 11
syscall

# handle input: w, a, s or d
# map w, a, s, d  to  U, L, D, R and call player_turn()

# a0 = map_ptr
# a1 = player_ptr
# a2 = char (direction)
la $a0, map
la $a1, player
beq $s1, 'w', input_U
beq $s1, 'a', input_L
beq $s1, 's', input_D
beq $s1, 'd', input_R
j game_loop # invalid input, keep asking

input_U:
	li $a2, 'U'
	j call_player_turn
input_L:
	li $a2, 'L'
	j call_player_turn
input_D:
	li $a2, 'D'
	j call_player_turn
input_R:
	li $a2, 'R'
	j call_player_turn
call_player_turn:
	jal player_turn
	move $s0, $v0 ##

# if move == 0, call reveal_area()  Otherwise, exit the loop.
bnez $s0, game_over
# reveal_area
la $a0, map # a0 = map_ptr
li $t0, 0
li $t1, 0
li $t2, 0
la $t0, player
lb $t1, 0($t0) # t1 = row
move $a1, $t1 # a1 = row # player_ptr.row = 0(addr)
lb $t2, 1($t0) # t2 = col
move $a2, $t2 # a2 = col # player_ptr.col = 1(addr)
jal reveal_area
j game_loop

	
game_over:
jal print_map
jal print_player_info
li $a0, '\n'
li $v0, 11
syscall

# choose between (1) player dead, (2) player escaped but lost, (3) player escaped and won

# if player_ptr.coins >=3 and player_ptr.health >0 : # coin good, health good
	# print "congrats" (3)
# else : # coin good, health bad || coin bad, health good || coin bad, health bad
	# if player_ptr.health <= 0: (1) # health bad, coin good, health bad || coin bad, health bad
		# print "you died" 
	# else :
		# print "you failed" (2) # coin bad, health good
# print_player_info()

li $t0, 0 # player struct addr
li $t1, 0 # player coins
li $t2, 0 # player health
la $t0, player
lbu $t1, 3($t0) # coins
lbu $t2, 2($t2) # health
bge $t1, 3, check_print_congrats # coin good
j check_print_else

check_print_else:
	# health <=0
	blez $t2, player_dead # health bad, you died
	# health good
	j failed

check_print_congrats:
	bgtz $t2, won # coin good, health good
	
	


won: #(3)
la $a0, you_won_str
li $v0, 4
syscall
j exit

failed: #(2)
la $a0, you_failed_str
li $v0, 4
syscall
j exit

player_dead: #(1)
la $a0, you_died_str
li $v0, 4
syscall

exit:
li $v0, 10
syscall

.include "hw4.asm"
