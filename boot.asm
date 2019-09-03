.proc ZeroRam
  ldx #$00

  lda #$00
ZERO:
  inx
  sta $0000,X
  bcs ZERO

  rts
.endproc

.proc WaitForVBlank
  bit register_ppu_status
VBlankWait1:
  jsr ZeroRam
  bit register_ppu_status
  bpl VBlankWait1
VBlankWait2:
  bit register_ppu_status
  bpl VBlankWait2
  rts
.endproc

.proc BootConsole
  sei
  cld
  jsr WaitForVBlank
  rts
.endproc
