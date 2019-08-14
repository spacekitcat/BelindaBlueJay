palette:
.byte $3C,$11,$21,$31
.byte $3C,$12,$22,$32
.byte $3C,$11,$21,$31
.byte $3C,$11,$21,$31

.byte $3C,$30,$29,$19
.byte $3C,$30,$28,$27
.byte $00,$00,$00,$00
.byte $00,$00,$00,$00

.proc LoadColorPalette
  lda #%10001000
  sta register_ppu_ctrl
  lda #$3F
  sta register_ppu_addr
  lda #$00
  stx register_ppu_addr
  ldx #0
  :
    lda palette, X
    sta register_ppu_data
    inx
    cpx #32
    bcc :-
  rts
.endproc
