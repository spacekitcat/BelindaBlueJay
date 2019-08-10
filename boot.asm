; We have to let 29658 cycles pass so that the console can get itself ready
WaitForVBlank:
  bit $2002
VBLANKWAIT1:
  bit $2002
  bpl VBLANKWAIT1
VBLANKWAIT2:
  bit $2002
  bpl VBLANKWAIT2
  rts

BootConsole:
  sei
  cld
  jsr WaitForVBlank
  rts
