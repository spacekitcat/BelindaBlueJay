.define OAM_TABLE_START             $0200

; .zeropage
; param_1:                            .res 1
; param_2:                            .res 1
; param_3:                            .res 1
; temp_var_1:                         .res 1
; temp_var_2:                         .res 1
; temp_var_3:                         .res 1

; Controls the sprite y/x offsets required to stitch
; and render the four sub sprites 
sub_sprite_offsets:
  .byte $00, $00, $00, $08, $08, $00, $08, $08

; param_1: Sprite OAM position offset. Subroutine expects
;          exclusive use of the subsequent 4 OAM slots 
;          (16 bytes)
;                    
; param_2: Sprite Y position
; param_3: Sprite X position
.proc DrawMagpie
  ldx param_1

  ; Sprite sheet offset
  lda #$08  ; The Magpie sprite starts at sprite sheet 1
  sta temp_var_1

  ; X iterates the OAM
  ldx #$00
  ; Y iterates the sub sprite offset table (sub_sprite_offsets)
  ldy #$00

  ; byte 0,1,2,3 = [y, pattern number, attributes, x]
LOAD_SUB_SPRITES:
  ; Y
  lda sub_sprite_offsets, Y
  adc param_2
  sta OAM_TABLE_START, X
  iny
  inx
  ; Pattern
  lda temp_var_1
  sta OAM_TABLE_START, X
  inc temp_var_1
  inx
  inx
  ; X
  lda sub_sprite_offsets, Y
  adc param_3
  sta OAM_TABLE_START, X
  iny
  inx
  tya
  cmp #$08
  bcc LOAD_SUB_SPRITES 

  rts
.endproc

; param_1: Sprite OAM position offset. Subroutine expects
;          exclusive use of the subsequent 4 OAM slots 
;          (16 bytes)
.proc SetLeftMagpie
  ldx param_1
  inx ; Pattern
  inx ; X
  lda #%00000000  ; OAM color palette 1
  sta OAM_TABLE_START, X 

  inx
  inx
  inx
  inx
  lda #%00000000  ; OAM color palette 1
  sta OAM_TABLE_START, X 

  inx
  inx
  inx
  inx
  lda #%00000000  ; OAM color palette 1
  sta OAM_TABLE_START, X 

  inx
  inx
  inx
  inx
  lda #%00000000  ; OAM color palette 1
  sta OAM_TABLE_START, X 

  ; OAM iteration step
  ; lda #$08
  ; sta temp_var_1
  ; OAM iteration accumulator
  ; lda #$00
  ; sta temp_var_1

  ; UPDATE_OAM_ATTR:
  ; lda #$04
  ; adc temp_var_1
  ; sta OAM_TABLE_START, X

  rts
.endproc
