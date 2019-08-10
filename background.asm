background_0:
  .incbin "name-table-0.dat"
background_1:
  .incbin "name-table-0.dat", $F0
background_2:
  .incbin "name-table-1.dat"
background_3:
  .incbin "name-table-1.dat", $F0

attribute:
  .byte %01000000,%00010000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
  .byte %00000100,%00000001,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000

  .byte %01000000,%00010000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
  .byte %00000100,%00000001,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000

  .byte %01000000,%00010000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
  .byte %00000100,%00000001,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000

  .byte %01000000,%00010000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
  .byte %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000

.proc LoadBackground
  lda #$20
  STA PPU_ADDR
  lda #$00
  sta PPU_ADDR
  ldx #$00
  :
    lda background_0, x
    sta $2007
    inx
    cpx #$FF
    bne :-
  lda #$20
  STA PPU_ADDR
  lda #$FF
  sta PPU_ADDR
  ldx #$00
  :
    lda background_1, x
    sta $2007
    inx
    cpx #$FF
    bne :-
  lda #$21
  STA PPU_ADDR
  lda #$FE
  sta PPU_ADDR
  ldx #$00
  :
    lda background_2, x
    sta $2007
    inx
    cpx #$FF
    bne :-
  lda #$22
  STA PPU_ADDR
  lda #$FD
  sta PPU_ADDR
  ldx #$00
  :
    lda background_3, x
    sta $2007
    inx
    cpx #$FF
    bne :-
LOAD_ATTRIBUTES:
  lda $2004
  lda #$23
  sta PPU_ADDR
  lda #$c0
  sta PPU_ADDR
  ldx #$00
  :
    lda attribute, x
    sta $2007;
    inx
    cpx #$40
    bne :-
  rts
.endproc
