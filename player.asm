.proc PlayerInit
  lda #$00
  ;sta player_move_rate_limit_counter
.endproc

.proc PlayerMoveNorth
  dec $0200
  rts
.endproc

.proc PlayerMoveEast
  inc $0203
  rts
.endproc

.proc PlayerMoveSouth
  inc $0200
  rts
.endproc

.proc PlayerMoveWest
  dec $0203
  rts
.endproc
