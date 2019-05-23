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
.byte $12,$15,$25,$15
.byte $00,$09,$19,$29
.byte $00,$01,$11,$21
.byte $00,$00,$10,$30

.byte $25,$35,$2c,$35
.byte $00,$14,$24,$34
.byte $00,$1B,$2B,$3B
.byte $00,$12,$22,$32

.zeropage
buttons1: .res 1
buttons2: .res 1
player_velocity_counter: .res 1
player_sprite_direction: .res 1

.segment "STARTUP"
IRQ:
RESET:
  sei
  cld
  ldx #$40
  stx $4017
  ldx #$FF
  txs
  inx ; Is this zero or does it just have the negative bit set?
  stx $2000
  stx $2001
  stx $4010

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

  lda player_sprite_direction
  cmp #%000000010
  bne DONE
  lda #$02
  sta $0201 ; Tile number.
DONE:
  
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
  jsr POLL_FLIP_FLOPS
  jsr PARSE_INPUT
END_MAIN:
  jmp MAIN

PARSE_INPUT:
  jsr RATE_LIMIT
  lda buttons1
  and #%00000001
  bne MOVE_RIGHT
  lda buttons1
  and #%00000010
  bne MOVE_LEFT
  lda buttons1
  and #%00001000
  bne MOVE_UP
  lda buttons1
  and #%00000100
  bne MOVE_DOWN
  rts

RATE_LIMIT:
  ; Rate limit
  inc player_velocity_counter
  lda player_velocity_counter
  and #%11000000
  beq MAIN
  clv
  rts

MOVE_RIGHT:
  ; Switch sprite sheet
  lda #$00000001
  sta player_sprite_direction

  ; Move point reset
  lda #$00
  sta player_velocity_counter

  inc $0203
  jmp MAIN

MOVE_LEFT:
  ; Switch sprite sheet
  lda #$00000001
  sta player_sprite_direction

  ; Rate limit
  inc player_velocity_counter
  lda player_velocity_counter
  and #%11000000
  beq MAIN
  clv

  ; Move point reset
  lda #$00
  sta player_velocity_counter

  dec $0203
  jmp MAIN

MOVE_UP:
  ; Switch sprite sheet
  ;lda #$00000000
  ;sta player_sprite_direction

  ; Vertical flip (via PPU OAM ports)
  lda #%00000000
  sta $0202
  
  ; Move point reset
  lda #$00
  sta player_velocity_counter

  dec $0200
  jmp MAIN

MOVE_DOWN:
  ; Vertical flip (via PPU OAM ports)
  ;lda #%10000000
  ;sta $0202

  ; Move point reset
  lda #$00
  sta player_velocity_counter

  inc $0200
  jmp MAIN

POLL_FLIP_FLOPS:
  lda #$01
  sta $4016
  sta buttons1
  lsr a
  sta $4016
  :
    lda $4016
    lsr a
    rol buttons1
    bcc :-
  rts

NMI:
  lda #$00
  sta $2003
  lda #$02
  sta $4014
  rti
