.proc WaitForVBlank
  bit register_ppu_status
VBlankWait1:
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
