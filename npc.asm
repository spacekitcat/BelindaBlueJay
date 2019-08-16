.define NORTH_BITMASK               %00001000
.define EAST_BITMASK                %00000001
.define SOUTH_BITMASK               %00000100
.define WEST_BITMASK                %00000010
.define NORTH_EAST_BITMASK          %00001001
.define SOUTH_EAST_BITMASK          %00000101
.define SOUTH_WEST_BITMASK          %00000110
.define NORTH_WEST_BITMASK          %00001010

waypoint:
  .byte NORTH_BITMASK, NORTH_BITMASK, NORTH_BITMASK, NORTH_BITMASK, NORTH_BITMASK, NORTH_BITMASK, NORTH_BITMASK, NORTH_BITMASK
  .byte EAST_BITMASK, EAST_BITMASK, EAST_BITMASK, EAST_BITMASK, EAST_BITMASK, EAST_BITMASK, EAST_BITMASK, EAST_BITMASK
  .byte SOUTH_BITMASK, SOUTH_BITMASK, SOUTH_BITMASK, SOUTH_BITMASK, SOUTH_BITMASK, SOUTH_BITMASK, SOUTH_BITMASK, SOUTH_BITMASK
  .byte WEST_BITMASK, WEST_BITMASK, WEST_BITMASK, WEST_BITMASK, WEST_BITMASK, WEST_BITMASK, WEST_BITMASK, WEST_BITMASK
  .byte EAST_BITMASK, EAST_BITMASK, EAST_BITMASK, EAST_BITMASK, EAST_BITMASK, EAST_BITMASK, EAST_BITMASK, EAST_BITMASK
  .byte SOUTH_BITMASK, SOUTH_BITMASK, SOUTH_BITMASK, SOUTH_BITMASK, SOUTH_BITMASK, SOUTH_BITMASK, SOUTH_BITMASK, SOUTH_BITMASK
  .byte SOUTH_BITMASK, SOUTH_BITMASK, SOUTH_BITMASK, SOUTH_BITMASK, SOUTH_BITMASK, SOUTH_BITMASK, SOUTH_BITMASK, SOUTH_BITMASK
  .byte NORTH_EAST_BITMASK, NORTH_EAST_BITMASK, NORTH_EAST_BITMASK, NORTH_EAST_BITMASK, NORTH_EAST_BITMASK, NORTH_EAST_BITMASK, NORTH_EAST_BITMASK, NORTH_EAST_BITMASK
  .byte SOUTH_EAST_BITMASK, SOUTH_EAST_BITMASK, SOUTH_EAST_BITMASK, SOUTH_EAST_BITMASK, SOUTH_EAST_BITMASK, SOUTH_EAST_BITMASK, SOUTH_EAST_BITMASK, SOUTH_EAST_BITMASK

.proc NPCInit
  jsr _resetWayPoint
  rts
.endproc

.proc _resetWayPoint
  lda #$40  ; This should be the number of bytes in `waypoint`.
  sta way_point_ptr
  rts
.endproc

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
  lda #%00000001
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
  ldx way_point_ptr
  lda waypoint, X
  and #%00001111
NORTH_EAST:
  cmp #NORTH_EAST_BITMASK
  bne NORTH_WEST
  jsr RenderNPCDirectionNorthEast
  jmp END_SELECT_SPRITE
NORTH_WEST:
  cmp #NORTH_WEST_BITMASK
  bne SOUTH_EAST
  jsr RenderNPCDirectionNorthWest
  jmp END_SELECT_SPRITE
SOUTH_EAST:
  cmp #SOUTH_EAST_BITMASK
  bne SOUTH_WEST
  jsr RenderNPCDirectionSouthEast
  jmp END_SELECT_SPRITE
SOUTH_WEST:
  cmp #SOUTH_WEST_BITMASK
  bne NORTH
  jsr RenderNPCDirectionSouthWest
  jmp END_SELECT_SPRITE
NORTH:
  cmp #NORTH_BITMASK
  bne EAST
  jsr RenderNPCDirectionNorth
  jmp END_SELECT_SPRITE
EAST:
  cmp #EAST_BITMASK
  bne SOUTH
  jsr RenderNPCDirectionEast
  jmp END_SELECT_SPRITE
SOUTH:
  cmp #SOUTH_BITMASK
  bne WEST
  jsr RenderNPCDirectionSouth
  jmp END_SELECT_SPRITE
WEST:
  cmp #WEST_BITMASK
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
  dec way_point_ptr
  bne SKIP_RESET
RESET:
  jsr _resetWayPoint
SKIP_RESET:
  ldx way_point_ptr
  lda waypoint, X
NORTH:
  cmp #NORTH_BITMASK
  bne EAST
  jsr NPCMoveNorth
EAST:
  cmp #EAST_BITMASK
  bne SOUTH
  jsr NPCMoveEast
SOUTH:
  cmp #SOUTH_BITMASK
  bne WEST
  jsr NPCMoveSouth
WEST:
  cmp #WEST_BITMASK
  bne NORTH_EAST
  jsr NPCMoveWest
NORTH_EAST:
  cmp #NORTH_EAST_BITMASK
  bne EXIT
  jsr NPCMoveNorth
  jsr NPCMoveEast
SOUTH_EAST:
  cmp #SOUTH_EAST_BITMASK
  bne EXIT
  jsr NPCMoveSouth
  jsr NPCMoveEast
EXIT:
  rts
.endproc

