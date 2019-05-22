.segment "HEADER"
  .byte "NES",26,2,1

.segment "CHARS"
  .incbin "sprites.chr"

.segment "VECTORS"
  .word NMI
  .word RESET
  .word IRQ

.segment "RODATA"
palette:
.byte $12,$15,$25,$15
.byte $00,$09,$19,$29
.byte $00,$01,$11,$21
.byte $00,$00,$10,$30

.byte $25,$35,$2c,$35
.byte $00,$14,$24,$34
.byte $00,$1B,$2B,$3B
.byte $00,$12,$22,$32

.segment "STARTUP"
IRQ:
RESET:
  sei
  cld
  ldx #$40
  stx $4017
  ldx #$FF
  txs
  inx ; Is this zero or does it just have the negative bit set?
  stx $2000
  stx $2001
  stx $4010

VBLANKWAIT1:
  bit $2002
  bpl VBLANKWAIT1

CLR_MEM:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  lda #$FE
  sta $0200, x
  inx
  bne CLR_MEM

VBLANKWAIT2:
  bit $2002
  bpl VBLANKWAIT2

BOOT_STRAP:
  lda $2002
  lda #$3F
  sta $2006
  lda $00
  sta $2006

	lda #%10001000
	sta $2000
	lda $2002
	lda #$3F
	sta $2006
  lda #$00
	stx $2006
	ldx #0
	:
		lda palette, X
		sta $2007
		inx
		cpx #32
    bcc :-

INIT_PPU_MIRROR_RAM:
  lda #$B0
  sta $0200 ; Y.
  lda #$00 
  sta $0201 ; Tile number.
  lda #%00010000
  sta $0202 ; Attributes.
  lda #$80
  sta $0203 ; X.

INIT_PPU:
  lda #%10000000
  sta $2000
  lda #%00010000
  sta $2001

MAIN:
  jmp MAIN

NMI:
  lda #$00
  sta $2003
  lda #$02
  sta $4014
  rti
