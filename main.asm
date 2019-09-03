; Hardware registers
.define register_ppu_ctrl           $2000
.define register_ppu_mask           $2001
.define register_ppu_status         $2002
.define register_ppu_oam_addr       $2003
.define register_ppu_oam_data       $2004
.define register_ppu_scroll         $2005
.define register_ppu_addr           $2006
.define register_ppu_data           $2007
.define register_apu_pulse1_byte1   $4000
.define register_apu_pulse1_byte3   $4002
.define register_apu_pulse1_byte4   $4003
.define register_ppu_oam_dma        $4014
.define register_apu_status         $4015

.define register_joy_one            $4016

.include "boot.asm"
.include "palette.asm"
.include "background.asm"
.include "bird-sprite.asm"
.include "player.asm"
.include "npc.asm"
.include "magpie.asm"

music:
  .byte $a9, $00, $00, $00, $00, $00, $00, $00
  .byte $c9, $00, $00, $00, $00, $00, $00, $00
  .byte $a9, $00, $00, $00, $00, $00, $00, $00
  .byte $99, $00, $00, $00, $00, $00, $00, $00
  .byte $00, $00, $00, $00, $00, $00, $00, $00
  .byte $00, $00, $00, $00, $00, $00, $00, $00

music_len:
  .byte $2F

.segment "HEADER"
  .byte "NES",26,2,1

.segment "CHARS"
  .incbin "sprites.chr"

.segment "VECTORS"
  .word NMI
  .word RESET
  .word IRQ

.define controller_up_bitfield      #%00001000
.define controller_down_bitfield    #%00000100
.define controller_left_bitfield    #%00000010
.define controller_right_bitfield   #%00000001

; Setting this to 3F *should* make the interval 60 seconds
; VBLANK is raised after each frame is rendered, 60 frames
; are rendered per second by the PPU
.define MOVEMENT_TIMER_MAX          #$00

.zeropage
last_controller_state:              .res 1
player_move_rate_limit_counter_lsb: .res 1
player_move_rate_limit_counter_msb: .res 1
animation_bishop:                   .res 1
animation_vertical:                 .res 1
animation_horizontal:               .res 1
animation_rate_count:               .res 1
way_point_ptr:                      .res 1
param_1:                            .res 1
param_2:                            .res 1
param_3:                            .res 1
music_tracker_bit:                  .res 1

movement_timer_one:                 .res 1
should_move:                        .res 1

temp_var_1:                         .res 1
temp_var_2:                         .res 1
temp_var_3:                         .res 1

.segment "STARTUP"

.proc InitGame
  lda #$00  
  sta animation_bishop
  sta animation_vertical
  sta param_1
  sta param_2
  sta param_3
  sta music_len
  sta music_tracker_bit
  sta movement_timer_one

  ; jsr PlayerInit
  ; jsr NPCInit

  lda #%00000010
  sta $4015
  
  rts
.endproc

.proc MakeSomeNoise
  lda #%00111000
  sta $4004
  ldx music_tracker_bit
  lda music, X
  sta $4006
  lda music_tracker_bit
  dec music_tracker_bit
  bne NEXT
RESET:
  lda music_len
  sta music_tracker_bit
NEXT:
  lda #$00
  sta $4007
  rts
.endproc

.proc InitSprites
;   lda #$B0
;   sta $0200 ; Y.

;   lda #$00
;   sta $0201 ; Tile number.
  
;   lda #%00010000
;   sta $0202 ; Attributes.
;   lda #$80
;   sta $0203 ; X.

  ; lda #$B0
  ; sta $0204 ; Y.

  ; lda #$00
  ; sta $0205 ; Tile number.
  
  ; lda #%00010001
  ; sta $0206 ; Attributes.
  ; lda #$80
  ; sta $0207 ; X.

  ; lda #$B0
  ; sta $0208 ; Y.

  ; lda #$09
  ; sta $0209 ; Tile number.
  
  ; lda #%00010000
  ; sta $020A ; Attributes.
  ; lda #$80
  ; sta $020B ; X.

  lda #$00
  sta param_1
  lda #$5B
  sta param_2
  lda #$5B
  sta param_3
  jsr DrawMagpie
  
  lda #$00
  sta param_1
  jsr SetLeftMagpie

  rts
.endproc

.proc InitPictureUnit
  lda #%10010000
  sta register_ppu_ctrl
  lda #%00011110
  sta register_ppu_mask
  rts
.endproc

.proc PollInput
  lda #$01
  sta register_joy_one
  sta last_controller_state
  lda #$00
  sta register_joy_one
  :
    lda register_joy_one
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
  ; lda last_controller_state
  ; sta param_1
  ; lda #$00
  ; sta param_2
  ; lda #%00000000
  ; sta param_3
  ; jsr RenderBirdSprite
  ; jsr RenderNPCDirectionSprite

  beq END_PARSE_INPUT
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
  lda should_move
  cmp #$FF
  bne EXIT
  ; jsr ProcessInput
  ; jsr NPCMove
  ; jsr AnimateSprites
  lda #$00
  sta should_move
EXIT:
  rts
.endproc

.proc CopyGraphicsBufferToPPU
  ; Ask the DMA at ppu_oam_dma to copy $0200-$02FF in RAM into the OAM table $02
  lda #$00
  sta register_ppu_oam_addr
  lda #$02
  sta register_ppu_oam_dma
  rts
.endproc

.proc HandleVBlankNMI
  jsr CopyGraphicsBufferToPPU
  lda #$00
  sta register_ppu_scroll
  sta register_ppu_scroll

  lda movement_timer_one
  cmp MOVEMENT_TIMER_MAX
  bcs RESET
  jmp INCREMENT
RESET:
  lda #$00
  sta movement_timer_one
  lda #$FF
  sta should_move
  jmp EXIT
INCREMENT:
  inc movement_timer_one
EXIT:
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
  jsr MakeSomeNoise
  rti
