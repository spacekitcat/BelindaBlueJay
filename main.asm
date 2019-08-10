.segment "HEADER"
  .byte "NES",26,2,1

.segment "CHARS"
  .incbin "sprites.chr"

.segment "VECTORS"
  .word NMI
  .word RESET
  .word IRQ

.segment "RODATA"

palette:
.byte $3C,$11,$21,$31
.byte $3C,$12,$22,$32
.byte $3C,$11,$21,$31
.byte $3C,$11,$21,$31

.byte $3C,$30,$29,$19
.byte $44,$00,$00,$00
.byte $00,$00,$00,$00
.byte $00,$00,$00,$00

background_0:
  .incbin "name-table-0.dat"
background_1:
  .incbin "name-table-0.dat", $F0
background_2:
  .incbin "name-table-1.dat"
background_3:
  .incbin "name-table-1.dat", $F0

attribute:
  .byte %01000000,%00010000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000 ; 0d - 7d
  .byte %00000100,%00000001,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000 ; 8d - 15d

  .byte %01000000,%00010000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
  .byte %00000100,%00000001,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000

  .byte %01000000,%00010000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
  .byte %00000100,%00000001,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000

  .byte %01000000,%00010000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
  .byte %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000

.define controller_up_bitfield #%00001000
.define controller_down_bitfield #%00000100
.define controller_left_bitfield #%00000010
.define controller_right_bitfield #%00000001

.define PPU_ADDR $2006

.zeropage
last_controller_state: .res 1
player_move_rate_limit_counter: .res 1
animation_bishop: .res 1
animation_vertical: .res 1
animation_horizontal: .res 1
animation_rate_count: .res 1

.segment "STARTUP"
IRQ:
RESET:
  sei
  cld

; We have to let 29658 cycles pass so that the console can get itself ready
  bit $2002
VBLANKWAIT1:
  bit $2002
  bpl VBLANKWAIT1
VBLANKWAIT2:
  bit $2002
  bpl VBLANKWAIT2

BOOT_STRAP:
  lda $2002
  lda #$3F
  sta PPU_ADDR
  lda $00
  sta PPU_ADDR
  lda #$00
  sta player_move_rate_limit_counter
  sta animation_bishop
  sta animation_vertical

  jsr LOAD_PALETTE
LOAD_BACKGROUND:
  lda #$20
  STA PPU_ADDR
  lda #$00
  sta PPU_ADDR
  ldx #$00
  :
    lda background_0, x
    sta $2007
    inx
    cpx #$FF
    bne :-
  lda #$20
  STA PPU_ADDR
  lda #$FF
  sta PPU_ADDR
  ldx #$00
  :
    lda background_1, x
    sta $2007
    inx
    cpx #$FF
    bne :-
  lda #$21
  STA PPU_ADDR
  lda #$FE
  sta PPU_ADDR
  ldx #$00
  :
    lda background_2, x
    sta $2007
    inx
    cpx #$FF
    bne :-
  lda #$22
  STA PPU_ADDR
  lda #$FD
  sta PPU_ADDR
  ldx #$00
  :
    lda background_3, x
    sta $2007
    inx
    cpx #$FF
    bne :-
    

LOAD_ATTRIBUTES:
  lda $2004
  lda #$23
  sta PPU_ADDR
  lda #$c0
  sta PPU_ADDR
  ldx #$00
  :
    lda attribute, x
    sta $2007;
    inx
    cpx #$40
    bne :-

INIT_PPU_MIRROR_RAM:
  lda #$B0
  sta $0200 ; Y.

  lda #$00
  sta $0201 ; Tile number.
  
  lda #%00010000
  sta $0202 ; Attributes.
  lda #$80
  sta $0203 ; X.

INIT_PPU:
  lda #%10010000
  sta $2000
  lda #%00011110
  sta $2001

MAIN:
REREAD:
  lda last_controller_state
  pha
  jsr POLL_INPUT
  pla
  cmp last_controller_state
  bne REREAD

  lda last_controller_state
  pha
  jsr POLL_INPUT
  pla
  cmp last_controller_state
  bne REREAD

  jsr PARSE_INPUT
END_MAIN:
  jmp MAIN

LOAD_PALETTE:
	lda #%10001000
	sta $2000
	lda #$3F
	sta PPU_ADDR
  lda #$00
	stx PPU_ADDR
	ldx #0
	:
		lda palette, X
		sta $2007
		inx
		cpx #32
    bcc :-
  rts

PARSE_INPUT:
  jsr SELECT_SPRITE

  jsr RATE_LIMIT
CHECK_RIGHT:
  lda last_controller_state
  and controller_right_bitfield
  beq CHECK_LEFT
  jsr MOVE_RIGHT
CHECK_LEFT:
  lda last_controller_state
  and controller_left_bitfield
  beq CHECK_DOWN
  jsr MOVE_LEFT
CHECK_DOWN:
  lda last_controller_state
  and controller_down_bitfield
  beq CHECK_UP
  jsr MOVE_DOWN
CHECK_UP:
  lda last_controller_state
  and controller_up_bitfield
  beq END_PARSE_INPUT
  jsr MOVE_UP

END_PARSE_INPUT:
  rts

RATE_LIMIT:
  inc player_move_rate_limit_counter
  lda player_move_rate_limit_counter
  and #%01000000
  beq MAIN
  clv
  rts

CLEAR_RATE_LIMIT:
  lda #$00
  sta player_move_rate_limit_counter
  rts

MOVE_RIGHT:
  jsr CLEAR_RATE_LIMIT
  inc $0203
  rts

MOVE_LEFT:
  jsr CLEAR_RATE_LIMIT
  dec $0203
  rts

MOVE_UP:
  jsr CLEAR_RATE_LIMIT
  dec $0200
  rts 

MOVE_DOWN:
  jsr CLEAR_RATE_LIMIT
  inc $0200
  rts
  
POLL_INPUT:
  lda #$01
  sta $4016
  sta last_controller_state
  lda #$00
  sta $4016
  :
    lda $4016
    lsr a
    rol last_controller_state
    bcc :-
  rts

NMI:
PPU_WRITE:
  ; Ask the DMA at $4014 to copy $0200-$02FF in RAM into the OAM table $02
  lda #$00
  sta $2003
  lda #$02
  sta $4014
LATCH_CONTROLLER:
  ; Phantom input and other glitches will occur if you don't do this.
  lda #$01
  sta $4016
  lda #$00
  sta $4016
  inc animation_rate_count
  bne END_NMI
  lda #$F6
  sta animation_rate_count
SPRITE_ROTATE:
  lda animation_bishop
  cmp #$00
  bne SPRITE_ROTATE_RST
  lda #$03
  sta animation_bishop
  lda #$04
  sta animation_vertical
  lda #$05
  sta animation_horizontal
  jmp END_NMI
SPRITE_ROTATE_RST:
  lda #$00
  sta animation_bishop
  lda #$01
  sta animation_vertical
  lda #$02
  sta animation_horizontal
END_NMI:
  lda #$00
  sta $2005
  sta $2005
  rti

; Depends on last_controller_state having the controller status bitfield.
SELECT_SPRITE:
  lda last_controller_state
  and #%00001111
NORTH_EAST:
  cmp #%00001001
  bne NORTH_WEST
  lda animation_bishop
  sta $0201
  lda #%00000000
  sta $0202
  jmp END_SELECT_SPRITE
NORTH_WEST:
  cmp #%00001010
  bne SOUTH_EAST
  lda animation_bishop
  sta $0201
  lda #%01000000
  sta $0202
  jmp END_SELECT_SPRITE
SOUTH_EAST:
  cmp #%00000101
  bne SOUTH_WEST
  lda animation_bishop
  sta $0201
  lda #%10000000
  sta $0202
  jmp END_SELECT_SPRITE
SOUTH_WEST:
  cmp #%00000110
  bne NORTH
  lda animation_bishop
  sta $0201
  lda #%11000000
  sta $0202
  jmp END_SELECT_SPRITE
NORTH:
  cmp #%00001000
  bne EAST
  lda animation_vertical
  sta $0201
  lda #%00000000
  sta $0202
  jmp END_SELECT_SPRITE
EAST:
  cmp #%00000001
  bne SOUTH
  ldx #$01
  lda animation_horizontal
  sta $0201
  lda #%00000000
  sta $0202
  jmp END_SELECT_SPRITE
SOUTH:
  cmp #%00000100
  bne WEST
  lda animation_vertical
  sta $0201
  lda #%10000000
  sta $0202
  jmp END_SELECT_SPRITE
WEST:
  cmp #%00000010
  bne END_SELECT_SPRITE
  lda animation_horizontal
  sta $0201
  lda #%01000000
  sta $0202
  jmp END_SELECT_SPRITE

END_SELECT_SPRITE:
  rts
