palette:
.byte $3c,$3c,$21,$16
.byte $28,$2C,$22,$21
.byte $3C,$11,$21,$31
.byte $3C,$11,$21,$31

.byte $24,$26,$15,$16
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
  ldx #00
  :
    lda palette, X
    sta register_ppu_data
    inx
    cpx #32
    bcc :-
  rts
.endproc
