.data
vin_00: .asciiz "JTDKN3DU0D5614628"
vin_01: .asciiz "2FMDK4JC5DBC37904"
vin_02: .asciiz "1B4HR28N51F502695"
vin_03: .asciiz "1G1AK15F967719757"
vin_04: .asciiz "1HGEM1159YL037618"
vin_05: .asciiz "5N1AR2MM2EC648945"

make_A: .asciiz "Fjord"
make_B: .asciiz "Honder"
make_C: .asciiz "Toyoter"
make_D: .asciiz "Hunday"
make_E: .asciiz "Mersaydeez"

model_A: .asciiz "Wolfie-Z"
model_B: .asciiz "X27"
model_C: .asciiz "Escapade"
model_D: .asciiz "Road Hog"
model_E: .asciiz "Elantris"
model_F: .asciiz "Raoden"
model_G: .asciiz "Sazed"
model_H: .asciiz "Scadrial"
model_I: .asciiz "Metalborn"
model_J: .asciiz "Terris Roadster"
model_K: .asciiz "Allomancer"
model_L: .asciiz "Stormlight"
model_M: .asciiz "Dalinar"
model_N: .asciiz "Shallan"
model_O: .asciiz "Elendel Highliner"

repair_desc_A: .asciiz "fix cracked windshield"
repair_desc_B: .asciiz "rotate tires"
repair_desc_C: .asciiz "change oil filter"
repair_desc_D: .asciiz "rebuild engine"
repair_desc_E: .asciiz "remove rocks from grill"
repair_desc_F: .asciiz "touch up paint"
repair_desc_G: .asciiz "replace windshield wipers"
repair_desc_H: .asciiz "top off wiper fluid"
repair_desc_I: .asciiz "replace spare tire"

.align 2
all_cars:
car_00: .word vin_00
car_00_make_addr: .word make_A
car_00_model_addr: .word model_A
car_00_year: .byte 110, 7
car_00_features: .byte 8
.byte 0

car_01: .word vin_01
car_01_make_addr: .word make_D
car_01_model_addr: .word model_B
car_01_year: .byte 115, 7
car_01_features: .byte 8
.byte 0

car_02: .word vin_02
car_02_make_addr: .word make_A
car_02_model_addr: .word model_C
car_02_year: .byte 225, 7
car_02_features: .byte 12
.byte 0

car_03: .word vin_03
car_03_make_addr: .word make_E
car_03_model_addr: .word model_D
car_03_year: .byte 175, 7
car_03_features: .byte 10
.byte 0

car_04: .word vin_04
car_04_make_addr: .word make_A
car_04_model_addr: .word model_E
car_04_year: .byte 122, 7
car_04_features: .byte 5
.byte 0

car_05: .word vin_05
car_05_make_addr: .word make_C
car_05_model_addr: .word model_F
car_05_year: .byte 150, 7
car_05_features: .byte 10
.byte 0

.align 2
all_repairs:
repair_00_car: .word car_01
repair_00_desc_addr: .word repair_desc_A
repair_00_cost: .byte 223, 0 # 223, 0
.byte 0, 0

repair_01_car: .word car_04
repair_01_desc_addr: .word repair_desc_G
repair_01_cost: .byte 35, 0 # 35, 0
.byte 0, 0

repair_02_car: .word car_02
repair_02_desc_addr: .word repair_desc_H
repair_02_cost: .byte 52, 0 # 52, 0
.byte 0, 0

repair_03_car: .word car_00
repair_03_desc_addr: .word repair_desc_C
repair_03_cost: .byte 64, 0 # 64, 0
.byte 0, 0

repair_04_car: .word car_02
repair_04_desc_addr: .word repair_desc_G
repair_04_cost: .byte 244, 1 # 244, 1
.byte 0, 0

repair_05_car: .word car_03
repair_05_desc_addr: .word repair_desc_A
repair_05_cost: .byte 156, 1 # 156, 1
.byte 0, 0

repair_06_car: .word car_04
repair_06_desc_addr: .word repair_desc_H
repair_06_cost: .byte 105, 1 # 105, 1
.byte 0, 0

repair_07_car: .word car_00
repair_07_desc_addr: .word repair_desc_G
repair_07_cost: .byte 222, 1 # 222, 1
.byte 0, 0

repair_08_car: .word car_04
repair_08_desc_addr: .word repair_desc_G
repair_08_cost: .byte 191, 0 # 191, 0
.byte 0, 0

repair_09_car: .word car_05
repair_09_desc_addr: .word repair_desc_C
repair_09_cost: .byte 42, 1 # 42, 1
.byte 0, 0

.space 64  # some extra memory set aside to make room for insertions
