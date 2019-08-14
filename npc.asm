.proc RenderDiagonalNPCSprite
  lda animation_bishop
  sta $0205
  rts
.endproc

.proc RenderVerticalNPCSprite
  lda animation_vertical
  sta $0205
  rts
.endproc

.proc RenderHorizontalNPCSprite
  lda animation_horizontal
  sta $0205
  rts
.endproc

.proc RenderNPCDirectionNorth
  jsr RenderVerticalNPCSprite
  lda #%00000000
  sta $0206
  rts
.endproc

.proc RenderNPCDirectionNorthEast
  jsr RenderDiagonalNPCSprite
  lda #%00000001
  sta $0206
  rts
.endproc

.proc RenderNPCDirectionEast
  jsr RenderHorizontalNPCSprite
  lda #%00000001
  sta $0206
  rts
.endproc

.proc RenderNPCDirectionSouthEast
  jsr RenderDiagonalNPCSprite
  lda #%10000001
  sta $0206
  rts
.endproc

.proc RenderNPCDirectionSouth
  jsr RenderVerticalNPCSprite
  lda #%10000001
  sta $0206
  rts
.endproc

.proc RenderNPCDirectionSouthWest
  jsr RenderDiagonalNPCSprite
  lda #%11000001
  sta $0206
  rts
.endproc

.proc RenderNPCDirectionWest
  jsr RenderHorizontalNPCSprite
  lda #%01000001
  sta $0206
  rts
.endproc

.proc RenderNPCDirectionNorthWest
  jsr RenderDiagonalNPCSprite
  lda #%01000001
  sta $0206
  rts
.endproc

.proc RenderNPCDirectionSprite
  lda #%00000010
  and #%00001111
NORTH_EAST:
  cmp #%00001001
  bne NORTH_WEST
  jsr RenderNPCDirectionNorthEast
  jmp END_SELECT_SPRITE
NORTH_WEST:
  cmp #%00001010
  bne SOUTH_EAST
  jsr RenderNPCDirectionNorthWest
  jmp END_SELECT_SPRITE
SOUTH_EAST:
  cmp #%00000101
  bne SOUTH_WEST
  jsr RenderNPCDirectionSouthEast
  jmp END_SELECT_SPRITE
SOUTH_WEST:
  cmp #%00000110
  bne NORTH
  jsr RenderNPCDirectionSouthWest
  jmp END_SELECT_SPRITE
NORTH:
  cmp #%00001000
  bne EAST
  jsr RenderNPCDirectionNorth
  jmp END_SELECT_SPRITE
EAST:
  cmp #%00000001
  bne SOUTH
  jsr RenderNPCDirectionEast
  jmp END_SELECT_SPRITE
SOUTH:
  cmp #%00000100
  bne WEST
  jsr RenderNPCDirectionSouth
  jmp END_SELECT_SPRITE
WEST:
  cmp #%00000010
  bne END_SELECT_SPRITE
  jsr RenderNPCDirectionWest
  jmp END_SELECT_SPRITE
END_SELECT_SPRITE:
  rts
.endproc

.proc NPCMoveNorth
  dec $0204
  rts
.endproc

.proc NPCMoveEast
  inc $0207
  rts
.endproc

.proc NPCMoveSouth
  inc $0204
  rts
.endproc

.proc NPCMoveWest
  dec $0207
  rts
.endproc

.proc NPCMove
  jsr NPCMoveWest
  rts
.endproc

