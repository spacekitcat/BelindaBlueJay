.proc WaitForVBlank
  bit $2002
VBlankWait1:
  bit $2002
  bpl VBlankWait1
VBlankWait2:
  bit $2002
  bpl VBlankWait2
  rts
.endproc

.proc BootConsole
  sei
  cld
  jsr WaitForVBlank
  rts
.endproc
