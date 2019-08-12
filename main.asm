.define PPU_ADDR $2006

.include "boot.asm"
.include "background.asm"

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

.define controller_up_bitfield #%00001000
.define controller_down_bitfield #%00000100
.define controller_left_bitfield #%00000010
.define controller_right_bitfield #%00000001

.zeropage
last_controller_state: .res 1
player_move_rate_limit_counter: .res 1
animation_bishop: .res 1
animation_vertical: .res 1
animation_horizontal: .res 1
animation_rate_count: .res 1

.segment "STARTUP"

.proc InitGame
  lda $2002
  lda #$3F
  sta PPU_ADDR
  lda $00
  sta PPU_ADDR
  lda #$00
  sta player_move_rate_limit_counter
  sta animation_bishop
  sta animation_vertical
  rts
.endproc

.proc LoadColorPalette
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
.endproc

.proc MakeSomeNoise
  lda #%00000111
  sta $4015

  lda #%00111000
  sta $4000
  lda #$C9
  sta $4002
  lda #$00
  sta $4003
  rts
.endproc

.proc InitSprites
  lda #$B0
  sta $0200 ; Y.

  lda #$00
  sta $0201 ; Tile number.
  
  lda #%00010000
  sta $0202 ; Attributes.
  lda #$80
  sta $0203 ; X.
  rts
.endproc

.proc InitPictureUnit
  lda #%10010000
  sta $2000
  lda #%00011110
  sta $2001
  rts
.endproc

.proc PollInput
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
.endproc

.proc PollInputWithVerification
REREAD:
  lda last_controller_state
  pha
  jsr PollInput
  pla
  cmp last_controller_state
  bne REREAD
  rts
.endproc

.proc ProcessInput
  jsr SELECT_SPRITE

  jsr RATE_LIMIT
CHECK_RIGHT:
  lda last_controller_state
  and controller_right_bitfield
  beq CHECK_LEFT
  jsr PlayerMoveEast
CHECK_LEFT:
  lda last_controller_state
  and controller_left_bitfield
  beq CHECK_DOWN
  jsr PlayerMoveWest
CHECK_DOWN:
  lda last_controller_state
  and controller_down_bitfield
  beq CHECK_UP
  jsr PlayerMoveSouth
CHECK_UP:
  lda last_controller_state
  and controller_up_bitfield
  beq END_PARSE_INPUT
  jsr PlayerMoveNorth

END_PARSE_INPUT:
  rts
.endproc

.proc HandleResetInterrupt
  jsr BootConsole
  jsr InitGame
  jsr LoadColorPalette
  jsr InitBackground
  jsr InitSprites
  jsr InitPictureUnit
  rts
.endproc

.proc PlayerMoveNorth
  dec $0200
  rts
.endproc

.proc PlayerMoveEast
  inc $0203
  rts
.endproc

.proc PlayerMoveSouth
  inc $0200
  rts
.endproc

.proc PlayerMoveWest
  dec $0203
  rts
.endproc

IRQ:
RESET:
  jsr HandleResetInterrupt
MAIN:
  jsr PollInputWithVerification
  jsr ProcessInput
END_MAIN:
  jmp MAIN

CLEAR_RATE_LIMIT:
  lda #$A0
  sta player_move_rate_limit_counter
  rts

RATE_LIMIT:
  inc player_move_rate_limit_counter
  bne MAIN
  jsr CLEAR_RATE_LIMIT
  clv
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
