.proc RenderDiagonalPlayerSprite
  lda animation_bishop
  sta $0201
  rts
.endproc

.proc RenderVerticalPlayerSprite
  lda animation_vertical
  sta $0201
  rts
.endproc

.proc RenderHorizontalPlayerSprite
  lda animation_horizontal
  sta $0201
  rts
.endproc

.proc RenderPlayerDirectionNorth
  jsr RenderVerticalPlayerSprite
  lda #%00000000
  sta $0202
  rts
.endproc

.proc RenderPlayerDirectionNorthEast
  jsr RenderDiagonalPlayerSprite
  lda #%00000000
  sta $0202
  rts
.endproc

.proc RenderPlayerDirectionEast
  jsr RenderHorizontalPlayerSprite
  lda #%00000000
  sta $0202
  rts
.endproc

.proc RenderPlayerDirectionSouthEast
  jsr RenderDiagonalPlayerSprite
  lda #%10000000
  sta $0202
  rts
.endproc

.proc RenderPlayerDirectionSouth
  jsr RenderVerticalPlayerSprite
  lda #%10000000
  sta $0202
  rts
.endproc

.proc RenderPlayerDirectionSouthWest
  jsr RenderDiagonalPlayerSprite
  lda #%11000000
  sta $0202
  rts
.endproc

.proc RenderPlayerDirectionWest
  jsr RenderHorizontalPlayerSprite
  lda #%01000000
  sta $0202
  rts
.endproc

.proc RenderPlayerDirectionNorthWest
  jsr RenderDiagonalPlayerSprite
  lda #%01000000
  sta $0202
  rts
.endproc

; Arguments: (1) The controller state bitfield where the last 4 bits
;     represent North, South, West and East respectively.
.proc RenderPlayerDirectionSprite
  tsx
  inx
  inx
  inx
  lda $0100,X
  and #%00001111
NORTH_EAST:
  cmp #%00001001
  bne NORTH_WEST
  jsr RenderPlayerDirectionNorthEast
  jmp END_SELECT_SPRITE
NORTH_WEST:
  cmp #%00001010
  bne SOUTH_EAST
  jsr RenderPlayerDirectionNorthWest
  jmp END_SELECT_SPRITE
SOUTH_EAST:
  cmp #%00000101
  bne SOUTH_WEST
  jsr RenderPlayerDirectionSouthEast
  jmp END_SELECT_SPRITE
SOUTH_WEST:
  cmp #%00000110
  bne NORTH
  jsr RenderPlayerDirectionSouthWest
  jmp END_SELECT_SPRITE
NORTH:
  cmp #%00001000
  bne EAST
  jsr RenderPlayerDirectionNorth
  jmp END_SELECT_SPRITE
EAST:
  cmp #%00000001
  bne SOUTH
  jsr RenderPlayerDirectionEast
  jmp END_SELECT_SPRITE
SOUTH:
  cmp #%00000100
  bne WEST
  jsr RenderPlayerDirectionSouth
  jmp END_SELECT_SPRITE
WEST:
  cmp #%00000010
  bne END_SELECT_SPRITE
  jsr RenderPlayerDirectionWest
  jmp END_SELECT_SPRITE
END_SELECT_SPRITE:
  sta $0100, X
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
