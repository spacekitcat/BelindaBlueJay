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
  sta $2000
  lda #$3F
  sta PPU_ADDR
  lda #$00
  stx PPU_ADDR
  ldx #0
  :
    lda palette, X
    sta $2007
    inx
    cpx #32
    bcc :-
  rts
.endproc
