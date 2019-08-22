.define NORTH_BITMASK               %00001000
.define EAST_BITMASK                %00000001
.define SOUTH_BITMASK               %00000100
.define WEST_BITMASK                %00000010
.define NORTH_EAST_BITMASK          %00001001
.define SOUTH_EAST_BITMASK          %00000101
.define SOUTH_WEST_BITMASK          %00000110
.define NORTH_WEST_BITMASK          %00001010

.proc InitBirdSprite
  rts
.endproc

.proc RenderBirdSprite
  lda param_1
  and #%00001111
NORTH:
  cmp #NORTH_BITMASK
  bne EAST
  ldx param_2
  lda animation_vertical
  sta $0201, X
  lda #%00000000
  ora param_3
  sta $0202, X
  jmp END
EAST:
  cmp #EAST_BITMASK
  bne SOUTH
  ldx param_2
  lda animation_horizontal
  sta $0201, X
  lda #%00000000
  ora param_3
  sta $0202, X
  jmp END
SOUTH:
  cmp #SOUTH_BITMASK
  bne WEST
  ldx param_2
  lda animation_vertical
  sta $0201, X
  lda #%10000000
  ora param_3
  sta $0202, X
  jmp END
WEST:
  cmp #WEST_BITMASK
  bne NORTH_EAST
  ldx param_2
  lda animation_horizontal
  sta $0201, X
  lda #%11000000
  ora param_3
  sta $0202, X
  jmp END
NORTH_EAST:
  cmp #NORTH_EAST_BITMASK
  bne SOUTH_EAST
  ldx param_2
  lda animation_bishop
  sta $0201, X
  lda #%00000000
  ora param_3
  sta $0202, X
  jmp END
SOUTH_EAST:
  cmp #SOUTH_EAST_BITMASK
  bne SOUTH_WEST
  ldx param_2
  lda animation_bishop
  sta $0201, X
  lda #%10000000
  ora param_3
  sta $0202, X
  jmp END
SOUTH_WEST:
  cmp #SOUTH_WEST_BITMASK
  bne NORTH_WEST
  ldx param_2
  lda animation_bishop
  sta $0201, X
  lda #%11000000
  ora param_3
  sta $0202, X
  jmp END
NORTH_WEST:
  cmp #NORTH_WEST_BITMASK
  bne END
  ldx param_2
  lda animation_bishop
  sta $0201, X
  lda #%01000000
  ora param_3
  sta $0202, X
  jmp END
END:
  rts
.endproc
