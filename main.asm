.define PPU_ADDR $2006

.include "boot.asm"
.include "palette.asm"
.include "background.asm"
.include "player.asm"
.include "npc.asm"

.segment "HEADER"
  .byte "NES",26,2,1

.segment "CHARS"
  .incbin "sprites.chr"

.segment "VECTORS"
  .word NMI
  .word RESET
  .word IRQ

.define controller_up_bitfield #%00001000
.define controller_down_bitfield #%00000100
.define controller_left_bitfield #%00000010
.define controller_right_bitfield #%00000001

; Hardware mapped memory addresses
.define joypad_one_addr $4016
.define ppu_oam_dma $4014

.zeropage
last_controller_state:            .res 1
player_move_rate_limit_counter:   .res 1
animation_bishop:                 .res 1
animation_vertical:               .res 1
animation_horizontal:             .res 1
animation_rate_count:             .res 1

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

  lda #$B0
  sta $0204 ; Y.

  lda #$00
  sta $0205 ; Tile number.
  
  lda #%00010001
  sta $0206 ; Attributes.
  lda #$80
  sta $0207 ; X.
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
  sta joypad_one_addr
  sta last_controller_state
  lda #$00
  sta joypad_one_addr
  :
    lda joypad_one_addr
    lsr a
    rol last_controller_state
    bcc :-
  rts
.endproc

.proc PollInputWithVerification
  lda last_controller_state
  pha
  jsr PollInput
  pla
  cmp last_controller_state
  bne PollInputWithVerification
  rts
.endproc

.proc ProcessInput
  ; Pass `last_controller_state` into `RenderPlayerDirectionSprite` via the stack
  lda last_controller_state
  pha
  jsr RenderPlayerDirectionSprite
  jsr RenderNPCDirectionSprite
  pla
  
  jsr UpdateRateLimit
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

.proc ResetRateLimit
  lda #$A0
  sta player_move_rate_limit_counter
  rts
.endproc

.proc UpdateRateLimit
  inc player_move_rate_limit_counter
  bne MAIN
  jsr ResetRateLimit
  clv
  rts
.endproc

.proc AnimateSprites

  lda animation_bishop
  cmp #$00
  bne SPRITE_FIRST
SPRITE_NEXT:
  lda #$03
  sta animation_bishop
  lda #$04
  sta animation_vertical
  lda #$05
  sta animation_horizontal
  jmp END
SPRITE_FIRST:
  lda #$00
  sta animation_bishop
  lda #$01
  sta animation_vertical
  lda #$02
  sta animation_horizontal
END:
  rts
.endproc

.proc Main
  jsr PollInputWithVerification
  jsr ProcessInput
  jsr NPCMove
  jsr AnimateSprites
  rts
.endproc

.proc CopyGraphicsBufferToPPU
  ; Ask the DMA at ppu_oam_dma to copy $0200-$02FF in RAM into the OAM table $02
  lda #$00
  sta $2003
  lda #$02
  sta ppu_oam_dma
  rts
.endproc

.proc HandleVBlankNMI
  jsr CopyGraphicsBufferToPPU
  lda #$00
  sta $2005
  sta $2005
  rts
.endproc

IRQ:
RESET:
  jsr HandleResetInterrupt

MAIN:
  jsr Main
  jmp MAIN

NMI:
  jsr HandleVBlankNMI
  rti
