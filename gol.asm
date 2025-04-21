    ;;    game state memory location
    .equ CURR_STATE, 0x1000              ; current game state
    .equ GSA_ID, 0x1004                  ; gsa currently in use for drawing
    .equ PAUSE, 0x1008                   ; is the game paused or running
    .equ SPEED, 0x100C                   ; game speed
    .equ CURR_STEP,  0x1010              ; game current step
    .equ SEED, 0x1014                    ; game seed
    .equ GSA0, 0x1018                    ; GSA0 starting address
    .equ GSA1, 0x1038                    ; GSA1 starting address
    .equ SEVEN_SEGS, 0x1198              ; 7-segment display addresses
    .equ CUSTOM_VAR_START, 0x1200        ; Free range of addresses for custom variable definition
    .equ CUSTOM_VAR_END, 0x1300
    .equ LEDS, 0x2000                    ; LED address
    .equ RANDOM_NUM, 0x2010              ; Random number generator address
    .equ BUTTONS, 0x2030                 ; Buttons addresses

    ;; states
    .equ INIT, 0
    .equ RAND, 1
    .equ RUN, 2

    ;; constants
    .equ N_SEEDS, 4
    .equ N_GSA_LINES, 8
    .equ N_GSA_COLUMNS, 12
    .equ MAX_SPEED, 10
    .equ MIN_SPEED, 1
    .equ PAUSED, 0x00
    .equ RUNNING, 0x01

main:
    addi sp, zero, 0x1FFC
    call reset_game
    call get_input
    add t0, v0, zero
    add t1, zero, zero
    main_loop:
      add a0, t0, zero
      call select_action
      call update_state
      call update_gsa
      call mask
      call draw_gsa
      call wait
      call decrement_step
      add t1, v0, zero
      call get_input
      add t0, v0, zero
      beq t1, zero, main_loop
    br main

font_data:
    .word 0xFC ; 0
    .word 0x60 ; 1
    .word 0xDA ; 2
    .word 0xF2 ; 3
    .word 0x66 ; 4
    .word 0xB6 ; 5
    .word 0xBE ; 6
    .word 0xE0 ; 7
    .word 0xFE ; 8
    .word 0xF6 ; 9
    .word 0xEE ; A
    .word 0x3E ; B
    .word 0x9C ; C
    .word 0x7A ; D
    .word 0x9E ; E
    .word 0x8E ; F

seed0:
    .word 0xC00
    .word 0xC00
    .word 0x000
    .word 0x060
    .word 0x0A0
    .word 0x0C6
    .word 0x006
    .word 0x000

seed1:
    .word 0x000
    .word 0x000
    .word 0x05C
    .word 0x040
    .word 0x240
    .word 0x200
    .word 0x20E
    .word 0x000

seed2:
    .word 0x000
    .word 0x010
    .word 0x020
    .word 0x038
    .word 0x000
    .word 0x000
    .word 0x000
    .word 0x000

seed3:
    .word 0x000
    .word 0x000
    .word 0x090
    .word 0x008
    .word 0x088
    .word 0x078
    .word 0x000
    .word 0x000

    ;; Predefined seeds
SEEDS:
    .word seed0
    .word seed1
    .word seed2
    .word seed3

mask0:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF

mask1:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x1FF
	.word 0x1FF
	.word 0x1FF

mask2:
  .word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF

mask3:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000

mask4:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000

MASKS:
    .word mask0
    .word mask1
    .word mask2
    .word mask3
    .word mask4

; BEGIN:clear_leds
clear_leds:
  stw zero, LEDS(zero)
  stw zero, LEDS+4(zero)
  stw zero, LEDS+8(zero)
  ret
; END:clear_leds

; BEGIN:set_pixel
set_pixel:
  addi t0, zero, 1
  andi t1, a0, 3
  slli t1, t1, 3
  add t1, t1, a1
  sll t0, t0, t1
  srli t2, a0, 2
  slli t2, t2, 2
  ldw t3, LEDS(t2)
  or t4, t3, t0
  stw t4, LEDS(t2)
  ret
; END:set_pixel

; BEGIN:wait
wait:
  addi t1, zero, 1
  slli t0, t1, 19
  ldw t2, SPEED(zero)
  wait_loop:
    sub t0, t0, t2
    bge t0, t1, wait_loop
  ret
; END:wait

; BEGIN:get_gsa
get_gsa:
  ldw t0, GSA_ID(zero)
  slli t1, a0, 2
  beq t0, zero, get_gsa_zero
  ldw v0, GSA1(t1)
  ret
  get_gsa_zero:
    ldw v0, GSA0(t1)
  ret
; END:get_gsa

; BEGIN:set_gsa
set_gsa:
  ldw t0, GSA_ID(zero)
  slli t1, a1, 2
  beq t0, zero, set_gsa_zero
  stw a0, GSA1(t1)
  ret
  set_gsa_zero:
    stw a0, GSA0(t1)
  ret
; END:set_gsa

; BEGIN:draw_gsa
draw_gsa:
  addi sp, sp, -4
  stw ra, 0(sp)
  call clear_leds
  add t0, zero, zero
  add t1, zero, zero
  loop_lines:
    add a0, t0, zero
    addi sp, sp, -8
    stw t0, 4(sp)
    stw t1, 0(sp)
    call get_gsa
    ldw t1, 0(sp)
    ldw t0, 4(sp)
    addi sp, sp, 8
    add t2, v0, zero
    cmplti t3, t0, N_GSA_LINES
    beq t3, zero, end_draw_gsa
  loop_columns:
    andi t4, t2, 1
    srli t2, t2, 1
    bne t4, zero, draw_pixel
  continue:
    addi t1, t1, 1
    cmplti t3, t1, N_GSA_COLUMNS
    bne t3, zero, loop_columns
  addi t0, t0, 1
  add t1, zero, zero
  br loop_lines
  draw_pixel:
    add a0, t1, zero
    add a1, t0, zero
    addi sp, sp, -12
    stw t0, 8(sp)
    stw t1, 4(sp)
    stw t2, 0(sp)
    call set_pixel
    ldw t2, 0(sp)
    ldw t1, 4(sp)
    ldw t0, 8(sp)
    addi sp, sp, 12
    br continue
  end_draw_gsa:
  ldw ra, 0(sp)
  addi sp, sp, 4
  ret
; END:draw_gsa

; BEGIN:random_gsa
random_gsa:
  addi sp, sp, -4
  stw ra, 0(sp)
  add t0, zero, zero
  add t1, zero, zero
  add t2, zero, zero
  rndgsa_loop:
    ldw t3, RANDOM_NUM(zero)
    andi t3, t3, 1
    add t2, t2, t3
    slli t2, t2, 1
    addi t1, t1, 1
    cmplti t4, t1, N_GSA_COLUMNS
    bne t4, zero, rndgsa_loop
	
	addi sp, sp, -4 
	stw a0, 0(sp)	 
	addi sp, sp, -4 
	stw a1, 0(sp)	
	add a0, t2, zero
	add a1, t0, zero
	addi sp, sp, -4
	stw t0, 0(sp)

	call set_gsa

	ldw a1, 0(sp)
	addi sp, sp, 4      
	ldw a0, 0(sp)
	addi sp, sp, 4 
	ldw t0, 0(sp)
	addi sp, sp, 4
	addi t0, t0, 1
	add t1, zero, zero
	add t2, zero, zero
	cmplti t4, t0, N_GSA_LINES
	bne t4, zero, rndgsa_loop
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
; END:random_gsa

; BEGIN:change_speed
change_speed:
  ldw t0, SPEED(zero)
  cmpeqi t1, t0, MIN_SPEED
  cmpeqi t3, t0, MAX_SPEED
  bne t1, zero, end_change_speed
  bne t3, zero, end_change_speed
  beq a0, zero, increment
  decrement:
    addi t0, t0, -1
    br end_change_speed
  increment:
    addi t0, t0, 1
  end_change_speed:
    stw t0, SPEED(zero)
  ret
; END:change_speed

; BEGIN:pause_game
pause_game:
  ldw t0, PAUSE(zero)
  xori t0, t0, RUNNING
  stw t0, PAUSE(zero)
  ret
; END:pause_game

; BEGIN:change_steps
change_steps:
  ldw t0, CURR_STEP(zero)
  addi t1, zero, 0xFFF
  bge t0, t1, max_steps
  bne a0, zero, units
  bne a1, zero, tens
  bne a2, zero, hundreds
  ret
  units:
    addi t0, t0, 1
    bge t0, t1, max_steps
    bne a1, zero, tens
    bne a2, zero, hundreds
    stw t0, CURR_STEP(zero)
  ret
  tens:
    addi t0, t0, 0x010
    bge t0, t1, max_steps
    bne a2, zero, hundreds
    stw t0, CURR_STEP(zero)
  ret
  hundreds: 
    addi t0, t0, 0x100
    bge t0, t1, max_steps
    stw t0, CURR_STEP(zero)
  ret
  max_steps:
    stw t1, CURR_STEP(zero)
  ret
; END:change_steps

; BEGIN:increment_seed
increment_seed:
  addi sp, sp, -4
  stw ra, 0(sp)
  ldw t0, SEED(zero)  
  cmpeqi t2, t0, N_SEEDS
  bne t2, zero, rand_gsa
  ldw t1, CURR_STATE(zero)
  beq t1, zero, incr_seed
  cmpeqi t2, t1, RAND
  bne t2, zero, rand_gsa
  br end_increment_seed
  incr_seed:
    addi t0, t0, 1
    stw t0, SEED(zero)
    cmpeqi t2, t0, N_SEEDS
    bne t2, zero, rand_gsa
  add t3, zero, zero 
  slli t0, t0, 2
  ldw t4, SEEDS(t0)
  loop_gsa:
    ldw t5, 0(t4)
    add a0, t5, zero
    add a1, t3, zero
    addi sp, sp, -8
    stw t3, 4(sp)
    stw t4, 0(sp)
    call set_gsa
    ldw t4, 0(sp)
    ldw t3, 4(sp)
    addi sp, sp, 8
    addi t3, t3, 1
    addi t4, t4, 4
    cmplti t2, t3, N_GSA_LINES
    bne t2, zero, loop_gsa
  br end_increment_seed
  rand_gsa:
    call random_gsa
  end_increment_seed:
  ldw ra, 0(sp)
  addi sp, sp, 4
  ret
; END:increment_seed

; BEGIN:update_state
update_state:
  addi sp, sp, -4
  stw ra, 0(sp)
  ldw t0, CURR_STATE(zero) 
  ldw t2, SEED(zero)
  beq t0, zero, from_init
  cmpeqi t1, t0, RAND
  bne t1, zero, from_rand
  cmpeqi t1, t0, RUN
  bne t1, zero, from_run
  br end_update_state
  from_init:
    cmpeqi t1, t2, N_SEEDS
    bne t1, zero, to_rand
    andi t3, a0, 2
    bne t3, zero, to_run
  br end_update_state
  from_rand:
    andi t3, a0, 2
    bne t3, zero, to_run
  br end_update_state
  from_run:
    andi t3, a0, 8
    bne t3, zero, to_init
  br end_update_state
  to_rand:
    addi t4, zero, RAND
    stw t4, CURR_STATE(zero)
  br end_update_state
  to_run:
    addi t4, zero, RUN
    stw t4, CURR_STATE(zero)
    addi t5, zero, RUNNING
    stw t5, PAUSE(zero)
  br end_update_state
  to_init: 
    call reset_game
  end_update_state:
  ldw ra, 0(sp)
  addi sp, sp, 4
  ret
; END:update_state

; BEGIN:select_action
select_action:
  addi sp, sp, -4
  stw ra, 0(sp)
  addi t0, zero, 1
  addi t1, zero, 2
  addi t2, zero, 4
  addi t3, zero, 8
  addi t4, zero, 0x10
  ldw t5, CURR_STATE(zero)
  cmpeqi t6, t5, RUN
  bne t6, zero, select_action_from_run
  and t7, a0, t0
  bne t7, zero, b0_pressed_from_init_or_rand
  and t7, a0, t2
  bne t7, zero, b2_pressed_from_init_or_rand
  and t7, a0, t3
  bne t7, zero, b3_pressed_from_init_or_rand
  and t7, a0, t4
  bne t7, zero, b4_pressed_from_init_or_rand
  br end_select_action
  select_action_from_run:
    and t7, a0, t0
    bne t7, zero, b0_pressed_from_run
    and t7, a0, t1
    bne t7, zero, b1_pressed_from_run
    and t7, a0, t2
    bne t7, zero, b2_pressed_from_run
    and t7, a0, t4
    bne t7, zero, b4_pressed_from_run
  br end_select_action
  b0_pressed_from_init_or_rand:
    call increment_seed
  br end_select_action
  b2_pressed_from_init_or_rand:
    add a0, zero, zero
    add a1, zero, zero
    addi a2, zero, 1
    call change_steps
  br end_select_action
  b3_pressed_from_init_or_rand:
    add a0, zero, zero
    add a2, zero, zero
    addi a1, zero, 1
    call change_steps
  br end_select_action
  b4_pressed_from_init_or_rand:
    add a1, zero, zero
    add a2, zero, zero
    addi a0, zero, 1
    call change_steps
  br end_select_action
  b0_pressed_from_run:
    call pause_game
  br end_select_action
  b1_pressed_from_run:
    add a0, zero, zero
    call change_speed
  br end_select_action
  b2_pressed_from_run:
    addi a0, zero, 1
    call change_speed
  br end_select_action
  b4_pressed_from_run:
    call random_gsa
  end_select_action:
  ldw ra, 0(sp)
  addi sp, sp, 4
  ret
; END:select_action

; BEGIN:cell_fate
cell_fate:
  addi sp, sp, -4
  stw ra, 0(sp)
  beq a1, zero, dead
  cmplti t0, a0, 2
  bne t0, zero, under_or_over_population
  cmpgei t0, a0, 4
  bne t0, zero, under_or_over_population
  addi v0, zero, 1
  br end_cell_fate
  dead:
    cmpeqi t0, a0, 3
    bne t0, zero, reproduction
    add v0, zero, zero
  br end_cell_fate
  under_or_over_population:
    add v0, zero, zero
  br end_cell_fate
  reproduction:
    addi v0, zero, 1
  end_cell_fate:
  ldw ra, 0(sp)
  addi sp, sp, 4
  ret
; END:cell_fate

; BEGIN:find_neighbours
find_neighbours:
  addi sp, sp, -4
  stw ra, 0(sp)
  add t2, a1, zero
  add t4, a0, zero
  addi t0, t2, -1
  andi t0, t0, 7
  add a0, t0, zero
  addi sp, sp, -8
  stw t4, 4(sp)
  stw t2, 0(sp)
  call get_gsa
  add t0, v0, zero
  ldw t2, 0(sp)
  addi t1, t2, 1
  andi t1, t1, 7
  addi sp, sp, -4
  stw t0, 4(sp)
  stw t2, 0(sp)
  add a0, t1, zero
  call get_gsa
  ldw t2, 0(sp)
  add t1, v0, zero
  stw t1, 0(sp)
  add a0, t2, zero
  call get_gsa
  add t2, v0, zero
  ldw t1, 0(sp)
  ldw t0, 4(sp)
  ldw t4, 8(sp)
  addi sp, sp, 12
  addi t7, zero, 1
  add t6, zero, zero
  sll t3, t7, t4
  and t5, t3, t2
  cmpne v1, t5, zero
  and t5, t3, t0
  cmpne t5, t5, zero
  add t6, t6, t5
  and t5, t3, t1
  cmpne t5, t5, zero
  add t6, t6, t5
  cmpeqi t5, t4, 11
  bne t5, zero, torus_left
  addi t3, t4, 1
  br continue_left
  torus_left:
    add t3, zero, zero
  continue_left:
  sll t3, t7, t3
  and t5, t3, t0
  cmpne t5, t5, zero
  add t6, t6, t5
  and t5, t3, t1
  cmpne t5, t5, zero
  add t6, t6, t5
  and t5, t3, t2
  cmpne t5, t5, zero
  add t6, t6, t5
  beq t4, zero, torus_right
  addi t3, t4, -1
  br continue_right
  torus_right:
    addi t3, zero, 11
  continue_right:
  sll t3, t7, t3
  and t5, t3, t0
  cmpne t5, t5, zero
  add t6, t6, t5
  and t5, t3, t1
  cmpne t5, t5, zero
  add t6, t6, t5
  and t5, t3, t2
  cmpne t5, t5, zero
  add t6, t6, t5
  add v0, t6, zero
  ldw ra, 0(sp)
  addi sp, sp, 4
  ret
; END:find_neighbours

; BEGIN:update_gsa
update_gsa:
  addi sp, sp, -4
  stw ra, 0(sp)
  ldw t2, PAUSE(zero)
  beq t2, zero, no_update
  add t0, zero, zero
  add t1, zero, zero
  add t3, zero, zero
  loop_update_gsa:
    add a0, t0, zero
    add a1, t1, zero
    addi sp, sp, -12
    stw t0, 8(sp)
    stw t1, 4(sp)
    stw t3, 0(sp)
    call find_neighbours
    add a0, v0, zero
    add a1, v1, zero
    call cell_fate
    ldw t3, 0(sp)
    ldw t1, 4(sp)
    ldw t0, 8(sp)
    addi sp, sp, 12
    sll t4, v0, t0
    add t3, t3, t4
    addi t0, t0, 1
    cmplti t5, t0, N_GSA_COLUMNS
    bne t5, zero, loop_update_gsa
  slli t0, t1, 2
  ldw t6, GSA_ID(zero)
  cmpeq t6, t6, zero
  beq t6, zero, update_zero
  stw t3, GSA1(t0)
  br next_line
  update_zero:
    stw t3, GSA0(t0)
  next_line:  
    add t0, zero, zero
    add t3, zero, zero
    addi t1, t1, 1  
    cmplti t5, t1, N_GSA_LINES
    bne t5, zero, loop_update_gsa
  stw t6, GSA_ID(zero) 
  no_update:
  ldw ra, 0(sp)
  addi sp, sp, 4 
  ret
; END:update_gsa

; BEGIN:mask
mask:
  addi sp, sp, -4
  stw ra, 0(sp)
  ldw t0, SEED(zero)  
  slli t0, t0, 2
  ldw t1, MASKS(t0)
  add t2, zero, zero
  loop_mask:
    add a0, t2, zero
    addi sp, sp, -8
    stw t2, 4(sp)
    stw t1, 0(sp)
    call get_gsa
    ldw t1, 0(sp)
    ldw t2, 4(sp)
    addi sp, sp, 8
    slli t6, t2, 2
    add t3, t1, t6
    ldw t4, 0(t3)
    add a1, t2, zero
    and a0, v0, t4
    addi sp, sp, -8
    stw t2, 4(sp)
    stw t1, 0(sp)
    call set_gsa
    ldw t1, 0(sp)
    ldw t2, 4(sp)
    addi sp, sp, 8
    addi t2, t2, 1
    cmplti t5, t2, N_GSA_LINES
    bne t5, zero, loop_mask
  ldw ra, 0(sp)
  addi sp, sp, 4 
  ret
; END:mask

; BEGIN:get_input
get_input:
  addi t0, zero, 1
  ldw t3, BUTTONS+4(zero)
  get_input_loop:
    and t2, t0, t3
    bne t2, zero, end_get_input
    slli t0, t0, 1
    cmpgei t4, t0, 0x11
    beq t4, zero, get_input_loop
  end_get_input:
    add v0, t2, zero
    stw zero, BUTTONS+4(zero)
  ret
; END:get_input

; BEGIN:decrement_step
decrement_step:
  addi t0, zero, 16
  add t1, zero, zero 
  ldw t2, CURR_STEP(zero)
  ldw t5, CURR_STATE(zero)
  cmpeqi t6, t5, RUN  
  beq t6, zero, seven_segs_loop
  beq t2, zero, reached_zero
  ldw t7, PAUSE(zero)
  cmpeqi t6, t7, PAUSED
  bne t6, zero, not_done
  addi t2, t2, -1
  stw t2, CURR_STEP(zero)
  seven_segs_loop:
    addi t0, t0, -4
    srl t3, t2, t1
    andi t3, t3, 0xF
    slli t3, t3, 2
    ldw t4, font_data(t3)
    stw t4, SEVEN_SEGS(t0)
    addi t1, t1, 4
    bne t0, zero, seven_segs_loop
  not_done:
    add v0, zero, zero
  ret
  reached_zero:
    addi v0, zero, 1
  ret
; END:decrement_step

; BEGIN:reset_game
reset_game:
  addi sp, sp, -4
  stw ra, 0(sp)
  addi t0, zero, 1
  stw t0, CURR_STEP(zero)  
  ldw t1, font_data(zero)
  stw t1, SEVEN_SEGS(zero)
  stw t1, SEVEN_SEGS+4(zero)
  stw t1, SEVEN_SEGS+8(zero)
  ldw t1, font_data+4(zero)
  stw t1, SEVEN_SEGS+12(zero)
  stw zero, SEED(zero)
  stw zero, CURR_STATE(zero)
  addi t2, zero, 32
  reset_gsa:
    addi t2, t2, -4
    ldw t3, seed0(t2)
    stw t3, GSA0(t2)
    bne t2, zero, reset_gsa
  stw zero, GSA_ID(zero)
  call draw_gsa
  call mask
  stw zero, PAUSE(zero)
  addi t4, zero, MIN_SPEED
  stw t4, SPEED(zero)
  ldw ra, 0(sp)
  addi sp, sp, 4 
  ret
; END:reset_game