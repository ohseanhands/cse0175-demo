	org 32768

start:
	; call setupInterrupt
  ld a, 2
  out ($fe), a
  call callback

callback:
  ;ld b, 5
  ;ld c, 5
  ;ld de, wall
  ;call blitTile
  ;ld b, 7
  ;ld c, 9
  ;ld de, wall
  ;call blitTile
  ld b, 0
  ld c, 0
  call coordToScrAddr
  ld de, wall
  call blitChar
  ld b, 1
  ld c, 1
  call coordToScrAddr
  ld de, wall
  call blitChar
  ld b, 2
  ld c, 2
  call coordToScrAddr
  ld de, wall
  call blitChar
  jp callback

;; Inputs: B - line (0-23) | C - col (0-32)
;; Outpus: HL - address of character in screen mem
coordToScrAddr:
  ; high address
  ld a, b
  and $f8
  add a, $40
  ld h, a

  ; low address
  ld a, b
  and $7
  rrca
  rrca
  add a, c
  ld l, a
  ret

;; DE is src
;; HL is dest
blitChar:
  ld b, $10 ; loop counter
blitChar_nxtr:
  ld a, (de)
  ld (hl), a
  inc de
  inc h
  djnz blitChar_nxtr
  ret

;; Inputs: B contains line, C contains col, DE contains ptr to tile data
blitTile:
  call coordToScrAddr
  push hl
  inc b
  call coordToScrAddr
  push hl
  ld b, $2    ; set counter
blitTile_row:
  pop hl
blitTile_col:
  push bc     ; save counter
  push hl
  call blitChar
  pop hl
  inc hl
  push hl
  call blitChar
  pop hl
  pop bc      ; restore counter
  djnz blitTile_row
  ret

drawWalls:
  ld b, $0
  ld c, $0
  call coordToScrAddr
  ld b, 10
drawWalls_topRow:
  ld de, wall
  push bc
  push hl
  call blitChar
  pop hl
  pop bc
  inc hl
  djnz drawWalls_topRow
  ret


;; Define sprites
wall:
  defb $FF, $FF, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $FF, $FF
  defb $FF, $FF, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $FF, $FF
  defb $FF, $FF, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $FF, $FF
  defb $FF, $FF, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $FF, $FF
