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
.byte $12,$15,$2A,$15
.byte $00,$09,$19,$29
.byte $00,$01,$11,$21
.byte $00,$00,$10,$30

.byte $1E,$25,$25,$25
.byte $00,$14,$24,$34
.byte $00,$1B,$2B,$3B
.byte $00,$12,$22,$32

.zeropage
buttons1_sample1: .res 1
buttons1_sample2: .res 1
buttons2: .res 1
player_velocity_counter: .res 1
player_sprite_direction: .res 1

.segment "STARTUP"
IRQ:
RESET:
  sei
  cld

  lda #$40
  sta $4017
  
  lda #$00
  sta $2000
  sta $2001
  sta $4010
  txa

VBLANKWAIT1:
  bit $2002
  bpl VBLANKWAIT1

CLR_MEM:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  lda #$FE
  sta $0200, x
  inx
  bne CLR_MEM

VBLANKWAIT2:
  bit $2002
  bpl VBLANKWAIT2

BOOT_STRAP:
  lda $2002
  lda #$3F
  sta $2006
  lda $00
  sta $2006
  lda #$00
  sta player_velocity_counter

	lda #%10001000
	sta $2000
	lda $2002
	lda #$3F
	sta $2006
  lda #$00
	stx $2006
	ldx #0
	:
		lda palette, X
		sta $2007
		inx
		cpx #32
    bcc :-

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
  lda #%10000000
  sta $2000
  lda #%00010000
  sta $2001

MAIN:
REREAD:
  lda buttons1_sample1
  pha
  jsr POLL_INPUT
  pla
  cmp buttons1_sample1
  bne REREAD

  lda buttons1_sample1
  pha
  jsr POLL_INPUT
  pla
  cmp buttons1_sample1
  bne REREAD

  jsr PARSE_INPUT
END_MAIN:
  jmp MAIN

PARSE_INPUT:
  jsr RATE_LIMIT
CHECK_RIGHT:
  lda buttons1_sample1
  and #%00000001
  beq CHECK_LEFT
  jsr MOVE_RIGHT
CHECK_LEFT:
  lda buttons1_sample1
  and #%00000010
  beq CHECK_DOWN
  jsr MOVE_LEFT
CHECK_DOWN:
  lda buttons1_sample1
  and #%00000100
  beq CHECK_UP
  jsr MOVE_DOWN
CHECK_UP:
  lda buttons1_sample1
  and #%00001000
  beq END_PARSE_INPUT
  jsr MOVE_UP

END_PARSE_INPUT:
  rts

RATE_LIMIT:
  ; Rate limit
  inc player_velocity_counter
  lda player_velocity_counter
  and #%11000000
  beq MAIN
  clv
  rts

CLEAR_RATE_LIMIT:
  lda #$00
  sta player_velocity_counter
  rts

MOVE_RIGHT:
  ; Tell the PPU to flip the sprite on y
  lda #%01000000
  sta $0202
  ; Switch sprite sheet
  lda #$02
  sta $0201
  jsr CLEAR_RATE_LIMIT
  inc $0203
  rts

MOVE_LEFT:
  ; Tell the PPU to flip the sprite on y
  lda #%00000000
  sta $0202
  ; Switch sprite sheet
  lda #$02
  sta $0201
  jsr CLEAR_RATE_LIMIT
  dec $0203
  rts

MOVE_UP:
  ; Tell the PPU to flip the sprite on y
  lda #%00000000
  sta $0202
  ; Switch sprite sheet
  lda #$07
  sta $0201
  jsr CLEAR_RATE_LIMIT
  dec $0200
  rts

MOVE_DOWN:
  ; Switch sprite sheet
  lda #$03
  sta $0201
  jsr CLEAR_RATE_LIMIT
  inc $0200
  rts
  
POLL_INPUT:
  lda #$01
  sta $4016
  sta buttons1_sample1
  lda #$00
  sta $4016
  :
    lda $4016
    lsr a
    rol buttons1_sample1
    bcc :-
  rts

NMI:
  lda #$00
  sta $2003
  lda #$02
  sta $4014

  lda #$01
  sta $4016
  lda #$00
  sta $4016
  rti
