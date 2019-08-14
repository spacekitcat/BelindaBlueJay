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

.proc InitBackground
  lda #$20
  STA register_ppu_addr
  lda #$00
  sta register_ppu_addr
  ldx #$00
  :
    lda background_0, x
    sta register_ppu_data
    inx
    cpx #$FF
    bne :-
  lda #$20
  STA register_ppu_addr
  lda #$FF
  sta register_ppu_addr
  ldx #$00
  :
    lda background_1, x
    sta register_ppu_data
    inx
    cpx #$FF
    bne :-
  lda #$21
  STA register_ppu_addr
  lda #$FE
  sta register_ppu_addr
  ldx #$00
  :
    lda background_2, x
    sta register_ppu_data
    inx
    cpx #$FF
    bne :-
  lda #$22
  STA register_ppu_addr
  lda #$FD
  sta register_ppu_addr
  ldx #$00
  :
    lda background_3, x
    sta register_ppu_data
    inx
    cpx #$FF
    bne :-
LOAD_ATTRIBUTES:
  lda register_ppu_oam_data
  lda #$23
  sta register_ppu_addr
  lda #$c0
  sta register_ppu_addr
  ldx #$00
  :
    lda attribute, x
    sta register_ppu_data;
    inx
    cpx #$40
    bne :-
  rts
.endproc
