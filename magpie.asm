.define OAM_TABLE_START             $0200

.define NORTH_BITMASK               %00001000
.define EAST_BITMASK                %00000001
.define SOUTH_BITMASK               %00000100
.define WEST_BITMASK                %00000010
.define NORTH_EAST_BITMASK          %00001001
.define SOUTH_EAST_BITMASK          %00000101
.define SOUTH_WEST_BITMASK          %00000110
.define NORTH_WEST_BITMASK          %00001010

; .zeropage
; param_1:                            .res 1
; param_2:                            .res 1
; param_3:                            .res 1
; temp_var_1:                         .res 1
; temp_var_2:                         .res 1
; temp_var_3:                         .res 1

; Controls the sprite y/x offsets required to stitch
; and render the four sub sprites 
sub_sprite_offsets_right:
  .byte $00, $00, $00, $08, $08, $00, $08, $08

; Controls the sprite y/x offsets required to stitch
; and render the four sub sprites 
sub_sprite_offsets_left:
  .byte $00, $08, $00, $00, $08, $08, $08, $00

; param_1: Sprite OAM position offset. Subroutine expects
;          exclusive use of the subsequent 4 OAM slots 
;          (16 bytes)
;                    
; param_2: Sprite Y position
; param_3: Sprite X position
.proc DrawMagpieRight
  ldx param_1

  ; Sprite sheet offset
  lda #$08  ; The Magpie sprite starts at sprite sheet 1
  sta temp_var_1

  ; X iterates the OAM
  ldx #$00
  ; Y iterates the sub sprite offset table (sub_sprite_offsets_right)
  ldy #$00

  ; byte 0,1,2,3 = [y, pattern number, attributes, x]
LOAD_SUB_SPRITES:
  ; Y
  lda sub_sprite_offsets_right, Y
  adc param_2
  sta OAM_TABLE_START, X
  iny
  inx
  ; Pattern
  lda temp_var_1
  sta OAM_TABLE_START, X
  inc temp_var_1
  inx
  ; Attribute
  lda #%00000000
  sta OAM_TABLE_START, X
  inx
  ; X
  lda sub_sprite_offsets_right, Y
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
;                    
; param_2: Sprite Y position
; param_3: Sprite X position
.proc DrawMagpieLeft
  ldx param_1

  ; Sprite sheet offset
  lda #$08  ; The Magpie sprite starts at sprite sheet 1
  sta temp_var_1

  ; X iterates the OAM
  ldx #$00
  ; Y iterates the sub sprite offset table (sub_sprite_offsets_right)
  ldy #$00

  ; byte 0,1,2,3 = [y, pattern number, attributes, x]
LOAD_SUB_SPRITES:
  ; Y
  lda sub_sprite_offsets_left, Y
  adc param_2
  sta OAM_TABLE_START, X
  iny
  inx
  ; Pattern
  lda temp_var_1
  sta OAM_TABLE_START, X
  inc temp_var_1
  inx
  ; Attribute
  lda #%01000000
  sta OAM_TABLE_START, X
  inx
  ; X
  lda sub_sprite_offsets_left, Y
  adc param_3
  sta OAM_TABLE_START, X
  iny
  inx
  tya
  cmp #$08
  bcc LOAD_SUB_SPRITES 

  rts
.endproc

.proc MagpieDirectionRenderDispatch
    sta param_1
    and #%00000011        ; Left/right bitmask
    beq END
    and #EAST_BITMASK
    beq LEFT
    and #WEST_BITMASK
    beq RIGHT
LEFT:
  jsr DrawMagpieLeft
  jmp END
RIGHT:
  jsr DrawMagpieRight
  jmp END
END:
  rts
.endproc
