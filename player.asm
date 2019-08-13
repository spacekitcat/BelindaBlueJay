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

.proc SetPlayerDirectionNorth
  jsr RenderVerticalPlayerSprite
  lda #%00000000
  sta $0202
  rts
.endproc

.proc SetPlayerDirectionNorthEast
  jsr RenderDiagonalPlayerSprite
  lda #%00000000
  sta $0202
  rts
.endproc

.proc SetPlayerDirectionEast
  jsr RenderHorizontalPlayerSprite
  lda #%00000000
  sta $0202
  rts
.endproc

.proc SetPlayerDirectionSouthEast
  jsr RenderDiagonalPlayerSprite
  lda #%10000000
  sta $0202
  rts
.endproc

.proc SetPlayerDirectionSouth
  jsr RenderVerticalPlayerSprite
  lda #%10000000
  sta $0202
  rts
.endproc

.proc SetPlayerDirectionSouthWest
  jsr RenderDiagonalPlayerSprite
  lda #%11000000
  sta $0202
  rts
.endproc

.proc SetPlayerDirectionWest
  jsr RenderHorizontalPlayerSprite
  lda #%01000000
  sta $0202
  rts
.endproc


.proc SetPlayerDirectionNorthWest
  jsr RenderDiagonalPlayerSprite
  lda #%01000000
  sta $0202
  rts
.endproc
